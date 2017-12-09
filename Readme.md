# Excel formula transpiler

### [>> open transpiler <<](https://md5crypt.github.io/eft/)

A little tool I glued together after getting frustrated with excel. Allows to write a formulas with if-elseif-else blocks and operators that for some reason where not included in excel's grammar (like `&&` or `||`) and then transpile them to a standard excel formula. As a bonus the tool translates function names to the target language and allows setting decimal point and list separator characters.

Oh, and the editor uses the awesome ACE editor with a custom syntax highlighter to make life easier.

## If-blocks
* `if` *expression* `then` *expression*
* `if` *expression* `then` *expression* `else` *expression*
* `if` *expression* `then` *expression* `elseif` *expression* `then` *[...]*

If-blocks can be enclosed in braces as any other expressions

## Constants
* normal numbers: `1234.12`
* scientific numbers: `12e12`
* hexadecimal numbers: `0x1234`
* binary numbers: `0b10101`
* strings: `"yo!"` (supported escape sequences `\\`, `\"`, `\n`, `\r`, `\t`, `xhh` and `\uhhhh`)
* boolean values: `true` and `false`

Decimal point has to be a dot, but output decimal point can be set to any character

## Cell addresses
* normal: `c1`, `c$1`, `$c$1`
* range: `c1:c2`
* external: `[foo]bar!c4`

## Functions
* English names `trim(c1)`
* Chosen language names `usuń.zbędne.odstępy(c1)`

Arguments have to be separated with a comma, but the output list separator can be set to any character. English names get translated when necessary.

## Added or changed operators
* logical or: `||`
* logical and: `&&`
* equal: `==`
* not equal: `!=`
* shift left: `<<`
* shift right: `>>`
* modulo: `%`
* negation: `!`

Bitwise or, and, and xor when not added as the standard symbols where already taken. Use excel functions.

## Standard excel operators
* standard arithmetic: `+`, `-`, `/`, `*`
* exponential: `^`
* string concatenation: `&`
* standard inequalities: `<`, `<=`, `>=`, `>`
* unary minus: `-`
