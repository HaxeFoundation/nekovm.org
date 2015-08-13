import ufront.MVC;
import NekoApi;

@viewFolder("/")
class NekoSite extends Controller {

	// Site initialisation

	static var ufApp:UfrontApplication;

	static function main() {

		#if server
			// Initialise the app on the server and execute the request.
			var ufApp = new UfrontApplication({
				indexController: NekoSite,
				remotingApi: NekoRemotingContext,
				defaultLayout: "layout.html"
			});
			ufApp.executeRequest();
			ufApp.useModNekoCache();
		#elseif client
			// Initialise the app on the client and respond to "pushstate" requests as a single-page-app.
			var clientApp = new ClientJsApplication({
				indexController: NekoSite,
				defaultLayout: "layout.html"
			});
			clientApp.listen();
		#end
	}

	// Main controller

	@inject public var nekoApi:AsyncNekoApi;

	@:route("/sitemap/")
	public function sitemap() {
		var pvr = new PartialViewResult({}, "page.html");
		return nekoApi.getSitemap() >> function( sitemap:Sitemap ):ViewResult {
			var ul = sitemapToList( sitemap );
			return pvr.setVars({
				title: "Sitemap",
				content: '<h1>Sitemap</h1>'+ul,
				currentYear: Date.now().getFullYear(),
				editLink: 'https://github.com/HaxeFoundation/nekovm.org/blob/master/www/pages/',
			});
		}
	}

	function sitemapToList( sitemap:Sitemap ):String {
		var buf = new StringBuf();
		buf.add( '<ul class="sitemap">' );
		for ( link in sitemap ) {
			buf.add( '<li>' );
			var label = (link.link!=null) ? '<a href="${link.link}" rel="pushstate">${link.name}</a>' : '${link.name}';
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
		var pvr = new PartialViewResult( {}, "page.html" );
		return nekoApi.getApi( name ) >> function( page:Page ):ViewResult {
			pvr.setVars( page );
			pvr.setVar( "currentYear", Date.now().getFullYear() );
			pvr.setVar( "editLink", 'https://github.com/HaxeFoundation/nekovm.org/blob/master/www/api/$name.xml' );
			return pvr;
		};
	}

	@:route("/*")
	public function page( rest:Array<String> ) {
		var pageName = (rest.length>0) ? rest.join("/") : "index";
		var pvr = new PartialViewResult({});
		return nekoApi.getPage( pageName ) >> function( page:Page ):ViewResult {
			pvr.setVars( page );
			pvr.setVar( "currentYear", Date.now().getFullYear() );
			pvr.setVar( "editLink", 'https://github.com/HaxeFoundation/nekovm.org/blob/master/www/pages/$pageName.md' );
			return pvr;
		};
	}
}
