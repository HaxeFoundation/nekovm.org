# Function & Function Calls

Defining new functions is easy, since functions are values, and you can simply assign them to a local or a global variable :

```neko
var foo = function() {
	return 0;
}
```

Functions are called by-value, this means that `foo(1)` calls the function which is the value of the variable foo. Calling a value that is not a function or does not accept this number of arguments will raise an exception.

You can know the number of arguments needed by a function by using the builtin `$nargs`. A function that accepts a variable number of arguments returns -1 when used with `$nargs`. Please also note that builtins can be used as values :

```neko
$print($nargs(function(a,b) { return a + b; }); // prints 2
$print($nargs($print)); // prints -1
$print($nargs(0)); // exception
```

There is one other way of calling a function : builtin `$call` takes an array of arguments and an object context (see Objects section) as parameters. This builtin can be useful for introspection :

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

Another useful builtin is `$apply` which is identical to a direct function call except that if the function require extra arguments, then its call is delayed until further arguments are used :

```neko
var f = function(x,y) { return x + y };
f(1,2);
$apply(f,1)(2); // equivalent
$apply(f,1,2); // equivalent
```

