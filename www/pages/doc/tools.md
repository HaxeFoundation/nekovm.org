====== Neko Tools ======

===== neko =====

The ''neko'' command will run a file which contains compiled Neko bytecode. If the file has a '.n', you can omit it.

<code>
neko <bytecode_file>
</code>

===== nekoc =====

==== compiling ====

The primary purpose of ''nekoc'' is to compile Neko code to Neko bytecode. It will output a file with the file's extension replaced with '.n'.

<code>
nekoc <source_file>
</code>

==== linking ====

Several bytecode files can be joined together into a single file.

<code>
nekoc -link <output_file_name> <bytecode_file> <bytecode_file> ...
</code>

This is very useful if you are planning on building a stand alone executable using ''nekotools''.

==== console ====

There is a read-execute-print loop available using ''nekoc''. To use this, type in the code and then '!' to execute it. The results will be shown.

<code>
nekoc -console
</code>

//Note: local variables (declared with 'var') will not be kept in scope after the '!' is used to execute the code.//

==== dumping bytecode ====

It can also dump the bytecode from a compiled file. It will output a file with '.dump' as the extension.

<code>
nekoc -d <bytecode_file>
</code>

==== stripping bytecode ====

Debugging information and global names can be stripped from compiled bytecode. This is done in place, it does not create a new file.

<code>
nekoc -z <bytecode_file>
</code>

==== prettifying code ====

''nekoc'' can also create a properly formatted version of a source file.

<code>
nekoc -p <source_file>
</code>

==== documentation ====

Documentation can be produced from comments in Neko source code. This will produce an HTML file.

<code>
nekoc -doc <source_file>
</code>

==== options ====

Verbosity can be turned on with '-v'.

The output directory can be set with '-o <directory>'.

===== nekotools =====
==== webserver ====

You can run a webserver that serves up pages using Neko code.

<code>
nekotools server
</code>

Options:
  * ''-h <domain>'' - set hostname
  * ''-p <port>'' - set port
  * ''-d <directory>'' - set base directory
  * ''-log <file>'' - set log file
  * ''-rewrite'' - activate pseudo mod-rewrite for smart urls

URLs will be matched to '.n' files in the server directory. For example, http://localhost:2000/test/ will execute and display the results from 'test.n' file, if it exists.

==== standalone executable ====

It is possible to create standalone executables from Neko bytecode. Note, however, that you will probably still need 'libneko.so' or 'libneko.dll' unless they are statically linked to ''neko''.

This will output an executable file with no extension.

<code>
nekotools boot <bytecode_file>
</code>

===== nekoml =====

This program compiles NekoML files.

<code>
nekoml <source_file>
</code>
