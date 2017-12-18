package generators;

import haxe.io.Path;

class Redirections {

	public static function generate () {
		Sys.println("Generating redirections ...");

		var list =  [
			"/doc/index.html" => "/doc/begin/",
			"/doc/misc/multilang/index.html" => "/doc/multilang/",
			"/lua/index.html" => "/doc/lua/",
			"/specs/index.html" => "/specs/syntax/"
		];

		for (page in list.keys()) {
			var content = Views.Redirection(list.get(page));

			Utils.save(page, content, null, null);
		}
	}

}
