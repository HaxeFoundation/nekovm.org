# Neko Virtual Machine

Before reading this part of the documentation, it is recommend to have already read the [C FFI](doc/ffi) Documentation or to have a good knowledge of it.

## Running the VM

The Neko Virtual Machine is one binary called `neko` included in the Neko distribution. You can call it anytime using `neko (file)` in order to execute the specified bytecode file.

Bytecode files are precompiled Neko sources and have the `.n` extension. They are searched in local directories but also using the `NEKOPATH` environment variable which can list several search paths separated by `:`. Each bytecode `.n` file is also called a .

## Libraries

Each `.ndll` file is neko library. It is a shared library (`.so` or `.dll`) linked with the Neko Library (`libneko.so` or `neko.lib`). Each Neko Library can contain several primitives that can be used from a Neko program. Neko libraries are also searched the same way as Modules, using `NEKOPATH`.

## Exports

Each Neko module has a global object named `$exports`. The module can set fields into this object in order to export some values that will be usable from other modules :

```neko
$exports.log = function() { $print("log test") };
```

## Loaders

Each Neko module have a  which is an object that can be used to load other Neko modules and C primitives. The loader is accessible using the `$loader` builtin.

In order to load a Module, you can simply call the `loadmodule` method, which takes two parameters. The first parameter is the name of the module and the second parameter is the loader that this module will used. If found, the module is loaded, executed, and then its `$exports` table is returned. If not found, an exception is thrown.

```neko
var m = $loader.loadmodule("log",$loader);
m.log();
```

You can also load C  using the loader. See the [C FFI](doc/ffi) API for help on how to write such primitives. A primitive is loaded using the `loadprim` method, using the name of the library and the name of the primitive separated by an arrowbase, as well as the number of arguments. If success, a Neko function is returned that is used to call the primitive. If not found, an exception is thrown.

```neko
var p = $loader.loadprim("std@test",0);
p();
```

## Custom loaders

It is possible to define your custom loader that will filter or secure the modules and primitive loaded. The only thing needed is to implement the two methods `loadmodule` and `loadprim` and use your loader as the second parameter of the `loadmodule` method when loading another module.


## Embedding the VM

The Neko Virtual Machine and its [C FFI](doc/ffi) are packaged into a single shared library (`libneko.so` on Unix systems and `neko.dll` on Windows). With the garbage collector library (`libgc` on Unix and `gc.dll` on Windows), this is all you need to add to your application in order to be able to run a Neko Program.

Here's a small code snippet that initialize a NekoVM and run a neko module inside it, then access to some data :

```c
#include <stdio.h>
#include <neko_vm.h>

value load( char *file ) {
    value loader;
    value args[2];
    value exc = NULL;
    value ret;
    loader = neko_default_loader(NULL,0);
    args[0] = alloc_string(file);
    args[1] = loader;
    ret = val_callEx(loader,val_field(loader,val_id("loadmodule")),args,2,&exc);
    if( exc != NULL ) {
        buffer b = alloc_buffer(NULL);
        val_buffer(b,exc);
        printf("Uncaught exception - %s\n",val_string(buffer_to_string(b)));
        return NULL;
    }
    return ret;
}

void execute( value module ) {
    value x = val_field(module,val_id("x"));
    value f = val_field(module,val_id("f"));
    value ret;
    if( !val_is_int(x) )
         return; 
    printf("x = %d\n",val_int(x));
    if( !val_is_function(f) || val_fun_nargs(f) != 1 )
         return;
    ret = val_call1(f,x);
    if( !val_is_int(ret) )
         return;
    printf("f(x) = %d\n",val_int(ret));
}


int main( int argc, char *argv[] ) {
    neko_vm *vm;
    value module;
    neko_global_init(NULL);
    vm = neko_vm_alloc(NULL);
    neko_vm_select(vm);

    module = load("mymodule.n");
    if( module == NULL ) {
         printf("Failed to load module !\n");
         return -1;
    }
    execute(module);

    neko_global_free();    
    return 0;
}

```

You can use it to load the following `mymodule.neko` file after compilation :
```neko
$exports.x = 33;
$exports.f = function(x) { return x * 2 + 1; }
```

### NekoVM API

The Neko VM API is declared into the `neko_vm.h` file. It will be fully documented later. There is also the `neko_mod.h` file for low level module access.

### Multithreading

Each thread can run several Neko virtual machine, however the same VM should not run at the same time in different threads. When changing virtual machine or after allocating one, you must call the `neko_vm_select` API function that will select this virtual machine for the current thread.