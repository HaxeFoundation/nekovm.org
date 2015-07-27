# Neko C FFI


The NekoVM itself have enough operations to compute any value. However it cannot do everything, like accessing files, connecting to server, or display and manage a window with menus and buttons. All these features and much more are however accessible from C code that will use operating system libraries. Since the NekoVM cannot call directly C functions, it is needed to write some glue C code that will wrap the OS libraries in order to make them accessible. These glue functions are called "primitives".

When you're writing primitives, you need to use the Neko C FFI (also called Neko API). To use it, you only need to include the `neko.h` file which is part of the Neko distribution, and to link with the Neko library (`libneko.so` on Unix, `libneko.dylib` on OSX, and `neko.lib` on Windows).

## A small sample

Here's an Hello World sample on how to write a Neko primitive in C :

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

The format of primitive name is @. You can then define several primitives in the same library.

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

Every value given as argument to a primitive or returned by a primitive must be of the C type `value`. The Neko API is defined in one single include file `neko.h`. There is several kind of API functions :

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

For more informations, see the [Type checks](#type_checks) section.

### Access Functions

In order to use the following functions, you must be sure first that the type of the value is correct by using functions above. If you don't the behavior is unexpected.

- `val_int(v)` : retrieve the integer stored into a value.
- `val_bool(v)` : retrieve the boolean stored into a value.
- `val_float(v)` : retrieve the float stored into a value.
- `val_string(v)` : retrieve the string stored into a value.
- `val_strlen(v)` : retrieve the length of the string stored into a value.
- `val_number(v)` : retrieve the float or the integer stored into a value.
- `val_array_ptr(v)` : retrieve the array stored into a value as a value*.
- `val_array_size(v)` : retrieve the size of the array stored into a value.
- `val_fun_nargs(v)` : retrieve the number of arguments of the function stored into a value.
- `val_data(v)` : retrieve the data stored into an abstract value.
- `val_kind(v)` : retrieve the kind of an abstract value.

### Allocation Functions

All of these functions are returning a value from some C data :

- `alloc_int(i)` : return a value from a C int.
- `alloc_float(f)` : return a value from a C float.
- `alloc_bool(b)` : return a value from a C bool (0 is false, true either).
- `alloc_array(size)` : create a Neko array from the given size.
- `alloc_string(str)` : return a value from a C string (make a copy).
- `alloc_empty_string(n)` : return an unitialized string value capable of storing `n` bytes.
- `copy_string(str,size)` : return a copy the `size` first bytes of the string `str` as a value.


## Printing a value

Using what you have learn from the Neko API, you can now write a function that print any value :

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

Please note that it's pretty inefficient since you are are doing a test for each type, while you could simply dispatch using `val_type` result :

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

The `default` case is not supposed to happen unless there is some bug into a C code function that doesn't return a correct value (or memory corruption). Since the NekoVM is safe in regard to memory manipulation, such problem can only arise from a buggy C primitive.

## Buffers

The printing of a value is a little more complex than that. In particular in case of objects you must call the `%%__string%%()` method to retrieve a representation of the object if available.

In order to easily construct strings of mixed constant C strings and values converted to strings, Neko API have `buffer`. A buffer is NOT a value, so you cannot return it outside of C primitive, but it is garbage collected so you don't have to free them after usage.

Here's a list of functions for using buffers :

- `alloc_buffer(str)` will allocate a fresh buffer with a string `str` or no data if `str` is `NULL`.
- `val_buffer(b,v)` will add a string representation of the value `v` to the buffer `b`.
- `buffer_append(b,str)` will append the C string `str` at the end of the buffer `b`.
- `buffer_append_sub(b,str,n)` will append the `n` first bytes of the C string `str` at the end of the buffer `b`.
- `buffer_to_string(b)` allocate and return a string value of the content of the buffer.

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

Objects in Neko are also values, and there is several functions in the Neko API to access and modify object fields.

### Objects API

- `alloc_object(o)` returns a copy of the object o, or an empty object if o is `NULL` or `val_null`.
- `val_is_object(v)` check that the value is an object.
- `val_id("fname")` : in the Neko specification, it is told that object tables does not contain directly fields names but a hashed identifier of the field name. `val_id` return a `field` identifier from a field name.
- `val_field(o,f)` access an object field for reading, returns `val_null` if the field is not found. `f` is the `field` identifier as retreived with `val_id`.
- `alloc_field(o,f,v)` will set or replace the value of the field `f` of object `o` by the value `v`.

Here's a small example that allocate an object with two fields x and y from two values :

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

If we want to add an method `%%__string%%` to the object in order to display its content when printed we can do the following :

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

Let's see a little what is done here :

In `make_point` we are setting the field `%%__string%%` of the object `o` to a value function allocated with `alloc_function`, which takes three parameters : the address of the C function, the number of parameters, and a name for the function that will help for debugging and errors location.

In `point_to_string` we are first retreiving `val_this()` which is the current `this` value. Since it might not be an object, we test it first before accessing its fields `x` and `y`. Then we want to construct the string `Point : x , y` with values of `x` and `y`, we're using for this a `buffer` (see Buffers).

### Objects Misc

It is possible to iterate through all fields of an object using the following function :

```c
val_iter_fields( value obj, void f( value v, field f, void * ), void *p );
```

You can reverse a hashed object field value by calling `val_field_name(f)`. This will return a string value if the field is found or `val_null` either.

## Type checks

Often when you're writing primitives, you're expecting the value arguments to be of one given type. So the first thing done in primitives is to check that the types are correct and have an exception raised if not. The Neko API provides several functions for that :

- `val_is_(v)` functions can test if a single value is of the given type.
- `val_check(v,)` will check `val_is_` and call `neko_error()` if it fails.
- `val_check_kind(v,)` will check that the value is an abstract of the given kind and call `neko_error()` if not.
- `val_check_function(v,)` will check that the value is a function that can be called with the specified number of arguments and call `neko_error()` if not.
- `neko_error()` will simply return the C `NULL` value. This special value will be catched  by the virtual machine that will raise an exception. Please use the macro instead of `return NULL` so your library will stay compatible if the implementation change.

Type checking is actualy very easy to use, simple add the `val_check*` statements at the beginning of your primitive :

```c
value myprim( value s, value n ) {
	val_check(s,string);
	val_check(n,int);
	...
}
```

## Function Callbacks

At some point, you might need to call back a value function or an object method. Callback API is here for you and enable you to do call any value function :

```c
value ret = val_callEx(vthis,f,args,nargs,&exc);
```

The API function `val_callEx` is the most general callback function. All other callback functions are only some easier ways of making calls. Here's a description of each of the arguments with their types :

- `value vthis` : a value specifying which will be the `this` value inside the call.
- `value f` : the function you want to call.
- `value *args` : a C array of values storing the arguments, in left-to-right order.
- `int nargs` : the number of arguments stored into `args`.
- `value *exc` : a value pointer to store an exception if it is raised in a subcall. If `NULL`, exceptions will not be catched and will go through your C function which is calling `val_callEx`.

The function `f` must have either a variable number of arguments (`VAR_ARGS`) or the exact `nargs` number of arguments, or an exception will be raised.

If the call is successful, the value returned by `f` is returned by `val_callEx`.

Here are other way of doing callbacks :

- `val_call0(value f)` : call the function `f` with 0 arguments.
- `val_call1(value f, value arg)` : call the function `f` with 1 argument.
- `val_call2(value f, value arg1, value arg2)` : call the function `f` with 2 arguments.
- `val_call3(value f, value arg1, value arg2, value arg3)`
- `val_callN(value f, value *args, int nargs)`

In the following functions, `f` is a field, so it's not the value of the method but the hash of the field name. The method is fetched from the object table before the call is performed.

- `val_ocall0(value o, field f)` : call the method `f` from the object o.
- `val_ocall1(value o, field f, value arg)` : call the method `f` from the object o.
- `val_ocall2(value o, field f, value arg1, value arg2)`
- `val_ocallN(value o, field f, value *args, int nargs)`

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

Since the function is a `value`, it is needed to store it into a place that can be accessed by the Neko garbage collector. This is why we allocate a `function_storage` with the `alloc_root` Neko FFI function. The `alloc_root` parameter is the number of values that can be stored in the allocated pointer.

Once the callback is set, we can call it from the C code by using the following code :

```c
// call the function with the Neko string "Hello"
value ret = val_call1(*function_storage,alloc_string("Hello"));
// ... handle the ret value
```

## Abstracts and Kinds

Most of the time, when you have to write an interface from Neko to a C library, you get some pointer to some mallocated memory. You can't safely return this value to the Neko program for the following reasons :

- it is not a `value` so it does not match the NekoVM memory model.
- it might then crash the program when accessed inappropriately.
- even it if was a value, it would have to be free explicitly.
- you cannot distinguish the types between two C pointers.

For all of these reasons, you need to be able to store a C pointer into an abstract Neko `value` and mark it with some type information called . The  of an abstract value is its type, and the  of an abstract value is the corresponding C pointer.

Please note that the VM itself cannot access either the kind or the data of an abstract value. For the VM, an abstract is an opaque value without any structure. It's up to your C primitives to manipulate the abstract. This ensure also that if you don't make any mistake in your C primitives, the whole program will be kept memory-safe.

First, you need to define a  somewhere in your C file, using the macro `DEFINE_KIND` from the Neko API. By convention, we often prefix the kind with `k_` but it's not mandatory :

```c
#include <neko.h>
DEFINE_KIND(k_mykind);
```

Now that you have a , you can create an abstract value of this kind using the `alloc_abstract` Neko API function :

```c
value create() {
	void *ptr = ....
	return alloc_abstract(k_mykind,ptr);
}
```

It is possible to store another `value` in the `data` part of an abstract, since it will still be checked by the garbage collector.

When you get back a value into one of your primitives, you can check if it's an abstract value using `val_is_abstract` then check its kind using the `val_is_kind` API function and then access its data using the `val_data` API function :

```c
value dosomething( value v ) {
	if( !val_is_abstract(v) || !val_is_kind(v,k_mykind) )
		neko_error();
	do_something_in_C( val_data(v) );
	return val_true;
}
```

Instead of all the time writing these checks you can use the `val_check_kind` macro that is more convenient :

```c
value dosomething( value v ) {
	val_check_kind(v,k_mykind);
	do_something_in_C( val_data(v) );
	return val_true;
}
```

In some cases, you might want the user to free the pointer stored into an abstract explicitly. At this time, you can set its kind to `NULL` so it is not accessible anymore :

```c
value destroy( value v ) {
	val_check_kind(v,k_mykind);
	free_data( val_data(v) );
	val_kind(v) = NULL;
	return val_true;
}
```

In other cases, you might want the pointer data to be free when the abstract value becomes garbage-collected. In that case you have to bind a  function on it. Please note that it might take some time between the value becomes unreachable and the finalizer is called.

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

## variable arguments function

If you want to pass more than five arguments, or a variable number of arguments, in a single neko-to-C function call, you can use the DEFINE_PRIM_MULT() macro:

```
value myprim( value *args, int nargs ) {
 ...
}
DEFINE_PRIM_MULT(myprim);
```

then, pass -1 as the number of arguments to $loadprim.

## Using 32 bits integers

As explained before, Neko integers are only signed 31 bits. While this is enough for most of the cases, there is some times where you want to use the full 32 bits. It was then added a common int32 abstract type.

You can use `val_is_int32(i)` to check that the value `i` is either an integer or an int32. And `val_int32(i)` will return the corresponding integer. If you want to check that the value is  an int32, then you can use `val_is_kind(i,k_in32)`.

To create an int32 value, you can use `alloc_int32(i)`. Please note that unlike `alloc_int` which is a fast macro, `alloc_int32` allocate some memory to store the integer so it is slower.

In the case most of your integers are using only 31 bits but you still want to be able to use the full 32 bits, then you can use the `alloc_best_int(i)` macro that will use either `alloc_int` or `alloc_int32` depending on the needed bits. Use then the `val_check(i,int32)` and `val_is_int32(v)` macros in order to accept both kind of integers.

## Managing Memory

When you're working with abstracts, you might want to allocate garbage-collected memory so you don't have to add finalizers for your datas (finalizers are more expensive than garbage-collected memory). The Neko VM API is providing several allocation functions :

Calling `alloc()` will return a pointer capable of storing up to `n` . So it's equivalent of `malloc(n)` but the memory will be automaticaly collected when unreachable from the VM. Please note that C  values are not reachable by the VM.

The memory allocated with `alloc` will be scanned by the garbage collector so you can store values and other `alloc`'ated pointers into it. As long as your pointer is reachable these values will also be reachable so they will not be collected.

If you want to allocate big chuncks of memory and you're sure they will not contain any value (strings for example) you can use `alloc_private()` that will return also `n`  of memory but that will not be scanned by the garbage collector. Please remember not to store any value in it.

In some cases, you might need to store some value into a  variable. First, you have to be sure of what you're doing, since the Neko VM can run in several threads, you need to protect the accesses to this value to ensure that your library will work when used simultaneously by multiple threads. Second, since the statics are not reachable by the garbage collector, you have to allocate a  value.

A  value is a pointer that can store several values and that will always be scanned by the GC. Since it will never be garbage-collected you can store it anywhere. However you'll have to free it explicitly. To allocate a root you can use the `alloc_root()` function that will return you a value pointer capable of storing up to `v` values. Once you don't need it anymore you have to free the root using the `free_root` function. Try to avoid the use of roots and static values as much as possible. Always store your datas into abstract values if you can.

## Misc API Functions

Before ending this document here are several functions that does not belong to any particular place. Feel free to use them when you need it :

- `val_compare(a,b)` : compare two values according to Neko specification. Returns an integer that will be 0 if `a = b`, -1 if `a < b`, 1 if `a > b` or `invalid_comparison` if `a` and `b` can't be compared.

- `val_print(v)` : print the value to the defined output of the virtual machine.

- `val_hash(v)` : hash any value into a positive integer.

- `val_throw(v)` and `val_rethrow(v)` : throw the value v as an exception.

- `failure(msg)` : throw a  exception using a constant C string as error message. This is a convenient way of handling errors in your primitives, since the exception will contain your error message as well as the C filename and the line where the error occured.

- `bfailure(buf)` : same as `failure` but use a  instead of a constant string.

## More Samples

If you want to have a look at samples using this API, you can simply browse the Neko standard libraries source code that should be perfectly understandable if you read this document.