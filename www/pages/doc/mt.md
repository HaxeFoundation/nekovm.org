# Neko Multithreading

NekoVM support multithreading and multiple VM instances. It means that you can run some Neko code into a multithreaded program, as long as you respect the following guidelines.

- you can allocate a VM with `neko_vm_alloc`. The VM holds the Neko stack and registers.
- a given thread can allocate several VM.
- you can choose the local thread current VM by calling `neko_vm_select(neko_vm *vm)`
- you can retrieve the selected VM for the current thread by calling `neko_vm_current()`
- a single VM should not be used to execute code on several threads at the same time
- a Neko Module can be used by several VM/Threads at the same time

Using some non-basic data structures such as loaders, hashtables or abstracts values (files, regular expressions...) from multiple threads can results in crashes. Try to always keep these data structures in the thread that allocated them in the first place.
