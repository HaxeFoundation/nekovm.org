import ufront.*;
import ufront.web.*;
import ufront.api.*;
import sys.FileSystem;
import sys.io.File;
using Detox;
using StringTools;
using haxe.io.Path;
using Lambda;

class NekoApi extends UFApi {
	@inject("scriptDirectory") public var scriptDir:String;

	/** Load a markdown page, convert to HTML, extract the document title and table of contents. **/
	public function getPage( fileName:String ):Page {
		var file = scriptDir + "pages/" + fileName + ".md";
		if ( FileSystem.exists(file) ) {
			var md = File.getContent( file );
			var data = PageProcessor.processMarkdown( md );
			return {
				title: (data.title!=null) ? data.title : fileName,
				content: data.content.html(),
				toc: data.toc.html()
			}
		}
		else return throw HttpError.pageNotFound();
	}

	/** Load some API XML, convert to HTML, extract the document title, description, and build table of contents. **/
	public function getApi( fileName:String ):Page {
		var file = scriptDir + "pages/doc/view/" + fileName + ".xml";
		if ( FileSystem.exists(file) ) {
			var xml = File.getContent( file );
			var data = PageProcessor.processHtml( xml );
			return {
				title: (data.title!=null) ? data.title : fileName,
				content: data.content.html(),
				toc: data.toc.html()
			}
		}
		else return throw HttpError.pageNotFound();
	}

	public function getSitemap():Sitemap {
		return getSitemapForDir( scriptDir + "pages" );
	}

	function getSitemapForDir( dir:String, ?prefix:String="" ):Sitemap {
		var sitemap:Sitemap = [];
		for ( fileName in FileSystem.readDirectory(dir) ) {
			var ext = fileName.extension();
			var name = fileName.withoutExtension();
			var url = '$prefix/$name';
			var filePath = dir.addTrailingSlash() + fileName;
			var isDir = FileSystem.isDirectory( filePath );

			var link = sitemap.find(function(l) return l.name==name);
			if ( link==null && (isDir || ext=="md" || ext=="xml") ) {
				link = { name:name, link:null, children:null };
				sitemap.push( link );
			}

			if ( isDir )
				link.children = getSitemapForDir( filePath, url );
			else if ( link!=null )
				link.link = url;
		}

		sitemap.sort(function(l1,l2) return Reflect.compare(l1.name,l2.name));

		return sitemap;
	}
}
class AsyncNekoApi extends UFAsyncApi<NekoApi> {}

typedef Page = {
	title:String,
	content:String,
	toc:String
}
typedef Sitemap = Array<{
    name:String,
    link:Null<String>,
    children:Null<Sitemap>
}>
