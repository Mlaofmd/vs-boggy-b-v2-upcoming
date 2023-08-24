package external.stylesheet;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.utils.Assets;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class CssAtlasFrames {
    public static function build(path:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Paths.image(path));
		var description:String = null;
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
		
		var css:CssParser = new CssParser(description);
		for (key => value in css.sprites) {
			var rect:FlxRect = new FlxRect(value.background_position.x, value.background_position.y, value.width, value.height);
			frames.addAtlasFrame(rect, new FlxPoint(rect.width, rect.height), new FlxPoint(), key, 0);
		}

		return frames;
	}
}