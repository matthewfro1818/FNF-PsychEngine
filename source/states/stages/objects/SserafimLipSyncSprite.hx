package states.stages.objects;

import objects.Character;

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
			case 'sserafim-yunjin', 'sserafim-kazuha', 'sserafim-chaewon', 'sserafim-eunchae', 'sserafim-sakura': true;
			default: false;
		}
	}

	public var target:Character;
	public var shouldSing:Bool = false;

	var alphaMultiplier:Float;

	public function new(target:Character)
	{
		super();

		this.target = target;
		alphaMultiplier = (target != null && target.curCharacter == 'sserafim-chaewon') ? 0.5 : 1;

		var asset:String = (target != null && target.curCharacter == 'sserafim-yunjin') ? 'sserafim-lipsync-yunjin' : 'sserafim-lipsync';
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

		synchronizeTransform();
		applyPose();

		if (anim.curInstance != null && anim.curSymbol != null)
			anim.curFrame = shouldSing ? getSongFrame() : 0;

		visible = target.visible && target.alpha > 0.001;
	}

	function synchronizeTransform():Void
	{
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
	}

	function applyPose():Void
	{
		var pose:SserafimLipSyncPose = getPose(target.curCharacter, target.getAnimationName());
		offset.set(pose.offsetX, pose.offsetY);
		angle = target.angle + pose.angle;
	}

	function getSongFrame():Int
	{
		if (anim == null || anim.curInstance == null || anim.curSymbol == null)
			return 0;

		var frameCount:Int = Std.int(Math.max(anim.length, 1));
		if (frameCount <= 1)
			return 0;

		var frame:Int = Std.int(Math.floor((Conductor.songPosition / 1000) * 24)) - 1;
		if (frame < 0)
			return 0;
		return frame % frameCount;
	}

	static function getPose(char:String, anim:String):SserafimLipSyncPose
	{
		if (anim == null || anim.length < 1)
			anim = 'idle';

		return switch (char)
		{
			case 'sserafim-yunjin':
				switch (anim)
				{
					case 'singUP': pose(6, 8, 22);
					case 'singRIGHT', 'singLEFT': pose(6, 8, 23);
					case 'singDOWN', 'idle': pose(8, 6, 23);
					default: pose(8, 6, 23);
				}
			case 'sserafim-kazuha':
				switch (anim)
				{
					case 'singUP': pose(7, 2, -14);
					case 'singRIGHT': pose(7, 2, -13);
					case 'singDOWN': pose(4, 6, -12);
					case 'singLEFT': pose(5, 4, -14);
					case 'idle': pose(5, 4, -13);
					default: pose(5, 4, -13);
				}
			case 'sserafim-chaewon':
				switch (anim)
				{
					case 'singUP': pose(38, 0, -168);
					case 'singRIGHT': pose(39, 1, -165);
					case 'singDOWN': pose(41, 3, -167);
					case 'singLEFT': pose(40, 2, -165);
					case 'idle': pose(41, 3, -166);
					default: pose(41, 3, -166);
				}
			case 'sserafim-eunchae':
				switch (anim)
				{
					case 'singUP': pose(45, 10, -166);
					case 'singRIGHT': pose(42, 5, -166);
					case 'singDOWN': pose(41, 3, -168);
					case 'singLEFT': pose(43, 6, -169);
					case 'idle': pose(43, 6, -168);
					default: pose(43, 6, -168);
				}
			case 'sserafim-sakura':
				switch (anim)
				{
					case 'singUP': pose(8, 1, -15);
					case 'singRIGHT': pose(7, 2, -15);
					case 'singDOWN': pose(6, 3, -15);
					case 'singLEFT': pose(7, 2, -14);
					case 'singUP-joint': pose(10, -1, -14);
					case 'singRIGHT-joint': pose(6, 3, -15);
					case 'singDOWN-joint': pose(5, 5, -15);
					case 'singLEFT-joint': pose(7, 2, -16);
					case 'idle': pose(7, 2, -14);
					default: pose(7, 2, -14);
				}
			default:
				pose(0, 0, 0);
		}
	}

	static inline function pose(offsetX:Float, offsetY:Float, angle:Float):SserafimLipSyncPose
	{
		return {
			offsetX: offsetX,
			offsetY: offsetY,
			angle: angle
		};
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
