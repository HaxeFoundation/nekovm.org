# A Quick Guide to NekoML

NekoML is a high-order functional language with type inference. It can be seen as Neko with a powerful static type system. It is very suitable for complex data structure manipulation, such as is performed by  compilers. NekoML is inspired by OCaml, but walks different ways for some points.

## Types

NekoML comes with several builtin types, and you can define your own types quite easily :

Core types :

```nekoml
1234 : int
1.234 : float
"hello" : string
true : bool
'\n' : char
() : void
```

Tuples :

```nekoml
(1,true) : (int, bool)
("a",(),1.23) : (string, void, float)
```

Union types :

```nekoml
type t {
	A;
	B;
	C : int;
	D : (int , string);
}

A : t;
B : t;
C(0) : t;
D(1,"") : t;
D : int -> string -> t;
```

Records :

```nekoml
type t {
	x : int;
	y : int;
}

{ x = 1; y = 2 } : t
```

Mutable record fields :

```nekoml
type t {
	mutable counter : int;
}

var x = { counter = 0 };
x.counter := 1;
```

Abstract types :

```nekoml
type t
```

Recursive types :

```nekoml
type t1 // declare as abstract

type t2 {
	A : t1;
	B : t2;
}

type t1 { // declare
	C : t1;
	D : t2;
}
```

Parametrized types :

```nekoml
type ('a,'b) pair {
	fst : 'a;
	snd : 'b;
}
```

Function Types :

```nekoml
function() { } : void -> void;
function(x,y) { x + y } : int -> int -> int
```

Lists :

```nekoml
[1; 2; 3] : int list
```

Lists contructors :

```nekoml
[] : 'a list;
0 :: [] : int list;
"a" :: "" :: [] : string list
```

## Syntax

The syntax of NekoML is similar to the syntax of Neko, but with some additional contructs.

Blocks :

```nekoml
{ f(); g(); h() }
```

Variables declaration :

```nekoml
var x = (expr);
```

Conditions :

```nekoml
if (expr) then (expr) [else (expr)]
```

Calls using parenthesis :

```nekoml
f(1,2,3);
g();
h((1,2)); // call with a tuple
```

Calls using spaces :

```nekoml
f 1 2 3;
g ();
h (1,2); // call with a tuple
```

Mixed calls :

```nekoml
f (1,2) g() h (1,2);
// means
f((1,2),g(),h,(1,2));
```

Function declarations : you can declare a function anonymously or with a name to add it to the local scope

```nekoml
var f = function() { ... };
// equivalent to
function f() {
	...
}
```

Recursive functions. When several following functions are declared recursive (using `rec`), they're mutually recursive so they can call each other :

```nekoml
function rec f() {
	g()
}

function rec g() {
	f()
}
```


## More later...

That's all for now since not so much time to write a complete manual. If you're interested by NekoML you can watch the Neko and NekoML compilers sources as well as the NekoML standard library which are on the Neko CVS. You can also ask on the Neko mailing list.