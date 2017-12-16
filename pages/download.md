# Downloads

The following downloads are currently available :

- Neko 2.1.0 [sources TGZ](media/neko-2.1.0-src.tar.gz)
- Neko 2.1.0 [sources ZIP](media/neko-2.1.0-src.zip)
- Neko 2.1.0 [Windows binaries](media/neko-2.1.0-win.zip)
- Neko 2.1.0 [Linux binaries](media/neko-2.1.0-linux.tar.gz)
- Neko 2.1.0 [Linux 64-bit binaries](media/neko-2.1.0-linux64.tar.gz)
- Neko 2.1.0 [OS X 64-bit binaries](media/neko-2.1.0-osx64.tar.gz)

You can access Neko sources from the [GitHub Repository](https://github.com/HaxeFoundation/neko).

# Snapshot Builds

## Windows

Compiled binaries can be found in the "artifacts" tab of each [AppVeyor build](https://ci.appveyor.com/project/HaxeFoundation/neko/history).

## Mac

Neko snapshot of the latest master branch can be built using [homebrew](http://brew.sh/) in a single command: `brew install neko --HEAD`. It will install required dependencies, build, and install Neko to the system. The binaries can be found at `brew --prefix neko`.

Use `brew reinstall neko --HEAD` to upgrade in the future.

## Linux

Ubuntu users can use the [Haxe Foundation snapshots PPA](https://launchpad.net/~haxe/+archive/ubuntu/snapshots) to install a Neko package built from the latest master branch. To do so, run the commands as follows:
```
sudo add-apt-repository ppa:haxe/snapshots -y
sudo apt-get update
sudo apt-get install neko -y
```

Users of other Linux/FreeBSD distributions should build Neko from source. See [README.md](https://github.com/HaxeFoundation/neko/blob/master/README.md#build-instruction) for additional instructions.
