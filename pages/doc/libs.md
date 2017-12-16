# Neko Libraries

Several libraries are already available with the standard Neko distribution. This document lists these libraries and also gives some guidelines about how to notate [types](#types) for automatic documentation generation.



## Libraries

The Standard Library comprises several modules: [Buffer](/doc/view/buffer/), [Date](/doc/view/date/), [File](/doc/view/file/), [Int32](/doc/view/int32/), [Math](/doc/view/math/), [MD5](/doc/view/md5/), [Memory](/doc/view/memory/), [Module](/doc/view/module/), [Random](/doc/view/random/), [Serialize](/doc/view/serialize/), [Socket](/doc/view/socket/), [String](/doc/view/string/), [System](/doc/view/sys/), [UTF8](/doc/view/utf8/), [Xml](/doc/view/xml/), [Thread](/doc/view/thread/), [Ui](/doc/view/ui/), [Process](/doc/view/process/), [Misc](/doc/view/misc/), [Regexp](/doc/view/regexp/), [Mysql](/doc/view/mysql/), [Mod_neko](/doc/view/cgi/), [Sqlite](/doc/view/sqlite/), [ZLib](/doc/view/zlib/) and the [builtins](/doc/view/builtins/).

If you want to write your own libraries, have a look at the [C FFI](/doc/ffi/) Documentation.



## Types

Here's the notation of types that should be used when documenting libraries :



- the basic types `null`, `int`, `float`, `bool`, `string`, `array`, `object`, `function`.

- the type `any` if any value is accepted.

- the type `void` can be used if the function is not supposed to return any meaningful value.

- the type `number` if both `int` and `float` are accepted.

- the type `function:` if a function with *n* parameters is accepted.

- for abstracts, you need to give them a name (corresponding to their kind) and write it with a single quote as the prefix (for example `'file` is an abstract of kind file).

- for arrays that contain a specified type of value, you can write the type before, then `int array` is an array containing only integers and `'file array array` is a two dimensions array that contains abstract files.

- for objects that must contain some fields, you can write it using Neko notation with types : `{ x => int, y => int }` means an object having at least two fields `x` and `y` of type `int`.

- if the `null` value is accepted as well as some other type, you can write, for example `int?`, which means `int` or `null`.

- if several types are accepted you can separate them with pipes. `number` is actually a shortcut for `int|float`.

- you can introduce your own names, prefixed with a sharp, that can be defined in your documentation using for example `#point = { x => int, y => int }`. In the case you don't define your type, the user of the library shouldn't rely on its actual implementation since you can change it in the future.

Please respect this type notation standard when documenting your Neko programs and libraries: it will help the people using them.
