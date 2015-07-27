====== Neko Libraries ======

Several libraries are already available with the standard Neko distribution. This document lists these libraries and also gives some guidelines about how to notate [[#types|types]] for automatic documentation generation.



===== Libraries =====

  * [[view/builtins|Builtins]]
  * The Standard Library comprises several modules :
    * [[view/buffer|Buffer]]
    * [[view/date|Date]]
    * [[view/file|File]]
    * [[view/int32|Int32]]
    * [[view/math|Math]]
    * [[view/md5|MD5]]
    * [[view/memory|Memory]]
    * [[view/module|Module]]
    * [[view/random|Random]]
    * [[view/serialize|Serialize]]
    * [[view/socket|Socket]]
    * [[view/string|String]]
    * [[view/sys|System]]
    * [[view/utf8|UTF8]]
    * [[view/xml|Xml]]
    * [[view/thread|Thread]]
    * [[view/ui|Ui]]
    * [[view/process|Process]]
    * [[view/misc|Misc]]
  * [[view/regexp|Regexp]]
  * [[view/mysql|Mysql]]
  * [[view/cgi|Mod_neko]]
  * [[view/sqlite|Sqlite]]
  * [[view/zlib|ZLib]]

If you want to write your own libraries, have a look at the [[ffi|C FFI]] Documentation.



===== Types =====

Here's the notation of types that should be used when documenting libraries :

//(is not up-to-date)//

  * the basic types ''null'', ''int'', ''float'', ''bool'', ''string'', ''array'', ''object'', ''function''.

  * the type ''any'' if any value is accepted.

  * the type ''void'' can be used if the function is not supposed to return any meaningful value.

  * the type ''number'' if both ''int'' and ''float'' are accepted.

  * the type ''function://n//'' if a function with //n// parameters is accepted.

  * for abstracts, you need to give them a name (corresponding to their kind) and write it with a single quote as prefix (for example '''file'' is an abstract of kind //file//).

  * for arrays that contains a specified type of value, you can write the type before, then ''int array'' is an array containing only integers and '''file array array'' is a two dimensions array that contains abstract files.

  * for objects that must contain some fields, you can write it using Neko notation with types : ''{ x => int, y => int }'' means an object having at least two fields ''x'' and ''y'' of type ''int''.

  * if the ''null'' value is accepted as well as some other ype, you can write, for example ''int?'', which means ''int'' or ''null''.

  * if several types are accepted you can separate them with pipes. ''number'' is actually a shortcut for ''int | float''.

  * you can introduce your own names, prefixed with a sharp, that can be defined in your documentation using for example ''#point = { x => int, y => int }''. In the case you don't define your type, the user of the library should not rely on its actual implementation since you can change it in the future.

Please respect this type notation standard when documenting your Neko programs and libraries: it will help people using them.