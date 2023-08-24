package external.stylesheet;

using StringTools;

class CssParser {
	public var sprites:Map<String, CssSprite> = [];

	private var curlyOpened:Bool = false;
	private var lastSprite:String = null;

	public function new(css:String) {
		css = css.replace("\n", " ").replace("  ", " ").replace("\t", "").replace(";", "");

		var words:Array<String> = css.split(" ");
		for (i in 0...words.length) {
			var word:String = words[i];

			if (word.startsWith(".sprite-")) {
				lastSprite = word.replace(".sprite-", "");
				sprites.set(lastSprite, new CssSprite());
			}
			else if (word == "{")
				curlyOpened = true;
			else if (word == "}") {
				if (!curlyOpened) {
					trace("Error on CSS! Unexpected }");
					return;
				} else {
					curlyOpened = false;
					lastSprite = null;
				}
			} else if (word == "width:") {
				if (lastSprite == null && curlyOpened) {
					trace("Error on CSS! Unknown Identifier: width. Word: " + i);
					return;
				} else
					sprites[lastSprite].width = Std.parseInt(words[i + 1].replace("px", ""));
			} else if (word == "height:") {
				if (lastSprite == null && curlyOpened) {
					trace("Error on CSS! Unknown Identifier: height. Word: " + i);
					return;
				} else
					sprites[lastSprite].height = Std.parseInt(words[i + 1].replace("px", ""));
			} else if (word == "background-position:") {
				if (lastSprite == null && curlyOpened) {
					trace("Error on CSS! Unknown Identifier: background-position. Word: " + i);
					return;
				} else
					sprites[lastSprite].background_position.set(Std.parseInt(words[i + 1].replace("px", "")) * -1, Std.parseInt(words[i + 2].replace("px", "")) * -1);
			}
		}

		for (key => value in sprites) {
			trace(key + ": " + haxe.Json.stringify(value));
		}
	}
}