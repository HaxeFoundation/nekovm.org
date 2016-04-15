# Variables

When an identifier is found, it must be resolved to a scope containing the variable's value. The search starts in the local scope.

## Local Scope

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

Since scoping is resolved at a purely syntactic level, local variables do not depend the on the current call-stack, and you cannot access variables defined outside the current local scope.

```neko
f = function() {
	$print(x);
}
...
var x = 3;
f(); // will print "null"
```

## Function Scope

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

Please also note that each function instance has its own environment :

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

## Global Scope

When a variable is not found in the local scope or in the local function environment, it's a global variable. A global variable can be accessed throughout the entire file; it is shared among all code.

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