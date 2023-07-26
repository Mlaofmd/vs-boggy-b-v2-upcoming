package idea.data;

import flixel.FlxSprite;
import flixel.FlxG;
import haxe.Json;
import sys.io.File;
import haxe.io.Path;
import sys.FileSystem;

using StringTools;

typedef AchievementFile = {
    var name:String;
    var description:String;
    var hidden:Bool;
}

class AchievementData {
	public static var henchmenDeath:Int = 0;

	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();
    public static var achievementsLoaded:Map<String, AchievementData> = [];
    public static var achievementsList:Array<String> = [];
    public var folder:String = "";

    public var name:String;
    public var description:String;
    public var hidden:Bool;
    
    public var fileName:String;

    public function createAchievementFile():AchievementFile {
        var achievementFile:AchievementFile = {
            name: "New Achievement",
            description: "Nothin'",
            hidden: false
        }
        return achievementFile;
    }

    public function new(achievementFile:AchievementFile, fileName:String) {
        for (field in Reflect.fields(achievementFile))
            Reflect.setProperty(this, field, Reflect.getProperty(achievementFile, field));

        this.fileName = fileName;
    }

    public static function reloadAchievementFiles() {
        achievementsList = [];
        achievementsLoaded.clear();

        #if MODS_ALLOWED
        var disabledMods:Array<String> = [];
        var modsListPath:String = 'modsList.txt';
        var directories:Array<String> = [Paths.mods(), Paths.getPreloadPath()];
        var originalLength:Int = directories.length;

        if (FileSystem.exists(modsListPath)) {
            var stuff:Array<String> = CoolUtil.coolTextFile(modsListPath);
            for (i in 0...stuff.length) {
				var splitName:Array<String> = stuff[i].trim().split("|");
				if (splitName[1] == "0") // Disable mod
					disabledMods.push(splitName[0]);
				else /* Sort mod loading order based on modsList.txt file */ {
					var path = Path.join([Paths.mods(), splitName[0]]);
					trace('trying to push: ' + splitName[0]);
					if (FileSystem.isDirectory(path) && !Paths.ignoreModFolders.contains(splitName[0]) && !disabledMods.contains(splitName[0]) && !directories.contains(path + '/')) {
						directories.push(path + "/");
						trace('pushed Directory: ' + splitName[0]);
					}
				}
			}
        }

        var modsDirectories:Array<String> = Paths.getModDirectories();
        for (folder in modsDirectories) {
			var pathThing:String = Path.join([Paths.mods(), folder]) + "/";
			if (!disabledMods.contains(folder) && !directories.contains(pathThing)) {
				directories.push(pathThing);
				trace('pushed Directory: ' + folder);
			}
		}
        #else
        var directories:Array<String> = [Paths.getPreloadPath()];
		var originalLength:Int = directories.length;
        #end

        var sexList:Array<String> = CoolUtil.coolTextFile(Paths.getPreloadPath("achievements/achievementList.txt"));
        for (i in 0...sexList.length) {
			for (j in 0...directories.length) {
				var fileToCheck:String = directories[j] + "achievements/" + sexList[i] + ".json";
				if (!achievementsLoaded.exists(sexList[i])) {
					var achievement:AchievementFile = getAchievementFile(fileToCheck);
					if (achievement != null) {
						var achievementFile:AchievementData = new AchievementData(achievement, sexList[i]);

						#if MODS_ALLOWED
						if (j >= originalLength)
							achievementFile.folder = directories[j].substring(Paths.mods().length, directories[j].length - 1);
						#end

						if (achievementFile != null) {
							achievementsLoaded.set(sexList[i], achievementFile);
							achievementsList.push(sexList[i]);
						}
					}
				}
			}
		}

        #if MODS_ALLOWED
		for (i in 0...directories.length) {
			var directory:String = directories[i] + "achievements/";
			if (FileSystem.exists(directory)) {
				var listOfWeeks:Array<String> = CoolUtil.coolTextFile(directory + "achievementList.txt");
				for (daWeek in listOfWeeks) {
					var path:String = directory + daWeek + ".json";
					if (FileSystem.exists(path))
						addAchievement(daWeek, path, directories[i], i, originalLength);
				}

				for (file in FileSystem.readDirectory(directory)) {
					var path = Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith(".json"))
						addAchievement(file.substr(0, file.length - 5), path, directories[i], i, originalLength);
				}
			}
		}
		#end
    }

    private static function addAchievement(achievementToCheck:String, path:String, directory:String, i:Int, originalLength:Int) {
        if (!achievementsLoaded.exists(achievementToCheck)) {
            var achievement:AchievementFile = getAchievementFile(path);
			if (achievement != null) {
				var achievementFile:AchievementData = new AchievementData(achievement, achievementToCheck);
				if (i >= originalLength) {
					#if MODS_ALLOWED
					achievementFile.folder = directory.substring(Paths.mods().length, directory.length-1);
					#end
				}
				achievementsLoaded.set(achievementToCheck, achievementFile);
				achievementsList.push(achievementToCheck);
			}
        }
    }

	private static function getAchievementFile(path:String):AchievementFile {
		var rawJson:String = null;
		#if MODS_ALLOWED
		if (FileSystem.exists(path))
			rawJson = File.getContent(path);
		#else
		if (OpenFlAssets.exists(path))
			rawJson = Assets.getText(path);
		#end

		if (rawJson != null && rawJson.length > 0)
			return cast Json.parse(rawJson);

		return null;
	}

	public static function unlockAchievement(name:String) {
		if (achievementsLoaded.exists(name)) {
			FlxG.log.add("Completed achievement: " + name);
			achievementsMap.set(name, true);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		} else
			FlxG.log.warn("Achievement \"" + name + "\" not found!");
	}

	public static function isAchievementUnlocked(name:String) {
		if (achievementsLoaded.exists(name) && achievementsMap.exists(name) && achievementsMap[name])
			return true;
		else
			FlxG.log.warn("Achievement \"" + name + "\" not found!");

		return false;
	}

	public static function loadAchievements() {
		reloadAchievementFiles();

		achievementsMap = [];
		if (FlxG.save.data != null) {
			if (FlxG.save.data.achievementsMap != null) {
				var tempMap:Map<String, Bool> = FlxG.save.data.achievementsMap;
				for (achieve in tempMap.keys()) {
					if (achievementsLoaded.exists(achieve))
						achievementsMap.set(achieve, tempMap[achieve]);
				}
			}

			if (henchmenDeath == 0 && FlxG.save.data.henchmenDeath != null)
				henchmenDeath = FlxG.save.data.henchmenDeath;
		}
	}
}