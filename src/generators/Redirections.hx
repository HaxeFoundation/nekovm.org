package generators;

import haxe.io.Path;

class Redirections {

	public static function generate () {
		Sys.println("Generating redirections ...");

		var list =  [
			"/doc/index.html" => "/doc/begin/",
			"/lua/index.html" => "/doc/lua/",
			"/specs/index.html" => "/specs/syntax/"
		];

		for (page in list.keys()) {
			var content = Views.Redirection(list.get(page));

			Utils.save(Path.join([Config.outputFolder, page]), content, null, null);
		}
	}

}
