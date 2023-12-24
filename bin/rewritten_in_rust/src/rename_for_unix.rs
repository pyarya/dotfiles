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

    for original_relative_name in to_rename {
        let original_name = fs::canonicalize(original_relative_name)?;
        let res_rename = fix_name(&original_name, !args.is_no_caps);

        let og_base_name = original_name.file_name()
            .unwrap()
            .to_str()
            .unwrap_or("<original-base-name>");

        if let Ok(new_name) = res_rename {
            let new_base_name = new_name.file_name().unwrap();

            if new_name == original_name {
                continue;
            } else if new_name.exists() {
                eprintln!("New file name {:?} already exists.", new_name);
                eprintln!("{:?}", original_name);
                eprintln!("{:?}", new_name);
                std::process::exit(1);
            }

            if args.is_dry_run {
                println!("{}\"{}\"{} -> {}{:?}{}",
                    tc::Fg(tc::Red), og_base_name, tc::Fg(tc::Reset),
                    tc::Fg(tc::Green), new_base_name, tc::Fg(tc::Reset));
            } else if !args.is_silent {
                println!("{}", new_name.to_str().unwrap());
            }

            if !args.is_dry_run {
                fs::rename(original_name, new_name)?;
            }
        } else {
            eprintln!("Error while moving \"{}\": {:?}", og_base_name, res_rename);
        }
    }

    Ok(())
}

fn fix_name(original_name: &Path, is_caps: bool) -> Try<PathBuf> {
    let base_name = original_name.file_name().unwrap();

    let mut new_base_name = String::new();
    let s = &mut new_base_name;  // Just an alias

    for c in base_name.to_str().expect("Valid unicode").chars() {
        match c {
            '-' if s.is_empty() => continue,
            ':' if s.is_empty() => s.push('_'),
            ';' if s.is_empty() => s.push('_'),
            '-' => s.push(c),
            '_' => s.push(c),
            '.' => s.push(c),
            ' ' => s.push('_'),
            ']' => s.push('_'),
            ':' => s.push('-'),
            ';' => s.push('-'),
            '&' => s.push_str("_and_"),
            _ if c.is_digit(10) => s.push(c),
            _ if c.is_lowercase() => s.push(c),
            _ if c.is_uppercase() && is_caps => s.push(c),
            _ if c.is_uppercase() => s.push(c.to_ascii_lowercase()),
            _ => continue,
        }

        // Combine consecutive underscores
        let c1 = s.chars().rev().nth(0).unwrap_or('a');
        let c2 = s.chars().rev().nth(1).unwrap_or('a');

        if c1 == '_' && c2 == '_' {
            s.pop();
        }
    }

    // Don't make dot file if it wasn't one initially
    let og_first_char = original_name.to_str().unwrap().chars().next().unwrap_or('_');
    let new_first_char = new_base_name.chars().next().unwrap_or('_');

    if og_first_char != '.' && new_first_char == '.' {
        new_base_name.insert(0, '_');
    }

    Ok(original_name.with_file_name(&new_base_name))
}
