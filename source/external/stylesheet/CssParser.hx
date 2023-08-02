package external.stylesheet;

using StringTools;

class CssParser {
	public static function getSprites(css:String):Array<CssSprite> {
		var sprites:Array<CssSprite> = [];
		for (string in css.replace("\n", "").split(".sprite"))
			sprites.push(new CssSprite(string));

		return sprites;
	}
}