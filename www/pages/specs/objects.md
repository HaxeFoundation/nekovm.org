# Objects

Objects are a kind of optimized hashtables. All fields names are hashed into an integer value that is used as the key in a lookup table. Insertion of a new field is `O(n)`, access to a field is `O(log n)`. If you're generating from a staticly typed language, you might prefer arrays for storing fields, since they provide `O(1)` access.

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

You can access object fields for reading using either dot access or builtin `$objget` :

```neko
o.field; // returns "field" value of object o
$objget(o,$hash("field")); // returns "field" value of object o
```

Please note that `$objset` and `$objget` second parameter is hashed at runtime, so it's a bit less efficient of an operation than dot access, but enables introspection.

If a field is not defined when accessed for reading, the `null` value is returned. If a field doesn't exists when a field is accessed for writing, the field is added.

To check for a field existance, you can use the `$objfield` builtin that checks if an object o has a given field, even if that field is set to the `null` value :

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

## Methods

When a function is called using the dot access or the builtin `$objcall`, the function can access a special variable called `this`, which is the "object context" (the object with which the function was called) :

```neko
o = $new(null);
o.x = 1;
o.add = function(y) { return this.x + y; }
$print(o.add(2)); // prints 3
$print( $objcall(o,$hash("add"),$array(2)) ); // prints 3
```

The context is set when an object function is called and can be accessed from any sub-function :

```neko
foo = function() {
	$print(this.x);
}
o = $new(null);
o.x = 3;
o.bar = function() { foo(); };
o.bar(); // prints 3
```

You can modify the value of `this` at runtime by simply assigning it to another value; it can be set to any value, not just objects. When returning from an object call, the context is restored, so any modifications are lost :

```neko
this = 1;
o.foo = function() {
	// here , we have this = o;
	this = 2; // modify
};
o.foo();
$print(this); // 1
```

## Fields lists

As explained before, fields names are first hashed into integer values for faster access. In order to avoid collisions in the hashing functions, they are then stored in a global table than will check that hash(x) = hash(y) implies that x = y. The other utilities of this library is to be able to reverse the hashing function at runtime. For example, this can be useful to print the field names of an object for debugging purposes.

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


## Operators Overloading

Several operators can be overloaded so when they're applied to objects, they are actually calling methods. Here's a list of overloadable operators and corresponding methods names :

- **string conversion** : call the `%%__string%%` method on the object with no arguments. A string should be returned.
- **object comparison** : for any comparison between two different objects, the `%%__compare%%` method is called on the first object with the second object as parameter.
- **addition** : in the case of `a + b`, if `a` is an object, `a.%%__add%%(b)` is called, otherwise if `b` is an object, `b.%%__radd%%(a)` is called.
- **subtraction** : same as addition but with `%%__sub%%` and `%%__rsub%%`.
- **multiplication** : same as addition but with `%%__mult%%` and `%%__rmult%%`.
- **division** : same a addition but with `%%__div%%` and `%%__rdiv%%`.
- **modulo** : same as addition but with `%%__mod%%` and `%%__rmod%%`.
- **array reading** : when an object is accessed as an array for reading, using `a[i]` actually calls `a.%%__get%%(i)`.
- **array writing** : when an object is accessed as an array for writing, using `a[i] = v` actually calls `a.%%__set%%(i,v)`.

If the overloaded field is not defined when an operation occured, an exception is raised.

## Prototypes

Each object can have a *prototype* which is also an object. When a field is accessed for reading and is not found in an object, it's searched recursively in its prototype.

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