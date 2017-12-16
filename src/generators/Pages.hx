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

	static function genPage (folder:String, sitepage:SiteMap.SitePage, content:String, file:String, editLink:String) {
		if ((folder == "doc" && file.indexOf("/") == -1) || file == "faq.md" || file == "news.md" || folder == "specs") {
			content = addAnchors(content);
		}

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

	static function addAnchors (content:String) : String {
		var xml = Xml.parse(content);
		processNode(xml);
		return xml.toString();
	}

	static function processNode (xml:Xml) {
		if (xml.nodeType == Xml.Element) {
			switch (xml.nodeName) {
				case "h2", "h3", "h4", "h5", "h6":
					var bookmarkID = getText(xml).toLowerCase().replace(" ", "-").replace("\"", "");
					var link = Xml.parse('<a id="$bookmarkID" class="anch" />').firstElement();
					var h = Xml.parse('<${xml.nodeName}><a href="#$bookmarkID"></a></${xml.nodeName}>').firstElement();
					for (child in xml) {
						h.firstElement().addChild(child);
					}
					insertBefore(link, xml);
					insertBefore(h, xml);
					xml.parent.removeChild(xml);

				default:
					processChildren(xml);
			}
		}

		if (xml.nodeType == Xml.Document) {
			processChildren(xml);
		}
	}

	static function getText (xml:Xml) : String {
		var text = "";

		if (xml.nodeType == Xml.Element) {
			for (child in xml) {
				text += getText(child);
			}
		} else {
			text += xml.nodeValue;
		}

		return text;
	}

	static function insertBefore (xml:Xml, before:Xml) {
		var siblings = [for (n in before.parent) n];
		before.parent.insertChild(xml, siblings.indexOf(before));
	}

	static function processChildren (xml:Xml) {
		var children = [for (n in xml) n];

		for (element in children) {
			processNode(element);
		}
	}
}
