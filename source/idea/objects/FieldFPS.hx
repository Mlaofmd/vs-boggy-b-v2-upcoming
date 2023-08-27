package idea.objects;

import flixel.math.FlxMath;
import openfl.Lib;
import openfl.events.Event;
import flixel.FlxG;
import openfl.text.TextFormat;
import flixel.util.FlxColor;
import openfl.text.TextField;

class FieldFPS extends TextField {
    public var currentFPS(default, null):Int;

    @:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

    public function new(x:Float = 10, y:Float = 10) {
        super();
        this.x = x;
        this.y = y;
        selectable = false;
        mouseEnabled = false;
        defaultTextFormat = new TextFormat(Paths.limeFont("vcr.ttf").name, 14, FlxColor.WHITE);
        autoSize = LEFT;
        multiline = true;

        currentFPS = 0;

        cacheCount = 0;
		currentTime = 0;
		times = [];

        FlxG.stage.addEventListener(Event.ENTER_FRAME, function(?e:Event) {
            update(Lib.getTimer() - currentTime);
        });
    }

    private function update(elapsed:Float) {
        currentTime += elapsed;
		times.push(currentTime);

        while (times[0] < currentTime - 1000)
			times.shift();

        var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

        if (currentCount != cacheCount)
		{
            text = "FPS: " + currentFPS;

            var memoryUsed:Float = Math.abs(FlxMath.roundDecimal(Native.getTotalRAM() / 1000000, 1));
            var memoryPostfix:String = (memoryUsed > 1000 ? "GB" : "MB");
            if (memoryUsed < 1000)
                memoryUsed = Math.round(memoryUsed);
            else if (memoryUsed > 1000)
                memoryUsed = FlxMath.roundDecimal(memoryUsed / 1000, 3);

            text += "\nMEM: " + memoryUsed + memoryPostfix;
		}

        cacheCount = currentCount;
    }
}