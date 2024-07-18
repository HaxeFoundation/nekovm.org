import haxe.macro.Compiler;

class Config {

	public static inline var activeClass : String = "active";
	public static inline var apiPath : String = "api";
	public static inline var baseEditLink : String = "https://github.com/HaxeFoundation/nekovm.org/tree/master/";
	public static inline var description : String = "Neko is a high-level dynamically typed programming language.";
	public static inline var index : String = "index.html";
	public static inline var pagesPath : String = "pages";
	public static inline var sitemapDividerUrl : String = "#divider";

	public static var outputFolder : String = {
		if (Compiler.getDefine("out") != null) {
			Compiler.getDefine("out");
		} else {
			env("GHP_HTMLDIR",  "out");
		}
	};

	static public var root = env("GHP_ROOT", null);

	static public function env(name:String, def:String):String {
		return switch(Sys.getEnv(name)) {
			case null:
				def;
			case v:
				v;
		}
	}
}
