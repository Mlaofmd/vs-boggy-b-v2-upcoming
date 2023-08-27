package idea.objects;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.graphics.frames.FlxAtlasFrames;
import external.animateatlas.AtlasFrameMaker;
import openfl.Assets;
import sys.FileSystem;
import haxe.Json;
import idea.objects.Character.AnimArray;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef HealthIconFile = {
	var image:String;
	var offsets:Array<Float>;
	var frames:Array<FrameData>;
	var no_antialiasing:Null<Bool>;
	var scale:Null<Float>;
}

typedef FrameData = {
	var x:Float;
	var y:Float;
	var width:Float;
	var height:Float;
}

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public var json:HealthIconFile = null;
	public var animOffsets:Map<String, Array<Float>>;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if (this.char != char) {
			this.char = char;

			var names:Array<String> = [char, "icon-" + char, "icon-face"];
			while (!Paths.fileExists("images/icons/" + names[0] + ".png", IMAGE) && names.length > 0)
				names.shift();

			if (Paths.fileExists("images/icons/" + names[0] + ".json", TEXT)) {
				var json:HealthIconFile = Json.parse(Paths.getTextFromFile("images/icons/" + names[0] + ".json"));

				var file:FlxGraphic = Paths.image("icons/" + names[0]);
				if (json.image != null)
					file = Paths.image(json.image);

				if (json.offsets != null)
					iconOffsets = json.offsets;
				updateHitbox();

				if (json.frames != null && json.frames.length > 0) {
					frames = new FlxAtlasFrames(file);
					for (frame in json.frames) {
						var rect:FlxRect = new FlxRect(frame.x, frame.y, frame.width, frame.height);
						frames.addSpriteSheetFrame(rect);
						if (animation.exists(char))
							animation.append(char, [json.frames.indexOf(frame)]);
						else
							animation.add(char, [json.frames.indexOf(frame)], 0, false, isPlayer);
					}
				} else {
					loadGraphic(file);
					loadGraphic(file, true, Math.floor(width / 2), Math.floor(height));
					animation.add(char, [0, 1, 0], 0, false, isPlayer);
				}

				if (json.no_antialiasing != null)
					antialiasing = json.no_antialiasing ? false : ClientPrefs.data.antialiasing;
				else
					antialiasing = (ClientPrefs.data.antialiasing ? !char.endsWith("-pixel") : false);

				if (json.scale != null)
					setGraphicSize(Std.int(width * json.scale));
			} else {
				var file:FlxGraphic = Paths.image("icons/" + names[0]);
				loadGraphic(file);
				loadGraphic(file, true, Math.floor(width / 2), Math.floor(height));
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
				updateHitbox();

				animation.add(char, [0, 1, 0], 0, false, isPlayer);

				antialiasing = (ClientPrefs.data.antialiasing ? !char.endsWith("-pixel") : false);
			}
			animation.play(char);
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.set(iconOffsets[0], iconOffsets[1]);
	}

	public function getCharacter():String {
		return char;
	}
}

/*
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public var animOffsets:Map<String, Array<Dynamic>>;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			loadGraphic(file); //Load stupidly first for getting the file size
			loadGraphic(file, true, Math.floor(width / 2), Math.floor(height)); //Then load it fr
			iconOffsets[0] = (width - 150) / 2;
			iconOffsets[1] = (width - 150) / 2;
			updateHitbox();

			animation.add("normal-loop", [0], 0, true, isPlayer);
			animation.add("lose-loop", [1], 0, true, isPlayer);
			animation.add("win-loop", [0], 0, true, isPlayer);
			playAnim("normal-loop");
			this.char = char;

			antialiasing = (ClientPrefs.data.antialiasing ? !char.endsWith("-pixel") : false);
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		animOffsets[name] = [x, y];
	}

	public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		animation.play(name, force, reversed, frame);

		if (animOffsets.exists(name))
			offset.set(animOffsets[name][0], animOffsets[name][1]);
	}
}
*/