# The Neko Programming Language

Neko is a high-level dynamically typed programming language. It can be used as an embedded scripting language. It has been designed to provide a common runtime for several different languages. Learning and using Neko is very easy. You can easily extend the language with C libraries. You can also write generators from your own language to Neko and then use the Neko Runtime to compile, run, and access existing libraries.

If you need to add a scripting language to your application, Neko provides one of the best tradeoff between simplicity, extensibility and speed.

Neko is also a good way for language designers to focus on design and reuse a fast and well-designed runtime, as well as existing libraries for accessing filesystem, network, databases, xml...

See [Neko Specifications...](/specs)

# The Neko Virtual Machine

Neko has a compiler and a virtual machine. The Virtual Machine is very lightweight and yet well optimized so it is running very quickly. The VM can be easily embedded into any application and your libraries can be accessed using the C foreign function interface.

The compiler converts a source .neko file into a bytecode .n file that can be executed with the Virtual Machine. The compiler is written in Neko itself, and is still very fast. You can use the compiler as standalone command line executable separated from the VM, or as a Neko library to perform compile-and-run for interactive languages.

See [NekoVM Documentation...](/doc/vm)

# Mod_neko

Neko comes with several libraries. One of these is mod_neko, which embeds the Neko Virtual Machine into the Apache web server, so you can use Neko to generate webpages. This website is actually generated using Neko.

See [Introduction to mod_neko...](/doc/mod_neko)


# About

Neko is developed as part of the Research and Development effort for better languages at Motion-Twin. You can contact Neko author Nicolas Cannasse (ncannasse _at_ gmail.com) for more information. Neko is free software and the full source code is available under the MIT License. You're also welcome to join the [mailing list](/ml)
