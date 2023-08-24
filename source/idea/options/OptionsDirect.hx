package idea.options;

import flixel.FlxSprite;

class OptionsDirect extends MusicBeatState
{
	override function create() {
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		openSubState(new OptionsMenu());
	}
}
