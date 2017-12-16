# Neko Starter's Guide

> So you want to learn about Neko? Here is a step-by-step guide to making and running your first Neko program. Before you start, please choose a distribution, download it, and get ready to install it. But first, you should know that the pronunciation of "Neko" is `n[e]ko` and not `n[i]ko`.

## Installation

Decompress the archive and put it into the folder you want :

- on Windows, you can use `c:\neko`
- on Mac, Linux, and other Unix systems, use a temp folder and we will move the files to appropriate locations in the next step

The archive contains :

- `neko` : the virtual machine boot binary
- `libneko.so*` (`neko.dll + neko.lib` on Windows) : the NekoVM library
- `nekoc` : the command-line Neko compiler
- `nekoml` : the command-line NekoML compiler
- `nekoml.std` : the NekoML standard library
- `nekotools` : neko utilities (including dev web server)
- several `.ndll` files : the Neko standard libraries
- `gc.dll` (on Windows only) : the garbage collector used by Neko
- `include/` : this directory contains the .H files needed for embedding and extending the VM
- `LICENCE` and `CHANGES` : some text documents




## Configuration

You have to setup a few things :

- **On Windows** : Add the `c:\neko` directory to your `PATH` environment variable. Here are instructions for [Windows 2000](https://support.microsoft.com/en-us/kb/311843) and [Windows XP](https://support.microsoft.com/en-us/kb/310519).

- **On Mac, Linux, and other Unix systems** : Put `neko`, `nekoc`, `nekoml`, and `nekotools` in `/usr/local/bin`. Put `libneko.so*` files in `/usr/local/lib`. Put `*.ndll` and `nekoml.std` in `/usr/local/lib/neko`. Put the `include/*.h` files in `/usr/local/include`. On Linux, you may have to run `sudo ldconfig`  and `sudo ldconfig /usr/local/lib` to refresh the library cache.


Once this is done you should be able to run the `neko` command from any directory. Please check that `neko` is working. (On Windows you can you can open a command terminal using `Start / Run..` and entering `cmd` then OK).

You should now be able to run the test : execute `neko -version` and it should print something like `2.1.0`. Now you can start using Neko.

## Compiling from Sources

Compiling Neko directly from sources is a little more difficult. See [README.md](https://github.com/HaxeFoundation/neko/blob/master/README.md#build-instruction) for additional instructions.

## Hello World

You can now start creating your first program `hello.neko` :

```neko
$print("hello neko world !\n");
```

Compile your `hello.neko` file into a `hello.n` file using the Neko command-line compiler by calling `nekoc hello.neko`. If you didn't make any syntax errors, this will produce a `hello.n` file containing the compiled bytecode of your sources.

You can now run this bytecode "module" by calling `neko hello`. This should print the usual funny string to the standard output.

## From here...

From here on, you're no longer a beginner so you can start reading the [other documents](/doc).

Congratulations!
