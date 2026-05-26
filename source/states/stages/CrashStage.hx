package states.stages;

import states.stages.objects.*;

class CrashStage extends BaseStage
{
	// If you're moving your stage from PlayState to a stage file,
	// you might have to rename some variables if they're missing, for example: camZooming -> game.camZooming
	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("rockslide"));
		bg.antialiasing = true;
		bg.active = false;
		bg.screenCenter(XY);
		add(bg);
	}
}
