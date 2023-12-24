use clap::Parser;
use rand::{RngCore, rngs::OsRng};
use std::fs::{File, OpenOptions};
use std::process::{Command, Stdio};
use std::path::PathBuf;
use std::io::{self, BufReader, BufRead, Write};

#[derive(Parser, Debug)]
#[command(name = "random_password", author, version = "0.1.0")]
/// Generates a random password, that's likely to work for most signups
struct Args {
    /// Copy to clipboard instead of printing to stdout
    #[arg(short = 'c', long = "clipboard")]
    is_clipboard: bool,
    /// Use a diceware-style passsword, made of words, instead
    #[arg(short = 'd', long = "dice")]
    diceware: Option<PathBuf>,
    /// Length of the generated password. In words with diceware
    #[arg(value_name = "LENGTH")]
    pass_length: u8,
}

#[derive(Default)]
struct CharDistro {
    uppercase: usize,
    lowercase: usize,
    numerical: usize,
    special: usize,
}

impl CharDistro {
    pub fn from(s: &str) -> Self {
        let mut d = Self::default();

        for c in s.chars() {
            if c.is_uppercase() {
                d.uppercase += 1;
            } else if c.is_lowercase() {
                d.lowercase += 1;
            } else if c.is_digit(10) {
                d.numerical += 1;
            } else {
                d.special += 1;
            }
        }

        d
    }

    pub fn all_nonzero(&self) -> bool {
        self.uppercase > 0 && self.lowercase > 0 && self.numerical > 0 && self.special > 0
    }
}

fn main() {
    let args = Args::parse();
    let mut pass;
    let mut trimmed;

    let mut key = [0_u8; 256];

    if args.diceware.is_none() {
        loop {
            OsRng.fill_bytes(&mut key);
            pass = encode_to_password(&key);
            trimmed = &pass[..args.pass_length as usize];

            let distro = CharDistro::from(trimmed);
            let is_enough_special = distro.special >= (args.pass_length / 10 + 1) as usize;

            if distro.all_nonzero() && is_enough_special && has_two_special(trimmed) {
                break;
            }
        }
    } else if args.diceware.as_ref().unwrap().exists() {
        let nb_lines = BufReader::new(File::open(args.diceware.as_ref().unwrap())
            .expect("Unable to open word-list file"))
            .lines()
            .count();

        let indices: Vec<u64> = (0..args.pass_length)
            .map(|_| OsRng.next_u64() % nb_lines as u64)
            .collect();

        pass = index_lines(args.diceware.as_ref().unwrap(), &indices)
            .unwrap()
            .join("8");

        trimmed = &pass;
    } else {
        eprintln!("Error: No such file `{:?}`", args.diceware.unwrap());
        std::process::exit(1);
    }

    if args.is_clipboard {
        let pbcopy = Command::new("wl-copy")
            .stdin(Stdio::piped())
            .spawn()
            .expect("Failed to start wl-copy");

        pbcopy.stdin.unwrap().write(trimmed.as_bytes()).unwrap();
    } else {
        println!("{}", trimmed);
    }
}

fn encode_to_password(key: &[u8; 256]) -> String {
    let mut pass = String::new();

    for bits in key {
        let c = bits & 0o77;

        if c <= 25 {
            pass.push((c + 65) as char);
        } else if c <= 51 {
            pass.push((c + 97 - 26) as char);
        } else if c <= 61 {
            pass.push((c + 48 - 52) as char);
        } else if c == 62 {
            pass.push('-');
        } else {
            pass.push(';');
        }
    }

    pass
}

fn index_lines(p: &PathBuf, indices: &[u64]) -> io::Result<Vec<String>> {
    let f = OpenOptions::new()
        .write(false)
        .read(true)
        .create(false)
        .open(p)?;

    let word_list: Vec<String> = BufReader::new(f).lines()
        .map(|l| l.expect("Failed to read line in provided words list"))
        .collect();

    Ok(indices.iter()
        .map(|i| word_list[*i as usize].clone())
        .collect())

    //Ok(lines)
}

fn has_two_special(s: &str) -> bool {
    let mut special_1 = 'a';

    for c in s.chars() {
        if !c.is_ascii_alphanumeric() && special_1 == 'a'{
            special_1 = c;
        } else if !c.is_ascii_alphanumeric() {
            return true;
        }
    }

    false
}
