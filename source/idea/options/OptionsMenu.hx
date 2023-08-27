package idea.options;

import flixel.FlxCamera;
import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import idea.options.Options;
import idea.backend.Controls.Control;
import openfl.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OptionCata extends FlxSprite {
	public var title:String;
	public var options:Array<Option>;

	public var optionObjects:FlxTypedGroup<FlxText>;

	public var titleObject:FlxText;

	public var middle:Bool = false;

	public function new(x:Float, y:Float, _title:String, _options:Array<Option>, middleType:Bool = false) {
		super(x, y);
		title = _title;
		middle = middleType;
		if (!middleType)
			makeGraphic(295, 64, FlxColor.BLACK);
		alpha = 0.4;

		options = _options;

		optionObjects = new FlxTypedGroup();

		titleObject = new FlxText((middleType ? 1180 / 2 : x), y + (middleType ? 0 : 16), 0, title);
		titleObject.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleObject.borderSize = 3;

		if (middleType)
			titleObject.x = 50 + ((1180 / 2) - (titleObject.fieldWidth / 2));
		else
			titleObject.x += (width / 2) - (titleObject.fieldWidth / 2);

		titleObject.scrollFactor.set();

		scrollFactor.set();

		for (i in 0...options.length) {
			var opt = options[i];
			var text:FlxText = new FlxText((middleType ? 1180 / 2 : 72), titleObject.y + 54 + (46 * i), 0, opt.getValue());
			if (middleType)
				text.screenCenter(X);
			text.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.borderSize = 3;
			text.borderQuality = 1;
			text.scrollFactor.set();
			optionObjects.add(text);
		}
	}

	public function changeColor(color:FlxColor) {
		makeGraphic(295, 64, color);
	}
}

class OptionsMenu extends MusicBeatSubstate {
	public static var instance:OptionsMenu;

	public var background:FlxSprite;

	public var selectedCat:OptionCata;

	public var selectedOption:Option;

	public var selectedCatIndex = 0;
	public var selectedOptionIndex = 0;

	public var isInCat:Bool = false;

	public var options:Array<OptionCata>;

	public static var isInPause = false;

	public var shownStuff:FlxTypedGroup<FlxText>;

	public static var visibleRange = [114, 640];

	public function new(pauseMenu:Bool = false) {
		super();
		isInPause = pauseMenu;
	}

	public var menu:FlxTypedGroup<FlxSprite>;

	public var descText:FlxText;
	public var descBack:FlxSprite;

	override function create() {
		options = [
			new OptionCata(50, 40, "Gameplay", [
				new HitsoundOption("Funny notes does \"Tick!\" when you hit them."),
				new ControllerOption("Check this if you want to play with\na controller instead of using your Keyboard."),
				new RatingOffsetOption("Changes how late/early you have to hit for a \"Sick!\"\nHigher values mean you have to hit later."),
				new GhostTappingOption("Toggle counting pressing a directional input when no arrow is there as a miss."),
				new DownScrollOption("Toggle making the notes scroll down rather than up."),
				new ResetButtonOption("Toggle pressing R to gameover."),
				new InstantRespawnOption("Toggle if you instantly respawn after dying."),
				new CamZoomOption("Toggle the camera zoom in-game."),
				new KeyBindsOption("Edit your keybindings."),
				new NotesColorsOption("Customize your note colors!"),
				new CustomizeOption("Drag and drop gameplay modules to your prefered positions!")
			]),
			new OptionCata(345, 40, "Appearance", [
				new HideHudOption("Hides most HUD elements."),
				new LowDetailOption("Toggle stage distractions that can hinder your gameplay."),
				new MiddleScrollOption("Put your lane in the center or on the right."),
				new HealthAlphaOption("How much transparent should the health bar and icons be."),
				new ScoreTextOption("Toggle score text type."),
				new TimeBarOption("Show the song's current position as a scrolling bar."),
				new HealthColorsOption("The color behind icons now fit with their theme. (e.g. Pico = green)"),
				new OpponentStrumsOption("Toggle the opponent's strumline lighting up when it hits a note."),
				new ComboStackingOption("If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read.")
			]),
			new OptionCata(640, 40, "Misc", [
                new ColorblindOption("You can set colorblind filter. (makes the game more playable for colorblind people)"),
				#if !web new FPSCapOption("Change your FPS Cap."), #end
				new FPSOption("Toggle FPS Counter."),
				new FlashingOption("Toggle flashing lights that can cause epileptic seizures and strain."),
				new AntialiasingOption("Toggle anti-aliasing, improving graphics quality at a slight performance penalty."),
				new ScoreScreenOption("Show the score screen after the end of a song."),
				new ShadersOption("Toggle shaders, It\'s used for some visual effects, and also CPU intensive for weaker PCs."),
				new PauseMusicOption("What song do you prefer for the Pause Screen?")
			]),
			new OptionCata(935, 40, "Judgements", [
				new SickWindowOption("How many milliseconds are in the SICK hit window."),
				new GoodWindowOption("How many milliseconds are in the GOOD hit window."),
				new BadWindowOption("How many milliseconds are in the BAD hit window.")
			])
		];

		/*options = [
			new OptionCata(50, 40, "Gameplay", [
				new Option("Rating Offset", "Changes how late/early you have to hit for a \"Sick!\"\nHigher values mean you have to hit later.", "ratingOffset", int, {minInt: -30, maxInt: 30, stepInt: 1}),
				new Option("Ghost Tapping", "Toggle counting pressing a directional input when no arrow is there as a miss.", "ghostTapping", bool),
				new Option("Downscroll", "Toggle making the notes scroll down rather than up.", "downScroll", bool),
				new Option("No Reset", "Toggle pressing R to gameover.", "noReset", bool),
				new Option("Instant Respawn", "Toggle if you instantly respawn after dying.", "instantRespawn", bool),
				new Option("CamZoomOption", "Toggle the camera zoom in-game.", "camZooms", bool),
				new Option("Edit Keybindings", "Edit your keybindings.", "", special, function() {
					if (!isInPause)
						openSubState(new ControlsSubState());
				}),
				new Option("Edit Notes Colors", "Customize your note colors!", "", special, function() {
					if (!isInPause)
						openSubState(new NotesSubState());
				}),
				new Option("Edit Delay and Combo", "Drag and drop gameplay modules to your prefered positions!", "", special, function() {
					if (isInPause)
						MusicBeatState.switchState(new NoteOffsetState());
				})
			]),
			new OptionCata(345, 40, "Appearance", [
				new Option("Note Splashes", "Toggle hitting \"Sick!\" notes show particles.", "noteSplashes", bool),
				new Option("Low Quality", "Toggle some stage distractions.", "lowQuality", bool),
				new Option("Middlescroll", "Put your lane in the center or on the right.", "middleScroll", bool),
				new Option("Health Bar Transparency", "How much transparent should the health bar and icons be.", "healthBarAlpha", percent, {minFloat: 0, maxFloat: 1, stepFloat: 0.1}),
				new Option("Classic Score Text", "Toggle score text type.", "classicScoreText", bool),
				new Option("Time Bar", "Show the song's current position as a scrolling bar.", "showTimeBar", bool),
				new Option("Health Bar Colors", "The color behind icons now fit with their theme. (e.g. Pico = green)", "healthBarColors", bool),
				new Option("Opponent Strums", "Toggle the opponent's strumline visible.", "opponentStrums", bool)
			]),
			new OptionCata(640, 40, "Misc", [
				#if !web new Option("FPS Cap", "Change your FPS Cap.", "framerate", int, {minInt: 60, maxInt: 360, stepInt: 10}, function() {
					if (ClientPrefs.data.framerate > FlxG.drawFramerate) {
						FlxG.updateFramerate = ClientPrefs.data.framerate;
						FlxG.drawFramerate = ClientPrefs.data.framerate;
					} else {
						FlxG.drawFramerate = ClientPrefs.data.framerate;
						FlxG.updateFramerate = ClientPrefs.data.framerate;
					}
				}), #end
				new Option("Flashing Lights", "Toggle flashing lights that can cause epileptic seizures and strain.", "flashing", bool),
				new Option("Anti-Aliasing", "Toggle anti-aliasing, improving graphics quality at a slight performance penalty.", "antialiasing", bool),
				new Option("Score Screen", "Show the score screen after the end of a song.", "scoreScreen", bool)
			]),
			new OptionCata(935, 40, "Judgements", [
				new Option("SICK Window", "How many milliseconds are in the SICK hit window.", "sickWindow", int, {minInt: 15, maxInt: 45, stepInt: 1, postfix: "ms"}),
				new Option("GOOD Window", "How many milliseconds are in the GOOD hit window.", "goodWindow", int, {minInt: 15, maxInt: 90, stepInt: 1, postfix: "ms"}),
				new Option("BAD Window", "How many milliseconds are in the BAD hit window.", "badWindow", int, {minInt: 15, maxInt: 135, stepInt: 1, postfix: "ms"})
			])
		];*/

		instance = this;

		menu = new FlxTypedGroup<FlxSprite>();

		shownStuff = new FlxTypedGroup<FlxText>();

		background = new FlxSprite(50, 40).makeGraphic(1180, 640, FlxColor.BLACK);
		background.alpha = 0.5;
		background.scrollFactor.set();
		menu.add(background);

		descBack = new FlxSprite(50, 640).makeGraphic(1180, 38, FlxColor.BLACK);
		descBack.alpha = 0.3;
		descBack.scrollFactor.set();
		menu.add(descBack);

		if (isInPause)
		{
			var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			bg.alpha = 0;
			bg.scrollFactor.set();
			menu.add(bg);

			background.alpha = 0.5;
			bg.alpha = 0.6;

			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		}

		selectedCat = options[selectedCatIndex];

		selectedOption = selectedCat.options[selectedOptionIndex];

		add(menu);

		add(shownStuff);

		for (i in 0...options.length) {
			if (i >= 4)
				continue;
			var cat = options[i];
			add(cat);
			add(cat.titleObject);
		}

		descText = new FlxText(62, 648);
		descText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.borderSize = 2;

		add(descBack);
		add(descText);

		isInCat = true;

		switchCat(selectedCat);

		selectedOption = selectedCat.options[selectedOptionIndex];

		super.create();
	}

	public function switchCat(cat:OptionCata, checkForOutOfBounds:Bool = true) {
		try {
			visibleRange = [114, 640];
			if (cat.middle)
				visibleRange = [Std.int(cat.titleObject.y), 640];
			if (selectedOption != null)
			{
				var object = selectedCat.optionObjects.members[selectedOptionIndex];
				object.text = selectedOption.getValue();
			}

			if (selectedCatIndex > options.length - 1 && checkForOutOfBounds)
				selectedCatIndex = 0;

			if (selectedCat.middle)
				remove(selectedCat.titleObject);

			selectedCat.changeColor(FlxColor.BLACK);
			selectedCat.alpha = 0.3;

			for (i in 0...selectedCat.options.length)
			{
				var opt = selectedCat.optionObjects.members[i];
				opt.y = selectedCat.titleObject.y + 54 + (46 * i);
			}

			while (shownStuff.members.length != 0)
			{
				shownStuff.members.remove(shownStuff.members[0]);
			}
			selectedCat = cat;
			selectedCat.alpha = 0.2;
			selectedCat.changeColor(FlxColor.WHITE);

			if (selectedCat.middle)
				add(selectedCat.titleObject);

			for (i in selectedCat.optionObjects)
				shownStuff.add(i);

			selectedOption = selectedCat.options[0];

			if (selectedOptionIndex > options[selectedCatIndex].options.length - 1)
			{
				for (i in 0...selectedCat.options.length)
				{
					var opt = selectedCat.optionObjects.members[i];
					opt.y = selectedCat.titleObject.y + 54 + (46 * i);
				}
			}

			selectedOptionIndex = 0;

			if (!isInCat)
				selectOption(selectedOption);

			for (i in selectedCat.optionObjects.members)
			{
				if (i.y < visibleRange[0] - 24)
					i.alpha = 0;
				else if (i.y > visibleRange[1] - 24)
					i.alpha = 0;
				else
				{
					i.alpha = 0.4;
				}
			}
		}
		catch (e) {
			selectedCatIndex = 0;
		}
	}

	public function selectOption(option:Option) {
		var object = selectedCat.optionObjects.members[selectedOptionIndex];

		selectedOption = option;

		if (!isInCat) {
			object.text = "> " + option.getValue();
			descText.text = option.getDescription();
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (selectedCat != null && !isInCat) {
			for (i in selectedCat.optionObjects.members) {
				if (selectedCat.middle)
					i.screenCenter(X);

				if (i.y < visibleRange[0] - 24)
					i.alpha = 0;
				else if (i.y > visibleRange[1] - 24)
					i.alpha = 0;
				else {
					if (selectedCat.optionObjects.members[selectedOptionIndex].text != i.text)
						i.alpha = 0.4;
					else
						i.alpha = 1;
				}
			}
		}

		try {
			if (isInCat) {
				descText.text = "Please select a category";
				if (controls.UI_RIGHT_P) {
					FlxG.sound.play(Paths.sound('scrollMenu'), isInPause ? 0.4 : 1);
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					selectedCatIndex++;

					if (selectedCatIndex > options.length - 1)
						selectedCatIndex = 0;
					if (selectedCatIndex < 0)
						selectedCatIndex = options.length - 1;

					switchCat(options[selectedCatIndex]);
				}
				else if (controls.UI_LEFT_P) {
					FlxG.sound.play(Paths.sound('scrollMenu'), isInPause ? 0.4 : 1);
					selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
					selectedCatIndex--;

					if (selectedCatIndex > options.length - 1)
						selectedCatIndex = 0;
					if (selectedCatIndex < 0)
						selectedCatIndex = options.length - 1;

					switchCat(options[selectedCatIndex]);
				}

				if (controls.ACCEPT) {
					FlxG.sound.play(Paths.sound('scrollMenu'), isInPause ? 0.4 : 1);
					selectedOptionIndex = 0;
					isInCat = false;
					selectOption(selectedCat.options[selectedOptionIndex]);
				}

				if (controls.BACK) {
					if (!isInPause) {
						FlxG.sound.play(Paths.sound("cancelMenu"));
						MusicBeatState.switchState(new MainMenuState());
					}
					else {
						PlayState.instance.openPauseMenu();
						PauseSubState.saveMusic = false;
					}
				}
			}
			else
			{
				if (selectedOption != null) {
					if (selectedOption.acceptType) {
						if (controls.BACK && selectedOption.waitingType) {
							FlxG.sound.play(Paths.sound('scrollMenu'), isInPause ? 0.4 : 1);
							selectedOption.waitingType = false;
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							object.text = "> " + selectedOption.getValue();
							return;
						}
						else if (FlxG.keys.justPressed.ANY || (FlxG.gamepads.lastActive != null ? FlxG.gamepads.lastActive.justPressed.ANY : false))
						{
							var object = selectedCat.optionObjects.members[selectedOptionIndex];
							selectedOption.onType(FlxG.gamepads.lastActive == null ? FlxG.keys.getIsDown()[0].ID.toString() : FlxG.gamepads.lastActive.firstJustPressedID());
							object.text = "> " + selectedOption.getValue();
						}
					}
				}

				if (selectedOption.acceptType || !selectedOption.acceptType) {
					if (controls.ACCEPT) {
						FlxG.sound.play(Paths.sound('scrollMenu'), isInPause ? 0.4 : 1);
						var prev = selectedOptionIndex;
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.press();

						if (selectedOptionIndex == prev) {
							ClientPrefs.saveSettings();
							object.text = "> " + selectedOption.getValue();
						}
					}

					if (controls.UI_DOWN_P) {
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'), isInPause ? 0.4 : 1);
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						selectedOptionIndex++;

						// just kinda ignore this math lol

						if (selectedOptionIndex > options[selectedCatIndex].options.length - 1) {
							for (i in 0...selectedCat.options.length) {
								var opt = selectedCat.optionObjects.members[i];
								opt.y = selectedCat.titleObject.y + 54 + (46 * i);
							}
							selectedOptionIndex = 0;
						}

						if (selectedOptionIndex != 0 && selectedOptionIndex != options[selectedCatIndex].options.length - 1 && options[selectedCatIndex].options.length > 6) {
							if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2) {
								for (i in selectedCat.optionObjects.members)
									i.y -= 46;
							}
						}

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
					}
					else if (controls.UI_UP_P) {
						if (selectedOption.acceptType)
							selectedOption.waitingType = false;
						FlxG.sound.play(Paths.sound('scrollMenu'), isInPause ? 0.4 : 1);
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						selectedOptionIndex--;

						if (selectedOptionIndex < 0) {
							selectedOptionIndex = options[selectedCatIndex].options.length - 1;

							if (options[selectedCatIndex].options.length > 6) {
								for (i in selectedCat.optionObjects.members)
									i.y -= (46 * ((options[selectedCatIndex].options.length - 1) / 2));
							}
						}

						if (selectedOptionIndex != 0 && options[selectedCatIndex].options.length > 6) {
							if (selectedOptionIndex >= (options[selectedCatIndex].options.length - 1) / 2) {
								for (i in selectedCat.optionObjects.members)
									i.y += 46;
							}
						}

						if (selectedOptionIndex < (options[selectedCatIndex].options.length - 1) / 2) {
							for (i in 0...selectedCat.options.length) {
								var opt = selectedCat.optionObjects.members[i];
								opt.y = selectedCat.titleObject.y + 54 + (46 * i);
							}
						}

						selectOption(options[selectedCatIndex].options[selectedOptionIndex]);
					}

					if (controls.UI_RIGHT_P) {
						FlxG.sound.play(Paths.sound('scrollMenu'), isInPause ? 0.4 : 1);
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.right();

						object.text = "> " + selectedOption.getValue();
					}
					else if (controls.UI_LEFT_P) {
						FlxG.sound.play(Paths.sound('scrollMenu'), isInPause ? 0.4 : 1);
						var object = selectedCat.optionObjects.members[selectedOptionIndex];
						selectedOption.left();

						object.text = "> " + selectedOption.getValue();
					}

					if (controls.BACK) {
						FlxG.sound.play(Paths.sound('scrollMenu'), isInPause ? 0.4 : 1);

						if (selectedCatIndex >= 4)
							selectedCatIndex = 0;

						for (i in 0...selectedCat.options.length)
						{
							var opt = selectedCat.optionObjects.members[i];
							opt.y = selectedCat.titleObject.y + 54 + (46 * i);
						}
						selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
						isInCat = true;
						if (selectedCat.optionObjects != null)
							for (i in selectedCat.optionObjects.members)
							{
								if (i != null)
								{
									if (i.y < visibleRange[0] - 24)
										i.alpha = 0;
									else if (i.y > visibleRange[1] - 24)
										i.alpha = 0;
									else
									{
										i.alpha = 0.4;
									}
								}
							}
						if (selectedCat.middle)
							switchCat(options[0]);
					}
				}
			}
		} catch (e) {
			selectedCatIndex = 0;
			selectedOptionIndex = 0;
			FlxG.sound.play(Paths.sound('scrollMenu'), isInPause ? 0.4 : 1);
			if (selectedCat != null) {
				for (i in 0...selectedCat.options.length) {
					var opt = selectedCat.optionObjects.members[i];
					opt.y = selectedCat.titleObject.y + 54 + (46 * i);
				}
				selectedCat.optionObjects.members[selectedOptionIndex].text = selectedOption.getValue();
				isInCat = true;
			}
		}

		if (isInPause && PauseSubState.pauseMusic.volume < 0.5)
			PauseSubState.pauseMusic.volume += 0.01 * elapsed;
	}
}