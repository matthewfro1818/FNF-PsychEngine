package objects;

import backend.Conductor;
import flixel.FlxBasic;
import states.PlayState;

class Character3D extends FlxBasic
{
	public var debugMode:Bool = false;
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var holdTimer:Float = 0;
	public var canAutoAnim:Bool = true;
	public var canAutoIdle:Bool = true;

	public var modelView:ModelView;
	public var modelName:String = "";
	public var modelScale:Float = 1;
	public var model:ModelThing;
	public var initYaw:Float = 0;
	public var initPitch:Float = 0;
	public var initRoll:Float = 0;
	public var xOffset:Float = 0;
	public var yOffset:Float = 0;
	public var zOffset:Float = 0;
	public var ambient:Float = 1;
	public var specular:Float = 1;
	public var diffuse:Float = 1;
	public var animSpeed:Map<String, Float> = [];
	public var noLoopList:Array<String> = [];
	public var geoMap:Map<String, String> = [];
	public var atf:Bool = false;
	public var light:Bool = false;
	public var jointsPerVertex:Int = 4;

	var danced:Bool = false;

	public function new(modelView:ModelView, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super();
		curCharacter = character;
		this.isPlayer = isPlayer;
		this.modelView = modelView;

		var antialias = true;
		switch (curCharacter)
		{
			case 'bf':
				modelName = 'bf';
				noLoopList = ["idle", "singUP", "singLEFT", "singRIGHT", "singDOWN"];
				ambient = 0;
				specular = 0;
				diffuse = 1;
				initYaw = 65;
				zOffset = 150;
				geoMap = [
					"singUP" => "singUP",
					"singRIGHT" => "singRIGHT",
					"singDOWN" => "singDOWN",
					"idle" => "default",
					"idleEnd" => "default",
					"singLEFT" => "singUP"
				];
				atf = true;
			case 'gf':
				modelName = 'gf';
				noLoopList = ["danceLEFT", "danceRIGHT"];
				ambient = 0;
				specular = 0;
				diffuse = 1;
				xOffset = -100;
				yOffset = -20;
				atf = true;
			case 'senpai' | 'senpai-angry':
				modelName = curCharacter;
				noLoopList = ["idle", "singUP", "singLEFT", "singRIGHT", "singDOWN"];
				ambient = 0;
				specular = 0;
				diffuse = 1;
				initYaw = -65;
				zOffset = -150;
				yOffset = 70;
				geoMap = [
					"singUP" => "singUP",
					"singRIGHT" => "singRIGHT",
					"singDOWN" => "singDOWN",
					"singLEFT" => "singLEFT",
					"idle" => "default",
					"idleEnd" => "default"
				];
				antialias = false;
			case 'hydra':
				modelName = 'hydra';
				noLoopList = ["idle", "singUP", "singLEFT", "singRIGHT", "singDOWN"];
				ambient = 0.5;
				specular = 0.5;
				diffuse = 1;
				xOffset = -150;
				yOffset = 120;
				atf = true;
				light = true;
				jointsPerVertex = 1;
			default:
				modelName = curCharacter;
		}

		if (!animSpeed.exists("default"))
			animSpeed["default"] = 1;

		model = new ModelThing("awd", modelName, modelView, modelScale, animSpeed, initYaw, initPitch, initRoll, 1, xOffset, yOffset, zOffset, noLoopList,
			null, atf, antialias, ambient, specular, diffuse, light, jointsPerVertex);
		dance();
	}

	override function update(elapsed:Float)
	{
		if (model == null || !model.fullyLoaded || (PlayState.instance != null && PlayState.instance.endingSong))
			return;

		model.update();

		if (!isPlayer && getCurAnim().startsWith('sing'))
		{
			holdTimer += elapsed;
			if (holdTimer >= Conductor.stepCrochet * 4 * 0.001)
			{
				idleEnd();
				holdTimer = 0;
			}
		}

		super.update(elapsed);
	}

	public function dance(?ignoreDebug:Bool = false):Void
	{
		if ((PlayState.instance != null && PlayState.instance.endingSong) || model == null || !model.fullyLoaded)
			return;

		if (!debugMode || ignoreDebug)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-car' | 'gf-christmas' | 'gf-pixel':
					danced = !danced;
					playAnim(danced ? 'danceRIGHT' : 'danceLEFT', true);
				default:
					if (holdTimer == 0 && noLoopList.contains('idle'))
						playAnim('idle', true);
			}
		}
	}

	public function idleEnd(?ignoreDebug:Bool = false):Void
	{
		if ((PlayState.instance != null && PlayState.instance.endingSong) || model == null || !model.fullyLoaded)
			return;

		if (!debugMode || ignoreDebug)
		{
			if (animExists(getCurAnim() + "End"))
				playAnim(getCurAnim() + "End", true);
			else if (animExists('idleEnd'))
				playAnim('idleEnd', true);
			else
				playAnim('idle', true);
		}
	}

	public function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
	{
		if ((PlayState.instance != null && PlayState.instance.endingSong) || model == null || !model.fullyLoaded)
			return;

		if (animName.endsWith('-alt') && !animExists(animName))
			animName = animName.substring(0, animName.length - 4);

		var geo:String = geoMap.exists(animName) ? geoMap[animName] : "";
		if (animName.endsWith('miss'))
		{
			if (!animExists(animName))
				animName = animName.substring(0, animName.length - 4);
			geo = "miss";
			model.modelMaterial.colorTransform.redMultiplier = 0.2;
			model.modelMaterial.colorTransform.greenMultiplier = 0.2;
			model.modelMaterial.colorTransform.blueMultiplier = 0.75;
		}
		else
		{
			model.modelMaterial.colorTransform.redMultiplier = 1;
			model.modelMaterial.colorTransform.greenMultiplier = 1;
			model.modelMaterial.colorTransform.blueMultiplier = 1;
		}

		model.playAnim(animName, force, frame, geo);
	}

	public function getCurAnim():String
	{
		return model != null && model.fullyLoaded ? model.currentAnim : "";
	}

	public function animExists(anim:String):Bool
	{
		return model != null && model.fullyLoaded && model.animExists(anim);
	}

	override public function destroy()
	{
		if (model != null)
			model.destroy();
		model = null;
		modelView = null;
		if (animSpeed != null)
			animSpeed.clear();
		super.destroy();
	}
}
