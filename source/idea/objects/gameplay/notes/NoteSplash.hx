package idea.objects.gameplay.notes;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwapPixel = null;
	private var textureLoaded:String = null;

	public var isSustain:Bool = false;
	public var regularSkin:String = "noteSplashes";
	public var sustainSkin:String = "NOTE_assets-extra";

	public var noteData:Int = 0;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0, isSustain:Bool = false) {
		super(x, y);
		this.isSustain = isSustain;
		noteData = note;

		if (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin != regularSkin && PlayState.SONG.splashSkin.length > 0)
			regularSkin = PlayState.SONG.splashSkin;

		/*if (PlayState.SONG.extraSkin != null && PlayState.SONG.extraSkin != sustainSkin && PlayState.SONG.extraSkin.length > 0)
			sustainSkin = PlayState.SONG.extraSkin;*/

		loadAnims(isSustain ? sustainSkin : regularSkin);
		
		colorSwap = new ColorSwapPixel(PlayState.isPixelStage ? PlayState.daPixelZoom : 1);
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.data.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0, ?strum:StrumNote) {
		noteData = note;

		if (textureLoaded != texture) {
			if (texture == null) {
				if (isSustain)
					//texture = (PlayState.SONG.extraSkin != null && PlayState.SONG.extraSkin.length > 0) ? PlayState.SONG.extraSkin : sustainSkin;
					texture = sustainSkin;
				else
					texture = (PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) ? PlayState.SONG.splashSkin : regularSkin;
			}

			loadAnims(texture);
			animation.finishCallback = function(name:String) {
				kill();
			}

			playAnim();
		}

		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		
		if (isSustain) {
			scale.set(0.7, 0.7);
			centerOffsets();
			alpha = 0.8;
			setPosition(x - width * 0.25, y + height * (ClientPrefs.data.downScroll ? 1 : 0.41));
			flipY = ClientPrefs.data.downScroll;

			if (strum != null) {
				for (i in 0...Std.int(width)) {
					for (j in 0...Std.int(height)) {
						var noteColor:FlxColor = strum.pixels.getPixel32(Std.int(x - strum.x) + i, Std.int(y - strum.y) + j);
						/*if (noteColor.alphaFloat == 1)
							framePixels.setPixel32(Std.int(x + i), Std.int(y + j), FlxColor.TRANSPARENT);*/
					}
				}
			}
		} else {
			alpha = 0.6;
			angle = FlxG.random.int(-10, 10);
			setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
			offset.set(-20); // пиздец костыли
		}
	}

	function playAnim() {
		animation.play("note" + noteData + "-" + FlxG.random.int(1, 2), true);
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
        var animPrefix:String = isSustain ? "hold" : "note";
        for (i in 1...3) {
            animation.addByPrefix("note0-" + i, animPrefix + " splash purple " + i, 24, false);
            animation.addByPrefix("note1-" + i, animPrefix + " splash blue " + i, 24, false);
            animation.addByPrefix("note2-" + i, animPrefix + " splash green " + i, 24, false);
            animation.addByPrefix("note3-" + i, animPrefix + " splash red " + i, 24, false);
        }
		textureLoaded = skin;
	}
}