
## Syntax

The syntax of the Neko language was designed to both be easy to parse and easy to generate. It is not specifically designed to be written by a programmer, but rather to be generated from a higher level language. For example, one could easily write a PHP-to-Neko, or a Java-to-Neko converter, that would generate the equivalent Neko code.

In particular, there are not multiple levels of expression, as in C. Every statement is also an expression, thus enabling some constructs that are not possible in other languages (for example : `return if(x) { ... } else { ... }`). This makes the generation of Neko from functional languages easier.

The syntax is parsed using a left-to-right LL(1) parser. This means that after reading a token, we have enough information to know which expression it will produce. This allows for a very lightweight parser which is easy to improve without creating ambiguities. Here's an Abstract Syntax Tree description of the language syntax, with the additional constraint that a program must be terminated by an EOF :

```
program :=
	| expr program
	| SEMICOLON program
	| _

ident :=
	| [a-zA-Z_@] [a-zA-Z0-9_@]*

binop :=
	| [!=*/<>&|^%+:-]+

value :=
	| [0-9]+
	| 0x[0-9A-Fa-f]+
	| [0-9]+ DOT [0-9]*
	| DOT [0-9]+
	| DOUBLEQUOTE characters DOUBLEQUOTE
	| DOLLAR ident
	| true
	| false
	| null
	| this
	| ident

expr :=
	| value
	| { program }
	| { ident1 => expr1 , ident2 => expr2 ... }
	| expr DOT ident
	| expr ( parameters )
	| expr [ expr ]
	| expr binop expr
	| ( expr )
	| var variables
	| while expr expr
	| do expr while expr
	| if expr expr [else expr]
	| try expr catch ident expr
	| function ( parameters-names ) expr
	| return [expr | SEMICOLON]
	| break [expr | SEMICOLON]
	| continue
	| ident :
	| switch expr { switch-case* }
	| MINUS expr

variables :=
	| ident [= expr] variables
	| COMMA variables
	| _

parameters :=
	| expr parameters
	| COMMA parameters
	| _

parameters-names :=
	| ident parameters-names
	| COMMA parameters-names
	| _

switch-case :=
	| default => expr
	| expr => expr
```

*Random notes:*

- `_` signifies an empty expression

- `continue` and `break` are not allowed outside of a `while` loop.

- There are a few ambiguous cases when two expressions follow each other (as in `while` and `if`). If the second expression is inside parenthesis, it will be parsed as a call of the first expression, while
such a representation e1 (e2) exists in the AST (the semicolons are optional).

- Arithmetic operations have the following precedences (from least to greatest):

	- assignments
	- `++=` and `%%--=%%`
	- `&&` and `||`
	- comparisons
	- `+` and `-`
	- `*` and `/`
	- `|`, `&` and `^`
	- `<<`, `>>`, `>>>` and `%`

