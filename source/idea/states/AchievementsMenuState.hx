package idea.states;

import sys.FileSystem;
#if desktop
import external.Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import idea.data.AchievementData;

using StringTools;

class AchievementsMenuState extends MusicBeatState {
	#if ACHIEVEMENTS_ALLOWED
	public var options:Array<String> = [];
	public var grpOptions:FlxTypedGroup<Alphabet>;
	public static var curSelected:Int = 0;
	public var achievementArray:Array<AttachedAchievement> = [];
	public var achievements:Array<AchievementData> = [];
	public var descText:FlxText;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Achievements Menu", null);
		#end

		var menuBG:FlxSprite = new FlxSprite(Paths.image('menuBGBlue'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = ClientPrefs.data.antialiasing;
		add(menuBG);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		AchievementData.loadAchievements();
		for (achieve in AchievementData.achievementsList) {
			if (!AchievementData.achievementsLoaded[achieve].hidden || (AchievementData.achievementsMap.exists(achieve) && AchievementData.achievementsMap[achieve])) {
				options.push(achieve);
				achievements.push(AchievementData.achievementsLoaded[achieve]);
			}
		}

		for (i in 0...options.length) {
			var achieveName:String = achievements[i].name;
			var optionText:Alphabet = new Alphabet(280, 300, AchievementData.isAchievementUnlocked(achievements[i].fileName) ? achieveName : "?", false);
			optionText.isMenuItem = true;
			optionText.targetY = i - curSelected;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			var icon:AttachedAchievement = new AttachedAchievement(optionText.x - 105, optionText.y, achieveName);
			icon.sprTracker = optionText;
			achievementArray.push(icon);
			add(icon);
		}

		descText = new FlxText(150, 600, 980, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);
		changeSelection();

		super.create();
	}

	override function update(elapsed:Float) {
		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	public function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}

		for (i in 0...achievementArray.length)
			achievementArray[i].alpha = (i == curSelected ? 1 : 0.6);

		descText.text = achievements[curSelected].description;
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}
	#end
}