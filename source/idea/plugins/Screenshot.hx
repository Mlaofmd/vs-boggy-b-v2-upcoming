package idea.plugins;

import sys.io.File;
import sys.FileSystem;
import openfl.display.PNGEncoderOptions;
import openfl.utils.ByteArray;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import flixel.FlxG;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.input.keyboard.FlxKey;
import flixel.FlxBasic;

using StringTools;

class Screenshot extends FlxBasic {
    inline static var COOLDOWN:Float = 1;
    private var cdTimer:Float = 0;

    public static var enabled:Bool = true;
    public static var binds:Array<FlxKey> = [F2];
    public static var sound:FlxSoundAsset = null;

    public static var onScreenshotTaken(default, null):FlxTypedSignal<Bitmap->Void> = new FlxTypedSignal<Bitmap->Void>();
    public static var onScreenshotTakenPost(default, null):FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();

    private var container:Sprite;
    private var flashSprite:Sprite;
    private var flashBitmap:Bitmap;
    private var screenshotSprite:Sprite;
    private var shotDisplayBitmap:Bitmap;
    private var outlineBitmap:Bitmap;

    public function new() {
        super();

        container = new Sprite();
        FlxG.stage.addChild(container);

        flashSprite = new Sprite();
        flashSprite.alpha = 0;
        flashBitmap = new Bitmap(new BitmapData(FlxG.width, FlxG.width, true, FlxColor.WHITE));
        flashSprite.addChild(flashBitmap);

        screenshotSprite = new Sprite();
        screenshotSprite.alpha = 0;
        container.addChild(screenshotSprite);

        outlineBitmap = new Bitmap(new BitmapData(Std.int(FlxG.width / 5) + 10, Std.int(FlxG.width / 5) + 10, true, FlxColor.WHITE));
        outlineBitmap.x = 5;
        outlineBitmap.y = 5;
        screenshotSprite.addChild(outlineBitmap);

        shotDisplayBitmap = new Bitmap();
        shotDisplayBitmap.scaleX /= 5;
        shotDisplayBitmap.scaleY /= 5;
        screenshotSprite.addChild(shotDisplayBitmap);
        container.addChild(flashSprite);

        FlxG.signals.gameResized.add(resizeBitmap);
    }

    override public function update(elapsed:Float):Void {
        if (FlxG.keys.anyJustPressed(binds) && enabled)
            shot();

        if (cdTimer > 0)
            cdTimer -= elapsed;
        if (cdTimer < 0)
            cdTimer = 0;

        super.update(elapsed);
    }

    private function shot():Void {
        for (sprite in [flashSprite, screenshotSprite]) {
            FlxTween.cancelTweensOf(sprite);
            sprite.alpha = 0;
        }

        var shot:Bitmap = new Bitmap(BitmapData.fromImage(FlxG.stage.window.readPixels()));
        onScreenshotTaken.dispatch(shot);

        var png:ByteArray = shot.bitmapData.encode(shot.bitmapData.rect, new PNGEncoderOptions());
        png.position = 0;

        var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "'");
        var path = "./screenshots/Screenshot_" + dateNow + ".png";
        if (!FileSystem.exists('./screenshots/'))
            FileSystem.createDirectory("./screenshots/");
        File.saveBytes(path, png);

        flashSprite.alpha = 1;
        FlxTween.tween(flashSprite, {alpha: 0}, 0.25);

        shotDisplayBitmap.bitmapData = shot.bitmapData;
        shotDisplayBitmap.x = outlineBitmap.x + 5;
        shotDisplayBitmap.y = outlineBitmap.y + 5;

        screenshotSprite.alpha = 1;
        FlxTween.tween(screenshotSprite, {alpha: 0}, 0.5, {startDelay: .5});

        if (sound != null)
            FlxG.sound.play(sound);

        onScreenshotTakenPost.dispatch();
    }

    private function resizeBitmap(width:Int, height:Int) {
        flashBitmap.bitmapData = new BitmapData(width, height, true, FlxColor.WHITE);
        outlineBitmap.bitmapData = new BitmapData(Std.int(width / 5) + 10, Std.int(height / 5) + 10, true, FlxColor.WHITE);
    }

    override function destroy() {
        if (FlxG.plugins.list.contains(this))
            FlxG.plugins.remove(this);

        FlxG.signals.gameResized.remove(resizeBitmap);
        FlxG.stage.removeChild(container);

        super.destroy();

        if (container == null)
            return;

        @:privateAccess {
            for (parent in [container, flashSprite, screenshotSprite]) {
                for (child in parent.__children)
                    parent.removeChild(child);
            }
        }

        container = null;
        flashSprite = null;
        flashBitmap = null;
        screenshotSprite = null;
        shotDisplayBitmap = null;
        outlineBitmap = null;
    }
}