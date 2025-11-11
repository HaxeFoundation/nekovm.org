# Downloads

The following downloads are currently available :

- Neko 2.4.1 [sources TGZ](https://github.com/HaxeFoundation/neko/archive/v2-4-1.tar.gz)
- Neko 2.4.1 [sources ZIP](https://github.com/HaxeFoundation/neko/archive/v2-4-1.zip)
- Neko 2.4.1 [Windows x86 32-bit binaries](https://github.com/HaxeFoundation/neko/releases/download/v2-4-1/neko-2.4.1-win.zip)
- Neko 2.4.1 [Windows x86 64-bit binaries](https://github.com/HaxeFoundation/neko/releases/download/v2-4-1/neko-2.4.1-win64.zip)
- Neko 2.4.1 [Linux x86 64-bit binaries](https://github.com/HaxeFoundation/neko/releases/download/v2-4-1/neko-2.4.1-linux64.tar.gz)
- Neko 2.4.1 [Linux Arm 64-bit binaries](https://github.com/HaxeFoundation/neko/releases/download/v2-4-1/neko-2.4.1-linux-arm64.tar.gz)
- Neko 2.4.1 [OS X x86 64-bit binaries](https://github.com/HaxeFoundation/neko/releases/download/v2-4-1/neko-2.4.1-osx64.tar.gz)
- Neko 2.4.1 [OS X Arm 64-bit binaries](https://github.com/HaxeFoundation/neko/releases/download/v2-4-1/neko-2.4.1-osx-arm64.tar.gz)
- Neko 2.4.1 [OS X Universal binaries](https://github.com/HaxeFoundation/neko/releases/download/v2-4-1/neko-2.4.1-osx-universal.tar.gz)

You can access Neko sources from the [GitHub Repository](https://github.com/HaxeFoundation/neko).

## Snapshot Builds

### Windows

Compiled binaries can be found in the "artifacts" tab of each [GitHub Actions build](https://github.com/HaxeFoundation/neko/actions/workflows/main.yml).

### Mac

Neko snapshot of the latest master branch can be built using [homebrew](http://brew.sh/) in a single command: `brew install neko --HEAD`. It will install required dependencies, build, and install Neko to the system. The binaries can be found at `brew --prefix neko`.

Use `brew reinstall neko --HEAD` to upgrade in the future.

### Linux

Ubuntu users can use the [Haxe Foundation snapshots PPA](https://launchpad.net/~haxe/+archive/ubuntu/snapshots) to install a Neko package built from the latest master branch. To do so, run the commands as follows:
```
sudo add-apt-repository ppa:haxe/snapshots -y
sudo apt-get update
sudo apt-get install neko -y
```

Users of other Linux/FreeBSD distributions should build Neko from source. See [README.md](https://github.com/HaxeFoundation/neko/blob/master/README.md#build-instruction) for additional instructions.
