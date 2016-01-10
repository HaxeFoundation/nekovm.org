# Neko Starter's Guide

> So you want to learn about Neko? Here is a step-by-step guide to making and running your first neko program. Before you start, please choose a distribution, download it, and get ready to install it. But first, you should know that the pronunciation of "Neko" is `n[e]ko` and not `n[i]ko`.

## Installation

Decompress the archive and put it into the folder you want :

- on Linux systems, the `/usr/lib/neko` is recommended
- on Windows, you can use `c:\neko`

The archive contains :

- `neko` : the virtual machine boot binary
- `libneko.so` (`neko.dll + neko.lib` on Windows) : the NekoVM library
- `nekoc` : the commandline Neko compiler
- `nekotools` : neko utilities (including dev web server)
- several `.ndll` files : the Neko standard libraries
- `test.n` : the test bytecode
- `gc.dll` (on Windows only) : the garbage collector used by Neko
- `include/` : this directory contains the .H files needed for embedding and extending the VM
- `LICENCE` and `CHANGES` : some text documents




## Configuration

Once Neko is installed on your system, you have to setup a few things :

- **On Linux** : Setup your system so it will look for shared libraries in the install path (using `export LD_LIBRARY_PATH=/usr/lib/neko` for example). Put `neko`, `nekoc` and `nekotools` in `/usr/bin` or other directory that you are using. Install the `libgc1` package on your system.

- **On Windows** : Add the `c:\neko` directory to your `PATH` environment variable. Here are instructions for [Windows 2000](https://support.microsoft.com/en-us/kb/311843) and [Windows XP](https://support.microsoft.com/en-us/kb/310519).

- **On Mac OS X(10.5 "leopard")** : make a new folder, `/opt/neko/`, for example. Unpack the contents from the download ("OS X Universal binaries") to `/opt/neko/`. Add NEKOPATH to your `.bash_profile`(`NEKOPATH=$NEKOPATH:/opt/neko/:/opt/neko/neko; PATH=$PATH:/usr/bin/:$NEKOPATH; export PATH; export NEKOPATH`)


Once this is done you should be able to run the `neko` command from any directory. Please check that `neko` is working. (On Windows you can you can open a command terminal using `Start / Run..` and entering `cmd` then OK).

On Linux or OSX, if you didn't install neko in `/usr/lib/neko` or `/usr/local/lib/neko` ( `/opt/neko` on OSX ), then you need to setup the `NEKOPATH` environment variable so the runtime can find the Neko libraries. Set it to `/my/path/to/neko:/my/path/to/neko_vm` on Linux.

You should now be able to run the test : execute `neko test` to check that everything is setup correctly. Now you can start using Neko.

## Compiling from Sources

Compiling Neko directly from sources is a little more difficult. First, you need to install [libgc-dev](http://www.hpl.hp.com/personal/Hans_Boehm/gc), Then try to run `make`. All the compiled files should be compiled inside the `bin` subdirectory.

Compiling for Windows from sources is possible using the Visual Studio project files. You need to compile the `neko.sln` project (nekovm and nekovm_dll only) as well as the `libs/libs.sln` project.

## Hello World

You can now start creating your first program `hello.neko` :

```neko
$print("hello neko world !\n");
```

Compile your `hello.neko` file into a `hello.n` file using the neko commandline compiler by calling `nekoc hello.neko`. If you didn't make any syntax errors, this will produce a `hello.n` file containing the compiled bytecode of your sources.

You can now run this bytecode "module" by calling `neko hello`. This should print the usual funny string to the standard output.

## From here...

From here on, you're no longer a beginner so you can start reading the [other documents](/doc).

Congratulations!
