package generators;

import haxe.io.Path;
import tink.template.Html;

using StringTools;

class Pages {

	public static function generate () {
		Sys.println("Generating pages ...");

		// Normal pages
		for (i in Utils.listDirectoryRecursive(Config.pagesPath)) {
			var path = i.split("/");
			path.shift();
			var folder = path.length > 1 ? path.shift() : "/";
			var file = path.join("/");

			var inPath = Path.join([Config.pagesPath, folder, file]);
			var sitepage = SiteMap.pageForUrl(folder + "/" + file, false, false);
			var content = Utils.readContentFile(inPath);
			var editLink = Config.baseEditLink + inPath;

			genPage(folder, sitepage, content, file, editLink);
		}
	}

	static function genPage (folder, sitepage:SiteMap.SitePage, content, file, editLink) {
		if (sitepage != null) { // Not top level
			if (sitepage.title.startsWith("Specification")) {
				content = Views.Spec(new Html(content));
			}
			else if (sitepage.title.startsWith("API")) {
				content = Views.API(new Html(content));
			}
			else if (sitepage.title.startsWith("Documentation")) {
				content = Views.Documentation(new Html(content));
			}
		}

		Utils.save(Path.join([Config.outputFolder, folder, file]), content, sitepage, editLink);
	}
}
