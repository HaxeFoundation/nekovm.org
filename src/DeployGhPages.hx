import Sys.*;
import Config.*;
import sys.io.*;
import sys.FileSystem.*;
import haxe.io.*;
using StringTools;

class DeployGhPages {
	static public function runCommand(cmd:String, args:Array<String>):Void {
		println('run: $cmd $args');
		switch(command(cmd, args)) {
			case 0:
				//pass
			case exitCode:
				exit(exitCode);
		}
	}
	static public function commandOutput(cmd:String, args:Array<String>):String {
		var p = new Process(cmd, args);
		var exitCode = p.exitCode();
		var output = p.stdout.readAll().toString();
		p.close();
		if (exitCode != 0)
			exit(exitCode);
		return output;
	}
	static public function copyRecursive(src:String, dest:String):Void {
		if (isDirectory(src)) {
			createDirectory(dest);
			for (item in readDirectory(src)) {
				var srcPath = Path.join([src, item]);
				var destPath = Path.join([dest, item]);
				copyRecursive(srcPath, destPath);
			}
		} else {
			File.copy(src, dest);
		}
	}
	static public function deleteRecursive(path:String):Void {
		if (!exists(path))
			return;

		if (isDirectory(path)) {
			for (item in readDirectory(path)) {
				deleteRecursive(Path.join([path, item]));
			}
			deleteDirectory(path);
		} else {
			deleteFile(path);
		}
	}

    static function main():Void {
        var root = getCwd();
        var sha = commandOutput("git", ["rev-parse", "HEAD"]).trim();

        setCwd(outputFolder);
        runCommand("git", ["init"]);
        if (username != null)
            runCommand("git", ["config", "--local", "user.name", username]);
        if (email != null)
            runCommand("git", ["config", "--local", "user.email", email]);
        runCommand("git", ["remote", "add", "local", root]);
        runCommand("git", ["remote", "add", "remote", remote]);
        runCommand("git", ["fetch", "--all"]);
        runCommand("git", ["checkout", "--orphan", branch]);
        if (commandOutput("git", ["ls-remote", "--heads", "local", branch]).trim() != "") {
            runCommand("git", ["reset", "--soft", 'local/${branch}']);
        }
        if (commandOutput("git", ["ls-remote", "--heads", "remote", branch]).trim() != "") {
            runCommand("git", ["reset", "--soft", 'remote/${branch}']);
        }
        runCommand("git", ["add", "--all"]);
        runCommand("git", ["commit", "--allow-empty", "--quiet", "-m", 'deploy for ${sha}']);
        runCommand("git", ["push", "local", branch]);

        if (remote == null) {
            println('GHP_REMOTE is not set, skip deploy.');
            return;
        }
        setCwd(root);
        runCommand("git", ["push", remote, branch]);
    }
}