# Strings

Like arrays, strings are a type and not objects. They are arrays of bytes, so can they be convenient for storing large quantity of small numbers or binary data, that might not be scanned by the Garbage Colllector. Please note that unlike C, the size of the string is stored so you can easily put binary data into it without caring about the ending \000 character.

Neko strings are just byte buffers, they are then independant of any encoding. It then depends of the API you're using to manipulate them. You can either use the builtins which are manipulating bytes (then suitable for ISO) or the UTF8 API (in the standard library) which is manipulating UTF8 charcodes.

Literal strings can contain any character, including newlines and binary data. However doublequotes and backslashs need to be escaped. A backslash is used for escaping some special characters, here's a list of recognized escape sequences :

- `\"` : doublequote
- `\\` : backslash
- `\n` : newline
- `\r` : carriage return
- `\t` : tab
- `\xxx` : xxx are three digits that represent a decimal binary code between 000 and 255

Strings can be created using the `$smake` builtin with a given size. Once allocated, a string can't be resized. The size of a string can be retrieved using the `$ssize` builtin :

```neko
s = $smake(16);
s = "hello";
$print( $ssize(s) ); // 5
```

Please note that assigning a constant string does not makes a copy of it, so the constant content can be modified. Also, several same constant strings can be merged into the same string, so you might want to be careful about unexpected side effects when modifying a constant string. You might want to use a `$scopy` or the `$ssub` builtins (similar to array ones) :

```neko
s = $scopy("hello");
$print( $ssub(s,1,3) ); // "ell"
```

Access to strings bytes can be done using the `$sget` and `$sset` builtins. `$sget` returns a integer between 0 and 255 or `null` if outside the string's bounds. `$sset` write the given integer value converted to an unsigned integer and modulo 256 :

```neko
$s = $smake(1);
$sset(s,0,3684); // set byte 0 to 3624 mod 256
$print( $sget(s,0) ); // prints 40
```

You can copy big chunks of bytes from one string to another using the `$sblit` builtin. It returns the number of bytes copied or `null` if the copy failed  :

```neko
s = "some string to blit from";
s2 = $smake(14);
$sblit(s2,0,s,5,14);
$print(s2); // "string to blit"
```

To find a substring of a string, you can use the `$sfind` builtin :

```neko
s = "some string to search";
$print($sfind(s,0,"to")); // 12
$print($sfind(s,20,"to")); // starting a byte 20 : null
```

Strings can contain a maximum of 2 ^ 29 - 1 characters, `$smake` will raise an exception if this is exceeded.
