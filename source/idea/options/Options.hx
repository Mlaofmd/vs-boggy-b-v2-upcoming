/*package idea.options;

typedef OptionConfig = {
	@:optional var minFloat:Float;
	@:optional var maxFloat:Float;
	@:optional var stepFloat:Float;

	@:optional var minInt:Int;
	@:optional var maxInt:Int;
	@:optional var stepInt:Int;

	@:optional var values:Array<String>;

	@:optional var postfix:String;
}

enum OptionType {
	bool;
	float;
	int;
	percent;
	string;
	special;
}

class Option {
	inline public static var PAUSE_MSG:String = "This option cannot be toggled in the pause menu.";

	public var name:String;
	public var description:String;
	public var variable:String;
	public var type:OptionType;
	public var config:OptionConfig;
	public var onChange:Void->Void;

	private var display:String;
	private var acceptValues:Bool = false;
	public var acceptType:Bool = false;
	public var waitingType:Bool = false;

	public function new(name:String, description:String, variable:String, type:OptionType, ?config:OptionConfig, ?onChange:Void->Void) {
		this.name = name;
		this.variable = variable;
		this.description = description;
		this.variable = variable;
		this.type = type;
		this.config = config;
		this.onChange = onChange;

		display = updateDisplay();
	}

	public function getDisplay() {
		return display;
	}

	public function getAccept() {
		return acceptValues;
	}

	public function getDescription():String {
		return description;
	}

	public function getValue():String {
		return updateDisplay();
	}

	public function onType(text:String) {}

	public function press():Bool {
		switch(type) {
			case bool:
				Reflect.setProperty(ClientPrefs.data, variable, !Reflect.getProperty(ClientPrefs.data, variable));

				if (onChange != null)
					onChange();
			case special:
				if (onChange != null)
					onChange();
			default:
		}

		display = updateDisplay();
		return true;
	}

	public function left():Bool {
		switch(type) {
			case float | percent:
				Reflect.setProperty(ClientPrefs.data, variable, Reflect.getProperty(ClientPrefs.data, variable) - config.stepFloat);
				if (Reflect.getProperty(ClientPrefs.data, variable) < config.minFloat)
					Reflect.setProperty(ClientPrefs.data, variable, config.minFloat);

				if (onChange != null)
					onChange();
			case int:
				Reflect.setProperty(ClientPrefs.data, variable, Reflect.getProperty(ClientPrefs.data, variable) - config.stepInt);
				if (Reflect.getProperty(ClientPrefs.data, variable) < config.minInt)
					Reflect.setProperty(ClientPrefs.data, variable, config.minInt);

				if (onChange != null)
					onChange();
			case string:
				if (config.values.indexOf(Reflect.getProperty(ClientPrefs.data, variable)) == 0)
					Reflect.setProperty(ClientPrefs.data, variable, config.values.length - 1);
				else
					Reflect.setProperty(ClientPrefs.data, variable, config.values[config.values.indexOf(Reflect.getProperty(ClientPrefs.data, variable)) - 1]);
			
				if (onChange != null)
					onChange();
			default:
		}

		display = updateDisplay();
		return true;
	}

	public function right():Bool {
		switch(type) {
			case float | percent:
				Reflect.setProperty(ClientPrefs.data, variable, Reflect.getProperty(ClientPrefs.data, variable) + config.stepFloat);
				if (Reflect.getProperty(ClientPrefs.data, variable) > config.maxFloat)
					Reflect.setProperty(ClientPrefs.data, variable, config.maxFloat);

				if (onChange != null)
					onChange();
			case int:
				Reflect.setProperty(ClientPrefs.data, variable, Reflect.getProperty(ClientPrefs.data, variable) + config.stepInt);
				if (Reflect.getProperty(ClientPrefs.data, variable) > config.maxInt)
					Reflect.setProperty(ClientPrefs.data, variable, config.maxInt);

				if (onChange != null)
					onChange();
			case string:
				if (config.values.indexOf(Reflect.getProperty(ClientPrefs.data, variable)) == config.values.length - 1)
					Reflect.setProperty(ClientPrefs.data, variable, 0);
				else
					Reflect.setProperty(ClientPrefs.data, variable, config.values[config.values.indexOf(Reflect.getProperty(ClientPrefs.data, variable)) + 1]);

				if (onChange != null)
					onChange();
			default:
		}

		display = updateDisplay();
		return true;
	}

	public function updateDisplay():String {
		var retVal:String = name + ": ";
		if (type != special) {
			var curValue:Dynamic = Reflect.getProperty(ClientPrefs.data, variable);
			switch(type) {
				case float | percent:
					retVal += (curValue == config.minFloat ? "  " : "< ");
				case int:
					retVal += (curValue == config.minInt ? "  " : "< ");
				case string:
					retVal += "< ";
				default:
			}
			switch(type) {
				case bool:
					retVal += (curValue ? "Enabled" : "Disabled");
				case percent:
					retVal += curValue * (100 / config.maxFloat);
				default:
					retVal += curValue;
			}
			retVal += (config.postfix != null ? config.postfix : "");
			switch(type) {
				case float | percent:
					retVal += (curValue == config.maxFloat ? "" : " >");
				case int:
					retVal += (curValue == config.maxInt ? "" : " >");
				case string:
					retVal += " >";
				default:
			}
		} else
			retVal = name;
		return retVal;
	}
}*/

package idea.options;

import flixel.FlxG;

class Option {
	inline public static var PAUSE_MSG:String = "This option cannot be toggled in the pause menu.";

	public function new() {
		display = updateDisplay();
	}

	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;

	public var acceptType:Bool = false;

	public var waitingType:Bool = false;

	public final function getDisplay():String {
		return display;
	}

	public final function getAccept():Bool {
		return acceptValues;
	}

	public final function getDescription():String {
		return description;
	}

	public function getValue():String {
		return updateDisplay();
	}

	public function onType(text:String) {}

	// Returns whether the label is to be updated.
	public function press():Bool {
		return true;
	}

	private function updateDisplay():String {
		return "";
	}

	public function left():Bool {
		return false;
	}

	public function right():Bool {
		return false;
	}
}

class HitsoundOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function left():Bool {
		ClientPrefs.data.hitsoundVolume -= 0.1;
		if (ClientPrefs.data.hitsoundVolume < 0.1)
			ClientPrefs.data.hitsoundVolume = 0;
		if (ClientPrefs.data.hitsoundVolume > 0.9)
			ClientPrefs.data.hitsoundVolume = 1;

		FlxG.sound.play(Paths.sound("hitsound"), ClientPrefs.data.hitsoundVolume);

		display = updateDisplay();
		return true;
	}

	override function right():Bool {
		ClientPrefs.data.hitsoundVolume += 0.1;
		if (ClientPrefs.data.hitsoundVolume < 0.1)
			ClientPrefs.data.hitsoundVolume = 0;
		if (ClientPrefs.data.hitsoundVolume > 0.9)
			ClientPrefs.data.hitsoundVolume = 1;

		FlxG.sound.play(Paths.sound("hitsound"), ClientPrefs.data.hitsoundVolume);

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return {
			if (ClientPrefs.data.hitsoundVolume == 0)
				"Hit Sound Volume:   " + (ClientPrefs.data.hitsoundVolume * 100) + "% >";
			else if (ClientPrefs.data.hitsoundVolume == 1)
				"Hit Sound Volume: < " + (ClientPrefs.data.hitsoundVolume * 100) + "%";
			else
				"Hit Sound Volume: < " + (ClientPrefs.data.hitsoundVolume * 100) + "% >";
		}
	}
}

class ControllerOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.controllerMode = !ClientPrefs.data.controllerMode;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Controler Mode: " + (ClientPrefs.data.controllerMode ? "Enabled" : "Disabled");
	}
}

class RatingOffsetOption extends Option {
	public function new(desc:String) {
		super();
		description = (OptionsMenu.isInPause ? Option.PAUSE_MSG : desc);
	}

	override function left():Bool {
		if (OptionsMenu.isInPause)
			return false;

		ClientPrefs.data.ratingOffset -= 5;
		if (ClientPrefs.data.ratingOffset < -30)
			ClientPrefs.data.ratingOffset = -30;
		if (ClientPrefs.data.ratingOffset > 30)
			ClientPrefs.data.ratingOffset = 30;

		display = updateDisplay();
		return true;
	}

	override function right():Bool {
		if (OptionsMenu.isInPause)
			return false;

		ClientPrefs.data.ratingOffset += 5;
		if (ClientPrefs.data.ratingOffset < -30)
			ClientPrefs.data.ratingOffset = -30;
		if (ClientPrefs.data.ratingOffset > 30)
			ClientPrefs.data.ratingOffset = 30;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return {
			if (ClientPrefs.data.ratingOffset == -30)
				"Rating Offset:   " + ClientPrefs.data.ratingOffset + " >";
			else if (ClientPrefs.data.ratingOffset == 30)
				"Rating Offset: < " + ClientPrefs.data.ratingOffset;
			else
				"Rating Offset: < " + ClientPrefs.data.ratingOffset + " >";
		}
	}
}

class GhostTappingOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.ghostTapping = !ClientPrefs.data.ghostTapping;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Ghost Tapping: " + (ClientPrefs.data.ghostTapping ? "Enabled" : "Disabled");
	}
}

class DownScrollOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.downScroll = !ClientPrefs.data.downScroll;

		if (OptionsMenu.isInPause)
			PlayState.instance.applySettings();

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Downscroll: " + (ClientPrefs.data.downScroll ? "Enabled" : "Disabled");
	}
}

class ResetButtonOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.noReset = !ClientPrefs.data.noReset;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Disable Reset Button: " + (ClientPrefs.data.noReset ? "Enabled" : "Disabled");
	}
}

class InstantRespawnOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.instantRespawn = !ClientPrefs.data.instantRespawn;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Instant Respawn: " + (ClientPrefs.data.instantRespawn ? "Enabled" : "Disabled");
	}
}

class CamZoomOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.camZooms = !ClientPrefs.data.camZooms;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Camera Zooms: " + (ClientPrefs.data.camZooms ? "Enabled" : "Disabled");
	}
}

class KeyBindsOption extends Option {
	public function new(desc:String) {
		super();
		description = (OptionsMenu.isInPause ? Option.PAUSE_MSG : desc);
	}

	override function press():Bool {
		if (!OptionsMenu.isInPause)
			OptionsMenu.instance.openSubState(new ControlsSubState());

		return false;
	}

	override function updateDisplay():String {
		return "Edit Keybindings";
	}
}

class NotesColorsOption extends Option {
	public function new(desc:String) {
		super();
		description = (OptionsMenu.isInPause ? Option.PAUSE_MSG : desc);
	}

	override function press():Bool {
		if (!OptionsMenu.isInPause)
			OptionsMenu.instance.openSubState(new NotesSubState());

		return false;
	}

	override function updateDisplay():String {
		return "Edit Notes Colors";
	}
}

class CustomizeOption extends Option {
	public function new(desc:String) {
		super();
		description = (OptionsMenu.isInPause ? Option.PAUSE_MSG : desc);
	}

	override function press():Bool {
		if (!OptionsMenu.isInPause)
			MusicBeatState.switchState(new NoteOffsetState());

		return false;
	}

	override function updateDisplay():String {
		return "Edit Delay and Combo";
	}
}

class HideHudOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		if (OptionsMenu.isInPause)
			return false;

		ClientPrefs.data.hideHud = !ClientPrefs.data.hideHud;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Hide HUD: " + (ClientPrefs.data.hideHud ? "Enabled" : "Disabled");
	}
}

class LowDetailOption extends Option {
	public function new(desc:String) {
		super();
		description = (OptionsMenu.isInPause ? Option.PAUSE_MSG : desc);
	}

	override function press():Bool {
		if (OptionsMenu.isInPause)
			return false;

		ClientPrefs.data.lowQuality = !ClientPrefs.data.lowQuality;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Low Detail: " + (ClientPrefs.data.lowQuality ? "Enabled" : "Disabled");
	}
}

class MiddleScrollOption extends Option {
	public function new(desc:String) {
		super();
		description = (OptionsMenu.isInPause ? Option.PAUSE_MSG : desc);
	}

	override function press():Bool {
		if (OptionsMenu.isInPause)
			return false;

		ClientPrefs.data.middleScroll = !ClientPrefs.data.middleScroll;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Middlescroll: " + (ClientPrefs.data.middleScroll ? "Enabled" : "Disabled");
	}
}

class HealthAlphaOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function left():Bool {
		ClientPrefs.data.healthBarAlpha -= 0.1;
		if (ClientPrefs.data.healthBarAlpha < 0.1)
			ClientPrefs.data.healthBarAlpha = 0;
		if (ClientPrefs.data.healthBarAlpha > 0.9)
			ClientPrefs.data.healthBarAlpha = 1;

		display = updateDisplay();
		return true;
	}

	override function right():Bool {
		ClientPrefs.data.healthBarAlpha += 0.1;
		if (ClientPrefs.data.healthBarAlpha < 0.1)
			ClientPrefs.data.healthBarAlpha = 0;
		if (ClientPrefs.data.healthBarAlpha > 0.9)
			ClientPrefs.data.healthBarAlpha = 1;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return {
			if (ClientPrefs.data.healthBarAlpha == 0)
				"Health Bar Transparency:   " + (ClientPrefs.data.healthBarAlpha * 100) + "% >";
			else if (ClientPrefs.data.healthBarAlpha == 1)
				"Health Bar Transparency: < " + (ClientPrefs.data.healthBarAlpha * 100) + "%";
			else
				"Health Bar Transparency: < " + (ClientPrefs.data.healthBarAlpha * 100) + "% >";
		}
	}
}

class ScoreTextOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.classicScoreText = !ClientPrefs.data.classicScoreText;
		
		if (OptionsMenu.isInPause)
			PlayState.instance.applySettings();

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Classic Score Text: " + (ClientPrefs.data.classicScoreText ? "Enabled" : "Disabled");
	}
}

class TimeBarOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.showTimeBar = !ClientPrefs.data.showTimeBar;
		
		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Time Bar: " + (ClientPrefs.data.showTimeBar ? "Enabled" : "Disabled");
	}
}

class HealthColorsOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.healthBarColors = !ClientPrefs.data.healthBarColors;

		if (OptionsMenu.isInPause)
			PlayState.instance.reloadHealthBarColors();
		
		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Health Colors: " + (ClientPrefs.data.healthBarColors ? "Enabled" : "Disabled");
	}
}

class OpponentStrumsOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.opponentStrums = !ClientPrefs.data.opponentStrums;
		
		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Opponent Strums: " + (ClientPrefs.data.opponentStrums ? "Enabled" : "Disabled");
	}
}

class ComboStackingOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.comboStacking = !ClientPrefs.data.comboStacking;
		
		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Combo Stacking: " + (ClientPrefs.data.comboStacking ? "Enabled" : "Disabled");
	}
}

class ColorblindOption extends Option {
	var values:Array<String> = ["None", "Deuteranopia", "Protanopia", "Tritanopia"];
	var value:Int;
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function left():Bool {
		value --;
		if (value < 0)
			value = values.length - 1;
		if (value > values.length - 1)
			value = 0;
		ClientPrefs.data.colorblind = values[value];

        ColorblindFilter.applyFiltersOnGame();

		display = updateDisplay();
		return true;
	}

	override function right():Bool {
		value ++;
		if (value < 0)
			value = values.length - 1;
		if (value > values.length - 1)
			value = 0;
		ClientPrefs.data.colorblind = values[value];

        ColorblindFilter.applyFiltersOnGame();

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Colorblind Mode: < " + ClientPrefs.data.colorblind + " >";
	}
}

class FPSCapOption extends Option {
	public function new(desc:String)  {
		super();
		description = desc;
	}

	override function left():Bool {
		ClientPrefs.data.framerate -= 10;
		if (ClientPrefs.data.framerate < 60)
			ClientPrefs.data.framerate = 60;
		if (ClientPrefs.data.framerate > 360)
			ClientPrefs.data.framerate = 360;

		if (ClientPrefs.data.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		} else {
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}

		display = updateDisplay();
		return true;
	}

	override function right():Bool {
		ClientPrefs.data.framerate += 10;
		if (ClientPrefs.data.framerate < 60)
			ClientPrefs.data.framerate = 60;
		if (ClientPrefs.data.framerate > 360)
			ClientPrefs.data.framerate = 360;

		if (ClientPrefs.data.framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		} else {
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return {
			if (ClientPrefs.data.framerate == 60)
				"FPS Cap:   " + ClientPrefs.data.framerate + " >";
			else if (ClientPrefs.data.framerate == 360)
				"FPS Cap: < " + ClientPrefs.data.framerate;
			else
				"FPS Cap: < " + ClientPrefs.data.framerate + " >";
		}
	}
}

class FPSOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.showFPS = !ClientPrefs.data.showFPS;

		if (Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
		
		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "FPS Counter: " + (ClientPrefs.data.showFPS ? "Enabled" : "Disabled");
	}
}

class FlashingOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.flashing = !ClientPrefs.data.flashing;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Flashing Lights: " + (ClientPrefs.data.flashing ? "Enabled" : "Disabled");
	}
}

class AntialiasingOption extends Option {
	public function new(desc:String) {
		super();
		description = (OptionsMenu.isInPause ? Option.PAUSE_MSG : desc);
	}

	override function press():Bool {
		if (OptionsMenu.isInPause)
			return false;

		ClientPrefs.data.antialiasing = !ClientPrefs.data.antialiasing;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Anti-Aliasing: " + (ClientPrefs.data.antialiasing ? "Enabled" : "Disabled");
	}
}

class ScoreScreenOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.scoreScreen = !ClientPrefs.data.scoreScreen;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Score Screen: " + (ClientPrefs.data.scoreScreen ? "Enabled" : "Disabled");
	}
}

class ShadersOption extends Option {
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function press():Bool {
		ClientPrefs.data.shaders = !ClientPrefs.data.shaders;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Shaders: " + (ClientPrefs.data.shaders ? "Enabled" : "Disabled");
	}
}

class PauseMusicOption extends Option {
	var values:Array<String> = ["None", "Breakfast", "Tea Time"];
	var value:Int;
	public function new(desc:String) {
		super();
		description = desc;
	}

	override function left():Bool {
		value --;
		if (value < 0)
			value = values.length - 1;
		if (value > values.length - 1)
			value = 0;
		ClientPrefs.data.pauseMusic = values[value];

		if (OptionsMenu.isInPause) {
			if (ClientPrefs.data.pauseMusic != "None") {
				PauseSubState.pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), true, true);
			}
			PauseSubState.pauseMusic.volume = 0;
			PauseSubState.pauseMusic.play(false, FlxG.random.int(0, Std.int(PauseSubState.pauseMusic.length / 2)));
		}

		display = updateDisplay();
		return true;
	}

	override function right():Bool {
		value ++;
		if (value < 0)
			value = values.length - 1;
		if (value > values.length - 1)
			value = 0;
		ClientPrefs.data.pauseMusic = values[value];

		if (OptionsMenu.isInPause) {
			if (ClientPrefs.data.pauseMusic != "None") {
				PauseSubState.pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), true, true);
			}
			PauseSubState.pauseMusic.volume = 0;
			PauseSubState.pauseMusic.play(false, FlxG.random.int(0, Std.int(PauseSubState.pauseMusic.length / 2)));
		}

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return "Pause Screen Song: < " + ClientPrefs.data.pauseMusic + " >";
	}
}

class SickWindowOption extends Option {
	public function new(desc:String) {
		super();
		description = (OptionsMenu.isInPause ? Option.PAUSE_MSG : desc);
	}

	override function left():Bool {
		if (OptionsMenu.isInPause)
			return false;

		ClientPrefs.data.sickWindow --;
		if (ClientPrefs.data.sickWindow < 15)
			ClientPrefs.data.sickWindow = 15;
		if (ClientPrefs.data.sickWindow > 45)
			ClientPrefs.data.sickWindow = 45;

		display = updateDisplay();
		return true;
	}

	override function right():Bool {
		if (OptionsMenu.isInPause)
			return false;

		ClientPrefs.data.sickWindow ++;
		if (ClientPrefs.data.sickWindow < 15)
			ClientPrefs.data.sickWindow = 15;
		if (ClientPrefs.data.sickWindow > 45)
			ClientPrefs.data.sickWindow = 45;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return {
			if (ClientPrefs.data.sickWindow == 15)
				"SICK Window:   " + ClientPrefs.data.sickWindow + "ms >";
			else if (ClientPrefs.data.sickWindow == 45)
				"SICK Window: < " + ClientPrefs.data.sickWindow + "ms";
			else
				"SICK Window: < " + ClientPrefs.data.sickWindow + "ms >";
		}
	}
}

class GoodWindowOption extends Option {
	public function new(desc:String) {
		super();
		description = (OptionsMenu.isInPause ? Option.PAUSE_MSG : desc);
	}

	override function left():Bool {
		if (OptionsMenu.isInPause)
			return false;

		ClientPrefs.data.goodWindow --;
		if (ClientPrefs.data.goodWindow < 15)
			ClientPrefs.data.goodWindow = 15;
		if (ClientPrefs.data.goodWindow > 90)
			ClientPrefs.data.goodWindow = 90;

		display = updateDisplay();
		return true;
	}

	override function right():Bool {
		if (OptionsMenu.isInPause)
			return false;

		ClientPrefs.data.goodWindow ++;
		if (ClientPrefs.data.goodWindow < 15)
			ClientPrefs.data.goodWindow = 15;
		if (ClientPrefs.data.goodWindow > 90)
			ClientPrefs.data.goodWindow = 90;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return {
			if (ClientPrefs.data.goodWindow == 15)
				"GOOD Window:   " + ClientPrefs.data.goodWindow + "ms >";
			else if (ClientPrefs.data.goodWindow == 90)
				"GOOD Window: < " + ClientPrefs.data.goodWindow + "ms";
			else
				"GOOD Window: < " + ClientPrefs.data.goodWindow + "ms >";
		}
	}
}

class BadWindowOption extends Option {
	public function new(desc:String) {
		super();
		description = (OptionsMenu.isInPause ? Option.PAUSE_MSG : desc);
	}

	override function left():Bool {
		if (OptionsMenu.isInPause)
			return false;

		ClientPrefs.data.badWindow --;
		if (ClientPrefs.data.badWindow < 15)
			ClientPrefs.data.badWindow = 15;
		if (ClientPrefs.data.badWindow > 135)
			ClientPrefs.data.badWindow = 135;

		display = updateDisplay();
		return true;
	}

	override function right():Bool {
		if (OptionsMenu.isInPause)
			return false;

		ClientPrefs.data.badWindow ++;
		if (ClientPrefs.data.badWindow < 15)
			ClientPrefs.data.badWindow = 15;
		if (ClientPrefs.data.badWindow > 135)
			ClientPrefs.data.badWindow = 135;

		display = updateDisplay();
		return true;
	}

	override function updateDisplay():String {
		return {
			if (ClientPrefs.data.badWindow == 15)
				"BAD Window:   " + ClientPrefs.data.badWindow + "ms >";
			else if (ClientPrefs.data.badWindow == 135)
				"BAD Window: < " + ClientPrefs.data.badWindow + "ms";
			else
				"BAD Window: < " + ClientPrefs.data.badWindow + "ms >";
		}
	}
}