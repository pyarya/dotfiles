# Working with numbers in bash
Bash interprets everything by default as a string, however it can also work with
numbers, just be careful with your conditional operators

## Storing numbers
`declare` and `local` both can make integer variables with the `-i` flag

```bash
declare -i a=2

f () { local -i a=3 ;}
```

Variables can be manipulated in double parenthesis, very similar to c/python.
Use `$(())` to return the value instead. Edges and centers seem whitespace
insensitive. No need to `$` in front of variables inside `(())`

Work as expected: `+ - * %`
Exponent: `**`
Floored division: `/`

```bash
declare -i a=2 b=3  # Multiple on the same line are fine

(( a++ ))    # a == 3
(( a+=b ))   # a == 6
(( a = 2 ))  # a == 2
((a=4+b))    # a == 7
(( a = 4 + b )) # Spacing is optional, same as above

declare -i c=$((a**b + 4))  # c == 7**3 + 4 == 347
```

## Using numbers
Conditionals are different for numbers in bash. Mapping c to bash:

```
 C  | Bash
----|-----
 == | -eq
 != | -ne
 >  | -gt
 <  | -lt
 >= | -ge
 <= | -le
```

```bash
declare -i a=3 b=2

if [[ $((a**b)) -ge 1000 ]]; then
  echo "Exponentiation with ${a}^${b} is pretty big"
elif [[ $a -lt $b ]]; then
  echo "$a is smaller than $b"
else
  echo "$a isn't smaller than $b"
fi

echo "You rolled a: $(( RANDOM % 6 + 1 )) on a 6 sided dice"
```

## Floats
Bash has no support for floats, don't even try. If you need floats, use awk,
which has full support. To still sort of use rational numbers in bash, store a
numerator and denominator, then pass both to awk when you need the float

```bash
declare -i num_1=4 denom_1=9
declare -i num_2=2 denom_2=9

(( num_1 += num_2 ))

awk -v n1=$num_1 -v d1=$denom_1 -v n2=$num_2 -v d2=$denom_2 \
  'BEGIN { printf "%.2f\n", n1/d1 + n2/d2 }'
```

Bash has floored division `/` and remainders `%`, though the awk approach is
easier. Note awk's syntax is identical to c, so it uses `^` for exponentiation
and the standard `==`, `<=`... for comparison
