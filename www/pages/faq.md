# FAQ

Frequently Asked Questions about Neko :


## How is Neko different from .Net's CLR or the Java's JVM?

The .Net's CLR and the Java Virtual Machine are both defined by a *bytecode* language with a *static type system* based on *classes*. As a result, you can easily run languages that have a type system compatible with Java or C# on these virtual machines. But if you have a dynamically typed language or no class system, you'll have to trick the virtual machine and find a *type mapping* from your type system to the JVM or the .NET one.

Neko is a lot more simple. First it is not a *bytecode* language but a high-level *programming* language. You don't have then to write a *compiler* for it, a simple *generator* that translates your program into the corresponding Neko program is enough. You still have to find a mapping from your values to Neko *data structures* but Neko gives you a dynamically typed language with no fixed class system. You have then to find a *runtime mapping* so that your program *executes* correctly on Neko, and not a *type mapping* so that your program *types* correctly like with .NET / JVM.

As a result, it is easier to write a new or existing language on the NekoVM than it is for the CLR / JVM, since you don't have to deal with a highlevel type system. Also, this means that languages can interoperate more easily since they only need to share the same *data structures* and not always the same *types*.

## How is Neko different from LLVM or C--?

These are compiler frameworks with low-level *abstract processor instructions* and a static type system with low-level *memory manipulation functions*. For example, it would be possible to use these frameworks to compile Neko, which stands as a higher-level language, although Neko is powered by its own runtime.

As a result, Neko is perhaps less suitable to optimizations than these *abstract processors* but is a lot easier to target for language designers that want to reuse a runtime. Since Neko is not a *framework*, it is very lightweight. For example, you only need `libneko.so`, which is only 68 KB, in order to embed and run Neko programs in your application.

## How is Neko different from PHP / Perl / Python / Ruby / Javascript?

These languages are meant to be used by people. They contain powerful but sometimes complex features. Often their runtimes are written entirely in C and can thus be difficult to maintain and their interpreters can be rather slow. Neko runtime could be used to run these languages more efficiently, and help them interact together and share the same libraries.

Actually, it is one of the goals of Neko to be able to run these languages on the same runtime. Since current implementations are either interpreted or running in a not-so-fast virtual machine using an intermediate compilable representation such as Neko should be a good improvement, especially when JIT is added.

## How is Neko different from Lua?

A complete [comparison](/lua) is available. Neko has better OO support and a more easy-to-use C FFI. Neko is faster for data structures manipulation but slower for floating-point arithmetics.


## How is Neko different from Parrot?

Targeting Parrot requires you to learn another language which is more complex that Neko itself, with different possibilties at different levels (low level PASM, medium level PIR, high level NQP).

It is also difficult to differenciate beetween the *language* and the *standard library* because of the numerous cores apis (PMC) whereas NekoVM has a single [builtins](/doc/view/builtins) core api which a single highlevel language with minimal syntax and core types.

Parrot is written in C while Neko compiler is written... in Neko. The language is fully bootstrapped right now. Also, Neko is lightweight and the Virtual Machine is only 68 KB on Linux and 40 KB on Windows, while still offering a very good speed.

## What garbage collector is Neko using?

Neko is using the [Boehm GC](http://www.hpl.hp.com/personal/Hans_Boehm/gc/) which is a conservative multithreaded mark and sweep collector. However since all calls to the GC are wrapper by the Neko API in `vm/alloc.c` it might be possible in the future to switch easily to another garbage collector.

## On which architecture can Neko run?

Neko is known to run on Windows x86, Linux, BSD, OSX, and Linux AMD64 architectures. A lot more architectures should be easily targeted since the NekoVM is written in pure ANSI C with only some differences for specific things such as some standard library functions for system API and dynamic loading.

## More questions?

You can ask on the [mailing list](/ml).
