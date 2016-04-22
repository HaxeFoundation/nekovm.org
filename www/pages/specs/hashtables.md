# Hashtables

There is a set of builtins that are useful for using Hashtables. A hashtable is not a basic type, but an *abstract* type. It can then only be manipulated using the following builtins :

- `$hnew(size)` : create a new hashtable having initialy `size` slots.
- `$hadd(h,k,v)` : add the value `v` with key `k` to the hashtable. Please note that `k` can be any Neko value, even recursive.
- `$hset(h,k,v,cmp)` : set the value of the key `k` to `v`. The previous binding is replaced if the `cmp` function between keys returns 0. If `cmp` is `null`, the default comparison function is used.
- `$hmem(h,k,cmp)` : returns true if a value exists for key `k` in the Hashtable.
- `$hget(h,k,cmp)` : returns the first value bound to key `k` or `null` if not found.
- `$hremove(h,k,cmp)` : removes the first binding of `k`, and returns a boolean indicating the success.
- `$hresize(h,size)` : resize the hashtable. Please note that the size is usually automaticaly handled.
- `$hsize(h)` : returns the size of the hashtable.
- `$hcount(h)` : returns the number of bindings in the hashtable.
- `$hiter(h,f)` : calls `f(k,v)` for each binding found in the hashtable.

The hashtable stores the (key, values) couples in one chained list per slot. Adding a new binding with the same key will mask the previous one. The hash function used internally is `$hkey(k)`, which will return a positive Neko integer for any Neko value. The hash function cannot be overridden, but the comparison function between keys can be overridden where it is used.

You can, of course, write your own hashtable implementation using Neko data structures, but using the standard builtin hashtable is better for languages interoperability.
