# Arrays

Array is a type. This means that Neko arrays (as well as Neko strings and booleans) are not objects. If in your language's arrays are objects, then you can write an object wrapper using an array value to store the data, and match the API of your language.

Creating an array can be done using the `$array` builtin, and accessing an array can be done using the brackets syntax. You can also create an array with a specific size using the `$amake` builtin :

```neko
var a = $amake(0); // empty array
a = $array(1,3,"test"); // array with three values

$print(a[0]); // 1
$print(a[2]); // "test"
$print(a[3]); // null
$print(a["2"]); // exception
```

Arrays are accessed with integer key values, every other key value type will raise an exception. If the integer is in the range of the array bounds (between 0 and `$asize(a) - 1`), then the value returned is the one stored at this index, otherwise, it's `null`. For writing, if a value is written outside the bounds of the array, then the array is not modified. You can get the size of an array using the `$asize` builtin. Arrays are not resizable :

```neko
a = $array(1,2,3);
$print($asize(a)); // prints 3
```

If you want to make a copy of an array or only of a part of an array, there is the `$acopy` and the `$asub` builtins. Please note that `$asub` can't access outside the bounds of the array :

```neko
a = $array(1,2,3,4);
$print( $acopy(a) ); // [1,2,3,4] , a copy can be modified separatly
$print( $asub(a,1,2) ); // [2,3]
$print( $asub(a,3,3) ); // null
$print( $asub(a,-2,3) ); // null
```

There is also a `$ablit` function to copy elements from one array to another :

```neko
a = $array(1,2,3,4);
b = $array(6,7,8);
$ablit(a,1,b,0,2); // copy 2 elements from b+0 to a+1
$print(a); // [1,6,7,4]
```

Arrays can contain a maximum of 2^29 - 1 elements, `$amake` and `$array` will raise an exception if this is exceeded.
