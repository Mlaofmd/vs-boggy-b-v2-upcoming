#if CRASH_HANDLER
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.CallStack;
import openfl.events.UncaughtErrorEvent;
#end

#if desktop
import external.Discord;
#end

import flixel.FlxG;
import flixel.FlxGame;
import openfl.events.Event;
import openfl.Lib;
import openfl.display.Sprite;
import flixel.FlxState;

using StringTools;

typedef GameConfig = {
	var width:Int; // WINDOW width
	var height:Int; // WINDOW height
	var initialState:Class<FlxState>; // initial game state
	var zoom:Float; // game state bounds
	var framerate:Int; // default framerate
	var skipSplash:Bool; // if the default flixel splash screen should be skipped
	var startFullscreen:Bool; // if the game should start at fullscreen mode
}

class Main extends Sprite {
	var game:GameConfig = {
		width: 1280,
		height: 720,
		initialState: TitleState,
		zoom: -1.0,
		framerate: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public static var fpsVar:FieldFPS;
	public static var achieveVar:AchievementToastManager;
	public static var discordVar:DiscordClient;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main() {
		Lib.current.addChild(new Main());
	}

	public function new() {
		super();

		if (stage != null)
			create();
		else
			addEventListener(Event.ADDED_TO_STAGE, create);
	}

	private function create(?e:Event) {
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, create);

		setupGame();
	}

	private function setupGame() {
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0) {
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		
        ClientPrefs.loadPrefs();
        
        #if !mobile
		fpsVar = new FieldFPS(10, 3);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.data.showFPS;
		}
		#end

		#if ACHIEVEMENTS_ALLOWED
		achieveVar = new AchievementToastManager();
		addChild(achieveVar);
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

        #if desktop
		if (!DiscordClient.isInitialized) {
			DiscordClient.initialize();
            FlxG.stage.application.window.onClose.add(function() {
				DiscordClient.shutdown();
			});
		}
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(?e:UncaughtErrorEvent) {
		var errMsg:String = "";
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");
		var path:String = "./crashes/Crash_" + dateNow + ".txt";

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/h4master/FNF-Idea-Engine\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists("./crashes/"))
			FileSystem.createDirectory("./crashes/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

        FlxG.stage.application.window.alert(errMsg, "Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end
}