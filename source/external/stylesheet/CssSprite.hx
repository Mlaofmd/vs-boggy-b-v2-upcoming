package external.stylesheet;

import flixel.math.FlxPoint;

using StringTools;

class CssSprite {
	public var width:Int = 0;
	public var height:Int = 0;
	public var background_position:FlxPoint = new FlxPoint();

	public function new(width:Int = 0, height:Int = 0, background_position:FlxPoint = null) {
		this.width = width;
		this.height = height;
		if (background_position != null)
			this.background_position = background_position;
	}
}