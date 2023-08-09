package external.stylesheet;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxAtlasFrames;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end
import flixel.FlxG;
import flixel.graphics.FlxGraphic;

using StringTools;

class CssAtlasFrames {
	public static function build(path:String) {
		var graphic:FlxGraphic = FlxG.bitmap.add(Paths.image(path));
		var description:String = "";
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modFolders("images/" + path + ".css")))
			description = File.getContent(Paths.modFolders("images/" + path + ".css"));
		#else
			description = Assets.getText(Paths.getPath("images/" + path + ".css", TEXT));
		#end

		if (graphic == null || description == null)
			return null;

		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		frames = new FlxAtlasFrames(graphic);

		var sprites:Array<CssSprite> = CssParser.getSprites(description);
		for (sprite in sprites) {
			if (sprite.tag != "") {
				var tag:String = sprite.tag;
				var width:Int = sprite.width;
				var height:Int = sprite.height;
				var pos:Array<Float> = [sprite.background_position.x, sprite.background_position.y];

				var region:FlxRect = FlxRect.get(pos[0], pos[1], width, height);
				var offsets:FlxPoint = FlxPoint.get();

				frames.addAtlasFrame(region, FlxPoint.get(region.width, region.height), offsets, tag);
			}
		}

		return frames;
	}
}