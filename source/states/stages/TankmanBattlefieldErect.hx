package states.stages;

import flixel.FlxSprite;

class TankmanBattlefieldErect extends BaseStage
{
	var sniper:FlxSprite;
	var tankBricks:FlxSprite;
	var enableMaskSeen:Bool = false;

	override function createPost()
	{
		sniper = cast getStageObject('sniper');
		tankBricks = cast getStageObject('tankBricks');
		resetBricks();
	}

	override function beatHit()
	{
		if(sniper != null && sniper.animation != null && FlxG.random.bool(2))
			sniper.animation.play('sip', true);
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		if(eventName == 'EnableMask')
			enableMaskSeen = true;
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		resetBricks();
	}

	override function closeSubState()
	{
		resetBricks();
	}

	function resetBricks()
	{
		if(tankBricks != null)
			tankBricks.setPosition(445, 774);
	}
}
