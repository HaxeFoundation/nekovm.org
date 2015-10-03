# An Introduction to Mod_neko

Mod_neko is an Apache *module* for Neko. This means it's possible to run Neko programs on the server side in order to serve webpages using Apache. Here's a step-by-step tutorial on how to configure and use Mod_neko.

## Quick configuration

If you don't have `mod_neko` compiled or you don't want to setup Apache, you can use a `mod_neko` emulator by using the Neko Web Server. This is a very small web server that is running localy for development purposes only. It mimics the same [API](/doc/view:cgi) as `mod_neko`, so you can use that instead.

In order to start the server, simply run the following command :

```bash
nekotools server
```

This should start the local server, by default, on the `localhost` on port `2000` so you can browse the configuration page by visiting <http://localhost:2000/server:config>. Change the server base path to your website directory and you can start browsing it. If it contains `.n` neko bytecode files, they will be loaded and executed just like Apache `mod_neko` is doing.


## Linux Installation

<http://haxe.org/doc/build/neko_linux>

## Apache configuration

If you want to use Apache with `mod_neko`, once Neko is correctly configured, you can edit your Apache configuration `httpd.conf` in order to add `mod_neko`. Each statement must be added on a single line in the proper place in the Apache configuration file :


- add `LoadModule neko_module (your path to mod_neko.ndll)`
- add `AddModule mod_neko.c`
- add `AddHandler neko-handler .n`
- add `index.n` to the list of `DirectoryIndex`

Now that you're done, you can restart Apache to check that Mod_neko is correctly loaded. If you have some problem, try to check that Neko is correctly configured.



## Some tests

Now you can simply edit a Neko file and print some welcome message :

```neko
$print("Hello Mod_neko !");
```

Compile this file (`nekoc hello.neko`) and place the `.n` file into your web directory so it can be accessed by Apache. Browsing it using your [favorite](http://www.getfirefox.com) webbrowser should display the message.

Now let's try to print the HTTP parameters that are passed to the script, using the `mod_neko` API :

```neko
get_params = $loader.loadprim("mod_neko@get_params",0);
// $loader.loadprim("mod_neko2@get_params",0) for mod_neko2.ndll module
$print("PARAMS = "+get_params());
```

Don't forget to compile in order to update the `.n` file before browsing your script. You can now set HTTP parameters `(your url)?p1=v1;p2=v2....` and see them displayed on your web page.


## Script versus Application

Since Neko is separated into two different phases: *compile* and *run*, you cannot directly see the modifications you're making to your script since you need to compile first. This have several advantages :

- it runs faster

- syntax is checked at compile-time, before you browse the page

	- you don't need to have *sources* on the server, binaries only is ok
	- you can run your module in *application mode* (see below).

Right now, however, everytime a request is made by the browser, Mod_neko is loading the module and executing it. If you have a very big script it might take some time (although it's already faster than other web scripting languages).

The idea of running in *Application Mode* is to have an initialization phase for your script that will create objects, load libraries, initialize global datas, and then setup an *entry point* which will be the function called for every request. Here's a small sample :

```neko
$print("Initializing...");

// this is the entry point
entry = function() {
	$print("Main...");
}

// setup the entry point
set_main = $loader.loadprim("mod_neko@cgi_set_main",1);
set_main(entry);

// call it the first time as well
entry();
```

Now after compiling, if you browse this page, it should display `Initializing... Main...` the first time and then `Main...` for every refresh. It means that you can initialize a lot of things at loading time and store values into globals that will be persistent between calls.

If you recompile, this will change the timestamp of the `.n` file so it will reload and initialize it again. This means that you should be able to reload everything you need at loading time.
