import sys.FileSystem;

class Main {

	public static function main () {
		Sys.println("== nekovm.org generation ==");
		Sys.println('Output folder: "${Config.outputFolder}"');
		var start = Date.now().getTime();

		// Make sure the output folder exists
		if (!FileSystem.exists(Config.outputFolder)) {
			FileSystem.createDirectory(Config.outputFolder);
		}

		// Generating the content
		SiteMap.init();
		generators.Assets.generate();
		generators.Pages.generate();
		generators.Redirections.generate();

		var end = Date.now().getTime();
		Sys.println('Generation complete, time ${(end - start)/1000}s');
	}

}
