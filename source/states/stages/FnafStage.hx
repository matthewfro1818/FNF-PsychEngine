package states.stages;

import states.stages.objects.*;

class FnafStage extends BaseStage
{
	// If you're moving your stage from PlayState to a stage file,
	// you might have to rename some variables if they're missing, for example: camZooming -> game.camZooming
	override function create()
	{
			var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("bedroom"));
			bg.antialiasing = true;
			bg.active = false;
			bg.setGraphicSize(Std.int(bg.width * 0.9));
			bg.updateHitbox();
			bg.screenCenter(XY);
			add(bg);
	}
}
