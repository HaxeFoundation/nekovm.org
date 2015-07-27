====== A Quick Guide to NekoML ======

NekoML is a high-order functional language with type inference. It can be seen as Neko with a powerful static type system. It is very suitable for complex data structure manipulation, such as is performed by  compilers. NekoML is inspired by OCaml, but walks different ways for some points.

===== Types =====

NekoML comes with several builtin types, and you can define your own types quite easily :

Core types :

<code nekoml>
1234 : int
1.234 : float
"hello" : string
true : bool
'\n' : char
() : void
</code>

Tuples :

<code nekoml>
(1,true) : (int, bool)
("a",(),1.23) : (string, void, float)
</code>

Union types :

<code nekoml>
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
</code>

Records :

<code nekoml>
type t {
	x : int;
	y : int;
}

{ x = 1; y = 2 } : t
</code>

Mutable record fields :

<code nekoml>
type t {
	mutable counter : int;
}

var x = { counter = 0 };
x.counter := 1;
</code>

Abstract types :

<code nekoml>
type t
</code>

Recursive types :

<code nekoml>
type t1 // declare as abstract

type t2 {
	A : t1;
	B : t2;
}

type t1 { // declare
	C : t1;
	D : t2;
}
</code>

Parametrized types :

<code nekoml>
type ('a,'b) pair {
	fst : 'a;
	snd : 'b;
}
</code>

Function Types :

<code nekoml>
function() { } : void -> void;
function(x,y) { x + y } : int -> int -> int
</code>

Lists :

<code nekoml>
[1; 2; 3] : int list
</code>

Lists contructors :

<code nekoml>
[] : 'a list;
0 :: [] : int list;
"a" :: "" :: [] : string list
</code>

===== Syntax =====

The syntax of NekoML is similar to the syntax of Neko, but with some additional contructs.

Blocks :

<code nekoml>
{ f(); g(); h() }
</code>

Variables declaration :

<code nekoml>
var x = (expr);
</code>

Conditions :

<code nekoml>
if (expr) then (expr) [else (expr)]
</code>

Calls using parenthesis :

<code nekoml>
f(1,2,3);
g();
h((1,2)); // call with a tuple
</code>

Calls using spaces :

<code nekoml>
f 1 2 3;
g ();
h (1,2); // call with a tuple
</code>

Mixed calls :

<code nekoml>
f (1,2) g() h (1,2);
// means
f((1,2),g(),h,(1,2));
</code>

Function declarations : you can declare a function anonymously or with a name to add it to the local scope

<code nekoml>
var f = function() { ... };
// equivalent to
function f() {
	...
}
</code>

Recursive functions. When several following functions are declared recursive (using ''rec''), they're mutually recursive so they can call each other :

<code nekoml>
function rec f() {
	g()
}

function rec g() {
	f()
}
</code>


===== More later... =====

That's all for now since not so much time to write a complete manual. If you're interested by NekoML you can watch the Neko and NekoML compilers sources as well as the NekoML standard library which are on the Neko CVS. You can also ask on the Neko mailing list.