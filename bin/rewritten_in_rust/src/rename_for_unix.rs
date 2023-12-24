use clap::Parser;
use std::fs;
use std::path::{Path, PathBuf};
use termion::color as tc;

#[derive(Parser, Debug)]
#[command(name = "rename_for_unix", author, version = "0.1.2")]
/// Renames a file to a reasonable (no special characters) name
///
/// Removes leading hyphens. Final file name character set is in /[0-9A-z._-]/, unless the
/// --no-caps flag is used
struct Args {
    /// Do not move the file, just print the changes that will be made
    #[arg(long = "dry-run")]
    is_dry_run: bool,
    /// Do not print the new file's path to stdout after moving
    #[arg(long = "silent")]
    is_silent: bool,
    /// Convert all letters to lowercase
    #[arg(long = "no-caps")]
    is_no_caps: bool,
    /// Rename all files/directories in the specified directory, not including itself
    #[arg(long = "full-directory")]
    is_full_directory: bool,
    /// Path to file that'll be renamed
    #[arg(value_name = "PATH")]
    original_name: PathBuf,
}

type Try<T> = Result<T, Box<dyn std::error::Error>>;

fn main() -> Try<()> {
    let args = Args::parse();
    let mut to_rename: Vec<PathBuf>;

    // Validate args
    if args.is_full_directory && args.original_name.is_dir() {
        to_rename = args.original_name.read_dir()
            .expect("Unable to read directory")
            .map(|x| x.expect("IO error while reading directory").path())
            .collect();
    } else if args.is_full_directory {
        eprintln!("Provided path is not a directory. Incompatible option --full-directory");
        std::process::exit(1);
    } else {
        to_rename = vec![args.original_name];
    }

    // Sort by length then subsort alphabetically
    to_rename.sort_by(|a, b| {
        let sa = a.to_str().unwrap_or("");
        let sb = b.to_str().unwrap_or("");

        if sa.len() == sb.len() {
            sa.cmp(&sb)
        } else {
            sa.len().cmp(&sb.len())
        }
    });

    // Create a vector of valid rename mappings
    let rename_pairs = match get_renamed_pairs(&to_rename, !args.is_no_caps) {
        Ok(rp) => rp,
        Err(e) => {
            eprintln!("{}", e);
            std::process::exit(1);
        }
    };

    for (og_full_name, new_full_name) in rename_pairs {
        let og_base_name = og_full_name.file_name().unwrap().to_str().unwrap();
        let new_base_name = new_full_name.file_name().unwrap().to_str().unwrap();

        if args.is_dry_run && og_full_name != new_full_name {
            println!("{}\"{}\"{} -> {}{:?}{}",
                tc::Fg(tc::Red), og_base_name, tc::Fg(tc::Reset),
                tc::Fg(tc::Green), new_base_name, tc::Fg(tc::Reset));
        } else if !args.is_dry_run {
            if !args.is_silent {
                println!("{}", new_full_name.to_str().unwrap());
            }

            fs::rename(og_full_name, new_full_name)?;
        }
    }

    Ok(())
}

fn get_renamed_pairs(to_rename: &[PathBuf], is_caps: bool) -> Try<Vec<(PathBuf, PathBuf)>> {
    let mut rename_pairs: Vec<(PathBuf, PathBuf)> = Vec::new();

    for og_rel_name in to_rename {
        let og_full_name = fs::canonicalize(og_rel_name)?;
        let new_full_name = fix_name(&og_full_name, is_caps)?;

        let conflict_index = rename_pairs.iter().position(|r| r.1 == new_full_name);

        // Check for naming conflict
        if new_full_name == og_full_name {
            // pass
        } else if new_full_name.exists() {
            return Err(format!("New file name {:?} already exists.", new_full_name).into());
        } else if conflict_index.is_some() {
            let index = conflict_index.unwrap();

            return Err(ManyToOneErr {
                from_1: rename_pairs.swap_remove(index).0,
                from_2: og_full_name,
                to_name: new_full_name,
            }.into());
        }

        rename_pairs.push((og_full_name, new_full_name));
    }

    Ok(rename_pairs)
}

fn fix_name(og_full_name: &Path, is_caps: bool) -> Try<PathBuf> {
    let og_base_name = og_full_name.file_name().unwrap();

    let mut new_base_name = String::new();
    let s = &mut new_base_name;  // Just an alias

    for c in og_base_name.to_str().expect("Valid unicode").chars() {
        match c {
            '-' if s.is_empty() => continue,
            ':' if s.is_empty() => s.push('_'),
            ';' if s.is_empty() => s.push('_'),
            '-' => s.push(c),
            '_' => s.push(c),
            '.' => s.push(c),
            ' ' => s.push('_'),
            ']' => s.push('_'),
            ')' => s.push('_'),
            '}' => s.push('_'),
            ':' => s.push('-'),
            ';' => s.push('-'),
            '&' => s.push_str("_and_"),
            _ if c.is_digit(10) => s.push(c),
            _ if c.is_lowercase() => s.push(c),
            _ if c.is_uppercase() && is_caps => s.push(c),
            _ if c.is_uppercase() => s.push(c.to_ascii_lowercase()),
            _ => continue,
        }
    }

    // Combine consecutive underscores and odd-looking _.
    let mut new_base_name_vec: Vec<char> = new_base_name.chars().collect();
    let mut i = 1;

    while i < new_base_name_vec.len() {
        let c1 = new_base_name_vec[i-1];
        let c2 = new_base_name_vec[i];

        if c1 == '_' && c2 == '_' {
            new_base_name_vec.remove(i-1);
        } else if c1 == '_' && c2 == '.' {
            new_base_name_vec.remove(i-1);
        } else {
            i += 1;
        }
    }

    // Removes tailing underscores
    while let Some(c) = new_base_name_vec.last() {
        if *c != '_' {
            break;
        }
        new_base_name_vec.pop();
    }

    new_base_name = new_base_name_vec.into_iter().collect();

    // Don't make a dot file if the original wasn't one
    let og_first_char = og_base_name.to_str().unwrap().chars().next().unwrap_or('_');
    let new_first_char = new_base_name.chars().next().unwrap_or('_');

    if og_first_char != '.' && new_first_char == '.' {
        new_base_name.insert(0, '_');
    }

    if new_base_name.len() == 0 || new_base_name == "." || new_base_name == ".." {
        Err(format!("{:?} has no name when renamed", og_base_name).into())
    } else {
        Ok(og_full_name.with_file_name(&new_base_name))
    }
}

#[derive(Debug)]
struct ManyToOneErr {
    from_1: PathBuf,
    from_2: PathBuf,
    to_name: PathBuf,
}

impl std::fmt::Display for ManyToOneErr {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let red = tc::Fg(tc::Red);
        let green = tc::Fg(tc::Green);
        let reset = tc::Fg(tc::Reset);

        write!(f, "Error: many to one renaming!\n{}{:?}{} <- {}{:?}{}\n{}{:?}{} <- {}{:?}{}",
            green, self.to_name, reset, red, self.from_1, reset,
            green, self.to_name, reset, red, self.from_2, reset)
    }
}

impl std::error::Error for ManyToOneErr {}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn tailing_underscores() {
        let one_tail = PathBuf::from(r"/mydir/sometail)");
        let mul_tail = PathBuf::from(r"/mydir/some tail)]])))");
        let and_tail = PathBuf::from(r"/mydir/some tail)]])))&");

        let one_answer = PathBuf::from(r"/mydir/sometail");
        let mul_answer = PathBuf::from(r"/mydir/some_tail");
        let and_answer = PathBuf::from(r"/mydir/some_tail_and");

        let one_tail_fix = fix_name(&one_tail, true).unwrap();
        let mul_tail_fix = fix_name(&mul_tail, true).unwrap();
        let and_tail_fix = fix_name(&and_tail, true).unwrap();

        assert_eq!(one_tail_fix, one_answer);
        assert_eq!(mul_tail_fix, mul_answer);
        assert_eq!(and_tail_fix, and_answer);
    }

    #[test]
    fn blank_names() {
        let blank_1 = PathBuf::from(r"/mydir/deep/(((((");
        let blank_2 = PathBuf::from(r"/mydir/deep/((((()");
        let blank_3 = PathBuf::from(r"/mydir/deep/([[{()}]]]]]");
        let blank_4 = PathBuf::from(r"/mydir/deep/.([[{()}]]]]]");

        let fix_1 = fix_name(&blank_1, true);
        let fix_2 = fix_name(&blank_2, true);
        let fix_3 = fix_name(&blank_3, true);
        let fix_4 = fix_name(&blank_4, true);

        assert!(fix_1.is_err());
        assert!(fix_2.is_err());
        assert!(fix_3.is_err());
        assert!(fix_4.is_err());
    }

    #[test]
    fn no_create_dotfiles() {
        let dots_1 = PathBuf::from(r"/mydir/deep/_.name");
        let dots_2 = PathBuf::from(r"/mydir/deep/.some image.avif");
        let dots_3 = PathBuf::from(r"/mydir/deep/([[{(.]]]]]");

        let answer_1 = PathBuf::from(r"/mydir/deep/_.name");
        let answer_2 = PathBuf::from(r"/mydir/deep/.some_image.avif");
        let answer_3 = PathBuf::from(r"/mydir/deep/_.");

        let fix_1 = fix_name(&dots_1, true).unwrap();
        let fix_2 = fix_name(&dots_2, true).unwrap();
        let fix_3 = fix_name(&dots_3, true).unwrap();

        assert_eq!(fix_1, answer_1);
        assert_eq!(fix_2, answer_2);
        assert_eq!(fix_3, answer_3);
    }

    #[test]
    fn no_capitals() {
        let dots_1 = PathBuf::from(r"/mydir/deep/_.NAME");
        let dots_2 = PathBuf::from(r"/mydir/deep/.some Image.avif");
        let dots_3 = PathBuf::from(r"/mydir/deep/([[{(.]]]]]");

        let answer_1 = PathBuf::from(r"/mydir/deep/_.name");
        let answer_2 = PathBuf::from(r"/mydir/deep/.some_image.avif");
        let answer_3 = PathBuf::from(r"/mydir/deep/_.");

        let fix_1 = fix_name(&dots_1, false).unwrap();
        let fix_2 = fix_name(&dots_2, false).unwrap();
        let fix_3 = fix_name(&dots_3, false).unwrap();

        assert_eq!(fix_1, answer_1);
        assert_eq!(fix_2, answer_2);
        assert_eq!(fix_3, answer_3);
    }

    #[test]
    fn many_to_one_mapping() {
        fn touch(path: &Path) -> std::io::Result<()> {
            match fs::OpenOptions::new().create(true).write(true).open(path) {
                Ok(_) => Ok(()),
                Err(e) => Err(e),
            }
        }

        let paths = vec![
            PathBuf::from(r"/tmp/[somefile]&conflict.avif"),
            PathBuf::from(r"/tmp/somefile and    (conflict).avif))"),
        ];

        paths.iter().for_each(|p| touch(p).expect("Failed to create files for test"));

        let pairs_res = get_renamed_pairs(&paths, true);

        assert!(pairs_res.is_err());
        assert_eq!(&pairs_res.err().unwrap().to_string()[..28], "Error: many to one renaming!");
    }
}
