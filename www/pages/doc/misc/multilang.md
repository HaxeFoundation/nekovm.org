====== Language Interoperability ======

A common problem when trying to run several languages on the same virtual machine is to be able to interact between languages. In a perfect world, we would like this to be seamless and transparent. Let's take DotNet as an example. You can call some C# class from your VB.Net program without any problem. This is possible because they both share the same //type system// which is the one specified in DotNet, so it is often said that whatever language you can run on DotNet it will //be// C# since you'll have to match this type system. That's quite true.

===== The Array Problem =====

Neko is trying to reach language interoperability by //data sharing//. One common problem you have when interacting between languages is about Arrays. Every language have arrays, but with different APIs. Some languages can resize the array, some can't. Some languages can modify the array, some can't. Some languages access Arrays with an Object Oriented API, some don't... So how can you pass one array from a language to another ?

One possibility is to have a //super// Array having all these possibilities, that is shared between all languages. That doesn't scale very well since you might have same method name with different behaviors depending on the language.

One other possibility is to be able to convert between arrays, but that doesn't scale well either since you need to add more convertion functions everytime you're supporting a new language.

The Neko way of doing is to provide a common //data representation// of the structure that will be shared between several //language specific APIs//. Because not all APIs are Object Oriented, a Neko array is not an object. Because not all arrays are resizable, a Neko array is not resizable.

Several languages then can share the same //Neko Array Reference// and wrap the datastructure with their own API. The only thing needed is then a generic way to wrap a Neko Array with the Language API, and to retrieve the Neko Array from any Language-specific Array.

===== The Class Problem =====

Neko does not provide a fixed class system. It does not provide then a way to check if an object is of the given class or //implements// an interface. It's up to the language generator designer to choose how they want their class system to be represented with Neko.

In some languages, function calls are typechecked, in some other languages, they are not. By providing a runtime dynamic type system Neko make it more easy for static and dynamicly typed languages to interact together.

As a result, it opens more flexible ways of encoding classes and doing typechecking. It is not particular to any language, so you can roll your own, optimized for your own language way of dealing with classes. And if you don't have classes, even if you don't have objects, Neko is still suitable since it doesn't enforce any specific way of doing.

However this might cause some problems in the way objects are represented at runtime between languages. The preferred way is to use Neko Objects so you can seamlessly interact with other Neko languages.