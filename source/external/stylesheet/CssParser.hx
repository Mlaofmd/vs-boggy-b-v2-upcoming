package external.stylesheet;

using StringTools;

class CssParser {
	public static function getSprites(css:String):Array<CssSprite> {
		var sprites:Array<CssSprite> = [];
		for (string in css.replace("\n", "").replace("  ", " ").split(".sprite")) {
			var tag:String = "";
			var width:Int = 0;
			var height:Int = 0;
			var pos:Array<Int> = [];

			var lines:Array<String> = string.split(";");

			tag = lines[0].substring(1, lines[0].indexOf("{")).trim();
			lines[0] = lines[0].substr(tag.length + 1).trim();

			for (line in lines) {
				var field:String = line.split(":")[0].replace(" ", "").trim();
				var value:String = line.split(":")[1].replace(" ", "").trim();

				switch(field) {
					case "width":
						width = Std.parseInt(value);
					case "height":
						height = Std.parseInt(value);
					case "background-position":
						pos = [Std.parseInt(value.replace("px", "").split(" ")[0]), Std.parseInt(value.replace("px", "").split(" ")[1])];
				}
			}

			sprites.push(new CssSprite(pos[0], pos[1], width, height, tag));
		}

		return sprites;
	}
}