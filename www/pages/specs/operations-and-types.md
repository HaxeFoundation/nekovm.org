# Operations on Basic Types

Basic types are: numbers (int and float), booleans (bool), the null value, strings, objects, arrays, and functions. There are several operations available to use with them (See the following tables). On the row is the type of the first operand, and on the columns is that of the second operand. The result is either the type of the returned value, or "concat" if we use string concatenation (in that case, the two values are converted to strings and then concatened together). An "X" means that the operation is invalid and will raise an exception.

## Arithmetic operations

Operation add ( + ) :

| +            | null      | int       | float     | string    | bool      | object     | array     | function  |
| ------------ | --------- | --------- | --------- | --------- | --------- | ---------- | --------- | --------- |
| **null**     | X         | X         | X         | concat    | X         | %%__radd%% | X         | X         |
| **int**      | X         | int       | float     | concat    | X         | %%__radd%% | X         | X         |
| **float**    | X         | float     | float     | concat    | X         | %%__radd%% | X         | X         |
| **string**   | concat    | concat    | concat    | concat    | concat    | %%__radd%% | concat    | concat    |
| **bool**     | X         | X         | X         | concat    | X         | %%__radd%% | X         | X         |
| **object**   | %%__add%% | %%__add%% | %%__add%% | %%__add%% | %%__add%% | %%__add%%  | %%__add%% | %%__add%% |
| **array**    | X         | X         | X         | concat    | X         | %%__radd%% | X         | X         |
| **function** | X         | X         | X         | concat    | X         | %%__radd%% | X         | X         |


Addition can be overridden for objects : `a + b` will call `a.%%__add%%(b)` if `a` is an object, or `b.%%__radd%%(a)` if `b` is an object.

Operations substract ( - ) divide ( / ) multiply ( * ) and modulo ( % ) :

|  - / * %  | int               | float |
| --------- | ----------------- | ----- |
| int       | int (float for /) | float |
| float     | float             | float |

Please note that unlike some languages, the divide operation between two integers returns a float. You can use the `$idiv` builtin to perform integer division.


Dividing or taking the modulo of one integer by the integer or the float 0 is hardware-dependent, and usually returns the float `+infinity` for division, and NaN for modulo. You can test it using the builtin `$isinfinite`. There is also `$isnan` for testing for NaN :

```neko
$print($isinfinite(1/0)); // prints true
$print($isnan(0/0)); // prints true
```

These operations are can be overriden by objects. See the Objects section.

Please note also that overflow on integer operations does not convert them to floats, and does not throw an exception. If you want to control overflow, you can define your own functions for operations, use floats everywhere, or use an object with overridden operators.

## Bitwise operations

The following operations are available for integers only. Please remember that for performance reasons, Neko integers are signed and only have 31 bits, so the "unsigned" part is only 30 bits of :

- `%%<<%%` left bit shift
- `%%>>%%` right bit shift
- `%%>>>%%` right unsigned bit shift
- `|` or bits
- `&` and bits
- `^` xor bits

Using these operations with one or more non-integer operands will raise an exception.

## Boolean operations


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

Boolean operations are short-circuited. This means that if the first operand of an `&&` is `false` or the first operand of an `||` is `true`, then the second operand is not evaluated, and the first value is returned. Otherwise, the second value is returned.

Please note that no automatic conversions to booleans are done. `a && b` is equivalent to `if( a == false ) b else a` and `a || b` is equivalent to `if( a == true ) a else b` with `a` being evaluated only once. You might prefer to call `$istrue` on each argument before performing the operation.


## Equality & Comparisons

Comparison occurs when the following operations are performed : equality `==`, inequality`!=`, greater than `>`, less than `<`, greater than or equal to `>=`, or less than or equal to `%%<=%%`.

Comparison method :

| $compare  | null | int    | float  | string | bool   | object | array | function |
| --------- | ---- | ---    | -----  | ------ | ----   | ------ | ----- | -------- |
| null      | 0    | -      | -      | -      | -      | -      | -     | -        |
| int       | -    | icmp   | fcmp   | strcmp | -      | -      | -     | -        |
| float     | -    | fcmp   | fcmp   | strcmp | -      | -      | -     | -        |
| string    | -    | strcmp | strcmp | strcmp | strcmp | -      | -     | -        |
| bool      | -    | -      | -      | strcmp | bcmp   | -      | -     | -        |
| object    | -    | -      | -      | -      | -      | ocmp   | -     | -        |
| array     | -    | -      | -      | -      | -      | -      | acmp  | -        |
| function  | -    | -      | -      | -      | -      | -      | -     | acmp     |

Here are the details of each comparison function :

- icmp compares two integers a and b. It returns 0 if they're equal, -1 if b > a, and 1 if a > b.
- fcmp is the same as icmp, but compares floats instead of integers.
- strcmp compares strings. It can be seen as a icmp applied to every byte of the two strings.
- acmp compares the addresses of a and b. It returns 0 if they're the same, -1 if b>a, and 1 if a>b
- bcmp returns 0 if a and b are both the same value, 1 if a is true and b and false, -1 if a is false and b is true.
- ocmp does "object comparison". If the two objects' addresses are the same, it returns 0. Otherwise, it calls the method `%%__compare%%` on the first object, with the second object as argument. If the returned value is an integer, the integer is returned by `$compare`, otherwise null is returned.
-  - means that the comparison is invalid, the returned value is null when using `$compare` and false when using an operator.

The following table shows how each operation is performing depending on the result of `$compare` :

|  op      | null  | -1    | 0     | 1     |
| -------- | ----- | ----- | ----- | ----- |
|  ==      | false | false | true  | false |
|  !=      | true  | true  | false | true  |
|  %%<=%%  | false | true  | true  | false |
|  <       | false | true  | false | false |
|  >=      | false | false | true  | true  |
|  >       | false | false | true  | true  |

Physical comparison :

The builtin `$pcompare` will compare two values physically. It will be the same result as `$compare` for integers, and other values will be compared using their memory address. You can use `$pcompare` instead of `$compare` if you want to optimize your integer comparisons.


## Assignments

The following operations are also available in order to modify the value of a variable, object field, array content...

The standard assignment operator is `=`. There are also the following augmented assignment operators which perform an operation at the same time. The returned value is always the assigned value :

```neko
+= -= *= /= %= <<= >>= >>>= |= &= ^=
```

There are two additional operators, `++=` and `--=`, which do the same thing as `+=` and `-=`, except that the returned value is the value of the variable before it was modified :

```neko
a = 0;
$print(a ++= 1); // 0
$print(a ++= 1); // 1
$print(a); // 2
```

## Conversions

To convert any value to a Boolean, you can use the `$istrue` builtin, as specified in [Boolean operations](/specs#boolean_operations).

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


To convert a string to a float, you can use the `$float` builtin :

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

On objects, `$string` calls the `%%__string%%` method on the object if it exists. If the returned value is a string, the string is returned, otherwise the string `#object` is returned.

On functions, `#function:n` is returned where `n` is the number of arguments of the function (or -1 if multiple arguments).


## Optimized Operations

There are several optimized builtins for integers : `$iadd, $isub, $imult, $idiv`. They all skip some typechecks, so they're faster. Their results will always be a valid integer, but their value is unspecified when one or more of the two values is not an integer. `$idiv` raises an exception when division by 0 is attempted :

```neko
$print( $iadd(1,3) ); // 4
$print( $idiv(5,2) ); // 2
$print( $idiv(1,0) ); // exception
```
