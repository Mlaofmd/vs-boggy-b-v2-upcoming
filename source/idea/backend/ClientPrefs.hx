package idea.backend;

import flixel.util.FlxSave;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class SaveVariables {
	public var gpuRender:Bool = true;
	public var downScroll:Bool = false;
	public var middleScroll:Bool = false;
	public var opponentStrums:Bool = true;
	public var showFPS:Bool = true;
	public var flashing:Bool = true;
	public var antialiasing:Bool = true;
	public var noteSplashes:Bool = true;
	public var lowQuality:Bool = false;
	public var shaders:Bool = true;
	public var framerate:Int = 60;
	public var cursing:Bool = true;
	public var violence:Bool = true;
	public var camZooms:Bool = true;
	public var hideHud:Bool = false;
	public var noteOffset:Int = 0;
	public var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public var ghostTapping:Bool = true;
	public var showTimeBar:Bool = true;
	public var scoreZoom:Bool = true;
	public var classicScoreText:Bool = false;
	public var scoreScreen:Bool = true;
	public var noReset:Bool = false;
	public var instantRespawn:Bool = false;
	public var healthBarAlpha:Float = 1;
	public var healthBarColors:Bool = true;
	public var controllerMode:Bool = false;
	public var hitsoundVolume:Float = 0;
	public var pauseMusic:String = "Tea Time";
	public var checkForUpdates:Bool = true;
	public var comboStacking:Bool = true;
    public var colorblind:String = "None";
	public var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative', 
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false
	];

	public var comboOffset:Array<Int> = [0, 0, 0, 0];
	public var ratingOffset:Int = 0;
	public var sickWindow:Int = 45;
	public var goodWindow:Int = 90;
	public var badWindow:Int = 135;
	public var safeFrames:Float = 10;

	public var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
		
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],
		
		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE]
	];

	public function new() {}
}

class ClientPrefs {
	public static var data:SaveVariables = new SaveVariables();
	public static var defaults:SaveVariables = new SaveVariables();

	public static function saveSettings() {
		for (field in Reflect.fields(data)) {
			if (field != "keyBinds")
				Reflect.setProperty(FlxG.save.data, field, Reflect.getProperty(data, field));
		}


		/*FlxG.save.data.downScroll = data.downScroll;
		FlxG.save.data.middleScroll = data.middleScroll;
		FlxG.save.data.opponentStrums = data.opponentStrums;
		FlxG.save.data.showFPS = data.showFPS;
		FlxG.save.data.flashing = data.flashing;
		FlxG.save.data.antialiasing = data.antialiasing;
		FlxG.save.data.noteSplashes = data.noteSplashes;
		FlxG.save.data.lowQuality = data.lowQuality;
		FlxG.save.data.shaders = data.shaders;
		FlxG.save.data.framerate = data.framerate;
		FlxG.save.data.camZooms = data.camZooms;
		FlxG.save.data.noteOffset = data.noteOffset;
		FlxG.save.data.hideHud = data.hideHud;
		FlxG.save.data.arrowHSV = data.arrowHSV;
		FlxG.save.data.ghostTapping = data.ghostTapping;
		FlxG.save.data.showTimeBar = data.showTimeBar;
		FlxG.save.data.scoreZoom = data.scoreZoom;
		FlxG.save.data.classicScoreText = data.classicScoreText;
		FlxG.save.data.scoreScreen = data.scoreScreen;
		FlxG.save.data.noReset = data.noReset;
		FlxG.save.data.healthBarAlpha = data.healthBarAlpha;
		FlxG.save.data.healthBarColors = data.healthBarColors;
		FlxG.save.data.comboOffset = data.comboOffset;

		FlxG.save.data.achievementsMap = Achievements.achievementsMap;
		FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;

		FlxG.save.data.ratingOffset = data.ratingOffset;
		FlxG.save.data.sickWindow = data.sickWindow;
		FlxG.save.data.goodWindow = data.goodWindow;
		FlxG.save.data.badWindow = data.badWindow;
		FlxG.save.data.safeFrames = data.safeFrames;
		FlxG.save.data.gameplaySettings = data.gameplaySettings;*/

		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind("controls_v2", CoolUtil.getSavePath()); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = data.keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		for (field in Reflect.fields(data)) {
			if (Reflect.getProperty(FlxG.save.data, field) != null)
				Reflect.setProperty(data, field, Reflect.getProperty(FlxG.save.data, field));
			else
				Reflect.setProperty(data, field, Reflect.getProperty(defaults, field));
		}

		if (Main.fpsVar != null)
			Main.fpsVar.visible = data.showFPS;

		if (data.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
		} else {
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		}

        ColorblindFilter.applyFiltersOnGame();

		// flixel automatically saves your volume!
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		var save:FlxSave = new FlxSave();
		save.bind("controls_v2", CoolUtil.getSavePath());
		if(save != null && save.data.customControls != null) {
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				data.keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	public static function resetOptions() {
		for (field in Reflect.fields(data))
			Reflect.setProperty(data, field, Reflect.getProperty(defaults, field));

		if (Main.fpsVar != null)
			Main.fpsVar.visible = data.showFPS;

		if (data.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
		} else {
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		}

		FlxG.sound.volume = 1;
		FlxG.sound.muted = false;
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic {
		return /*PlayState.isStoryMode ? defaultValue : */ (data.gameplaySettings.exists(name) ? data.gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(Solo);

		TitleState.muteKeys = copyKey(data.keyBinds.get("volume_mute"));
		TitleState.volumeDownKeys = copyKey(data.keyBinds.get("volume_down"));
		TitleState.volumeUpKeys = copyKey(data.keyBinds.get("volume_up"));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}