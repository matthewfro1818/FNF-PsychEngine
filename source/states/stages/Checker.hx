package states.stages;

import states.stages.objects.*;

class Checker extends BaseStage
{
	// If you're moving your stage from PlayState to a stage file,
	// you might have to rename some variables if they're missing, for example: camZooming -> game.camZooming
	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("redfloor"));
		// bg.setGraphicSize(Std.int(bg.width * 2.5));
		// bg.updateHitbox();
		bg.antialiasing = true;
		// bg.scrollFactor.set(0.66, 0.66);
		bg.active = false;
		bg.screenCenter(XY);
		add(bg);
	}
}
