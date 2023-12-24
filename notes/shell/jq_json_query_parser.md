# JQ, stream json parser

`jq` is a minimal json parser that's pretty useful in shell scripts. It can
quickly filter json outputs for reading something. Most languages, for example
js, have much faster json-parsers built-in, so it's better to use those when
possible

Json output usually comes in one of two forms, either a single json object, or
an array of jsons. To extract jsons we can use

```bash
yabai -m query --windows --window | jq '.'  # Already a single json
yabai -m query --windows          | jq '.[]'  # Iterates through array
```

`jq` takes in a filter on the right side, after a pipe-like separator. The
output will just be the that value for single fields

```bash
yabai -m query --windows | jq '.[] | .id'  # Id of every window
yabai -m query --windows | jq '.[] | .id, .app' # ID and name
yabai -m query --windows | jq '.[] | .frame.x'  # x field in frame field
```

Your output can be either raw values, json objects, or arrays:

```bash
yabai -m query --windows | jq '.[] | .id'  # Raw id
yabai -m query --windows | jq '.[] | { id: .id }'  # Id objects
yabai -m query --windows | jq '.[] | [{ id: .id }]'  # Id objects in individual arrays
yabai -m query --windows | jq '[.[] | { id: .id }]'  # Id objects in one array
```
