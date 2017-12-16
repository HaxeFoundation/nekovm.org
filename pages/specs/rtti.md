# Runtime Type Information (RTTI)

No matter if your language is statically or dynamically typed, you can always access RTTI in Neko. RTTI is powerful because you can decide which behavior to adopt depending on some value at runtime. The most common application of this is to print some debugging information. Another one is introspection : the ability to look inside an object, read its fields, and call its methods.

The builtin `$typeof` returns an integer specifying the type of a value according to the following table :

| Type     | Constant     | Value |
| -------- | ------------ | ----- |
| null     | `$tnull`     | 0     |
| int      | `$tint`      | 1     |
| float    | `$tfloat`    | 2     |
| bool     | `$tbool`     | 3     |
| string   | `$tstring`   | 4     |
| object   | `$tobject`   | 5     |
| array    | `$tarray`    | 6     |
| function | `$tfunction` | 7     |
| abstract | `$tabstract` | 8     |

Example :

```neko
$typeof(3); // 1
$typeof($array(1,2)); // 6
$typeof(null) == $tnull; // true
```

You can use the builtins for [Objects](/specs#objects), [Strings](/specs#strings), [Functions](/specs#function_function_calls), and [Arrays](/specs#arrays) to manipulate them at runtime.
