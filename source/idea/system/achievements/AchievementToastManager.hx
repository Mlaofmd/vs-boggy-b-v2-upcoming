package idea.system.achievements;

import flixel.FlxG;
import openfl.display.Sprite;

class AchievementToastManager extends Sprite {
	public function new() {
		super();
	}

	public function giveAchievement(name:String, ?onFinish:Void->Void) {
		var data:AchievementData = AchievementData.achievementsLoaded[name];
		if (!AchievementData.isAchievementUnlocked(data.fileName)) {
			AchievementData.achievementsMap.set(data.fileName, true);
			var toast:AchievementToast = new AchievementToast(name);
			toast.onFinish = onFinish;
			addChild(toast);
			FlxG.sound.play(Paths.sound("confirmMenu"), 0.7);
		}
	}
}