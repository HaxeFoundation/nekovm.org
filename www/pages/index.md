<div class="col-3">
<h1>The Neko Programming Language</h1>

Neko is a high-level dynamically typed programming language. It can be used as an embedded scripting language. It has been designed to provide a common runtime for several different languages. Learning and using Neko is very easy. You can easily extend the language with C libraries. You can also write generators from your own language to Neko and then use the Neko Runtime to compile, run, and access existing libraries.

If you need to add a scripting language to your application, Neko provides the best tradeoff between simplicity, extensibility and speed.

Neko is also a good way for language designers to focus on design and reuse a fast and well-designed runtime, as well as existing libraries for accessing filesystem, network, databases, xml...

See <a href="/specs">Neko Specifications...</a>

</div><div class="col-3">

<h1>The Neko Virtual Machine</h1>

Neko has a compiler and a virtual machine. The Virtual Machine is both very lightweight and well optimized, so it can run very quickly. The VM can be easily embedded into any application and your libraries can be accessed using the C foreign function interface.

The compiler converts a source .neko file into a bytecode .n file that can be executed using the Virtual Machine. The compiler is written in Neko itself, and is still very fast. You can use the compiler as standalone command line executable separate from the VM, or as a Neko library to perform compile-and-run funtions for interactive languages.

See <a href="/doc/vm">NekoVM Documentation...</a>

</div><div class="col-3">
<h1>Mod_neko</h1>

Neko comes with several libraries. One of these is mod_neko, which embeds the Neko Virtual Machine into an Apache web server, so you can use Neko to generate webpages. This website is actually generated using Neko.

See <a href="/doc/mod_neko">Introduction to mod_neko</a>

</div>

<h3>About</h3>

Neko is developed as part of the Research and Development effort for better languages at Motion-Twin. You can contact the Neko author Nicolas Cannasse (ncannasse _at_ gmail.com) for more information. Neko is free software and the full source code is available under the MIT License. You're also welcome to join the <a href="/ml">mailing list</a>
