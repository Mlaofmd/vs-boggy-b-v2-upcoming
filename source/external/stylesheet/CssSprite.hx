package external.stylesheet;

import flixel.math.FlxPoint;

using StringTools;

class CssSprite {
	public var tag:String = "";
	public var width:Int = 0;
	public var height:Int = 0;
	public var background_position:FlxPoint = FlxPoint.get();

	public function new(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0, tag:String) {
		this.tag = tag;
		this.width = width;
		this.height = height;
		background_position.set(x, y); 
	}
}