package states.stages;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class SpookyMansionErect extends BaseStage
{
	var bgLight:FlxSprite;
	var stairsLight:FlxSprite;
	var lightningStrikeBeat:Int = 0;
	var lightningStrikeOffset:Int = 8;
	var postShockCounter:Int = 0;
	var postShockActive:Bool = false;

	override function create()
	{
		Paths.sound('thunder_1');
		Paths.sound('thunder_2');
	}

	override function createPost()
	{
		bgLight = cast getStageObject('bgLight');
		stairsLight = cast getStageObject('stairsLight');

		if (bgLight != null)
			bgLight.alpha = 0.0001;
		if (stairsLight != null)
			stairsLight.alpha = 0.0001;
	}

	override function beatHit()
	{
		if (songName == 'spookeez' && curBeat == 4)
			doLightningStrike(false);

		if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningStrikeOffset)
			doLightningStrike(true);
	}

	override function stepHit()
	{
		if (postShockActive)
		{
			postShockCounter++;
			if (postShockCounter >= 10)
			{
				postShockCounter = 0;
				postShockActive = false;
			}
		}
	}

	function doLightningStrike(playSound:Bool):Void
	{
		if (playSound)
			FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));

		if (bgLight != null)
			bgLight.alpha = 1;
		if (stairsLight != null)
			stairsLight.alpha = 1;
		if (boyfriend != null)
			boyfriend.alpha = 0;
		if (dad != null)
			dad.alpha = 0;
		if (gf != null)
			gf.alpha = 0;

		new FlxTimer().start(0.06, function(_)
		{
			if (bgLight != null)
				bgLight.alpha = 0;
			if (stairsLight != null)
				stairsLight.alpha = 0;
			if (boyfriend != null)
				boyfriend.alpha = 1;
			if (dad != null)
				dad.alpha = 1;
			if (gf != null)
				gf.alpha = 1;
		});

		new FlxTimer().start(0.12, function(_)
		{
			if (bgLight != null)
			{
				bgLight.alpha = 1;
				FlxTween.tween(bgLight, {alpha: 0}, 1.5);
			}
			if (stairsLight != null)
			{
				stairsLight.alpha = 1;
				FlxTween.tween(stairsLight, {alpha: 0}, 1.5);
			}
			if (boyfriend != null)
			{
				boyfriend.alpha = 0;
				FlxTween.tween(boyfriend, {alpha: 1}, 1.5);
			}
			if (dad != null)
			{
				dad.alpha = 0;
				FlxTween.tween(dad, {alpha: 1}, 1.5);
			}
			if (gf != null)
			{
				gf.alpha = 0;
				FlxTween.tween(gf, {alpha: 1}, 1.5);
			}
		});

		lightningStrikeBeat = curBeat;
		lightningStrikeOffset = FlxG.random.int(8, 24);

		if (boyfriend != null
			&& boyfriend.hasAnimation('scared')
			&& boyfriend.animation.curAnim != null
			&& boyfriend.animation.curAnim.name != 'cheer')
			boyfriend.playAnim('scared', true);
		if (dad != null && dad.hasAnimation('scared'))
			dad.playAnim('scared', true);
		if (gf != null && gf.hasAnimation('scared'))
			gf.playAnim('scared', true);

		postShockCounter = 0;
		postShockActive = true;
	}
}
