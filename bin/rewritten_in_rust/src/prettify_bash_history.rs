use chrono::{NaiveDateTime, offset::{Local, TimeZone}};
use clap::{Parser, ValueEnum};
use regex::Regex;
use std::fs::File;
use std::io::{self, BufRead, Write};
use std::path::PathBuf;

#[derive(Parser)]
#[command(name = "prettify_bash_history", author, version = "0.1.0", long_about = None)]
/// Prints a prettier version of the bash-history with unix timestamps
///
/// Converts the unix-timestamped lines to human-readable dates and indents everything else
struct Args {
    /// Path to bash history file
    #[arg(value_name = "FILE")]
    history_file: PathBuf,
    /// Type of formatting for the output
    #[arg(value_enum)]
    style: Style,
}

#[derive(Debug, Copy, Clone, ValueEnum)]
enum Style {
    /// Plain text. Readable in vim
    Plain,
    /// With markdown code blocks
    Markdown,
    /// With pretty html code blocks
    Html,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = Args::parse();
    let timestamp = Regex::new(r"^#[0-9]{8,}$")?;

    let mut wb = io::BufWriter::new(io::stdout());

    let mut is_first = true;

    let history = File::open(args.history_file)?;
    let lines = io::BufReader::new(history).lines().map(|l| l.expect("File is readable"));

    for line in lines {
        if timestamp.is_match(&line) {
            let unix_utc: i64 = line[1..].parse()?;
            let time = NaiveDateTime::from_timestamp_opt(millis, 0).unwrap();
            let local_time = Local.from_utc_datetime(&time);

            let fmttime = local_time.format("%a %b %e %T %Y").to_string();

            let start_line = starting_for_command_line(args.style);
            let time_line = format_time_line(&fmttime, args.style);
            let end_line = ending_for_command_line(args.style);

            if is_first {
                writeln!(&mut wb, "{}{}", time_line, start_line)?;
            } else {
                writeln!(&mut wb, "{}{}{}", end_line, time_line, start_line)?;
            }

            is_first = false;
        } else if is_first {
            panic!("Improper file format. Must start with unix timestamp comment line");
        } else {
            writeln!(&mut wb, "{}", format_command_line(&line, args.style))?;
        }
    }

    writeln!(&mut wb, "{}", ending_for_command_line(args.style))?;
    wb.flush()?;
    Ok(())
}

fn format_time_line(time: &str, style: Style) -> String {
    match style {
        Style::Plain => format!("{}", time),
        Style::Markdown => format!("## {}\n", time),
        Style::Html => format!("<h2>{}</h2>\n", time),
    }
}

fn starting_for_command_line(style: Style) -> &'static str {
    match style {
        Style::Plain => "",
        Style::Markdown => "```bash",
        Style::Html => "<code>",
    }
}

fn ending_for_command_line(style: Style) -> &'static str {
    match style {
        Style::Plain => "",
        Style::Markdown => "```\n\n",
        Style::Html => "</code>\n\n",
    }
}

fn format_command_line(line: &str, style: Style) -> String {
    match style {
        Style::Plain => format!("    {}", line),
        Style::Markdown => format!("{}", line),
        Style::Html => {
            format!("{}", line
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&apos;")
            )
        },
    }
}
