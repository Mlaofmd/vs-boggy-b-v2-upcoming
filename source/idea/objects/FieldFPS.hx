package idea.objects;

import flixel.math.FlxMath;
import openfl.Lib;
import openfl.events.Event;
import flixel.FlxG;
import openfl.utils.Assets;
import lime.text.Font;
import openfl.text.TextFormat;
import flixel.util.FlxColor;
import openfl.display.Bitmap;
import openfl.text.TextField;
import openfl.display.Sprite;

class FieldFPS extends Sprite {
    public var currentFPS(default, null):Int;

    private var source:TextField;
    private var output:Bitmap;

    @:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

    public function new(x:Float = 10, y:Float = 10) {
        super();

        if (stage != null)
            create();
        else
            addEventListener(Event.ADDED_TO_STAGE, create);
    }

    private function create(?e:Event) {
        if (hasEventListener(Event.ADDED_TO_STAGE))
            removeEventListener(Event.ADDED_TO_STAGE, create);
        
        currentFPS = 0;
        
        source = new TextField();
        source.x = x;
        source.y = y;
        source.selectable = false;
		source.mouseEnabled = false;
		source.defaultTextFormat = new TextFormat(Paths.limeFont("vcr.ttf").name, 14, FlxColor.WHITE);
		source.autoSize = LEFT;
		source.multiline = true;
        source.visible = visible;

        output = ImageOutline.renderImage(source, 1, 0xff000000, true);
        output.visible = visible;
        addChild(output);

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
            source.text = "FPS: " + currentFPS;

            var memoryUsed:Float = Math.abs(FlxMath.roundDecimal(Native.getTotalRAM() / 1000000, 1));
            var memoryPostfix:String = (memoryUsed > 1000 ? "GB" : "MB");
            if (memoryUsed < 1000)
                memoryUsed = Math.round(memoryUsed);
            else if (memoryUsed > 1000)
                memoryUsed = FlxMath.roundDecimal(memoryUsed / 1000, 3);

            source.text += "\nMEM: " + memoryUsed + memoryPostfix;
		}

        source.visible = visible;
        removeChild(output);

        output = ImageOutline.renderImage(source, 1, 0xff000000, true);
        output.visible = visible;

        addChild(output);
        source.visible = false;

        cacheCount = currentCount;
    }
}