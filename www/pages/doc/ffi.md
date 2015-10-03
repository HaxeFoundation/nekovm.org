# Neko C FFI


The NekoVM itself have enough operations to compute any value. However it cannot do everything, like accessing files, connecting to a server, or display and manage a window with menus and buttons. All these features and much more are however accessible from C code that will use operating system libraries. Since the NekoVM cannot call C functions directly, it is needed to write some glue C code that will wrap the OS libraries in order to make them accessible. These glue functions are called "primitives".

When you're writing primitives, you need to use the Neko C FFI (also called Neko API). To use it, you only need to include the `neko.h` file which is part of the Neko distribution, and to link with the Neko library (`libneko.so` on Unix, `libneko.dylib` on OSX, and `neko.lib` on Windows).

## A small sample

Here's a Hello World sample on how to write a Neko primitive in C :

```c
#include <neko.h>

value test() {
	return alloc_string("Hello world");
}

DEFINE_PRIM(test,0); // function test with 0 arguments
```

Now all you have to do is to compile this C file into a shared library named "hello.ndll". In order to test your primitive, it is very easy to use it from a Neko program. Simply call the $loader `loadprim` method and request the primitive with the declared number of arguments :

```c
var p = $loader.loadprim("hello@test",0);
$print( p() );
```

The format of primitive name is *name_of_library*@*name_of_the_function*. You can then define several primitives in the same library.

## Manipulating Values

As we saw in the Language Specification, there are the following types of values available :

- null
- integer
- float
- boolean
- string
- array
- object
- abstract

Every value given as an argument to a primitive or returned by a primitive must be of the `value` type. The Neko API is defined in one single include file `neko.h`. There is several kind of API functions :

- `val_is_*` functions work on any value and return 1 if the value is of the given type, or 0 otherwise.
- `val_*` functions enable you to retreive the content of a value. Please note that you must first ENSURE that the value is of the given type before using such a function or the program might crash or have impredictable behavior.
- `alloc_*` functions enable you to convert a C value to a Neko value.

Please note that most (almost all) of these functions are actually C macros, so there is no call done. You can have a look at `neko.h` if you're performance-oriented and want to differentiate between macros and real API functions.

### Constant Values

- `val_null` : the Neko null value.
- `val_true` : the Neko true value.
- `val_false` : the Neko false value.

### Typecheck Functions

- `val_is_null(v)` : check if a value is null.
- `val_is_int(v)` : check if a value is an integer.
- `val_is_float(v)` : check if a value is a float.
- `val_is_string(v)` : check if a value is a string.
- `val_is_bool(v)` : check if a value is a boolean.
- `val_is_array(v)` : check if a value is an array.
- `val_is_object(v)` : check if a value is an object.
- `val_is_function(v)` : check if a value is a function.
- `val_is_abstract(v)` : check if a value is an abstract.
- `val_is_kind(v,k)` : check if a value is an abstract of the kind `k`.
- `val_is_number(v)` : check if a value is either an integer or a float.

For more information, see the [Type checks](#type_checks) section.

### Access Functions

In order to use the following functions, you must first be sure that the type of the value is correct by using functions above. If you don't, the behavior may be unexpected.

- `val_int(v)` : retrieve the integer stored in a value.
- `val_bool(v)` : retrieve the boolean stored in a value.
- `val_float(v)` : retrieve the float stored in a value.
- `val_string(v)` : retrieve the string stored in a value.
- `val_strlen(v)` : retrieve the length of the string stored in a value.
- `val_number(v)` : retrieve the float or the integer stored in a value.
- `val_array_ptr(v)` : retrieve the array stored in a value as a value*.
- `val_array_size(v)` : retrieve the size of the array stored in a value.
- `val_fun_nargs(v)` : retrieve the number of arguments of the function stored in a value.
- `val_data(v)` : retrieve the data stored in an abstract value.
- `val_kind(v)` : retrieve the kind of an abstract value.

### Allocation Functions

All of these functions are returning a value from some C data :

- `alloc_int(i)` : return a value from a C int.
- `alloc_float(f)` : return a value from a C float.
- `alloc_bool(b)` : return a value from a C bool (0 is false, true otherwise).
- `alloc_array(size)` : create a Neko array from the given size.
- `alloc_string(str)` : return a value from a C string (make a copy).
- `alloc_empty_string(n)` : return an unitialized string value capable of storing `n` bytes.
- `copy_string(str,size)` : return a copy the `size` first bytes of the string `str` as a value.


## Printing a value

Using what you have learned from the Neko API, you can now write a function that can print any value :

```c
#include <stdio.h>
#include <neko.h>

value print( value v ) {
	if( val_is_null(v) )
		printf("null");
	else if( val_is_int(v) )
		printf("int : %d",val_int(v));
	else if( val_is_float(v) )
		printf("float : %f",val_float(v));
	else if( val_is_bool(v) )
		printf("bool : %s",val_bool(v)?"true":"false");
	else if( val_is_array(v) )
		printf("array : size %d",val_array_size(v));
	else if( val_is_function(v) )
		printf("function : %d args",val_fun_nargs(v));
	else if( val_is_string(v) )
		printf("string : %s (%d bytes)",val_string(v),val_strlen(v));
	else if( val_is_object(v) )
		printf("object");
	else if( val_is_abstract(v) )
		printf("abstract of kind %X",val_kind(v));
	else
		printf("?????");
	return val_null;
}

DEFINE_PRIM(print,1);
```

Please note that it's pretty inefficient since you are are doing a test for each type, when you could simply dispatch using `val_type` result :

```c
#include <stdio.h>
#include <neko.h>

value print( value v ) {
	switch( val_type(v) ) {
	case VAL_NULL:
		printf("null");
		break;
	case VAL_INT:
		printf("int : %d",val_int(v));
		break;
	case VAL_FLOAT:
		printf("float : %f",val_float(v));
		break;
	case VAL_BOOL:
		printf("bool : %s",val_bool(v)?"true":"false");
		break;
	case VAL_ARRAY:
		printf("array : size %d",val_array_size(v));
		break;
	case VAL_FUNCTION:
		printf("function : %d args",val_fun_nargs(v));
		break;
	case VAL_STRING:
		printf("string : %s (%d bytes)",val_string(v),val_strlen(v));
		break;
	case VAL_OBJECT:
		printf("object");
		break;
	case VAL_ABSTRACT:
		printf("abstract of kind %X",val_kind(v));
		break;
	default:
		printf("?????");
		break;
	}
	return val_null;
}

DEFINE_PRIM(print,1);
```

The `default` case is not supposed to happen unless there is some bug in a C function that doesn't return a correct value (or memory corruption). Since the NekoVM is safe in regard to memory manipulation, such a problem can only arise from a buggy C primitive.

## Buffers

The printing of a value is a little more complex than that. In the case of objects in particular, you must call the `%%__string%%()` method to retrieve a representation of the object if available.

In order to easily construct strings of mixed constant C strings and values converted to strings, Neko API has `buffer`. A buffer is NOT a value, so you cannot return it outside of a C primitive, but it's garbage collected so you don't have to free them after usage.

Here's a list of functions for using buffers :

- `alloc_buffer(str)` will allocate a fresh buffer with a string `str` or no data if `str` is `NULL`.
- `val_buffer(b,v)` will add a string representation of the value `v` to the buffer `b`.
- `buffer_append(b,str)` will append the C string `str` at the end of the buffer `b`.
- `buffer_append_sub(b,str,n)` will append the `n` first bytes of the C string `str` at the end of the buffer `b`.
- `buffer_to_string(b)` allocate and return a string value of the buffer's content.

Here's a small example of a buffer usage :

```c
value print2( value v1, value v2 ) {
	buffer b = alloc_buffer("Values");
	buffer_append(b," = ");
	val_buffer(b,v1);
	buffer_append_sub(b,",xxx",1); // only first byte, so ','
	val_buffer(b,v2);
	return buffer_to_string(b);
}
```

## Working with Objects

Objects in Neko are also values, and there are several functions in the Neko API used to access and modify object fields.

### Objects API

- `alloc_object(o)` returns a copy of the object `o`, or an empty object if `o` is `NULL` or `val_null`.
- `val_is_object(v)` check that the value is an object.
- `val_id("fname")` : in the Neko specification, it is said that object tables doesn't contain direct fields names, but a hashed identifier of the field name. `val_id` returns a `field` identifier from a field name.
- `val_field(o,f)` access an object field for reading, returns `val_null` if the field is not found. `f` is the `field` identifier as retreived with `val_id`.
- `alloc_field(o,f,v)` will set or replace the value of the field `f` of object `o` by the value `v`.

Here's a small example that allocates an object with two fields x and y from two values :

```c
#include<neko.h>

value make_point( value x, value y ) {
	value o;
	val_check(x,number);
	val_check(y,number);
	o = alloc_object(NULL);
	alloc_field(o,val_id("x"),x);
	alloc_field(o,val_id("y"),y);
	return o;
}

DEFINE_PRIM(make_point,2);
```

### Objects Methods

If we want to add a method `%%__string%%` to the object in order to display its content when printed, we can do the following :

```c
#include<neko.h>

value point_to_string() {
	value o = val_this();
	value x , y;
	buffer b;
	val_check(o,object);
	x = val_field(o,val_id("x"));
	y = val_field(o,val_id("y"))
	b = alloc_buffer("Point : ");
	val_buffer(b,x);
	buffer_append(b," , ");
	val_buffer(b,y);
	return buffer_to_string(b);
}

value make_point( value x, value y ) {
	value f = alloc_function(point_to_string,0,"point_to_string");
	....
	alloc_field(o,val_id("%%__string%%"),f);
	return o;
}
```

Let's see a little bit of what is done here :

In `make_point` we are setting the field `%%__string%%` of the object `o` to a value function allocated with `alloc_function`, which takes three parameters : the address of the C function, the number of parameters, and a name for the function that will help for debugging and error locations.

In `point_to_string` we are first retreiving `val_this()`, which is the current `this` value. Since it might not be an object, we test it first before accessing the `x` and `y` fields. Then we want to construct the string `Point : x , y` with the values of `x` and `y`, we're using a `buffer` for this (see Buffers).

### Objects Misc

It's possible to iterate through all the fields of an object using the following function :

```c
val_iter_fields( value obj, void f( value v, field f, void * ), void *p );
```

You can reverse a hashed object field value by calling `val_field_name(f)`. This will return a string value if the field is found, otherwise `val_null` is returned.

## Type checks

Often when you're writing primitives, you're expecting the value arguments to be of one given type. So the first thing done in primitives is to check that the types are correct and have an exception raised if not. The Neko API provides several functions for that :

- `val_is_type(v)` functions can test if a single value is of the given type.
- `val_check(v,type)` will check `val_is_type` and call `neko_error()` if it fails.
- `val_check_kind(v,kind)` will check that the value is an abstract of the given kind and call `neko_error()` if not.
- `val_check_function(v,nargs)` will check that the value is a function that can be called with the specified number of arguments and call `neko_error()` if not.
- `neko_error()` will simply return the C `NULL` value. This special value will be caught by the virtual machine and will raise an exception. Please use the macro instead of `return NULL` so your library will stay compatible if the implementation changes.

Type checking is actualy very easy to do, simply add the `val_check*` statements at the beginning of your primitive :

```c
value myprim( value s, value n ) {
	val_check(s,string);
	val_check(n,int);
	...
}
```

## Function Callbacks

At some point, you might need to call back a value function or an object method. Callback API is here for you and enables you to call any value function :

```c
value ret = val_callEx(vthis,f,args,nargs,&exc);
```

The API function `val_callEx` is the most general callback function. All other callback functions are only easier ways of making calls. Here's a description of each of the arguments with their types :

- `value vthis` : a value specifying what the `this` will be inside of the call.
- `value f` : the function you want to call.
- `value *args` : a C array of values storing the arguments, in left-to-right order.
- `int nargs` : the number of arguments stored into `args`.
- `value *exc` : a value pointer to store an exception if it's raised in a subcall. If `NULL`, exceptions will not be caught and will go through your C function, which is calling `val_callEx`.

The function `f` must have either a variable number of arguments (`VAR_ARGS`) or the exact `nargs` number of arguments, or an exception will be raised.

If the call is successful, the value returned by `f` is returned by `val_callEx`.

Here are other way of doing callbacks :

- `val_call0(value f)` : call the function `f` with 0 arguments.
- `val_call1(value f, value arg)` : call the function `f` with 1 argument.
- `val_call2(value f, value arg1, value arg2)` : call the function `f` with 2 arguments.
- `val_call3(value f, value arg1, value arg2, value arg3)` : call the function `f` with 3 arguments.
- `val_callN(value f, value *args, int nargs)` : call the function with `nargs` amount of arguments.

In the following functions, `f` is a field, so it's not the value of the method but the hash of the field name. The method is fetched from the object table before the call is performed.

- `val_ocall0(value o, field f)` : call the method `f` from the object `o`.
- `val_ocall1(value o, field f, value arg)` : call the method `f` from the object `o`.
- `val_ocall2(value o, field f, value arg1, value arg2)` : call the method `f` from the object `o`.
- `val_ocallN(value o, field f, value *args, int nargs)` : call the method `f` from the object `o`.

### C to Neko callback sample

This is a small example that enable the C code to callback a Neko function.

First we define a primitive so that we can register our callback :

```c
#include <neko.h>

value *function_storage = NULL;

static value set_handler( value f ) {
	val_check_function(f,1); // checks that f has 1 argument
	if( function_storage == NULL )
		function_storage = alloc_root(1);
	*function_storage = f;
	return val_null;
}

DEFINE_PRIM(set_handler,1);
```

Since the function is a `value`, it's needs to be store in a place that can be accessed by the Neko garbage collector. This is why we allocate a `function_storage` with the `alloc_root` Neko FFI function. The `alloc_root` parameter is the number of values that can be stored in the allocated pointer.

Once the callback is set, we can call it from the C code by using the following code :

```c
// call the function with the Neko string "Hello"
value ret = val_call1(*function_storage,alloc_string("Hello"));
// ... handle the ret value
```

## Abstracts and Kinds

Most of the time when you have to write an interface from Neko to a C library, you get some pointer to some mallocated memory. You can't safely return this value to the Neko program for the following reasons :

- it's not a `value` so it doesn't match the NekoVM memory model.
- it might crash the program when accessed inappropriately.
- even if it was a value, it would have to be freed explicitly.
- you cannot distinguish the types between two C pointers.

For all of these reasons, you need to be able to store a C pointer in an abstract Neko `value` and mark it with some type information called *kind*. The *kind* of an abstract value is its type, and the *data* of an abstract value is the corresponding C pointer.

Please note that the VM itself cannot access either the kind nor the data of an abstract value. For the VM, an abstract is an opaque value without any structure. It's up to your C primitives to manipulate the abstract. This ensures that if there aren't any mistakes in your C primitives, the whole program will be kept memory-safe.

First, you need to define a *kind* somewhere in your C file using the macro `DEFINE_KIND` from the Neko API. By convention, we often prefix the kind with `k_`, but it's not mandatory :

```c
#include <neko.h>
DEFINE_KIND(k_mykind);
```

Now that you have a *kind*, you can create an abstract value of this kind using the `alloc_abstract` Neko API function :

```c
value create() {
	void *ptr = ....
	return alloc_abstract(k_mykind,ptr);
}
```

It's possible to store another `value` in the `data` part of an abstract, since it will still be checked by the garbage collector.

When one of your primitives gets a value back, you can check if it's an abstract value using `val_is_abstract`, check its kind using the `val_is_kind` API function, and then access its data using the `val_data` API function :

```c
value dosomething( value v ) {
	if( !val_is_abstract(v) || !val_is_kind(v,k_mykind) )
		neko_error();
	do_something_in_C( val_data(v) );
	return val_true;
}
```

Instead of writing these checks all the time, you can use more convenient `val_check_kind` macro :

```c
value dosomething( value v ) {
	val_check_kind(v,k_mykind);
	do_something_in_C( val_data(v) );
	return val_true;
}
```

In some cases, you might want the user to free the pointer stored in an abstract explicitly. At this time, you can set its kind to `NULL` so it is not accessible anymore :

```c
value destroy( value v ) {
	val_check_kind(v,k_mykind);
	free_data( val_data(v) );
	val_kind(v) = NULL;
	return val_true;
}
```

In other cases, you might want the pointer data to be freed when the abstract value gets garbage-collected. In that case, you have to bind a *finalizer* function on it. Please note that it might take some time between when the value becomes unreachable and the finalizer is called.

```c
void finalize( value v ) {
	free_data( val_data(v) );
}

value create() {
	void *ptr = ....
	value v = alloc_abstract(k_mykind,ptr);
	val_gc(v,finalize);
	return v;
}
```

You can remove the finalizer function from an abstract value by calling `val_gc(v,NULL)`.

## Variable arguments function

If you want to pass more than five arguments, or a variable number of arguments, in a single neko-to-C function call, you can use the DEFINE_PRIM_MULT() macro:

```
value myprim( value *args, int nargs ) {
 ...
}
DEFINE_PRIM_MULT(myprim);
```

Then, pass -1 as the number of arguments to $loadprim.

## Using 32 bits integers

As explained before, Neko integers are only signed 31 bits. While this is enough for most of the cases, there are some cases where you want to use the full 32 bits; a common int32 abstract type was then added.

You can use `val_is_int32(i)` to check whether the value of `i` is either an integer or an int32; `val_int32(i)` will also return the corresponding integer. If you want to check that the value is *exactly* an int32, then you can use `val_is_kind(i,k_in32)`.

To create an int32 value, you can use `alloc_int32(i)`. Please note that unlike `alloc_int` which is a fast macro, `alloc_int32` allocate some memory to store the integer, making it slower.

In the case that most of your integers are using only 31 bits but you still want to be able to use the full 32 bits, you can use the `alloc_best_int(i)` macro that will use either `alloc_int` or `alloc_int32` depending on the needed bits. Then use the `val_check(i,int32)` and `val_is_int32(v)` macros in order to accept both kind of integers.

## Managing Memory

When you're working with abstracts, you might want to allocate garbage-collected memory so you don't have to add finalizers for your datas (finalizers are more expensive than garbage-collected memory). The Neko VM API is provides several allocation functions :

Calling `alloc(n)` will return a pointer capable of storing up to `n` *bytes*. So it's equivalent to `malloc(n)`, but the memory will be automaticaly collected when unreachable from the VM. Please note that C *static* values are not reachable by the VM.

The memory allocated with `alloc` will be scanned by the garbage collector so you can store values and other `alloc`'ated pointers into it. As long as your pointer is reachable, these values will also be reachable so they won't be collected.

If you want to allocate big chuncks of memory and you're sure they will not contain any value (strings for example), you can use `alloc_private(n)` which will return `n` *bytes* of memory and won't be scanned by the garbage collector. Please remember not to store any value in it.

In some cases, you might need to store some value into a *static* variable. First, you have to be sure of what you're doing, since the Neko VM can run in several threads; you need to protect the accesses to this value to ensure that your library will work when used simultaneously by multiple threads. Second, since the statics are not reachable by the garbage collector, you have to allocate a *root* value.

A *root* value is a pointer that can store several values that will always be scanned by the GC. Since it will never be garbage-collected, you can store it anywhere. However you'll have to free it explicitly. To allocate a root, you can use the `alloc_root(v)` function which will return a value pointer capable of storing up to `v` values. Once you don't need it anymore, you have to free the root using the `free_root` function. Try to avoid the use of roots and static values as much as possible, and always store your datas in abstract values if you can.

## Misc API Functions

Before ending this document, here are several functions that do not belong in any particular place. Feel free to use them when you need it :

- `val_compare(a,b)` : compare two values according to the Neko specification. Returns an integer that will be 0 if `a = b`, -1 if `a < b`, 1 if `a > b`, or `invalid_comparison` if `a` and `b` can't be compared.

- `val_print(v)` : print the value to the defined output of the virtual machine.

- `val_hash(v)` : hash any value into a positive integer.

- `val_throw(v)` and `val_rethrow(v)` : throw the value `v` as an exception.

- `failure(msg)` : throw a *failure* exception using a constant C string as error message. This is a convenient way of handling errors in your primitives, since the exception will contain your error message as well as the C filename and the line where the error occured.

- `bfailure(buf)` : same as `failure`, but uses a *buffer* instead of a constant string.

## More Samples

If you want to have a look at samples using this API, you can simply browse the Neko standard library's source code, which should be perfectly understandable if you read this document.
