# nekovm.org

[![CI](https://github.com/HaxeFoundation/nekovm.org/actions/workflows/main.yml/badge.svg)](https://github.com/HaxeFoundation/nekovm.org/actions/workflows/main.yml)

This is the code base for the <http://nekovm.org> website.

## Contributing Content

On the website there is a "Contribute" link on the footer of each page. Clicking this link will take you to the relevant file in this repository.

You can then edit using Github's online file editor and submit a pull request. You can also fork the repo and edit on your local machine with your preferred text editor, which may be easier for large integrations.

## Issues, bugs and suggestions

If you find a bug, have an issue, suggestion, or want to contribute in some other way, please use the Github Issue Tracker.

Any bugs we will attempt to address promptly. New content or subjective issues (colours, fonts, marketing material etc) will be considered on a case by case basis.

If you are a designer and want to help freshen up the look of the site, please open an issue or contact <contact@haxe.org>. We'd love your input!

## Running a local copy for development

To run a local copy follow these steps:

* Install the dependencies `haxelib install all` in the root directory.
* Generate the website by running `haxe generate.hxml`.

The website is now available in the `out/` folder, you can launch it any webserver, for instance:

* with neko `nekotools server -d out` and access it at `http://localhost:2000/`.
* with python `cd out/ && python -m SimpleHTTPServer` and access it at `http://localhost:8000/`.

## Deploying updates

Any push or merge to the `master` branch will trigger a github actions workflow to build and deploy to "nekovm.org".
