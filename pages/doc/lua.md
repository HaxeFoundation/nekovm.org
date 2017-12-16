# A comparison of Neko and Lua

Since [Lua](http://www.lua.org) is probably the most similar to Neko in terms of goals, architecture, and performances. It is interesting to compare the choices that the two VMs are doing.

This comparison is established on the base of information available in the paper *The Implementation of Lua 5.0*, which explains the global design of the virtual machine.

This document can also be a good start for someone interested in the implementation of the Neko Virtual Machine.

## Values

The representation of values in a dynamically typed language is very important since it can lead to big differences in terms of performances. Such representation has several constraints :

- fast accesses
- must represent several kind of values (bool, integer, objects...)
- be able to cope with the garbage collector
- low memory overhead (when allocating a lot of small values matters)


### Value types

First, let's compare the different Lua/Neko value types :

- `nil` in Lua is similar to `null` in Neko since there is only one instance shared by all the code.
- `bool` in Lua (`true` and `false`) is similar to the Neko `bool` except that in Neko only one instance of `true` and one instance of `false` are allocated and shared by all the code.
- `number` in Lua is similar to Neko `float`; both are, by default, double-precision IEEE floating point values. And both are customizable to use single precision or even fixed point arithmetics.
- Neko has an additional `int` type that represents a signed 31-bits integer, as we will explain below when introducing the values runtime structure.
- both languages have a `function` type that can represent either a Bytecode or a C function. There are some implementation differences (see below).
- both languages have a `string` type, with implementation differences (see below).
- Lua differentiates between two kinds of user-defined data : `light` and `fat` pointers, which are either GC or User allocated. Neko has a single `abstract` type with a fixed tag that represents its internal type (see below).
- Lua has a `thread` type for coroutines. Neko does not have coroutines yet, but it might not be introduced as an additional value type.

The main difference, however, is of the structured value types :

Lua has a single `table` associative table that stores `(key,value)` pairs where `key` can be any value but `nil`. It has special optimizations that are explained in the paper presented above.

Neko has two structured value types :

- `array` which is a not-resizable block capable of storing a fixed number of values using 0-based integer accesses.
- `object` which stores `(key,value)` pairs, but keys are integer hashcodes obtained from the field string name.

Except for the structure values, the value types are pretty similar in both Neko and Lua. However their runtime representation and way of manipulating them differ.



### Runtime Representation

Neko and Lua have very different ways of representing their values.

In Lua, the following definition is used :

```c
typedef struct {
    int vtype;
    value_data vdata;
} value;

typedef union {
    GCObject *gc_data;
    void *user_data;
    double number_data;
    int int_data;
} value_data;
```

It means the following :

- every value is a structure of exactly 12 bytes.
- passing a value as an argument or storing it involves copying these bytes around. Values are not pointers but structures.
- basic type instances such as `nil`, `bool`, and `number` are not allocated by the Garbage collector.
- others (such as functions, strings, and tables) have GC-allocated data in the `gc_data` field.

Neko has a bit more complex representation. The first field is also an integer representing the value type, but the internal structure differs depending on the value type. It can somehow be represented this way :

```
typedef struct {
   int vtype;
   // type-specific data
} *value;

typedef struct {
   int vtype; // = VAL_NULL
   // NO DATA
} *vnull;

typedef struct {
   int vtype; // = VAL_BOOL
   // NO DATA
} *vbool;

typedef int vint;

typedef struct {
   int vtype; // = VAL_FLOAT
   double vdata;
} *vfloat;

typedef struct {
   int vtype; // = VAL_STRING + (character count << 3)
   char cfirst;
   // ... more characters
} *vstring;

...

```

The difference with Lua is that Neko has value pointers, so no copying is needed when passing values into the program. This actually means that Neko is more efficient, with the only drawback being the `float` type as we will see below.

Neko has an additional 31-bit integer type which is the only non-pointer value. Integers are differentiated from other values by having their last bit set to `1` while other pointers are guaranteed to be multiple of 2 (for memory-alignment purposes). That has an overhead compared to Lua since when accessing the `type` of a value, Neko needs to check if the pointer is odd or even first. In the first case it's an integer, in the second case it's a value and the type is stored in the first integer.

Let's make a type-by-type runtime structure comparison :

- `null` : similar in both Lua and Neko, since there is only one instance shared by all the code. The comparison can be done by physical-equality.
- `bool` : Neko has two unique instances: `true` and `false`, so no allocation is performed for these two and comparisons can be made physically. Lua does not have allocation for these values also, but copying occurs.
- `float` : copying values in Lua means that the `float` type is not allocated by the GC. This is not the case with Neko where the only *unboxed* type is `int`. This is not something that can be changed easily since it's the result of Lua's design of copying value-structures instead of passing value-pointers.
- `string` : Neko allocates a block of `sizeof(int) + number_of_chars` for each string. Lua allocates a similar block with the GC header, length, and a precomputed hash value for each string.

Some more comments can be done for each value structure more particularly.

### Functions

Lua does not seem to enforce the number of parameters as part of the type of the function, as it is in Neko. Neko has a special value of `-1` meaning *variable* number of parameters.

Calling a function in Neko with an invalid number of parameters will result in a runtime error. This way of doing it permits a more natural way of extending Neko with C functions, as we will see in the API part of this comparison.


### Strings

What Neko and Lua strings have in common is that they can store any character, including `\0`. This means they are more like byte-buffers than C-style-string. Also, the size of the string is stored in the value, preventing out-of-bounds memory violations.

One large difference is that Neko's strings are mutable, that is, they can be modified at runtime. This makes an operation like reading a file to a string byte by byte a fast, efficient, linear operation. By contrast, if you were to try and do this in Lua (which has immutable strings), the operation would be quadratic and become prohibitively slow for even files of a few kilobytes. Lua offers a facility, table.concat, to alleviate this problem; but it still bites programmers on occasion.

There are advantages in Lua's approach, however; one is that a string can only exist once in memory, compared to Neko where it is possible for two strings with the same value to exist twice in memory (wasting memory). It also allows comparing strings by their pointer values, where as Neko requires a linear operation. Finally, it allows the hash of the string to be calculated just once, to greatly speed hash table indexing with the key.

In summary, Lua strings offer faster hash table indexing and equality comparisons at the cost of being unable to modify a string at runtime and slower string creation. Neko on the other hand offers mutable strings, which are faster to create.


### User Data

Lua and Neko both provide means of using user-defined data from within the language, although the implementations differ. In Lua, two data types are provided, one which holds a user-allocated pointer (`lightuserdata`), and the other is GC allocated (`userdata`). The user-allocated pointer carries no additional information, with no type security when it is dereferenced in C (although the value can never be modified from within Lua, so this is usually not a problem). The GC allocated pointer carries a `metatable` which defines operations on the data (such as addition), and can be used to identify what type it is.

Neko's approach combines the two types into one `abstract` value type which stores two values:

- the `data` pointer that can be either User-allocated or GC-allocated. Its content is user-defined.
- the `kind` is a marker for the internal type of the `data` pointer.

The difference is that whilst user-allocated pointers in Lua allow no runtime type checking, the Neko approach does, providing a security advantage.

Another difference is that whilst the Lua GC ignores user-allocated data, Neko tracks it and calls a *finalizer* method when it's no longer used, which allows the data to be freed. Lua only offers finalizers on GC allocated data; if a finalizer is required on a user-allocated pointer, the pointer must be boxed in a GC allocated pointer, which provides a similar construct to Neko's `abstract` value type.

More information on the Neko `abstract` can be found in the Neko [FFI documentation](/doc/ffi/).


### Objects VS Tables

Neko has an `object` and an `array` type. Lua has a single `table` type, which consists of both an array and a hashtable.

Neko's arrays allow fast access via integer indices. If the index is outside of the array bounds, `NULL` is returned. Lua tables are slower for integer indexing, though, as Lua possesses no integer datatype. This means that before the array portion of the hashtable can be used, the number has to be checked if it's an integer (requiring two cast operations and a comparison). If the index is outside of the array component bounds, the hashtable is tried.

Thus, for allocating small blocks that are accessed through integer indexes, Neko arrays are a lot more efficient than Lua tables. That's a design choice, which also comes from different goals :

- Lua is meant to be a full-featured scripting language, easy to pickup and which favors simplicity.
- Neko is meant to be a runtime targetable by language designers. It offers different kinds of value types that can be used for encoding the runtime values of the language. A fast lightweight array is useful in that context.

The `object` and the hash table component of a Lua `table` differ greatly. Lua tables can be indexed with any kind of key, which are hashed for optimized lookup.

Neko objects are accessed through Neko integers (which are unboxed values, hence with no memory overhead). Field names are computed at compile-time; for example, `obj.field` would get compiled into the following opcodes:

```neko
  ACCSTACK 0 // the obj value
  ACCFIELD 0x56BD6 // the hashcode for the string "field"
```

All hashed fields are cached into a per-thread hashtable. This way Neko can ensure :

- that two field names with the same hashcode are the same string, or an exception will occur at runtime. In order to avoid this, the hash function is optimized to minimize collisions.
- that a field hash value can always be reversed to the original field name (for debugging/display purposes).

Object fields are stored into a flat resizable array and are ordered by their field hash. When a new field is inserted, the array size is increased. When a field is searched, a simple dichotomy is used. This offer good performance since all the object table memory is retained into a single block that usually fits into the CPU cache.

This approach doesn't allow accessing a field with a name generated at runtime. Lua tables allow this, as they are an ordinary hashtable that can be indexed with any Lua type.

Both Neko and Lua allow a form of inheritance. In Neko, objects may have a `prototype`, which is another object. When a field is not found in an object, Neko tries its prototype recursively. Lua tables will lookup an index `metamethod` before returning nil. If this is another table, it is indexed recursively, like Neko. However, it can also be a function, which Lua will call with the table and the field as parameters.

Both approaches allow easily encoding class-based objects and inheritance without copying the whole object/table for every instance: (in Neko opcodes)

```neko
classA = { foo => function() { } };
classB = { foo2 => function() { } };
$objsetproto(classB,classA); // B extends A
instA = $new(null);
$objsetproto(instA,classA); // creates a new instance of A
```

In that example, `instA` has access to all the fields of `classA` and `classB`, but has its own table to store its instance-defined fields. Such a scheme greatly decreases memory usage.

As a conclusion, it's almost impossible to compare the two approaches. Neko `array` and `object` are two optimized domain-specific structured types while Lua tables are more generalist.

As a side note, Neko also has its own (hash) tables but, although directly supported by the virtual machine, they are not in the base language. Neko's hashtable implementation is quite simple, but may not be as well as Lua's (eg. no precomputed hashes in Neko).

## Virtual Machine

The major difference between Lua and Neko is that Lua is register-based (since 5.0) while Neko is stack-based. Both approaches are very difficult to compare directly since it's also bound to the value encoding. By using a register-based approach, Lua can preallocate the working space for its values. It improves higher performances since less copy occurs when moving values forth-and-back like in Lua 4.

Instead of trying to run a head-to-head comparison that wouldn't make too much sense, let's have a look at how some specific features are implemented in both VM :


### Opcodes

As stated in the Lua 5.0 paper, all Lua opcodes fit into 32 bits, requiring a bit of unpacking to extract the operands and result registers.

Neko opcodes have one optional parameter so they are stored with either one or two 32-bit values. The bytecode loader ensures that all jumps are performed on valid opcode offsets so an invalid bytecode file cannot corrupt the Virtual Machine, and appropriate optimizations can be done upon bytecode loading, such as inlining the globals addresses.

A lot of Lua's opcodes allow an operand to be either a register or a constant, depending on a set bit. This requires additional processing but reduces the number of instructions.

Neko has 63 opcodes, with 11 of them being used only for optimizations purposes and 8 for optimizing different kinds of often-used comparisons. Each binary operation also has its own opcode and some domain-specific opcodes have been added for partial application (currying) and tail-recursive calls.

### Globals

Globals are stored by name in a regular `table` in Lua. This means that getting a global variable requires a hash table lookup. This is massively slower compared to Neko, which can inline the address of globals providing much faster read/write access. There is a reason in the madness of the Lua approach, though, namely you can: find a global by a runtime generated string (eg. `_G["Button"..i]`), provide the global table with metamethods for new default values, etc. Finally, the global table can be resized or even freed.

### Closures

Neko stores the locals into the function environment, which is a small array that is accessed by integer index by the Virtual Machine :

```neko
   add = function(x) {
       return function(y) {
           return x + y;
       }
   };
   add2 = add(2);
   $print(add2(3));
```

This get compiled into the following :

```
   // body for add_local_function
   AccEnv 0 // 'x' in the environment
   Push
   AccStack 1 // 'y' on the stack
   Add
   Ret

   // body for the add function
   AccStack 0 // 'x'
   Push
   AccGlobal 0 // the add_local_function
   MakeEnv 1 // creates a closure of size 1 with x
   Ret
```

The main difference between Lua and Neko closures can be seen below:

```neko
var x = 0;
f = function() { x += 1; };
f(); // increment the env. variable
$print(x);
```

Will print 0 in Neko (but the functions environment is correctly incremented), but in its equivalent Lua code:

```lua
f = function() x = x + 1 end
f()
print(x)
```

Will print 1.

Implementation comparison with Lua is a bit difficult to do since the specification is different. Both provide very fast access to their non-local variables, but Lua's mechanism requires a bit more GC overhead.


### OO Support

The NekoVM give access to the `this` register which stores the current object. This gives proper OO support, but has a side effect that calling `o.field(33)` is different from calling `(o.field)(33)` since in the first case, the `this` value is set to `o` while in the second case it is unchanged (plain function call). Lua provides `self`, but requires the user to distinguish between a regular function call, `string.sub(strname, 2, 3)` and a method call `strname:sub(2, 3)`.

While OO can also be encoded using closures capturing the instance, it has a big memory cost since one method closure needs to be allocated per object method and per instance (or lazily every time a method is fetched).

High-level OO languages that are targeting Neko (such as [Haxe](http://haxe.org)) have support for method-closure, but only when an object method is not directly applied, reducing the memory overhead.

## FFI

Foreign Function Interface (FFI) is the VM API that is exported to C for extensibility purposes. It's a set of functions that are used to manipulate values and the internal VM state.

### Macros VS Functions

Access to values is entirely done through function calls in Lua. That means that accessing the `double` from a number or checking the value type consists of calling a C function that performs the operation.

On the other hand, the Neko API directly expresses some common operations in terms of C macros. This way, for instance, the `val_float` operation to access the `double` is declared as the following :

```c
#define val_float(v)	((vfloat*)(v))->f
```

And checking the type of a value is the following :

```c
#define val_type(v)	((v & 1) ? VAL_INT : ((*v)&7))
```

This enables a lot faster access to the values on the C side. Some functions are also available when needed when allocating a value, for example.


### VM stack manipulation

When adding a new C primitive to Lua that adds two floats, one would do the following :

```c
int do_add(lua_State *L) {
   if( !lua_isnumber(L,1) || !lua_isnumber(L,2) ) {
       lua_pushstring(L, "incorrect arguments for 'do_add'");
       lua_error(L);
   }
   lua_pushnumber(L, lua_tonumber(L,1) + lua_tonumber(L,2));
   return 1; // number of results
}

// Or more commonly, by using the standard Lua auxiliary library:
int do_add(lua_State *L) {
  lua_pushnumber(L, luaL_checknumber(L, 1) + luaL_checknumber(L, 2));
  return 1;
}
```

Here's the equivalent in Neko :

```c
value do_add( value a, value b ) {
    val_check(a,float);
    val_check(b,float);
    return alloc_float( val_float(a) + val_float(b) );
}
```

The differences are the following :

- since the number of arguments is fixed in the function type, the C function gets directly called with its arguments in Neko. It does not need to then extract them from the VM stack like in Lua.
- Lua C functions can have more values passed than required, and although it can be checked at runtime, this is rarely done. This is because providing the same checks inside pure Lua functions is cumbersome, requiring writing them as vararg functions.
- only one value is returned by a C function so the stack does not need to be manipulated.
- since the VM instance is stored in a thread local storage value, it doesn't need to be passed to all FFI functions like in Lua (only the ones that need to access the VM will retrieve them).
- macros are provided to check the type parameters and returns NULL if an error occurs. In that case, an exception containing the name of the function is automatically raised. (The Lua aux library also provides this behaviour with luaL_checknumber.)

As a result, Neko restricts two things that Lua allows :

- doing arbitrary stack manipulations.
- returning multiple values : they can instead be returned as a newly allocated array.

Neko's method prevents possible stack corruption by the C programmer, which, in Lua, is possible by passing erroneous values to the stack manipulation functions. (Defining lua_assert will catch such attempts as runtime errors). It can also be considerably easier to understand values as values, rather than having to visualize the state of the stack.


## Conclusion

Here are some of the conclusions that can be reached from this comparison :

- the basic value types are similar between Neko and Lua.
- for structured values, Neko provides two optimized types `array` and `object`, whereas Lua has only one generic type `table`.
- the runtime representation of the values differs. Lua is relying on copying while Neko is using pointers and GC-allocated blocks.
- the NekoVM has better support for OO features and a different closure specification that results in a more simple implementation.
- the Neko FFI, by applying some security restrictions compared to Lua, makes it a lot easier for the end-user to implement additional primitives. Using macros also speed up a lot the C primitives that are often called.

As for the speed, using copying with unboxed floats and a register-based VM gives Lua an advantage over Neko when doing heavy floating point calculus (like the `n-bodies` shootout benchmark is showing).

On the other hand, allocating a lot of small arrays and performing recursive integer calculus over them is a lot faster in Neko (like the `binary-trees` shootout benchmark is showing).

Lua and Neko have made different choices with different results depending on the application, but both have good quality and are pretty fast VMs compared to other dynamically typed languages implementations.
