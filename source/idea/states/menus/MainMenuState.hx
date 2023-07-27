package idea.states.menus;

import sys.FileSystem;
#if desktop
import external.Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var ideaEngineVersion:String = "0.0.3"; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	public var menuItems:FlxTypedGroup<FlxSprite>;
	public var camGame:FlxCamera;
	public var camAchievement:FlxCamera;
	
	public var optionShit:Array<String> = [
		"story_mode",
		"freeplay",
		#if MODS_ALLOWED "mods", #end
		#if ACHIEVEMENTS_ALLOWED "awards", #end
		"credits",
		#if !switch "donate", #end
		"options"
	];

	public var magenta:FlxSprite;
	public var camFollow:FlxObject;
	public var debugKeys:Array<FlxKey>;

	public static var firstStart:Bool = true;
	public static var finishedFunnyMove:Bool = false;

	#if HSCRIPT_ALLOWED
	var hscript:FunkinHScript;
	#end

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();
		AchievementData.loadAchievements();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.data.keyBinds.get("debug_1"));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80, Paths.image("menuBG"));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image("menuDesat"));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.data.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		if (firstStart)
			finishedFunnyMove = false;

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas("mainmenu/menu_" + optionShit[i]);
			menuItem.animation.addByPrefix("idle", optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix("selected", optionShit[i] + " white", 24);
			menuItem.animation.play("idle");
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.data.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			if (firstStart)
				FlxTween.tween(menuItem, {y: (i * 140) + offset}, 1 + (i * 0.25), {
					ease: FlxEase.expoInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						changeItem();
					}
				});
			else {
				menuItem.y = (i * 140) + offset;
				changeItem();
			}
		}
		firstStart = false;

		FlxG.camera.follow(camFollow, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Idea Engine v" + ideaEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get("version"), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent("swag").send();

		#if ACHIEVEMENTS_ALLOWED
		var leDate:Date = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Main.achieveVar.giveAchievement("friday_night_play");
		#end

		super.create();

		#if HSCRIPT_ALLOWED
		var directories:Array<String> = [];
		for (mod in Paths.getGlobalMods())
			directories.push(mod);
		directories.push(Paths.mods());
		directories.push(Paths.getPreloadPath());

		while (!FileSystem.exists(directories[0] + "hscripts/states/MainMenuState.hx") && directories.length > 0)
			directories.shift();

		if (directories.length > 0)
			hscript = new FunkinHScript(directories[0] + "hscripts/states/MainMenuState.hx");
		else
			hscript = new FunkinHScript("");

		hscript.set("this", this);
		#end
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.8) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		FlxG.camera.followLerp = FlxMath.bound(elapsed * 9 / (FlxG.updateFramerate / 60), 0, 1);
		
		if (!selectedSomethin && finishedFunnyMove) {
			if (controls.UI_UP_P) {
				FlxG.sound.play(Paths.sound("scrollMenu"));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P) {
				FlxG.sound.play(Paths.sound("scrollMenu"));
				changeItem(1);
			}

			if (controls.BACK) {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound("cancelMenu"));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT) {
				if (optionShit[curSelected] == "donate")
					CoolUtil.browserLoad("https://ninja-muffin24.itch.io/funkin");
				else {
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound("confirmMenu"));

					if(ClientPrefs.data.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite) {
						if (curSelected != spr.ID) {
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween) {
									spr.kill();
								}
							});
						}
						else {
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
								var daChoice:String = optionShit[curSelected];

								switch (daChoice) {
									case "story_mode":
										MusicBeatState.switchState(new StoryMenuState());
									case "freeplay":
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case "mods":
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case "awards":
										MusicBeatState.switchState(new AchievementsMenuState());
									case "credits":
										MusicBeatState.switchState(new CreditsState());
									case "options":
										LoadingState.loadAndSwitchState(new OptionsDirect());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys)) {
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite) {
			spr.screenCenter(X);
		});

		#if HSCRIPT_ALLOWED
		hscript.call("update", [elapsed]);
		#end
	}

	public function changeItem(huh:Int = 0) {
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite) {
			spr.animation.play("idle");
			spr.updateHitbox();

			if (spr.ID == curSelected) {
				spr.animation.play("selected");
				var add:Float = 0;
				if (menuItems.length > 4)
					add = menuItems.length * 8;
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});

		#if HSCRIPT_ALLOWED
		hscript.call("changeItem", [huh]);
		#end
	}

	override function stepHit() {
		super.stepHit();

		#if HSCRIPT_ALLOWED
		hscript.call("stepHit", []);
		#end
	}

	override function beatHit() {
		super.beatHit();

		#if HSCRIPT_ALLOWED
		hscript.call("beatHit", []);
		#end
	}

	override function sectionHit() {
		super.sectionHit();

		#if HSCRIPT_ALLOWED
		hscript.call("sectionHit", []);
		#end
	}

	override function destroy() {
		#if HSCRIPT_ALLOWED
		hscript.call("destroy", []);
		hscript = null;
		#end

		super.destroy();
	}
}
