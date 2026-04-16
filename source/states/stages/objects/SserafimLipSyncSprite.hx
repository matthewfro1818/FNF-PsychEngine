package states.stages.objects;

import objects.Character;
import flixel.FlxSprite;

#if flxanimate
import backend.ClientPrefs;
import backend.Conductor;
import backend.Paths;
import flxanimate.PsychFlxAnimate as FlxAnimate;

typedef SserafimLipSyncPose =
{
	var offsetX:Float;
	var offsetY:Float;
	var angle:Float;
}

class SserafimLipSyncSprite extends FlxAnimate
{
	public static function supportsCharacter(char:String):Bool
	{
		return switch (char)
		{
			case 'sserafim-yunjin', 'sserafim-kazuha', 'sserafim-chaewon', 'sserafim-eunchae', 'sserafim-sakura':
				true;
			default:
				false;
		}
	}

	public var target:Character;
	public var shouldSing:Bool = false;
	var alphaMultiplier:Float = 1;

	public function new(target:Character)
	{
		super();
		this.target = target;
		alphaMultiplier = (target != null && target.curCharacter == 'sserafim-chaewon') ? 0.5 : 1;

		var asset:String = (target != null && target.curCharacter == 'sserafim-yunjin')
			? 'sserafim-lipsync-yunjin'
			: 'sserafim-lipsync';

		Paths.loadAnimateAtlas(this, asset);
		anim.addBySymbol('lipsync', 'lipsync', 24, false);
		anim.play('lipsync', true);
		antialiasing = ClientPrefs.data.antialiasing;
		visible = false;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (target == null || !supportsCharacter(target.curCharacter))
		{
			shouldSing = false;
			visible = false;
			return;
		}

		x = target.x;
		y = target.y;
		scale.set(target.scale.x, target.scale.y);
		scrollFactor.set(target.scrollFactor.x, target.scrollFactor.y);
		flipX = target.flipX;
		flipY = target.flipY;
		alpha = target.alpha * alphaMultiplier;
		color = target.color;
		shader = target.shader;
		cameras = target.cameras;

		var poseData:SserafimLipSyncPose = getPose(target.curCharacter, target.getAnimationName());
		offset.set(poseData.offsetX, poseData.offsetY);
		angle = target.angle + poseData.angle;

		if (anim != null && anim.curInstance != null && anim.curSymbol != null)
			anim.curFrame = shouldSing ? getSongFrame() : 0;

		visible = target.visible && target.alpha > 0.001;
	}

	function getSongFrame():Int
	{
		if (anim == null || anim.curInstance == null || anim.curSymbol == null)
			return 0;

		var frameCount:Int = Std.int(Math.max(anim.length, 1));
		if (frameCount <= 1) return 0;

		var frame:Int = Std.int(Math.floor((Conductor.songPosition / 1000) * 24)) - 1;
		if (frame < 0) return 0;

		return frame % frameCount;
	}

	static function getPose(char:String, anim:String):SserafimLipSyncPose
	{
		if (anim == null || anim.length < 1) anim = 'idle';

		return switch (char)
		{
			case 'sserafim-yunjin':
				switch (anim)
				{
					case 'singUP': {offsetX: 6, offsetY: 8, angle: 22};
					case 'singRIGHT', 'singLEFT': {offsetX: 6, offsetY: 8, angle: 23};
					default: {offsetX: 8, offsetY: 6, angle: 23};
				}
			case 'sserafim-kazuha':
				switch (anim)
				{
					case 'singUP': {offsetX: 7, offsetY: 2, angle: -14};
					case 'singRIGHT': {offsetX: 7, offsetY: 2, angle: -13};
					case 'singDOWN': {offsetX: 4, offsetY: 6, angle: -12};
					case 'singLEFT': {offsetX: 5, offsetY: 4, angle: -14};
					default: {offsetX: 5, offsetY: 4, angle: -13};
				}
			case 'sserafim-chaewon':
				switch (anim)
				{
					case 'singUP': {offsetX: 38, offsetY: 0, angle: -168};
					case 'singRIGHT': {offsetX: 39, offsetY: 1, angle: -165};
					case 'singDOWN': {offsetX: 41, offsetY: 3, angle: -167};
					case 'singLEFT': {offsetX: 40, offsetY: 2, angle: -165};
					default: {offsetX: 41, offsetY: 3, angle: -166};
				}
			case 'sserafim-eunchae':
				switch (anim)
				{
					case 'singUP': {offsetX: 45, offsetY: 10, angle: -166};
					case 'singRIGHT': {offsetX: 42, offsetY: 5, angle: -166};
					case 'singDOWN': {offsetX: 41, offsetY: 3, angle: -168};
					case 'singLEFT': {offsetX: 43, offsetY: 6, angle: -169};
					default: {offsetX: 43, offsetY: 6, angle: -168};
				}
			case 'sserafim-sakura':
				switch (anim)
				{
					case 'singUP': {offsetX: 8, offsetY: 1, angle: -15};
					case 'singRIGHT': {offsetX: 7, offsetY: 2, angle: -15};
					case 'singDOWN': {offsetX: 6, offsetY: 3, angle: -15};
					case 'singLEFT': {offsetX: 7, offsetY: 2, angle: -14};
					case 'singUP-joint': {offsetX: 10, offsetY: -1, angle: -14};
					case 'singRIGHT-joint': {offsetX: 6, offsetY: 3, angle: -15};
					case 'singDOWN-joint': {offsetX: 5, offsetY: 5, angle: -15};
					case 'singLEFT-joint': {offsetX: 7, offsetY: 2, angle: -16};
					default: {offsetX: 7, offsetY: 2, angle: -14};
				}
			default:
				{offsetX: 0, offsetY: 0, angle: 0};
		}
	}
}
#else
class SserafimLipSyncSprite extends FlxSprite
{
	public static function supportsCharacter(char:String):Bool
	{
		return false;
	}

	public var target:Character;
	public var shouldSing:Bool = false;

	public function new(target:Character)
	{
		super();
		this.target = target;
		visible = false;
	}
}
#end
