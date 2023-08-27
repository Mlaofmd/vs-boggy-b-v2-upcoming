package external.stylesheet;

using StringTools;

class CssParser {
	public var sprites:Map<String, CssSprite> = [];
	public var background_image:String = null;
	public var background_repeat:Dynamic = null;
	public var display:Dynamic = null;

	private var curlyOpened:Bool = false;
	private var lastSprite:String = null;
	private var isInfo:Bool = false;

	public function new(css:String) {
		css = css.replace("\n", " ").replace("\t", "").replace("  ", " ");

		var words:Array<String> = css.split(" ");
		for (i in 0...words.length) {
			var word:String = words[i];

			if (word.startsWith(".sprite-")) {
				if (lastSprite != null) {
					trace("Error on CSS! Unclosed module. Word: " + i);
					return;
				} else {
					lastSprite = word.replace(".sprite-", "");
					sprites.set(lastSprite, new CssSprite());
				}
			} else if (word == ".sprite") {
				isInfo = true;
			} else if (word == "{")
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
				if (lastSprite == null) {
					trace("Error on CSS! Unknown Identifier: width. Word: " + i);
					return;
				} else if (!words[i + 1].endsWith(";")) {
					trace("Error on CSS! Missing ;. Word: " + i + 1);
					return;
				} else
					sprites[lastSprite].width = Std.parseInt(words[i + 1].replace("px", "").replace(";", ""));
			} else if (word == "height:") {
				if (lastSprite == null) {
					trace("Error on CSS! Unknown Identifier: height. Word: " + i);
					return;
				} else if (!words[i + 1].endsWith(";")) {
					trace("Error on CSS! Missing ;. Word: " + i + 1);
					return;
				} else
					sprites[lastSprite].height = Std.parseInt(words[i + 1].replace("px", "").replace(";", ""));
			} else if (word == "background-position:") {
				if (lastSprite == null) {
					trace("Error on CSS! Unknown Identifier: background-position. Word: " + i);
					return;
				} else if (!words[i + 2].endsWith(";")) {
					trace("Error on CSS! Missing ;. Word: " + i + 2);
					return;
				} else
					sprites[lastSprite].background_position.set(Std.parseInt(words[i + 1].replace("px", "")) * -1, Std.parseInt(words[i + 2].replace("px", "")) * -1);
			} else if (word == "background-image:") {
				if (!isInfo) {
					trace("Error on CSS! Unknown Identifier: background-image. Word: " + i);
					return;
				} else if (!words[i + 1].endsWith(";")) {
					trace("Error on CSS! Missing ;. Word: " + i + 1);
					return;
				} else {
					if (words[i + 1].startsWith("\""))
						background_image = words[i + 1].substring(1, words[i + 1].lastIndexOf("\""));
					else if (words[i + 1].startsWith("'"))
						background_image = words[i + 1].substring(1, words[i + 1].lastIndexOf("'"));
				}
			} else if (word == "background-repeat:") {
				if (!isInfo) {
					trace("Error on CSS! Unknown Identifier: background-repeat. Word: " + i);
					return;
				} else if (!words[i + 1].endsWith(";")) {
					trace("Error on CSS! Missing ;. Word: " + i + 1);
					return;
				} else
					background_repeat = words[i + 1].replace(";", "");
			} else if (word == "display:") {
				if (!isInfo) {
					trace("Error on CSS! Unknown Identifier: display. Word: " + i);
					return;
				} else if (!words[i + 1].endsWith(";")) {
					trace("Error on CSS! Missing ;. Word: " + i + 1);
					return;
				} else
					display = words[i + 1].replace(";", "");
			}
		}
	}
}