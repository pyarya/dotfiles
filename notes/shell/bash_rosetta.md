# Using shell in other languages
Bash is incredibly concise at allowing programs to interact on a basic level,
however it severely lacks control flow and sensible data structures, which make
it a bad choice for logic-heavy scripting

In these cases we can attempt to recreate the high-level control bash has over
programs in other languages. All languages are able to call programs exactly
like bash, though almost all of them are much more verbose

The examples below use translate line of bash

```bash
swaymsg -t get_tree | jq '.nodes[1].nodes[].representation' | tr -d '\"'
```

## Python
A great and portable choice for easy scripting

```python
from subprocess import Popen, PIPE

p1 = Popen(["swaymsg", "-t", "get_tree"], stdout=PIPE);
p2 = Popen(["jq", ".nodes[1].nodes[].representation"],
        stdin=PIPE,
        stdout=PIPE);
p3 = Popen(["tr", "-d", '"'), stdin=PIPE, stdout=PIPE)

p1_stdout, _ = p1.communicate(timeout=1)
p2_stdout, _ = p2.communicate(p1_stdout, timeout=1)
p3_stdout, _ = p3.communicate(p2_stdout, timeout=1)
print(str(p3_stdout))
```

Shell-like strings can easily be split into the args lists required by Popen

```python
from shlex import split as shsplit
# ...
p3 = Popen(shsplit("tr -d '\"'"), stdin=PIPE, stdout=PIPE)
# ...
```

Do not use pipes even in the shsplit strings. Pipes must be manually managed,
unless the `shell=True` parameter is passed to Popen. However, that essentially
completely gives up control over the subprocess, so it's highly not recommend

## Rust
Rust is very fast, though not very portable. Portable binaries can be made by
compiling with a musl libc target. That way everything will be statically linked
into the binary, which typically makes it work across all Linux systems

```bash
cargo build --release --target=x86_64-unknown-linux-musl
```

Rust is extremely verbose, though allows for very fine error handling. The below
uses unwrap mostly

```rust
use std::io::{self, BufRead, BufReader};
use std::process::{Command, Stdio, ChildStdout};

fn get_tree() -> io::Result<ChildStdout> {
    let swaymsg = Command::new("swaymsg")
        .arg("-t")
        .arg("get_tree")
        .stdout(Stdio::piped())
        .spawn()?;

    let jq = Command::new("jq")
        .arg(".nodes[1].nodes[].representation")
        .stdin(swaymsg.stdout.unwrap())
        .stdout(Stdio::piped())
        .spawn()
        .expect("`jq` binary is not available");

    let tr = Command::new("tr")
        .arg("-d")
        .arg("\"")
        .stdin(jq.stdout.unwrap())
        .stdout(Stdio::piped())
        .spawn()?;

    Ok(tr.stdout.unwrap())
}
```
