# Execution Flow

Here's some explanation on how each expression is evaluated:

## Values :

- `[0-9]+` | `0x[0-9A-Fa-f]+` : evaluates to the corresponding integer value.
- `[0-9]+` **`DOT`** `[0-9]*` | **`DOT`** `[0-9]+` : evaluates to the corresponding floating-point number.
- **`DOUBLEQUOTE`** *`characters`* **`DOUBLEQUOTE`** : evaluates to the corresponding string. Escaped characters are similar to the C programming language.
- **`DOLLAR`** *`ident`* : identifiers prefixed with a dollar sign are builtins. They enable you to call some compiler constructors or do optimized function calls.
- **`true`** | **`false`** : evaluate to the corresponding boolean.
- **`null`** : evaluates to the null value.
- **`this`** : evaluates to the local object value (See below for more details on objects).
- *`ident`* : evaluates to the value currently bound to this variable name.

## Expressions

Before evaluating any expression, all sub-expressions are evaluated in an unspecified order. "v"s represent the values obtained from the evaluation of sub-expressions.

- `{ v1; v2; .... vk }` : The evaluation order follows the order of the expressions declarations. The last value `vk` is returned as the result unless `program` does not contain any expressions, in which case `null` is returned.
- `{ i1 => v1, i2 => v2 ... }` : This will create an object with fields _i1...ik_ set to values _v1...vk_. It might be more optimal than setting the fields one-by-one on an empty object.
- `v DOT ident` : `v` is accessed as an object using `ident` as a key (see Objects).
- `v ( v1, v2, ... vk )` : The function `v` is called with the parameters `v1, v2... vk` (see Function Calls).
- `v [ v1 ]` : `v` is accessed as an array using `v1` as the index (see Arrays).
- `v1 binop v2` : Calculates v1 op v2 (see Operations).
- `expr = v` : This is a special case when the operation is an assignment (see Operations).
- `( v )` : Evaluates to `v`.
- `var i1 = v1, i2 = v2, .... ik = vk` : Each variable `i` is set to the corresponding value `v`, or to `null` if no initialization expression is provided.
- `while ....`  | `do ... while ...` : Implements the classic while-loop. Its value is that returned by a `break` inside the while, or unspecified if the loop ends without using `break`.
- `if v1 e1` : If v1 is the boolean `true`, then `e1` is evaluated and its value is returned. Otherwise, its value is unspecified.
- `if v1 e1 else e2` : If v1 is the boolean `true`, then `e1` is evaluated and its value is returned. Otherwise, `e2` is evaluated and its value is returned.
- `try e1 catch i e2` : Evaluates `e1` and returns its value. If an exception is raised during the evaluation of `e1`, then `e2` is evaluated, with the local variable `i`  being set to the raised exception value (see Exceptions). The value of the `try...catch` will be `e2`.
- `function ( parameters-names ) expr` : Evaluates to the corresponding function.
- `return;` : Exits the current function with an unspecified return value.
- `return v` : Exits the current function and returns `v`.
- `break;` : Exits the current while loop with an unspecified return value.
- `break v` : Exits the current while-loop and returns value `v`.
- `continue` : Skips the rest of the loop body and jumps to the start of the loop, reevaluating the loop condition.
- `_ident_:` : A label (See the corresponding section).
- `switch e { _e1a_ => e1b e2a => _e2b_ .... default => edef }` : Evaluates `e` and tests it with each `eia` sequentially until it is found to be equal, then returns value of the corresponding expression `eib`. If no value is found to be equal to `e`, the value of the `edef` expression is returned. `null` is returned if `default` is not specified.

Please note that the conditions of `if` and `while` only consider the boolean `true` to be true. You might need to add a `$istrue` code before each expression in order to convert the expression result into a boolean.
