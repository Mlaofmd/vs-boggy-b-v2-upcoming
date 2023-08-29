package idea.objects;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwapPixel = null;
	private var textureLoaded:String = null;

	public var isSustain:Bool = false;
	public var skin:String = "noteSplashes";

	public var noteData:Int = 0;
	private var parentStrum:StrumNote = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0, isSustain:Bool = false) {
		super(x, y);
		this.isSustain = isSustain;
		noteData = note;

		var _song = PlayState.SONG;
		if (_song.splashSkin != null && _song.splashSkin.trim().length > 0)
			skin = _song.splashSkin;

		loadAnims(skin);
		
		colorSwap = new ColorSwapPixel(PlayState.isPixelStage ? PlayState.daPixelZoom : 1);
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0, ?strum:StrumNote) {
		noteData = note;

		if (textureLoaded != texture) {
			if (texture == null)
				texture = skin;

			loadAnims(texture);

			playAnim();
		}

		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		
		if (isSustain) {
			scale.set(0.7, 0.7);
			centerOffsets();
			alpha = 0.8;
			setPosition(x - width * 0.25, y + height * (ClientPrefs.data.downScroll ? -1 : 0.41));
			flipY = ClientPrefs.data.downScroll;

			parentStrum = strum;
		} else {
			alpha = 0.6;
			if (animation.curAnim != null)
				animation.curAnim.frameRate = 24 + FlxG.random.int(-3, 4);
			angle = FlxG.random.int(-10, 10);
			setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
			offset.set(-20); // пиздец костыли
		}
	}

	function playAnim() {
		animation.play("note" + noteData + "-" + FlxG.random.int(1, 2), true);
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin + (isSustain ? "-sustain" : ""));
        var animPrefix:String = isSustain ? "hold" : "note";
        for (i in 1...3) {
            animation.addByPrefix("note0-" + i, animPrefix + " splash purple " + i, 24, false);
            animation.addByPrefix("note1-" + i, animPrefix + " splash blue " + i, 24, false);
            animation.addByPrefix("note2-" + i, animPrefix + " splash green " + i, 24, false);
            animation.addByPrefix("note3-" + i, animPrefix + " splash red " + i, 24, false);
        }
		textureLoaded = skin;
	}

	override function update(elapsed:Float) {
		if (animation.curAnim != null && animation.curAnim.finished)
			kill();

		super.update(elapsed);
	}
}