# Labels and Gotos

It is sometimes useful to be able to jump directly at some code location. Labels provide a way to *mark* a location in the code and the builtin `$goto` can jump to a label :

```neko
$print("enter");
$goto(next);
$print("skipping");
next:
$print("done");
```

Please note that label identifiers are global to the file, but cannot be defined in all expressions. The reason is to simplify the compiler, since labels normaly require multiple passes for stack preservation (see below). In the case a label cannot be declared, an error is printed at compilation-time. The builtin `$goto` can only be used with a valid label identifier, in that case only, the identifier is treated as a label and not as a variable.

## Gotos and Stack Preservation

In all cases, gotos going to labels are preserving the stack. For example, in the following case, the variable "x" is popped out of the stack when the goto occurs :

```neko
{
	var x = 0;
	$goto(next);
}
next:
```

If the goto is done *inside* a block having defined local variables, these variables are also accessible, but their values are unspecified :

```neko
$goto(next);
{
	var x = 0;
	next:
	$print(x);
}
```

## Gotos and Exceptions

In the same way gotos are preserving the stack size, they are also preserving the exception handlers, such that the following program is correctly compiled :

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
