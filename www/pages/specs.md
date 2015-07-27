Neko Language Specification
=============================

## Syntax

The syntax of the Neko language was designed to be easy to parse and easy to generate. It is not specifically designed to be written by a programmer, but rather to be generated from a higher level language. For example, one could write easily a PHP-to-Neko or a Java-to-Neko converter that would generate equivalent code but with Neko syntax and semantics rather than those of PHP or Java.

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



- `_` signifies an empty expression

- `continue` and `break` are not allowed outside of a `while` loop.

- There are a few ambiguous cases when two expressions follow each other (as in `while` and `if`). If the second expression is inside parenthesis, it will be parsed as a call of first expression, while such a representation e1 (e2) exists in the AST (the semicolons are optional).

- Arithmetic operations have the following precedences (from least to greatest ):

	- assignments
	- `++=` and `%%--=%%`
	- `&&` and `||`
	- comparisons
	- `+` and `-`
	- `*` and `/`
	- `|`, `&` and `^`
	- `<<`, `>>`, `>>>` and `%`


## Values

A value in Neko can be one of the following :

- **Null :** the special value `null` is used for uninitialized variables as well as programmer/language specific coding techniques.
- **Integer :** integers can be represented in either decimal form (such as `12345` or `-12`), or hexadecimal (`0x1A2B3C4D`).
- **Floats :** floating-point numbers are represented using a period (such as `12.345` or `-0.123`)
- **Boolean :** the two booleans are represented by the following lowercase identifiers `true` and `false`.
- [Strings](specs#strings) : strings are surrounded by double quotes (for example: `"foo"`, or `"hello,\nworld !"`, or `"My name is \"Bond\\James Bond\"."`). Neko strings are mutable, which means that you can modify them.
- [Arrays](specs#arrays) : arrays are an integer-indexed table of values, with the index starting at 0. They provide fast random access to their elements.
- [Objects](specs#objects) : an object is a table, which associates an identifier or a string to a value. How objects are created and managed is explained later.
- [Functions](specs#function_function_calls) : a function is also a value in Neko, and thus can be stored in any variable.
- **Abstract :** an abstract value is some C data that cannot be accessed from a Neko program.

Some Notes :

- Integers have 31 bits for virtual-machine performance reasons. An API for full [32-bit integers](doc/view/int32) is available through a standard library.
- Floating-point numbers are 64-bit double-precision floating points values.
- Strings are sequences of 8-bit bytes. A string can contain \0 characters. The length of a string is determined by the number of bytes in it, and not by the number of characters before the first \0.

## Execution Flow

Here's some explanation on how each expression is evaluated :

### Values :

- `[0-9]+ | 0x[0-9A-Fa-f]+` : evaluates to the corresponding integer value
- `[0-9]+ **DOT** [0-9]* | **DOT** [0-9]+` : evaluates to the corresponding floating-point number.
- `**DOUBLEQUOTE**  **DOUBLEQUOTE**` : evaluates to the corresponding string. Escaped characters are similar to the C programming language.
- `**DOLLAR** ` : identifiers prefixed with a dollar sign are builtins. They enable you to call some compiler constructors or do optimized function calls.
- `**true** | **false**` : evaluate to the corresponding boolean.
- `**null**` : evaluates to the null value.
- `**this**` : evaluates to the local object value (See below for more details on objects).
- `` : evaluates to the value currently bound to this variable name.

### Expressions

Before evaluating any expression, all sub-expressions are evaluated in an unspecified order. "v"s here represent the values obtained from evaluation of sub-expressions.

- **{**  **}** : The evaluation order follows the order of the expressions declarations. The last value `vk` is returned as the result, unless `program` does not contain any expressions, in which case it returns `null`.
- **{**  **=>**  **,**  **=>**  **...** **}** : This will create an object with fields  set to values . It might be more optimized than setting the fields one-by-one on an empty object.
-  **DOT**  : `v` is accessed as an object using `ident` as a key (see Objects).
-  **(**  **)** : The function `v` is called with the parameters `v1, v2... vk` (see Function Calls)
-  **[**  **]** : `v` is accessed as an array using `v1` as the index (see Arrays).
-    : Calculates v1 op v2 (see Operations).
-  **=**  : This is a special case when the operation is an assignment (see Operations).
- **(**  **)** : Evaluates to `v`.
- **var**  : Each variable `i` is set to the corresponding value `v`, or to `null` if no initialization expression is provided.
- **while** ....  | **do** ... **while** ... : Implements the classic while-loop. Its value is that returned by a `break` inside the while, or unspecified if the loop ends without using `break`.
- **if**   : If v1 is the boolean `true`, then `e1` is evaluated and its value returned. Otherwise, its value is unspecified.
- **if**   **else**  : If v1 is the boolean `true`, then `e1` is evaluated and its value returned. Otherwise, `e2` is evaluated and its value returned.
- **try**  **catch**   : Evaluates `e1` and returns its value. If an exception is raised during the evaluation of `e1`, then `e2` is evaluated, with the local variable `i`  being set to the raised exception value (see Exceptions). The value of the `try...catch` will be `e2`.
- **function (**  **)**  : Evaluates to the corresponding function.
- **return**; : Exits the current function with an unspecified return value.
- **return** v : Exits the current function and returns `v`.
- **break**; : Exits the current while loop with an unspecified return value.
- **break** v : Exits the current while-loop and returns value `v`.
- **continue** : Skips the rest of the loop body and jumps to the start of the loop, reevaluating the loop condition.
- **ident** : A label (See the corresponding section).
- **switch e { e1a ⇒ e1b e2a ⇒ e2b .... default ⇒ edef }** : Evaluates `e` and tests it with each `ea` sequentially until it is found to be equal, then returns value of the corresponding expression `eb`. If no value is found to be equal to `e`, the value of the `edef` expression is returned. `null` is returned if `default` is not specified.

Please note that the conditions of `if` and `while` only consider the boolean `true` to be true. You might need to add a `$istrue` code before each expression in order to convert the expression result into a boolean.

## Variables

When an identifier is found, it must be resolved to a scope containing the variable's value. The search starts in the local scope.

### Local Scope

The local scope contains all variables defined with the "var" keyword in previous syntactical blocks. In the following sample, `x` resolves to the value 3 :

```neko
var x = 3;
$print(x);
```

A "var" declaration is local to the curly-braced block it has been declared in. For example :

```neko
var x = 3;
// x defined
if( ... ) {
	// x defined
	var y;
	// x and y defined;
}
// x defined
```

The same variable name can be reused in the same block or another block. It will shadow or erase previous value :

```neko
var x = 1;
$print(x); // print 1
var x = 3;
$print(x); // print 3
if( ... ) {
	var x = "neko";
	$print(x); // print "neko"
}
$print(x); // print 3
```

Function parameters are also local variables. They are defined within the whole function :

```neko
var x = 3;
f = function(x) {
	$print(x);
}
f("neko"); // print "neko"
```

Since scoping is resolved at a purely syntactic level, local variables do not depend the on current call-stack, and you cannot access variables defined outside the current local scope.

```neko
f = function() {
	$print(x);
}
...
var x = 3;
f(); // will print "null"
```

### Function Scope

Local variables can be used inside functions if they're accessible at the time the function is declared. In this case, the value of the variable is a copy of its value at the time the function was defined :

```neko
var x = 3;
f = function() {
	$print(x);
}
x = 4;
f(); // print 3
```

Such variables are called environment variables because they're no longer part of the local context but of the function "environment" context. A function can still modify an environment variable, but this will not modify the original variable reference :

```neko
var x = 3;
f = function() {
	$print(x);
	x = x + 1;
}
x = 50;
f(); // print 3
f(); // print 4
$print(x); // print 50
```

Please note also that each function instance has its own environment :

```neko
gen = function() {
	var i = 0;
	return function() { $print(i); i = i + 1; };
}
f1 = gen();
f2 = gen();
f1(); // print 0
f1(); // print 1
f2(); // print 0
f1(); // print 2
...
```

### Global Scope

When a variable is not found in the local scope or in the local function environment, it is a global variable. A global variable can be accessed throughout the whole file; it is shared among all code.

```neko
f = function() {
	$print(x);
	x = x + 1;
}
x = 0;
f(); // print 0
f(); // print 1
$print(x); // print 2
```

## Operations on Basic Types

Basic types are numbers (int and float), booleans (bool), the null value, strings, objects, arrays, and functions. There are several operations available to use with them (See the following tables). On the row is type of the first operand, and on the columns is that of the second operand. The result is either the type of the returned value, or "concat" if we use string concatenation (in that case, the two values are converted to strings and then concatened together). An "X" means that the operation is invalid and will raise an exception.

### Arithmetic operations

Operation add ( + ) :

^ `+` ^ null ^ int ^ float ^ string ^ bool ^ object ^ array ^ function ^
| **null** | X         | X   | X     | concat | X | %%__radd%% | X | X |
| **int**  | X         | int | float | concat | X | %%__radd%% | X | X |
| **float**    | X         | float | float | concat | X | %%__radd%% | X | X |
| **string**   | concat    | concat | concat  | concat | concat | %%__radd%% | concat | concat |
| **bool**     | X         | X | X | concat | X | %%__radd%% | X | X |
| **object**   | %%__add%% | %%__add%% | %%__add%% | %%__add%% | %%__add%% | %%__add%% | %%__add%% | %%__add%% |
| **array**    | X         | X | X | concat | X | %%__radd%% | X | X |
| **function** | X         | X | X | concat | X | %%__radd%% | X | X |


Addition can be overridden for objects : `a + b` will call `a.%%__add%%(b)` if `a` is an object, or `b.%%__radd%%(a)` if `b` is an object.

Operations substract ( - ) divide ( / ) multiply ( * ) and modulo ( % ) :

^ `-` `/` `*` `%`  ^ int ^ float ^
| int | int (float for /) | float |
| float | float | float |

Please note that unlike some languages, the divide operation between two integers return a float. You can use the `$idiv` builtin to perform integer division.


Dividing or taking the modulo of one integer by the integer or the float 0 is hardware-dependent, and usually returns the float `+infinity` for division, and NaN for modulo. You can test it using the builtin `$isinfinite`. There is also `$isnan` for testing for NaN :

```neko
$print($isinfinite(1/0)); // prints true
$print($isnan(0/0)); // prints true
```

These operations are can be overriden by objects. See the Objects section.

Please note also that overflow on integer operations does not convert them to floats, and does not throw an exception. If you want to control overflow, you can define your own functions for operations, use floats everywhere, or use an object with overridden operators.

### Bitwise operations

The following operations are available for integers only. Please remember that for performance reasons, Neko integers are signed and only have 31 bits, so the "unsigned" part is only 30 bits of :

- `%%<<%%` left bit shift
- `%%>>%%` right bit shift
- `%%>>>%%` right unsigned bit shift
- `|` or bits
- `&` and bits
- `^` xor bits

Using these operations with one or more non-integer operands will raise an exception.

### Boolean operations


To convert any value to a boolean, use the builtin `$istrue` :

- null : false
- int : false if 0, true otherwise
- float : true
- string : true
- bool : itself
- object : true
- array : true
- function : true

As you can see, only the values `null`, `false`, and `0` (integer) evaluate to false.

`$not` is the inverse of `$istrue`. It returns the opposite of the boolean that would be returned by `$istrue`.

Operations BooleanAnd ( && ) and BooleanOr ( || ) :

Boolean operations are short-circuited. That means that if the first operand of an `&&` is `false` or the first operand of an `||` is `true`, then the second operand is not evaluated, and the first value is returned. Otherwise, the second value is returned.

Please note that no automatic conversions to booleans are done. `a && b` is equivalent to `if( a == false ) b else a` and `a || b` is equivalent to `if( a == true ) a else b` with `a` being evaluated only once. You might prefer to call `$istrue` on each argument before performing the operation.


### Equality & Comparisons

Comparison occurs when the following operations are performed : equality `==`, inequality`!=`, greater than `>`, less than `<`, greater than or equal to `>=`, or less than or equal to `%%<=%%`.

Comparison method :

^  $compare  ^ null ^ int ^ float ^ string ^ bool ^ object ^ array ^ function ^
| null | 0 | - | - | - | - | - | - | - |
| int | - | icmp | fcmp | strcmp | - | - | - | - |
| float | - | fcmp | fcmp | strcmp | - | - | - | - |
| string | - | strcmp | strcmp | strcmp | strcmp | - | - | - |
| bool | - | - | - | strcmp | bcmp | - | - | - |
| object | - | - | - | - | - | ocmp | - | - |
| array | - | - | - | - | - | - | acmp | - |
| function | - | - | - | - | - | - | - | acmp |

Here are the details of each comparison function :

- icmp compares two integers a and b. It returns 0 if they're equal, -1 if b > a, and 1 if a > b.
- fcmp is the same as icmp, but compares floats instead of integers.
- strcmp compares strings. It can be seen as a icmp applied to every byte of the two strings.
- acmp compares the addresses of a and b. It returns 0 if they're the same, -1 if b>a, and 1 if a>b
- bcmp returns 0 if a and b are both true or both false, 1 if a is true and b and false, -1 if a is false and b is true.
- ocmp does "object comparison". If the two objects' addresses are same, then it returns 0. Otherwise, it calls the method `%%__compare%%` on the first object, with the second object as argument. If the returned value is an integer, the integer is returned by `$compare`, else null is returned.
- `-` means that the comparison is invalid, the returned value is null when using `$compare` and false when using an operator.

The following table show how each operation is performing depending on the result of `$compare` :

^  op  ^ null ^ -1 ^ 0 ^ 1 ^
|  ==  | false | false | true| false |
|  !=  | true | true | false | true |
|  %%<=%%  | false | true | true | false |
|  <  | false | true | false | false |
|  >=  | false | false | true | true |
|  >  | false | false | true | true |

Physical comparison :

The builtin `$pcompare` will compare two values physically. It will be the same result as `$compare` for integers, and other values will be compared using their memory address. You can use `$pcompare` instead of `$compare` if you want to optimize your integer comparisons.


### Assignments

The following operations are also available in order to modify the value of a variable, object field, array content...

The standard assignment operator is `=`. There are also the following augmented assignment operators which perform an operation at the same time. The return value is always the assigned value :

```neko
+= -= *= /= %= <<= >>= >>>= |= &= ^=
```

There are two additional operators `++=` and `--=` which do the same thing as `+=` and `-=`, except that the returned value is the value of the variable before it was modified :

```neko
a = 0;
$print(a ++= 1); // 0
$print(a ++= 1); // 1
$print(a); // 2
```

### Conversions

To convert any value to a Boolean, you can use the `$istrue` builtin, as specified in [Boolean operations](specs#boolean_operations).

```neko
$istrue(null); // false
$istrue(1); // true
```

To convert a string or a float to an integer, you can use the `$int` builtin :

```neko
$int(45.67); // 45
$int("67.87"); // 67
$int($array(4)); // null
```


To convert a string to a float you can use the `$float` builtin :

```neko
$float("1.345"); // 1.345
$float(12345); // 12345.0000
$float($array()); // null
```

Any value can be converted to a string using `$string`, this operation is used in particular in the `$print` builtin :

```neko
$string(null); // "null"
$string(123); // "123"
$string($array(1,2,3)); // "[1,2,3]"
```

On objects, `$string` calls the `%%__string%%` method on the object if it exists. If the returned value is a string, this string is returned, else the string `#object` is returned.

On functions, `#function:n` is returned where `n` is the number of arguments of the function (or -1 if multiple arguments).


### Optimized Operations

There are several optimized builtins for integers : `$iadd, $isub, $imult, $idiv`. They all skip some typechecks, so they're faster. Their results will always be a valid integer, but their value is unspecified when one ore more of the two values is not an integer. `$idiv` raises an exception when division by 0 is attempted :

```neko
$print( $iadd(1,3) ); // 4
$print( $idiv(5,2) ); // 2
$print( $idiv(1,0) ); // exception
```

## Runtime Type Information (RTTI)

No matter if your language is statically or dynamically typed, you can always access RTTI in Neko. RTTI is powerful because you can decide which behavior to adopt depending on some value at runtime. The most common application of this is to print some debugging information. Another one is introspection : the ability to look inside an object, read its fields, and call its methods.

The builtin `$typeof` returns an integer specifying the type of a value according to the following table :

^ Type ^ Constant ^ Value ^
| null | `$tnull` | 0 |
| int | `$tint` | 1 |
| float | `$tfloat` | 2 |
| bool | `$tbool` | 3 |
| string | `$tstring` | 4 |
| object | `$tobject` | 5 |
| array | `$tarray` | 6 |
| function | `$tfunction` | 7 |
| abstract | `$tabstract` | 8 |

Example :

```neko
$typeof(3); // 1
$typeof($array(1,2)); // 6
$typeof(null) == $tnull; // true
```

You can use the builtins for [Arrays](specs#objects|Objects]], [Strings](specs#strings), [Functions](specs#function_function_calls) and [Arrays](specs#arrays) to manipulate them at runtime.

## Function & Function Calls

Defining new functions is easy, since functions are values, you can simply assign them to a local or a global variable :

```neko
var foo = function() {
	return 0;
}
```

Functions are called by-value, that means that `foo(1)` calls the function which is the value of the variable foo. Calling a value that is not a function or that does not accept this number of arguments will raise an exception.

You can know the number of arguments needed by a function by using the builtin `$nargs`. A function that accepts a variable number of arguments returns -1 when used with `$nargs`. Please note also that builtins can be used as values :

```neko
$print($nargs(function(a,b) { return a + b; }); // prints 2
$print($nargs($print)); // prints -1
$print($nargs(0)); // exception
```

There is one other way of calling a function : builtin `$call` takes an array of arguments and a object context (see Objects section) as parameters. This builtin can be useful for introspection :

```neko
// call the foo function with null context
// and two parameters 3 and 4
$call(foo,null,$array(3,4));
```

Functional languages require partial application (aka currying) : the ability to creates closures by setting a fixed number of arguments of a function, leaving the rest for later call. The builtin `$closure` enable to create a closure :

```neko
var add = function(x,y) { return x + y };
var plus5 = $closure(add,null,5); // null context and 5 as first argument
$print( plus5(2) ); // 7
```

The builtin `$closure` can also be used to fix the `this` context of a function :

```neko
var f = function() { $print(this) };
f = $closure(f,55);
f(); // prints 55
```

Some languages might want more security about the types of the arguments that are passed to a function, or selecting at runtime different implementations of a function depending on the type of the arguments. There are many ways of doing that in Neko. For example, you might want to add arguments checks at the beginning of the function body using runtime types informations (RTTI) builtins.

Another useful builtin is `$apply` which is identical to a direct function call except that if the function require extra arguments then its call is delayed until further arguments are used :

```neko
var f = function(x,y) { return x + y };
f(1,2);
$apply(f,1)(2); // equivalent
$apply(f,1,2); // equivalent
```

## Objects

Objects are some kind of optimized hashtables. All fields names are hashed into an integer value that is used as the key into a lookup table. Insertion of a new field is `O(n)`, access to a field is `O(log n)`. If you're generating from a staticly typed programming language, you might prefer arrays for storing fields, since they provide `O(1)` access.

To create an object, you can use the builtin `$new`, that can either returns a copy of an object or a new object :

```neko
o = $new(null); // new empty object
o2 = $new(o); // makes a copy of o
o2 = $new(33); // if parameter is not an object, throw an exception
```

You can set fields of an object using dot access or using the builtin `$objset` :

```neko
o.field = value;
$objset(o,$hash("field"),value);
```

Accessing object fields for reading use either dot access or builtin `$objget` :

```neko
o.field; // returns "field" value of object o
$objget(o,$hash("field")); // returns "field" value of object o
```

Please note that `$objset` and `$objget` second parameter is hashed at runtime so it's a bit less efficient operation than dot access but enables introspection.

If a field is not defined when accessed for reading, the `null` value is returned. If a field does not exists when a field is accessed for writing, the field is added.

To check for a field existance, you can use the `$objfield` builtin that checks if an object o have a given field, even if that field is set to the `null` value :

```neko
$objfield(o,$hash("field")); // true if o have "field"
$objfield(null,33); // false
```

You can remove an object field with the `$objremove` builtin :

```neko
$objremove(o,$hash("field")); // remove "field" from o
```

One other way to declare objects is to use the following notation, which is more efficient when you want initialize several fields at the same time :

```neko
var o = {
	x => 0,
	y => -1,
	msg => "hello"
}
```


### Methods

When a function is called using the dot access or the builtin `$objcall`, the function can access a special variable named `this` which is the "object context" (the object with which the function was called) :

```neko
o = $new(null);
o.x = 1;
o.add = function(y) { return this.x + y; }
$print(o.add(2)); // prints 3
$print( $objcall(o,$hash("add"),$array(2)) ); // prints 3
```

The context is set when a object function is called and can be accessed from any sub function :

```neko
foo = function() {
	$print(this.x);
}
o = $new(null);
o.x = 3;
o.bar = function() { foo(); };
o.bar(); // prints 3
```

You can modify the value of `this` at runtime by simply assigning it to another value. It can be set to any value, not only objects. When returning from an object call, the context is restored, so any modifications are lost :

```neko
this = 1;
o.foo = function() {
	// here , we have this = o;
	this = 2; // modify
};
o.foo();
$print(this); // 1
```

### Fields lists

As explained before, fields names are first hashed into integer values for faster access. In order to avoid collisions in the hashing functions, they are then stored into a global table than will check that hash(x) = hash(y) implies that x = y. The other utility of this library is to be able to reverse the hashing function at runtime, that can be useful to print the field names of an object, for debugging purpose for example.

You can use the following builtins : `$hash` returns the integer hashing value of a string, or raise an exception in case of collision. `$field` transforms an integer into a previously hashed string or returns `null`.

The builtin `$objfields` returns an array containing all fields identifiers for the given object :

```neko
var a = $objfields(o);
var i = 0;
while( i < $asize(a) ) {
	var fname = $field(a[i]);
	var fval = $objget(o,a[i]);
	$print( fname + " = " + fval + "\n" );
	i = i + 1;
}
```


### Operators Overloading

Several operators can be overloaded so when they're applied to objects they are actually calling methods. Here's a list of operators overloadable and corresponding methods names :

- **string conversion** : call the `%%__string%%` method on the object with no arguments. A string should be returned.
- **object comparison** : for any comparison between two different objects, the `%%__compare%%` method is called on the first object with the second object as parameter.
- **addition** : in the case of `a + b`, if `a` is an object, `a.%%__add%%(b)` is called else if `b` is an object, `b.%%__radd%%(a)` is called.
- **subtraction** : same as addition but with `%%__sub%%` and `%%__rsub%%`.
- **multiplication** : same as addition but with `%%__mult%%` and `%%__rmult%%`.
- **division** : same a addition but with `%%__div%%` and `%%__rdiv%%`.
- **modulo** : same as addition but with `%%__mod%%` and `%%__rmod%%`.
- **array reading** : when an object is accessed as an array for reading, using `a[i]` actually calls `a.%%__get%%(i)`.
- **array writing** : when an object is accessed as an array for writing, using `a[i] = v` actually calls `a.%%__set%%(i,v)`.

If the overloaded field is not defined when an operation occured, an exception is raised.

### Prototypes

Each object can have a  which is also an object. When a field is accessed for reading and is not found in an object, it is searched in its prototype, and like this recursively.

Prototypes can be accessed using `$objgetproto` and `$objsetproto` :

```neko
var proto = $new(null);
proto.foo = function() { $print(this.msg) }

var o = $new(null);
o.msg = "hello";
$objsetproto(o,proto);
o.foo(); // print "hello"

$objsetproto(o,null); // remove proto
o.foo(); // exception
```



## Arrays

Array is a type. That means that Neko arrays (and Neko strings and booleans as well) are not objects. If in your language arrays are objects, then you can write an object wrapper using an array value to store the data, and matching the API of your language.

Creating an array can be done using the `$array` builtin, and accessing an array can be done using the brackets syntax. You can also create an array with a specific size using the `$amake` builtin :

```neko
var a = $amake(0); // empty array
a = $array(1,3,"test"); // array with three values

$print(a[0]); // 1
$print(a[2]); // "test"
$print(a[3]); // null
$print(a["2"]); // exception
```

Arrays are accessed with integer key values, every other key value type will raise an exception. If the integer is in the range of the array bounds (between 0 and `$asize(a) - 1`), then the value returned is the one stored at this index, else it's `null`. For writing, if a value is written outside the bounds of the array then the array is not modified. You can get the size of an array using the `$asize` builtin. Arrays are not resizable :

```neko
a = $array(1,2,3);
$print($asize(a)); // prints 3
```

If you want to make a copy of an array or only of a part of an array, there is the `$acopy` and the `$asub` builtins. Please note that `$asub` can't access outside the bounds of the array :

```neko
a = $array(1,2,3,4);
$print( $acopy(a) ); // [1,2,3,4] , a copy can be modified separatly
$print( $asub(a,1,2) ); // [2,3]
$print( $asub(a,3,3) ); // null
$print( $asub(a,-2,3) ); // null
```

There is also a `$ablit` function to copy elements from one array to another :

```neko
a = $array(1,2,3,4);
b = $array(6,7,8);
$ablit(a,1,b,0,2); // copy 2 elements from b+0 to a+1
$print(a); // [1,6,7,4]
```

Arrays can contain a maximum of 2^29 - 1 elements, or `$amake` and `$array` will raise an exception.

## Strings

Like arrays, strings are a type and not objects. They are arrays of bytes, so can be convenient for storing large quantity of small numbers or binary data, that might not be scanned by the Garbage Colllector. Please note that unlike C language, the size of the string is stored so you can easily put binary data into it without caring about ending \000 character.

Neko strings are just byte buffers, they are then independant of any encoding. It then depends of the API you're using to manipulate them. You can user either the builtins which are manipulating bytes (then suitable for ISO) or the UTF8 API (in the standard library) which is manipulating UTF8 charcodes.

Literal strings can contain any character, including newlines and binary data. However doublequotes and backslashs need to be escaped. A backslash is used for escaping some special characters, here's a list of recognized escape sequences :

- `\"` : doublequote
- `\\` : backslash
- `\n` : newline
- `\r` : carriage return
- `\t` : tab
- `\xxx` : xxx are three digits that represent a decimal binary code between 000 and 255

Strings can be created using the `$smake` builtin with a given size. Once allocated, a string can't be resized. The size of a string can be retrieved using the `$ssize` builtin :

```neko
s = $smake(16);
s = "hello";
$print( $ssize(s) ); // 5
```

Please note that assigning a constant string does not makes a copy of it, so the constant content can be modified. Also, several same constant strings can be merged into the same string, so you might be careful about unexpected side effects when modifying a constant string. You might want to use a `$scopy` or the `$ssub` builtins (similar to array ones) :

```neko
s = $scopy("hello");
$print( $ssub(s,1,3) ); // "ell"
```

Access to strings bytes can be done using the `$sget` and `$sset` builtins. `$sget` returns a integer between 0 and 255 or `null` if outside the string bounds. `$sset` write the given integer value converted to an unsigned integer and modulo 256 :

```neko
$s = $smake(1);
$sset(s,0,3684); // set byte 0 to 3624 mod 256
$print( $sget(s,0) ); // prints 40
```

You can copy big chunks of bytes from one string to another using the `$sblit` builtin. It returns the number of bytes copied or `null` if the copy failed  :

```neko
s = "some string to blit from";
s2 = $smake(14);
$sblit(s2,0,s,5,14);
$print(s2); // "string to blit"
```

To find a substring in a string, you can use the `$sfind` builtin :

```neko
s = "some string to search";
$print($sfind(s,0,"to")); // 12
$print($sfind(s,20,"to")); // starting a byte 20 : null
```

Strings can contain a maximum of 2 ^ 29 - 1 characters, or `$smake` will raise an exception.

## Exceptions

Exceptions are often referred as "non local jumps". It's a very good way for handling errors than can happen at several calls between the function that yields an error and the handler that will take care of it. Raising an exception is done using the `$throw` builtin, and catching it is done using the `try...catch` syntax. Please note that any value can be an exception, it's up to you to decide which structure you want to use :

```neko
var foo = function() {
	$throw("failure");
}
try
	foo()
catch e {
	$print(e); // prints "failure"
}
```

Every time an exception is catched, the  is stored and can be retrieved using the builtin `$excstack()`. It contains the filenames and positions of the different calls between the `try` and the place the exception was raised.

```neko
try
	foo()
catch e {
	$print(e," raised from : ",$excstack());
}
```

In some cases, you want to filter exceptions and catch only some of these. You need then to catch all the exceptions, check if the exception is filtered, and raise it again if not. However, in order to loose the exception stack by throwing a new exception, you can use the `$rethrow` builtin that will add the two stacks together (the current one and the one to the next `catch`).

```neko
try
	foo()
catch e {
	if( $typeof(e) == $tint )
		$print("catched !")
	else
		$rethrow(e);
}
```

Please note that you can `rethrow` another exception, so it's more easy to rewrap some Neko libraries exceptions with your own format.

It is also possible to get the current call stack at any point of a Neko program using the `$callstack()` builtin.


## Hashtables

There is a set of builtins that are useful for using Hashtables. An hashtable is not a basic type but an  type. It can then only be manipulated using the following builtins :

- `$hnew(size)` : create a new hashtable having initialy `size` slots.
- `$hadd(h,k,v)` : add the value `v` with key `k` to the hashtable. Please note that `k` can be any Neko value, even recursive.
- `$hset(h,k,v,cmp)` : set the value of the key `k` to `v`. The previous binding is replaced if the `cmp` function between keys returns 0. If `cmp` is `null`, the default comparison function is used.
- `$hmem(h,k,cmp)` : returns true if a value exists for key `k` in the Hashtable.
- `$hget(h,k,cmp)` : returns the first value bound to key `k` or `null` if not found.
- `$hremove(h,k,cmp)` : removes the first binding of `k`. returns a boolean indicating the success.
- `$hresize(h,size)` : resize the hashtable. Please note that the size is usually automaticaly handled.
- `$hsize(h)` : returns the size of the hashtable.
- `$hcount(h)` : returns the number of bindings in the hashtable.
- `$hiter(h,f)` : calls `f(k,v)` for each binding found in the hashtable.

The hashtable stores the (key,values) couples in one chained list per slot. Adding a new binding with the same key will mask the previous one. The hash function used internaly is `$hkey(k)` which will return a positive Neko integer for any Neko value. The hash function cannot be overriden but the comparison function between keys can be where it is used.

You can of course write your own hashtable implementation using Neko data structures, but using the standard builtin hashtable is better for languages interoperability.

## Labels and Gotos

It is sometimes useful to be able to jump directly at some code location. Labels are providing a way to  a location in the code and the builtin `$goto` can jump to a label :

```neko
$print("enter");
$goto(next);
$print("skipping");
next:
$print("done");
```

Please note that labels identifiers are globals to the file, but cannot be defined in all expressions. The reason is to simplify the compiler since labels normaly require multiple passes for stack preservation (see below). In the case a label cannot be declared an error is printed at compilation-time. The builtin `$goto` can only be used with a valid label identifier, in that case only, the identifier is treated as a label and not as a variable.

### Gotos and Stack Preservation

In all cases, gotos to labels are preserving the stack. For example in the following case, the variable "x" is popped out of the stack when the goto occurs :

```neko
{
	var x = 0;
	$goto(next);
}
next:
```

If the goto is done  a block having defined local variables, these variables are also accessible but their values are unspecified :

```neko
$goto(next);
{
	var x = 0;
	next:
	$print(x);
}
```

### Gotos and Exceptions

In the same way gotos are preserving the stack size, they are also preserving the exception handlers, such as the following program is correctly compiled :

```neko
try {
	$goto(next);
} catch e {
	...
}
next:
```

In the case a goto is done inside a `try...catch` block, a temporary exception handler will be set that will only reraise the exception. The exception is not handled by the `catch` block since the `try` setup have been skipped :

```neko
$goto(next);
try {
	next:
	$throw("error");
} catch e {
	...
}
```

# End

Hope you didn't fell asleep while reading this long document.  Use the [Mailing List](ml).
