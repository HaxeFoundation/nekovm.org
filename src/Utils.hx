import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import tink.template.Html;
import Config.*;

using StringTools;

class Utils {

	public static function listDirectoryRecursive (path:String) : Array<String> {
		var list = [];

		for (entry in FileSystem.readDirectory(path)) {
			var entryPath = Path.join([path, entry]);

			if (FileSystem.isDirectory(entryPath)) {
				list = list.concat(listDirectoryRecursive(entryPath));
			} else {
				list.push(entryPath);
			}
		}

		return list;
	}

	public static function readContentFile (path:String) : String {
		var content = File.getContent(path);

		switch (Path.extension(path)) {
			case "md":
				content = Markdown.markdownToHtml(content);

			default:
		}

		return content;
	}

	public static function save(outPath:String, content:String, current:SiteMap.SitePage, editLink:String, title:String = null, description:String = null) {
		var canonical = outPath;
		switch (Path.extension(outPath)) {
			case "md":
				if (outPath == 'index.md') {
					outPath = 'index.html';
					canonical = root;
				}
				else {
					canonical = Path.withoutExtension(outPath);
					outPath = canonical + "/index.html";
				}

			case "xml":
				canonical = Path.withoutExtension(outPath);
				outPath = canonical + "/index.html";

			default:
		}

		outPath = Path.join([outputFolder, outPath]);
		canonical = Path.join([root, canonical]);

		var dir = Path.directory(outPath);
		if (!FileSystem.exists(dir)) {
			FileSystem.createDirectory(dir);
		}
		File.saveContent(outPath, Views.Layout(
			current != null ? current.title : title,
			description != null ? description : Config.description,
			new Html(content),
			Std.string(Date.now().getFullYear()),
			current != null && current.editLink != null ? current.editLink : editLink,
			canonical
		));
	}

	public static function copy (src:String, dest:String) {
		var dir = Path.directory(dest);
		if (!FileSystem.exists(dir)) {
			FileSystem.createDirectory(dir);
		}

		File.copy(src, dest);
	}

	public static function urlNormalize (url:String, mdToHtml:Bool = true) : String {
		url = url.replace("//", "/");

		if (url.startsWith(Config.outputFolder)) {
			url = url.substr(Config.outputFolder.length);
		}

		if (url.endsWith(Config.index)) {
			url = Path.directory(url);
		}

		if (Path.extension(url) == "" && url.charAt(url.length - 1) != "/") {
			url = url + "/";
		}

		if (mdToHtml && Path.extension(url) == "md") {
			url = Path.withoutExtension(url) + ".html";
		}

		if (url.charAt(0) != "/") {
			url = "/" + url;
		}

		if (new Path(url).file == "" && url.charAt(url.length - 1) != "/") {
			url = url + "/";
		}

		return url;
	}

}
