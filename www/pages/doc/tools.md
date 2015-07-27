# Neko Tools

## neko

The `neko` command will run a file which contains compiled Neko bytecode. If the file has a '.n', you can omit it.

```
neko <bytecode_file>
```

## nekoc

### compiling

The primary purpose of `nekoc` is to compile Neko code to Neko bytecode. It will output a file with the file's extension replaced with '.n'.

```
nekoc <source_file>
```

### linking

Several bytecode files can be joined together into a single file.

```
nekoc -link <output_file_name> <bytecode_file> <bytecode_file> ...
```

This is very useful if you are planning on building a stand alone executable using `nekotools`.

### console

There is a read-execute-print loop available using `nekoc`. To use this, type in the code and then '!' to execute it. The results will be shown.

```
nekoc -console
```



### dumping bytecode

It can also dump the bytecode from a compiled file. It will output a file with '.dump' as the extension.

```
nekoc -d <bytecode_file>
```

### stripping bytecode

Debugging information and global names can be stripped from compiled bytecode. This is done in place, it does not create a new file.

```
nekoc -z <bytecode_file>
```

### prettifying code

`nekoc` can also create a properly formatted version of a source file.

```
nekoc -p <source_file>
```

### documentation

Documentation can be produced from comments in Neko source code. This will produce an HTML file.

```
nekoc -doc <source_file>
```

### options

Verbosity can be turned on with '-v'.

The output directory can be set with '-o <directory>'.

## nekotools
### webserver

You can run a webserver that serves up pages using Neko code.

```
nekotools server
```

Options:
- `-h <domain>` - set hostname
- `-p <port>` - set port
- `-d <directory>` - set base directory
- `-log <file>` - set log file
- `-rewrite` - activate pseudo mod-rewrite for smart urls

URLs will be matched to '.n' files in the server directory. For example, http://localhost:2000/test/ will execute and display the results from 'test.n' file, if it exists.

### standalone executable

It is possible to create standalone executables from Neko bytecode. Note, however, that you will probably still need 'libneko.so' or 'libneko.dll' unless they are statically linked to `neko`.

This will output an executable file with no extension.

```
nekotools boot <bytecode_file>
```

## nekoml

This program compiles NekoML files.

```
nekoml <source_file>
```
