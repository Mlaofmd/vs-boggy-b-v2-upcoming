package idea.objects.gameplay;

import external.animateatlas.AtlasFrameMaker;
import openfl.Assets;
import sys.FileSystem;
import haxe.Json;
import idea.objects.gameplay.characters.Character.AnimArray;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef HealthIconFile = {
	var animations:Array<AnimArray>;
	var scale:Float;
	var flip_x:Bool;
	var no_antialiasing:Bool;
}

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public var isAnimated:Bool = false;
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
			var names:Array<String> = [char, "icon-" + char, "icon-face"];
			while (!Paths.fileExists("images/icons/" + names[0] + ".png", IMAGE) && names.length > 0)
				names.shift();

			trace(names[0]);

			isAnimated = Paths.fileExists("images/icons/" + names[0] + ".json", TEXT);

			if (isAnimated) {
				json = Json.parse(Paths.getTextFromFile("images/icons/" + names[0] + ".json"));

				#if MODS_ALLOWED
				var modTxtToFind:String = Paths.modsTxt("images/icons/" + names[0]);
				var txtToFind:String = Paths.getPath("images/icons/" + names[0] + ".txt", TEXT);

				var modAnimToFind:String = Paths.modFolders("images/icons/" + names[0] + '/Animation.json');
				var animToFind:String = Paths.getPath('images/icons/' + names[0] + '/Animation.json', TEXT);
				#end

				#if MODS_ALLOWED
				if (FileSystem.exists(modTxtToFind) || FileSystem.exists(txtToFind) || Assets.exists(txtToFind))
				#else
				if (Assets.exists(Paths.getPath("images/icons/" + names[0] + ".txt", TEXT)))
				#end
				frames = Paths.getPackerAtlas("icons/" + names[0]);
				#if MODS_ALLOWED
				else if (FileSystem.exists(modAnimToFind) || FileSystem.exists(animToFind) || Assets.exists(animToFind))
				#else
				else if (Assets.exists(Paths.getPath('images/icons/' + names[0] + '/Animation.json', TEXT)))
				#end
					frames = AtlasFrameMaker.construct("icons/" + names[0]);
				else
					frames = Paths.getSparrowAtlas("icons/" + names[0]);

				var animationsArray:Array<AnimArray> = json.animations;
				if (animationsArray != null && animationsArray.length > 0) {
					for (anim in animationsArray) {
						var animAnim:String = "" + anim.anim;
						var animName:String = "" + anim.name;
						var animFps:Int = anim.fps;
						var animLoop:Bool = anim.loop;
						var animIndices:Array<Int> = anim.indices;
						if (animIndices != null && animIndices.length > 0)
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						else
							animation.addByPrefix(animAnim, animName, animFps, animLoop);

						if (anim.offsets != null && anim.offsets.length > 1)
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
					}
				}
				if (animation.exists("normal-loop"))
					playAnim("normal-loop");
				else
					playAnim("normal");
			} else {
				var file:FlxGraphic = Paths.image("icons/" + names[0]);
				loadGraphic(file, true, Math.floor(file.width / 2), Math.floor(file.height));
				iconOffsets[0] = (width - 150) / 2;
				iconOffsets[1] = (width - 150) / 2;
				updateHitbox();

				animation.add("normal-loop", [0], 0, true, isPlayer);
				animation.add("lose-loop", [1], 0, true, isPlayer);
				animation.add("win-loop", [0], 0, true, isPlayer);
				animation.play("normal-loop");

				antialiasing = (ClientPrefs.data.globalAntialiasing ? !char.endsWith("-pixel") : false);
			}
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

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		//animOffsets.set(name, [x, y]);
		animOffsets[name] = [x, y]; // ??????????????????????
	}

	public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0) {
		animation.play(name, force, reversed, frame);

		/*if (animOffsets.exists(name))
			offset.set(iconOffsets[0] + animOffsets[name][0], iconOffsets[1] + animOffsets[name][1]);*/
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

			antialiasing = (ClientPrefs.data.globalAntialiasing ? !char.endsWith("-pixel") : false);
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