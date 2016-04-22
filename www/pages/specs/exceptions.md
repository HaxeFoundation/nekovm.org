# Exceptions

Exceptions are often referred to as "nonlocal jumps". It's a very good way for handling errors than can happen at several calls between the function that yield an error and the handler that will take care of it. Raising an exception is done using the `$throw` builtin, and catching it is done using the `try...catch` syntax. Please note that any value can be an exception, it's up to you to decide which structure you want to use :

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

Every time an exception is caught, the *exception stack* is stored and can be retrieved using the builtin `$excstack()`. It contains the filenames and positions of the different calls between the `try` and the place the exception was raised.

```neko
try
	foo()
catch e {
	$print(e," raised from : ",$excstack());
}
```

In some cases, you want to filter exceptions and catch only some of them. You then need to catch all the exceptions, check if the exception is filtered, and raise it again if not. However, in order to lose the exception stack by throwing a new exception, you can use the `$rethrow` builtin which will add the two stacks together (the current one and the one to the next `catch`).

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

Please note that you can `rethrow` another exception, so it's easier to rewrap some Neko libraries exceptions with your own format.

It is also possible to get the current call stack at any point of a Neko program using the `$callstack()` builtin.
