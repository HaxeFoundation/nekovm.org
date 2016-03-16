# Values

A value in Neko can be one of the following :

- **Null:** the special value `null` is used for uninitialized variables as well as programmer/language specific coding techniques.
- **Integer:** integers can be represented in either decimal form (such as `12345` or `-12`), or hexadecimal (`0x1A2B3C4D`).
- **Floats:** floating-point numbers are represented using a period (such as `12.345` or `-0.123`)
- **Boolean:** booleans are represented by the following two lowercase identifiers: `true` and `false`.
- [Strings](/specs/strings): strings are surrounded by double quotes (for example: `"foo"`, or `"hello,\nworld !"`, or `"My name is \"Bond\\James Bond\"."`). Neko strings are mutable, which means that you can modify them.
- [Arrays](/specs/arrays): arrays are an integer-indexed table of values, with the index starting at 0. They provide fast random access to their elements.
- [Objects](/specs/objects): an object is a table, which associates an identifier or a string to a value. How objects are created and managed is explained later.
- [Functions](/specs/functions): a function is also a value in Neko, and thus can be stored in any variable.
- **Abstract:** an abstract value is C data that cannot be accessed from a Neko program.

Some Notes:

- Integers have 31 bits for virtual-machine performance reasons. An API for full [32-bit integers](/doc/view/int32) is available through a standard library.
- Floating-point numbers are 64-bit double-precision floating points values.
- Strings are sequences of 8-bit bytes. A string can contain `\0` characters. The length of a string is determined by the number of bytes in it, and not by the number of characters before the first \0.
