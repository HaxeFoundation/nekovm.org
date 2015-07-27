import ufront.MVC;

@viewFolder("/")
class NekoSite extends Controller {
	static var ufApp:UfrontApplication;

	static function main() {
		ufApp = new UfrontApplication({
			indexController: NekoSite,
			defaultLayout: "layout.html",
		});
		ufApp.useModNekoCache();
		ufApp.executeRequest();
	}

	@:route("/")
	public function home() {
		return new ViewResult({
			title: "[NekoVM]",
			currentYear: Date.now().getFullYear()
		});
	}
}
