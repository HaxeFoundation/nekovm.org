import tink.template.Html;

class Views {

	@:template public static function API (content:Html) : Html;
	@:template public static function Documentation (content:Html) : Html;
	@:template public static function Layout (title:String, description:String, viewContent:Html, currentYear:String, editLink:String, canonical:String) : Html;
	@:template public static function Redirection (redirectionLink:String) : Html;
	@:template public static function Spec (content:Html) : Html;

}
