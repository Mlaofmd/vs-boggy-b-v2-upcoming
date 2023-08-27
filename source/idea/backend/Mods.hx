package idea.backend;

import idea.states.ModsMenuState.ModMetadata;
import sys.io.File;
import sys.FileSystem;

class Mods {
    public static function loadTheFirstEnabledMod():ModMetadata {
		Paths.currentModDirectory = "";
		
		#if MODS_ALLOWED
		if (FileSystem.exists("modsList.txt"))
		{
			var list:Array<String> = CoolUtil.listFromString(File.getContent("modsList.txt"));
			var foundTheTop = false;
			for (i in list)
			{
				var dat = i.split("|");
				if (dat[1] == "1" && !foundTheTop)
				{
					foundTheTop = true;
					Paths.currentModDirectory = dat[0];
					return new ModMetadata(dat[0]);
				}
			}
		}
		#end

		return null;
	}
}