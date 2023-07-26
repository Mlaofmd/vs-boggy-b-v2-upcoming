package idea.scripts;

import flixel.FlxG;
import sys.io.File;
import hscript.Parser;
import hscript.Interp;

class FunkinHScript {
    public var interp:Interp = new Interp();
    public var parser:Parser = new Parser();

    public function new(file:String) {
        if (file != null && file.length > 0) {
            try {
                interp.execute(parser.parseString(File.getContent(file)));
            } catch(e:Dynamic)
                alert(e);
        }

        set("import", function(name:String, as:String) {
            var array:Array<String> = name.split(".");
            var pack:String = "";
            while (array.length > 1) {
                pack += array[0] + ".";
                array.shift();
            }
            var name:String = array[0];

            set(name, Type.resolveClass(pack + name));
        });
    }

    public function set(name:String, value:Dynamic) {
        interp.variables.set(name, value);
    }

    public function call(event:String, args:Array<Dynamic>):Dynamic {
        if (interp.variables.exists(event)) {
            try {
                return Reflect.callMethod(interp.variables, interp.variables[event], args);
            } catch(e:Dynamic)
                alert(e);
        }
        return null;
    }

    public function alert(e:Dynamic) {
        FlxG.stage.application.window.alert(e, "Error on HScript!");
    }
}