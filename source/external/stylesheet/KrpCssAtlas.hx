package external.stylesheet;

import flash.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames.TexturePackerObject;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFramesCollection.FlxFrameCollectionType;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxTexturePackerSource;
import openfl.Assets;
import haxe.Json;
import haxe.xml.Access;
import haxe.ds.StringMap;

import flixel.graphics.frames.FlxFramesCollection;

import flixel.FlxG;

using StringTools;


// h4master, sorry za ujastniy cod, ya bil sonnim

class KrpCssAtlas extends FlxFramesCollection
{
    public static function fromCss(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if (graphic == null || Description == null)
			return null;

		frames = new FlxAtlasFrames(graphic);

		if (Assets.exists(Description))
			Description = Assets.getText(Description);

		
        var animations:StringMap<Dynamic> = CSSToJson.convertCSSToJson(Description,false);
		trace(CSSToJson.convertCSSToJson(Description,true));
		for (key in animations.keys()){
			if(key != ".sprite"){
				var _frame = animations.get(key);
				var _pos:String = _frame.get("background-position");
				var position:Array<String> = _pos.trim().split(' ');

				/*trace();
				var rect = FlxRect.get(Std.parseFloat(position[0]), Std.parseFloat(position[1]), Std.parseFloat(_frame.get("width")),
				Std.parseFloat(_frame.get("height")));*/


				var name = StringTools.trim(key);
				var currImageRegion = StringTools.trim(position[0]+" "+position[1]+" "+_frame.get("width")+" "+_frame.get("height")).split(" ");
	
				var rect = FlxRect.get(Std.parseInt(currImageRegion[0])*-1, Std.parseInt(currImageRegion[1])*-1, Std.parseInt(currImageRegion[2]),
					Std.parseInt(currImageRegion[3]));
				var sourceSize = FlxPoint.get(rect.width, rect.height);
				var offset = FlxPoint.get();
	
				frames.addAtlasFrame(rect, sourceSize, offset, name, FlxFrameAngle.ANGLE_0);
			}
		}

		return frames;
	}
}


class CSSToJson {


	// YEEEES I CAN DO IT... 5 hours to create it..
    public static function convertCSSToJson(cssString:String, ?jsonCode:Bool = false):Dynamic {
		var json = new StringMap<Dynamic>();

        var styles = cssString.split("\n\n");
        for (style in styles) {
            var lines = style.split("\n");
            var selector = lines[0].trim();
			selector = StringTools.replace(selector," {","");
            var properties = lines.slice(1);

            var styleJson = new StringMap<Dynamic>();
            for (property in properties) {
				var keyValue = property.split(":");
				var key = keyValue[0].trim();
				var value = keyValue[1].trim();
				if (key != '}' && key != ''){
					value = StringTools.replace(value,"px","");
					value = StringTools.replace(value,";","");
    	            styleJson.set(key, value);
				}	
            }

            json.set(selector.replace('.sprite-',''), styleJson);
        }

		
		if (jsonCode){
			var _json = {
				"json": json
			};

        	return Json.stringify(_json, "\t");
		}
		else{
			return json;
		}
	}
}