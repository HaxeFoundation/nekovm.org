# An Introduction to Mod_neko

Mod_neko is an Apache *module* for Neko. This means it's possible to run Neko programs on the server side in order to serve web pages using Apache. Here's a step-by-step tutorial on how to configure and use Mod_neko.

## Quick configuration

If you don't have `mod_neko` compiled or you don't want to setup Apache, you can use a `mod_neko` emulator by using the Neko Web Server. This is a very small web server that is running locally for development purposes only. It mimics the same [API](/doc/view/cgi) as `mod_neko`, so you can use that instead.

In order to start the server, simply run the following command :

```bash
nekotools server
```

This should start the local server, by default, on the `localhost` on port `2000` so you can browse the configuration page by visiting <http://localhost:2000/server:config>. Change the server base path to your website directory and you can start browsing it. If it contains `.n` Neko bytecode files, they will be loaded and executed just like Apache `mod_neko` is doing.


## Linux Installation

### Debian / Ubuntu
It's recommended to first setup the prerequisites in order to build the neko vm and its extensions. The following packages are needed:
* apache2-threaded-dev: For Apache module libraries such as mod_neko and mod_tora
* libmysqlclient15-dev: For building the Mysql client library
* libpcre3-dev: For building the regular expression library
* libgc-dev: For the garbage collector of the neko vm
* libgtk2.0-dev: For the GTK bindings

#### Install Requirements
Download all the needed system packages

`$ sudo apt-get install apache2 apache2-threaded-dev libmysqlclient15-dev libpcre3-dev libgc-dev libgtk2.0-dev`

#### Install nekovm and apache extensions

The following script downloads the official NekoVM release, compiles the C sources and installs it on your system. Alternatively, if you want to work with the latest features you can checkout the sources from CVS.

**Install script**

Shellscript for the complete build and install process. 
1. Copy the contents into a shell script, like "installneko.sh"
2. Decide if you want to download the release or checkout from CVS
3. make it executable: sudo chmod 0755 installneko.sh
3. run it: sudo ./installneko.sh (It's important that you run the script as root with sudo)

```
#!/bin/sh

# Build the neko VM
# =================
# Important: run the script as root with "sudo ./installneko.sh"

# ------- User Configuration BEGIN -----------

# $RELEASE: release or cvs?
# 
# - If you want to build neko with a official release you have to define the
# release version 
# - If you want to build neko from CVS you have to comment out the following
# line

RELEASE="neko-1.8.2"

# -------- User Configuration END ------------



mkdir -p /usr/local/src && cd /usr/local/src
rm -rf /usr/local/src/neko*
rm -rf /usr/local/neko
rm -rf /usr/local/bin/neko*

if [ $RELEASE ]; then
    wget "http://nekovm.org/_media/$RELEASE.tar.gz"
    tar xfvz $RELEASE.tar.gz
    cd $RELEASE
else
    #cvs -d:pserver:anonymous@cvs.motion-twin.com:/cvsroot login
    #cvs -d:pserver:anonymous@cvs.motion-twin.com:/cvsroot co neko
    svn co http://nekovm.googlecode.com/svn/trunk neko
    cd neko
fi

# build neko
make

# install neko
mkdir /usr/local/neko
cp bin/* /usr/local/neko
ln -s /usr/local/neko/neko* /usr/local/bin/
ln -s /usr/local/neko/libneko.so /usr/local/lib


# may be required if /usr/local/lib is not in your library search path
grep "/usr/local/lib" /etc/ld.so.conf || echo "/usr/local/lib" >> /etc/ld.so.conf
ldconfig

# setup environment variables for neko
grep "NEKOPATH" /etc/environment || echo "export NEKOPATH=/usr/local/neko" >> /etc/environment
```

Quick notes about building Neko:
* The build script will also build mod_neko (and mod_tora) so you will be prompted to choose to target apache 1.3 or apache 2. Please read the following section for more information.
* Since subshell () is used in the Neko Makefile, you may get a segfault from bash because of insufficient stack. To avoid this problem, you can increase the stack size by 'ulimit -s 20000'.
* If you are not using gcc or an earlier gcc version, the option -fno-stack-protector may not be recognized. All you need to do is to removed it from the Neko Makefile. (Also comment it out in src/tools/neko.install, line 82 and 83).

### mod_neko
Compiling mod_neko is currently only compatible with Apache 2.2.x or Apache 1.3.

#### DEAPI Workaround (Apache 1.3.x only?)**

If you are using 1.3.34 you may need to do this.
You'll have to make an modification to neko/src/tools/install.neko (this is the workaround): Add -DEAPI to the list of cflags around line 75.

**Apache 1.3.x**
If you instead installed Apache2 DON’T FOLLOW THIS.

```
Compiling mod_neko...
The file httpd.h provided when installing Apache 1.3.x was not found
Please enter a valid include path to look for it
Or 's' to skip this library
>/usr/include/apache-1.3
```

**Apache 2.2.x**
```Compiling mod_neko...
The file httpd.h provided when installing Apache 1.3.x was not found
Please enter a valid include path to look for it
Or 's' to skip this library
> s
Compiling mod_neko2...
```

Now let's install it and run ldconfig for good measure.
```
$ sudo make install
$ sudo ldconfig
```
#### Apache 1.3 Configuration

Possibly inaccurate:
* add LoadModule neko_module /usr/local/lib/neko/mod_neko.ndll
* add AddModule mod_neko.c
* add AddHandler neko-handler .n
* add index.n to the list of DirectoryIndex
	
#### Apache 2 Configuration
```
\# add NEKOPATH variable to apache2 environment vars
sudo grep "NEKOPATH" /etc/apache2/envvars || echo "export NEKOPATH=/usr/local/neko" >> /etc/apache2/envvars

\# create a neko.conf in available modules
sudo test -f /etc/apache2/mods-available/neko.conf || echo "AddHandler neko-handler .n" >> /etc/apache2/mods-available/neko.conf

\# create a neko.load in available modules
sudo test -f /etc/apache2/mods-available/neko.load || echo "LoadModule neko_module /usr/local/neko/mod_neko2.ndll" >> /etc/apache2/mods-available/neko.load

\# enable neko module
sudo ln -s /etc/apache2/mods-available/neko.* /etc/apache2/mods-enabled

\# add index.n to DirectoryIndex in dir.conf
sudo grep "index.n" /etc/apache2/mods-available/dir.conf || cat /etc/apache2/mods-available/dir.conf | sed -r 's/DirectoryIndex (.*?)/DirectoryIndex index.n \1/' > dir.conf.tmp && cp dir.conf.tmp /etc/apache2/mods-available/dir.conf 
sudo test -f dir.conf.tmp && rm dir.conf.tmp

\# restart apache2
/etc/init.d/apache2 restart
```

### Neko from backports.org

Download and install neko from [Debian Backports](http://backports.org/Instructions/)


## Apache configuration

If you want to use Apache with `mod_neko`, once Neko is correctly configured, you can edit your Apache configuration `httpd.conf` in order to add `mod_neko`. Each statement must be added to a single line in the proper place in the Apache configuration file :


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

Compile this file (`nekoc hello.neko`) and place the `.n` file into your web directory so it can be accessed by Apache. Browsing it using your [favorite](http://browsehappy.com/) web browser should display the message.

Now let's try to print the HTTP parameters that are passed to the script, using the `mod_neko` API :

```neko
get_params = $loader.loadprim("mod_neko@get_params",0);
// $loader.loadprim("mod_neko2@get_params",0) for mod_neko2.ndll module
$print("PARAMS = "+get_params());
```

Don't forget to compile in order to update the `.n` file before browsing your script. You can now set HTTP parameters `(your URL)?p1=v1;p2=v2....` and see them displayed on your web page.


## Script versus Application

Since Neko is separated into two different phases: *compile* and *run*, you cannot directly see the modifications you're making to your script since you need to compile first. This has several advantages :

- it runs faster

- the syntax is checked at compile-time before you browse the page

	- you don't need to have *sources* on the server; having only binaries is ok
	- you can run your module in *application mode* (see below).

Right now, however, every time a request is made by the browser, Mod_neko is loading the module and executing it. If you have a very big script it might take some time (although it's already faster than other web scripting languages).

The idea of running in *Application Mode* is to have an initialization phase for your script that will create objects, load libraries, initialize global data, and then setup an *entry point* which will be the function called for every request. Here's a small sample :

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
