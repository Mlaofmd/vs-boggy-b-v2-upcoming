package idea.objects;

class SpookyBackground extends BGSprite {
    public function new(x:Float = 0, y:Float = 0) {
        if (ClientPrefs.data.lowQuality)
            super("halloween_bg_low", x, y);
        else
            super("halloween_bg", -200, -100, ["halloweem bg0", "halloweem bg lightning strike"]);
    }

    override function dance(?forcePlay:Bool = false) {
        if (!ClientPrefs.data.lowQuality)
            animation.play('halloweem bg lightning strike');
    }
}