package idea.system.achievements;

import openfl.Lib;
import openfl.events.Event;
import flixel.FlxG;
import openfl.text.TextFormatAlign;
import openfl.text.TextFormat;
import openfl.text.TextField;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenManager;
import openfl.display.Sprite;

class AchievementToast extends Sprite {
	public var onFinish:Void->Void;

	var tweenManager:FlxTweenManager;

	var bgTween:FlxTween;
	var iconTween:FlxTween;
	var nameTween:FlxTween;
	var textTween:FlxTween;

	private var currentTime:Float;
	private var timer:FlxTimer;

	public function new(name:String) {
		super();
		AchievementData.loadAchievements();
		ClientPrefs.saveSettings();

		if (AchievementData.achievementsLoaded.exists(name)) {
			var data:AchievementData = AchievementData.achievementsLoaded[name];

			var achievementBG:Bitmap = new Bitmap(new BitmapData(420, 120, FlxColor.BLACK));
			achievementBG.x = 60;
			achievementBG.y = 50;
			achievementBG.alpha = 0;

			var achievementIcon:Bitmap = new Bitmap(Paths.image("achievements/" + name).bitmap);
			achievementIcon.x = achievementBG.x + 10;
			achievementIcon.y = achievementBG.y + 10;
			achievementIcon.scaleX = achievementIcon.scaleY = (2 / 3);
			achievementIcon.smoothing = true;
			achievementIcon.alpha = 0;

			var achievementName:TextField = new TextField();
			achievementName.x = achievementIcon.x + achievementIcon.width + 20;
			achievementName.y = achievementIcon.y + 16;
			achievementName.width = 280;
			achievementName.text = data.name;
			achievementName.defaultTextFormat = new TextFormat(Paths.limeFont("vcr.ttf").name, 16, FlxColor.WHITE, TextFormatAlign.LEFT);
			achievementName.alpha = 0;
			
			var achievementText:TextField = new TextField();
			achievementText.x = achievementName.x;
			achievementText.y = achievementName.y + 32;
			achievementText.width = 280;
			achievementText.text = data.description;
			achievementText.defaultTextFormat = new TextFormat(Paths.limeFont("vcr.ttf").name, 16, FlxColor.WHITE, TextFormatAlign.LEFT);
			achievementText.alpha = 0;

			addChild(achievementBG);
			addChild(achievementName);
			addChild(achievementText);
			addChild(achievementIcon);

			tweenManager = new FlxTweenManager();

			bgTween = FlxTween.tween(achievementBG, {alpha: 1}, 0.5, {onComplete: function(twn:FlxTween) {
				bgTween = FlxTween.tween(achievementBG, {alpha: 0}, 0.5, {startDelay: 2.5, onComplete: function(twn:FlxTween) {
					bgTween = null;
					removeChild(achievementBG);
				}});
			}});

			iconTween = FlxTween.tween(achievementIcon, {alpha: 1}, 0.5, {onComplete: function(twn:FlxTween) {
				iconTween = FlxTween.tween(achievementIcon, {alpha: 0}, 0.5, {startDelay: 2.5, onComplete: function(twn:FlxTween) {
					iconTween = null;
					removeChild(achievementIcon);
				}});
			}});

			nameTween = FlxTween.tween(achievementName, {alpha: 1}, 0.5, {onComplete: function(twn:FlxTween) {
				nameTween = FlxTween.tween(achievementName, {alpha: 0}, 0.5, {startDelay: 2.5, onComplete: function(twn:FlxTween) {
					nameTween = null;
					removeChild(achievementName);
				}});
			}});

			textTween = FlxTween.tween(achievementText, {alpha: 1}, 0.5, {onComplete: function(twn:FlxTween) {
				textTween = FlxTween.tween(achievementText, {alpha: 0}, 0.5, {startDelay: 2.5, onComplete: function(twn:FlxTween) {
					textTween = null;
					removeChild(achievementText);
				}});
			}});

			timer = new FlxTimer().start(3.5, function(tmr:FlxTimer) {
				stage.removeChild(this);
				if (onFinish != null)
					onFinish();
			});

			FlxG.stage.addEventListener(Event.ENTER_FRAME, function(?e:Event) {
				update(Lib.getTimer() - currentTime);
			});
		} else
			FlxG.log.warn("Achievement \"" + name + "\" not found!");
	}

	private function update(elapsed:Float) {
		currentTime += elapsed;

		tweenManager.update(elapsed);

		if (timer != null && timer.active)
			timer.update(elapsed);
	}
}