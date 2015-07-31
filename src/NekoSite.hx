import ufront.*;
import ufront.web.*;
import ufront.api.*;
import NekoApi;

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

	@:route("/sitemap/")
	public function sitemap() {
		return nekoApi.getSitemap() >> function( sitemap:Sitemap ) {
			var ul = sitemapToList( sitemap );
			return new ViewResult({
				title: "Sitemap",
				content: '<h1>Sitemap</h1>'+ul,
				currentYear: Date.now().getFullYear(),
				editLink: 'https://github.com/HaxeFoundation/nekovm.org/blob/master/www/pages/',
			}, "page.html");
		}
	}

	function sitemapToList( sitemap:Sitemap ):String {
		var buf = new StringBuf();
		buf.add( '<ul class="sitemap">' );
		for ( link in sitemap ) {
			buf.add( '<li>' );
			var label = (link.link!=null) ? '<a href="${link.link}">${link.name}</a>' : '${link.name}';
			buf.add( label );
			if ( link.children!=null ) {
				buf.add( sitemapToList(link.children) );
			}
		}
		buf.add( '</ul>' );
		return buf.toString();
	}

	@:route("/doc/view/$name")
	public function api( name:String ) {
		return nekoApi.getApi( name ) >> function( page:Page ):ViewResult {
			var view = new ViewResult( page, "page.html" );
			view.setVar( "currentYear", Date.now().getFullYear() );
			view.setVar( "editLink", 'https://github.com/HaxeFoundation/nekovm.org/blob/master/www/api/$name.xml' );
			return view;
		};
	}

	@:route("/*")
	public function page( rest:Array<String> ) {
		var pageName = (rest.length>0) ? rest.join("/") : "index";
		return nekoApi.getPage( pageName ) >> function( page:Page ):ViewResult {
			var view = new ViewResult( page );
			view.setVar( "currentYear", Date.now().getFullYear() );
			view.setVar( "editLink", 'https://github.com/HaxeFoundation/nekovm.org/blob/master/www/pages/$pageName.md' );
			return view;
		};
	}
}
