// Quick and dirty tree representation of sway's tree string
//
// Input looks something like:
//   H[T[H[S[Alacritty baobab] T[ArchWiki]]] T[chromium-browser Alacritty]]
//
// This can be found, in the case of one workspace, at
//   swaymsg -t get_tree | jq '.nodes[1].nodes[0].representation'
//
// Which can then be piped to this script
//   swaymsg -t get_tree | jq '.nodes[1].nodes[0].representation' | sway_tree 2>/dev/null
//
// For the example string above, the output will be
// └─┬(Horizontal)
//   ├─┬(Tabbed)
//   | └─┬(Horizontal)
//   |   ├─┬(Stacked)
//   |   | ├───> [Alacritty]
//   |   | └───> [Baobab]
//   |   └─┬(Tabbed)
//   |     └───> [ArchWiki]
//   └─┬(Tabbed)
//     ├───> [Chromium-browser]
//     └───> [Alacritty]

use std::io::{self, BufRead};

fn main() {
    let stdin = io::stdin();
    let sway_representation = stdin.lock().lines().next()
        .expect("Could not read from stdin")
        .expect("Stdio error");

    println!("{}", ParserTree::from(&sway_representation).format());
}


#[derive(Debug)]
pub enum State {
    ReadingTitle(String),
    ExitContainer,
    EnterContainer,
}

#[derive(Debug)]
pub enum Layout {
    Horizontal,
    Vertical,
    Tabbed,
    Stacked,
}

#[derive(Debug)]
pub enum ParserTree {
    Container(Layout, Vec<ParserTree>),
    Leaf(String),
    Empty,
}

impl ParserTree {
    pub fn new() -> Self {
        ParserTree::Empty
    }

    pub fn from(str_rep: &str) -> Self {
        parse_sway_tree(str_rep)
    }

    pub fn new_leaf(title: String) -> Self {
        ParserTree::Leaf(title)
    }

    pub fn container(layout: Layout, nodes: Vec<Self>) -> Self {
        Self::Container(layout, nodes)
    }

    // Formats a tree view of parsed tree
    pub fn format(self) -> String {
        self.format_recursive(vec![false], true)
    }

    fn format_recursive(self, mut is_branched: Vec<bool>, is_last: bool) -> String {
        let indent_size = 2;

        let mut indent = (0..((is_branched.len() - 1) * indent_size)).map(|i| {
            if i % indent_size == 0 && is_branched[i / indent_size + 1] {
                '|'
            } else {
                ' '
            }
        }).collect::<String>();

        indent += match is_last {
            true  => "└─",
            false => "├─",
        };

        return match self {
            Self::Container(layout, children) => {
                indent.push(if children.is_empty() { '─' } else { '┬' });

                let mut container = indent;

                match layout {
                    Layout::Horizontal => container.push_str("(Horizontal)\n"),
                    Layout::Vertical   => container.push_str("(Vertical)\n"),
                    Layout::Tabbed     => container.push_str("(Tabbed)\n"),
                    Layout::Stacked    => container.push_str("(Stacked)\n"),
                }

                let last_i = children.len() - 1;
                is_branched.push(!is_last);

                for (i, child) in children.into_iter().enumerate() {
                    container += &child.format_recursive(is_branched.clone(), i == last_i);
                }

                container
            }
            Self::Leaf(title) => {
                let mut cs = title.chars();

                let title_cased = match cs.next() {
                    None => String::from("Untitled"),
                    Some(f) => f.to_uppercase().collect::<String>() + cs.as_str(),
                };

                format!("{}> {}\n", indent, title_cased)
            }
            Self::Empty => format!("{} - <>\n", indent),
        }
    }
}


fn parse_sway_tree(rep: &str) -> ParserTree {
    let mut state = State::EnterContainer;

    let characters: Vec<char> = rep.chars().collect();

    let mut container_stack: Vec<(Layout, Vec<ParserTree>)> = Vec::new();

    let mut c: char;
    let mut i = 0;

    loop {
        c = characters[i];

        match state {
            State::ReadingTitle(ref mut title) => {
                if c == ']' {
                    let leaf = ParserTree::new_leaf(title.clone());

                    let mut container = container_stack.pop().unwrap();
                    container.1.push(leaf);

                    let child = ParserTree::container(container.0, container.1);

                    if !container_stack.is_empty() {
                        let parent = container_stack.last_mut().unwrap();
                        parent.1.push(child);
                    } else {
                        return child
                    }

                    eprintln!("PushLeaf:    {:?}", &container_stack);

                    state = State::ExitContainer;
                } else if c == ' ' {
                    let leaf = ParserTree::new_leaf(title.clone());

                    let container = container_stack.last_mut().unwrap();
                    container.1.push(leaf);

                    eprintln!("PushLeaf:    {:?}", &container_stack);

                    state = State::EnterContainer;
                } else {
                    title.push(c);
                }
                i += 1;
            }
            State::EnterContainer => {
                let c1 = *characters.get(i + 1).unwrap_or(&'\0');

                if (c == 'H' || c == 'V' || c == 'T' || c == 'S') && c1 == '[' {
                    container_stack.push(init_container(c));
                    eprintln!("AppendChild: {:?}", &container_stack);

                    i += 2;
                } else {
                    state = State::ReadingTitle("".to_string());
                }
            }
            State::ExitContainer => {
                if c == ']' {
                    eprintln!("AppendParent:{:?}", &container_stack);
                    let container = container_stack.pop().unwrap();
                    let child = ParserTree::container(container.0, container.1);

                    if container_stack.len() == 0 {
                        return child
                    } else {
                        let parent = container_stack.last_mut().unwrap();
                        parent.1.push(child);
                    }

                    i += 1;
                } else {
                    eprintln!("NextChild:   {:?}", &container_stack);
                    state = State::EnterContainer;
                    i += 1;
                }
            }
        }
    }
}


// Creates new parts for a container
fn init_container(layout_char: char) -> (Layout, Vec<ParserTree>) {
    match layout_char {
        'H' => (Layout::Horizontal, vec![]),
        'V' => (Layout::Vertical, vec![]),
        'T' => (Layout::Tabbed, vec![]),
        'S' => (Layout::Stacked, vec![]),
        _ => unreachable!(),
    }
}
