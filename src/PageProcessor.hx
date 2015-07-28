using Detox;
using StringTools;

class PageProcessor {
	public static function processMarkdown( markdown:String ) {
		var html = Markdown.markdownToHtml( markdown );
		return processHtml( html );
	}

	public static function processHtml( html:String ) {
		var dom = html.parse();
		return new PageProcessor( dom ).process();
	}

	var dom:DOMCollection = null;
	var mainTOC:DOMCollection = null;
	var currentIndentLevel:Int = 1;
	var numberOfLinks:Int = 0;
	var currentMenu:DOMCollection = null;
	var currentLink:DOMCollection = null;

	public function new ( dom ) {
		this.dom = dom;
	}

	function process():{ title:String, content:DOMCollection, toc:DOMCollection } {
		var title:String = null;
		mainTOC = newTableOfContents();
		currentMenu = mainTOC;

		for ( child in dom ) if ( child.nodeType==Xml.Element ) {
			switch child.nodeName {
				case "h1":
					addLink( child, 1 );
					if ( title==null )
						title = child.text();
				case "h2": addLink( child, 2 );
				case "h3": addLink( child, 3 );
				case "h4": addLink( child, 4 );
			}
		}

		if ( numberOfLinks<2 )
			mainTOC = null;

		return {
			title: title,
			content: dom,
			toc: mainTOC
		}
	}

	function addLink( headerNode:DOMNode, indent:Int ) {
		var title = headerNode.text();
		numberOfLinks++;

		// Figure out a href for this header.
		var url = title.trim().toLowerCase().replace( " ", "_" );
		url = ~/[^a-z0-9_]/g.replace( url, "" );
		headerNode.setAttr( "id", url );

		this.currentMenu =
			if ( indent>currentIndentLevel ) newTableOfContents( currentLink )
			else if ( indent<currentIndentLevel ) currentMenu.parent().parent()
			else currentMenu;

		this.currentLink = appendLinkToTOC( currentMenu, indent, url, title );
		this.currentIndentLevel = indent;
	}

	function newTableOfContents( ?parentLink:DOMCollection ):DOMCollection {
		return '<ul class="toc"></ul>'.parse().appendTo( parentLink );
	}

	function appendLinkToTOC( toc:DOMCollection, level:Int, link:String, title:String ):DOMCollection {
		var linkHTML = '<li class="level${level}"><span class="li"><a href="#$link">$title</a></span></li>';
		return linkHTML.parse().appendTo( toc );
	}
}
