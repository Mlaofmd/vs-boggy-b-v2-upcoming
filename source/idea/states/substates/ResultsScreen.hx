package idea.states.substates;

import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class ResultsScreen extends MusicBeatSubstate {
    override function create() {
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0;
        add(bg);

        var clearedText:FlxText = new FlxText(20, -55, PlayState.isStoryMode ? "Week Cleared!" : "Song Cleared!");
        clearedText.setFormat(Paths.font("vcr.ttf"), 34);
        clearedText.setBorderStyle(OUTLINE, FlxColor.BLACK, 4, 1);
        add(clearedText);

        var comboText:FlxText = new FlxText(20, -75, "Judgements:");
        comboText.text += "\nPerfects: " + (PlayState.isStoryMode ? PlayState.campaignPerfects : PlayState.instance.perfects);
        comboText.text += "\nSicks: " + (PlayState.isStoryMode ? PlayState.campaignSicks : PlayState.instance.sicks);
        comboText.text += "\nGoods: " + (PlayState.isStoryMode ? PlayState.campaignGoods : PlayState.instance.goods);
        comboText.text += "\nBads: " + (PlayState.isStoryMode ? PlayState.campaignBads : PlayState.instance.bads);
        comboText.text += "\nShits: " + (PlayState.isStoryMode ? PlayState.campaignShits : PlayState.instance.shits);
        comboText.text += "\nMisses: " + (PlayState.isStoryMode ? PlayState.campaignMisses : PlayState.instance.songMisses);
        comboText.text += "\n\nHighest Combo: " + (PlayState.isStoryMode ? PlayState.campaignCombo : PlayState.instance.highestCombo);
        comboText.text += "\nScore: " + (PlayState.isStoryMode ? PlayState.campaignScore : PlayState.instance.songScore);
        comboText.text += "\nAccuracy: " + Highscore.floorDecimal((PlayState.isStoryMode ? PlayState.campaignRating : PlayState.instance.ratingPercent) * 100, 2) + "%";
        comboText.text += "\nRating: " + PlayState.instance.ratingName + " (" + PlayState.instance.ratingFC + ")";
        comboText.setFormat(Paths.font("vcr.ttf"), 28);
        comboText.setBorderStyle(OUTLINE, FlxColor.BLACK, 4, 1);
        add(comboText);

        var continueText:FlxText = new FlxText(FlxG.width - 475, FlxG.height + 50, "Press ACCEPT to continue");
        continueText.setFormat(Paths.font("vcr.ttf"), 28);
        continueText.setBorderStyle(OUTLINE, FlxColor.BLACK, 4, 1);
        add(continueText);

        FlxTween.tween(bg, {alpha: 0.5}, 0.5);
        FlxTween.tween(clearedText, {y: 20}, 0.5, {ease: FlxEase.expoInOut});
        FlxTween.tween(comboText, {y: 145}, 0.5, {ease: FlxEase.expoInOut});
        FlxTween.tween(continueText, {y: FlxG.height - 45}, 0.5, {ease: FlxEase.expoInOut});

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        super.create();
    }

    override function update(elapsed:Float) {
        if (controls.ACCEPT) {
            close();
            PlayState.instance.closeResultsMenu();
        }

        super.update(elapsed);
    }
}