import ufront.MVC;
import sys.FileSystem;
import sys.io.File;
using Detox;

@viewFolder("/")
class NekoSite extends Controller {

	// Site initialisation

	static var ufApp:UfrontApplication;

	static function main() {
		ufApp = new UfrontApplication({
			indexController: NekoSite,
			defaultLayout: "layout.html",
		});
		ufApp.useModNekoCache();
		ufApp.executeRequest();
	}

	// Main controller

	@inject public var nekoApi:AsyncNekoApi;

	@:route("/doc/view/$name")
	public function api( name:String ) {
		return 'Showing API documentation for $name';
	}

	@:route("/*")
	public function page( rest:Array<String> ) {
		var pageName = rest.join("/");
		return nekoApi.getPage( pageName ) >> function( page:Page ):ViewResult {
			var view = new ViewResult( page );
			view.setVar( "currentYear", Date.now().getFullYear() );
			return view;
		};
	}
}

typedef Page = {
	title:String,
	content:String,
	toc:String
}

class NekoApi extends UFApi {
	@inject("scriptDirectory") public var scriptDir:String;

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
}
class AsyncNekoApi extends UFAsyncApi<NekoApi> {}
