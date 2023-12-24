#!/usr/bin/env python3
import sys, re, subprocess, itertools

SPECIAL_GROUP = r"(<[^>]+>)"


def print_help():
    print("""\
Pastes the clipboard by typing it out. Limited to 40 characters in length

Use vim-style characters for modifiers

Examples:
    <C-v>somemoretext<cr>""")
    return


class InvalidModifierError(Exception):
    def __init__(self, message="Invalid modifier special key"):
        super().__init__(message)


class NotASpecialCharacterError(Exception):
    def __init__(self, key):
        super().__init__(f"`{key}` is not a special character")


def special_convert(special: str) -> str:
    special = special.lower()

    if (m := re.fullmatch(r"<([scmad])-([a-z])+>", special)) is not None:
        try:
            c = convert_special_character(f"<{m.group(2)}>")
        except Exception:
            c = m.group(2)

        s = []

        if "s" in m.group(1):
            s += ["shift"]
        if "c" in m.group(1):
            s += ["ctrl"]
        if "m" in m.group(1) or "a" in m.group(1) or "d" in m.group(1):
            s += ["logo"]

        if len(s) == 0:
            raise InvalidModifierError()

        s_down = list(itertools.chain(*[["-M", x] for x in s]))
        s_up = list(itertools.chain(*[["-m", x] for x in s]))

        return s_down + [c] + s_up
    elif (m := re.fullmatch(r"<([a-z])+>", special)) is not None:
        return convert_special_character(m.group(0))
    else:
        raise NotASpecialCharacterError(special)


def convert_special_character(special: str):
    match special.lower():
        case "<space>":
            c = "space"
        case "<bs>":
            c = "backspace"
        case "<del>":
            c = "delete"
        case "<tab>":
            c = "tab"
        case "<cr>" | "<enter>" | "<return>":
            c = "return"
        case "<esc>":
            c = "escape"
        case "<home>":
            c = "home"
        case "<end>":
            c = "end"
        case "<pageup>":
            c = "prior"
        case "<pagedown>":
            c = "next"
        case "<bar>":
            c = "bar"
        case "<backslash>":
            c = "backslash"
        case "<up>":
            c = "up"
        case "<down>":
            c = "down"
        case "<left>":
            c = "left"
        case "<right>":
            c = "right"
        case "<f1>":
            c = "f1"
        case "<f2>":
            c = "f2"
        case "<f3>":
            c = "f3"
        case "<f4>":
            c = "f4"
        case "<f5>":
            c = "f5"
        case "<f6>":
            c = "f6"
        case "<f7>":
            c = "f7"
        case "<f8>":
            c = "f8"
        case "<f9>":
            c = "f9"
        case "<f10>":
            c = "f10"
        case "<f11>":
            c = "f11"
        case "<f12>":
            c = "f12"
        case _:
            raise NotASpecialCharacterError(special)

    return ["-k", c]


def type_text(text: str) -> list:
    wtype_str = []
    text = text.replace(" ", "<space>")

    for i, s in enumerate(re.split(SPECIAL_GROUP, text)):
        if re.fullmatch(SPECIAL_GROUP, s) is not None:
            try:
                wtype_str += special_convert(s)
            except InvalidModifierError:
                wtype_str += [s]
            except NotASpecialCharacterError:
                wtype_str += [s]
        elif s == "":
            pass
        elif s[0] == "-":
            wtype_str += ["-k", "hyphen", s[1:]]
        else:
            wtype_str += [s]

    print(f"Running: `{wtype_str}`", file=sys.stderr)
    return wtype_str


clip_cmd = subprocess.Popen(["wl-paste"], stdout=subprocess.PIPE)

try:
    clipboard = clip_cmd.communicate(timeout=1)[0].strip().decode('utf-8')
except subprocess.TimeoutExpired:
    print("wl-paste took too long")
    exit(1)
except UnicodeError:
    print("Clipboard does not currently store valid utf-8 unicode")
    exit(1)

if len(sys.argv) != 1:
    print_help()
    exit(2)
elif len(clipboard) > 400:
    print("Clipboard text is too long")
    exit(1)
else:
    wtype_list = ["wtype"] + type_text(clipboard)
    finished = subprocess.run(wtype_list)
    exit(finished.returncode)
