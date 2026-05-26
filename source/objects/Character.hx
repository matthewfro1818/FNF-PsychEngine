package objects;

import backend.animation.PsychAnimationController;
import flixel.util.FlxSort;
import flixel.util.FlxDestroyUtil;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import backend.Song;
import states.stages.objects.TankmenBG;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	@:optional var model:CharacterModelFile;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;
	@:optional var healthIcon:Dynamic;

	var position:Array<Float>;
	var camera_position:Array<Float>;
	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
	var vocals_file:String;
	@:optional var _editor_isPlayer:Null<Bool>;
}

typedef CharacterModelFile = {
	var name:String;
	var type:String;
	@:optional var scale:Null<Float>;
	@:optional var yaw:Null<Float>;
	@:optional var pitch:Null<Float>;
	@:optional var roll:Null<Float>;
	@:optional var x:Null<Float>;
	@:optional var y:Null<Float>;
	@:optional var z:Null<Float>;
	@:optional var view_width:Null<Float>;
	@:optional var view_height:Null<Float>;
	@:optional var ambient:Null<Float>;
	@:optional var specular:Null<Float>;
	@:optional var diffuse:Null<Float>;
	@:optional var alpha:Null<Float>;
	@:optional var no_loop:Array<String>;
	@:optional var anim_speed:Dynamic;
	@:optional var md5_animations:Dynamic;
	@:optional var geo_map:Dynamic;
	@:optional var atf:Null<Bool>;
	@:optional var light:Null<Bool>;
	@:optional var joints_per_vertex:Null<Int>;
	@:optional var source_mod:String;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite {
	/**
	 * In case a character is missing, it will use this on its place
	**/
	public static final DEFAULT_CHARACTER:String = 'bf';

	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var extraData:Map<String, Dynamic> = new Map<String, Dynamic>();

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; // Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; // Character use "danceLeft" and "danceRight" instead of "idle"
	public var skipDance:Bool = false;

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public var missingCharacter:Bool = false;
	public var missingText:FlxText;
	public var hasMissAnimations:Bool = false;
	public var vocalsFile:String = '';

	public var camOffsets:Array<Float> = [0, 0];
	public var posOffsets:Array<Float> = [0, 0];

	// 3D model characters
	public var isModel:Bool = false;
	public var modelName:String = '';
	public var beganLoading:Bool = false;
	public var modelType:String = 'md2';
	public var modelScale:Float = 1;
	public var modelYaw:Float = 0;
	public var modelPitch:Float = 0;
	public var modelRoll:Float = 0;
	public var modelX:Float = 0;
	public var modelY:Float = 0;
	public var modelZ:Float = 0;
	public var modelViewWidth:Float = 720;
	public var modelViewHeight:Float = 720;
	public var modelAmbient:Float = 1;
	public var modelSpecular:Float = 1;
	public var modelDiffuse:Float = 1;
	public var modelAlpha:Float = 1;
	public var modelSourceMod:String = null;
	public var modelNoLoop:Array<String> = [];
	public var modelAnimSpeed:Map<String, Float> = [];
	public var modelMD5Animations:Map<String, String> = [];
	public var modelGeoMap:Map<String, String> = [];
	public var modelAtf:Bool = false;
	public var modelLight:Bool = false;
	public var modelJointsPerVertex:Int = 4;
	public var modelView:ModelView;
	public var model:ModelThing;
	var beganLoadingModel:Bool = false;
	var ownsModelView:Bool = false;
	public var isGlass:Bool = false;
	public var modelOrigBPM:Int;
	public var initAlpha:Float = 1.0;
	public var shimmer:Bool = false;
	public var modelSpeed:Map<String, Float> = new Map<String, Float>();

	public var viewX:Float = 750;
	public var viewY:Float = 750;
	public var ambient:Float = 1;
	public var specular:Float = 1;
	public var diffuse:Float = 1;
	public var animSpeed:Map<String, Float> = new Map<String, Float>();
	public var noLoopList:Array<String> = [];
	public var md5Anims:Map<String, String> = new Map<String, String>();

	public var initYaw:Float = 0;
	public var initPitch:Float = 0;
	public var initX:Float = 0;
	public var initY:Float = 0;
	public var initZ:Float = 0;

	public static var modelMutex:Bool = false;
	public static var modelMutexThing:ModelThing;

	// Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var editorIsPlayer:Null<Bool> = null;

	inline function setAntialiasingDirect(sprite:FlxSprite, value:Bool):Void {
		@:bypassAccessor sprite.antialiasing = value;
	}

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false) {
		super(x, y);

		animation = new PsychAnimationController(this);

		animOffsets = new Map<String, Array<Dynamic>>();
		this.isPlayer = isPlayer;
		changeCharacter(character);

		var loadFrom = Main.modelView.sprite;

		switch (curCharacter) {
			case 'pico-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
			case 'pico-blazin', 'darnell-blazin':
				skipDance = true;
			case 'sserafim-chaewon':
				#if flxanimate
				isAnimateAtlas = true;
				atlas = new FlxAnimate();
				atlas.showPivot = false;
				Paths.loadAnimateAtlas(atlas, 'characters/sserafim/chaewon');

				atlas.anim.addBySymbol('idle', 'idle', 24, false);
				atlas.anim.addBySymbol('kim left pose', 'singLEFT', 24, false);
				atlas.anim.addBySymbol('kim down pose', 'singDOWN', 24, false);
				atlas.anim.addBySymbol('kim up pose', 'singUP', 24, false);
				atlas.anim.addBySymbol('kim right pose', 'singRIGHT', 24, false);
				atlas.anim.addBySymbol('kim left miss', 'singLEFTmiss', 24, false);
				atlas.anim.addBySymbol('kim down miss', 'singDOWNmiss', 24, false);
				atlas.anim.addBySymbol('kim up miss', 'singUPmiss', 24, false);
				atlas.anim.addBySymbol('kim right miss', 'singRIGHTmiss', 24, false);

				addOffset('idle', 0, 0);
				addOffset('singLEFT', 0, 0);
				addOffset('singDOWN', 0, 0);
				addOffset('singUP', 0, 0);
				addOffset('singRIGHT', 0, 0);
				addOffset('singLEFTmiss', 0, 0);
				addOffset('singDOWNmiss', 0, 0);
				addOffset('singUPmiss', 0, 0);
				addOffset('singRIGHTmiss', 0, 0);

				imageFile = 'characters/sserafim/chaewon';
				jsonScale = 1;
				scale.set(1, 1);
				updateHitbox();
				positionArray = [0, 330];
				cameraPosition = [0, 330];
				healthIcon = 'bf';
				singDuration = 4;
				flipX = (false != isPlayer);
				healthColorArray = [49, 176, 209];
				vocalsFile = '';
				originalFlipX = false;
				editorIsPlayer = null;
				noAntialiasing = false;
				setAntialiasingDirect(this, ClientPrefs.data.antialiasing);
				copyAtlasValues();
				return;
				#end

			case 'sserafim-eunchae':
				#if flxanimate
				isAnimateAtlas = true;
				atlas = new FlxAnimate();
				atlas.showPivot = false;
				Paths.loadAnimateAtlas(atlas, 'characters/sserafim/eunchae');

				atlas.anim.addBySymbol('idle', 'idle', 24, false);
				atlas.anim.addBySymbol('eunchae left', 'singLEFT', 24, false);
				atlas.anim.addBySymbol('eunchae down', 'singDOWN', 24, false);
				atlas.anim.addBySymbol('eunchae up', 'singUP', 24, false);
				atlas.anim.addBySymbol('eunchae right', 'singRIGHT', 24, false);
				atlas.anim.addBySymbol('eunchae left miss', 'singLEFTmiss', 24, false);
				atlas.anim.addBySymbol('eunchae down miss', 'singDOWNmiss', 24, false);
				atlas.anim.addBySymbol('eunchae up miss', 'singUPmiss', 24, false);
				atlas.anim.addBySymbol('eunchae right miss', 'singRIGHTmiss', 24, false);

				addOffset('idle', 0, 0);
				addOffset('singLEFT', 0, 0);
				addOffset('singDOWN', 0, 0);
				addOffset('singUP', 0, 0);
				addOffset('singRIGHT', 0, 0);
				addOffset('singLEFTmiss', 0, 0);
				addOffset('singDOWNmiss', 0, 0);
				addOffset('singUPmiss', 0, 0);
				addOffset('singRIGHTmiss', 0, 0);

				imageFile = 'characters/sserafim/eunchae';
				jsonScale = 1;
				scale.set(1, 1);
				updateHitbox();
				positionArray = [0, 260];
				cameraPosition = [0, 260];
				healthIcon = 'bf';
				singDuration = 4;
				flipX = (false != isPlayer);
				healthColorArray = [49, 176, 209];
				vocalsFile = '';
				originalFlipX = false;
				editorIsPlayer = null;
				noAntialiasing = false;
				setAntialiasingDirect(this, ClientPrefs.data.antialiasing);
				copyAtlasValues();
				return;
				#end

			case 'sserafim-kazuha':
				#if flxanimate
				isAnimateAtlas = true;
				atlas = new FlxAnimate();
				atlas.showPivot = false;
				Paths.loadAnimateAtlas(atlas, 'characters/sserafim/kazuha');

				atlas.anim.addBySymbol('idle', 'idle', 24, false);
				atlas.anim.addBySymbol('kazuha left pose', 'singLEFT', 24, false);
				atlas.anim.addBySymbol('kazuha down pose', 'singDOWN', 24, false);
				atlas.anim.addBySymbol('kazuha up pose', 'singUP', 24, false);
				atlas.anim.addBySymbol('kazuha right pose', 'singRIGHT', 24, false);
				atlas.anim.addBySymbol('kazuha left miss', 'singLEFTmiss', 24, false);
				atlas.anim.addBySymbol('kazuha down miss', 'singDOWNmiss', 24, false);
				atlas.anim.addBySymbol('kazuha up miss', 'singUPmiss', 24, false);
				atlas.anim.addBySymbol('kazuha right miss', 'singRIGHTmiss', 24, false);

				addOffset('idle', 0, 0);
				addOffset('singLEFT', 0, 0);
				addOffset('singDOWN', 0, 0);
				addOffset('singUP', 0, 0);
				addOffset('singRIGHT', 0, 0);
				addOffset('singLEFTmiss', 0, 0);
				addOffset('singDOWNmiss', 0, 0);
				addOffset('singUPmiss', 0, 0);
				addOffset('singRIGHTmiss', 0, 0);

				imageFile = 'characters/sserafim/kazuha';
				jsonScale = 1;
				scale.set(1, 1);
				updateHitbox();
				positionArray = [0, 200];
				cameraPosition = [0, 200];
				healthIcon = 'kazuha';
				singDuration = 4;
				flipX = (false != isPlayer);
				healthColorArray = [49, 176, 209];
				vocalsFile = '';
				originalFlipX = false;
				editorIsPlayer = null;
				noAntialiasing = false;
				setAntialiasingDirect(this, ClientPrefs.data.antialiasing);
				copyAtlasValues();
				return;
				#end

			case 'sserafim-gf':
				#if flxanimate
				isAnimateAtlas = true;
				atlas = new FlxAnimate();
				atlas.showPivot = false;
				Paths.loadAnimateAtlas(atlas, 'characters/sserafim/sserafim-gf');

				atlas.anim.addBySymbol('gf idle', 'danceLeft', 24, false);
				atlas.anim.addBySymbol('gf idle', 'danceRight', 24, false);

				atlas.anim.addBySymbol('gf left 1', 'singLEFT', 24, false);
				atlas.anim.addBySymbol('gf down 1', 'singDOWN', 24, false);
				atlas.anim.addBySymbol('gf up 1', 'singUP', 24, false);
				atlas.anim.addBySymbol('gf right 1', 'singRIGHT', 24, false);
				atlas.anim.addBySymbol('gf left miss 1', 'singLEFTmiss', 24, false);
				atlas.anim.addBySymbol('gf down miss 1', 'singDOWNmiss', 24, false);
				atlas.anim.addBySymbol('gf up miss 1', 'singUPmiss', 24, false);
				atlas.anim.addBySymbol('gf right miss 1', 'singRIGHTmiss', 24, false);

				atlas.anim.addBySymbol('gf left 2', 'singLEFT-beautiful', 24, false);
				atlas.anim.addBySymbol('gf down 2', 'singDOWN-beautiful', 24, false);
				atlas.anim.addBySymbol('gf up 2', 'singUP-beautiful', 24, false);
				atlas.anim.addBySymbol('gf right 2', 'singRIGHT-beautiful', 24, false);
				atlas.anim.addBySymbol('gf left miss 2', 'singLEFTmiss-beautiful', 24, false);
				atlas.anim.addBySymbol('gf down miss 2', 'singDOWNmiss-beautiful', 24, false);
				atlas.anim.addBySymbol('gf up miss 2', 'singUPmiss-beautiful', 24, false);
				atlas.anim.addBySymbol('gf right miss 2', 'singRIGHTmiss-beautiful', 24, false);

				addOffset('danceLeft', 0, 0);
				addOffset('danceRight', 0, 0);
				addOffset('danceLeft-beautiful', 0, 0);
				addOffset('danceRight-beautiful', 0, 0);
				addOffset('singLEFT', 0, 0);
				addOffset('singDOWN', 0, 0);
				addOffset('singUP', 0, 0);
				addOffset('singRIGHT', 0, 0);
				addOffset('singLEFTmiss', 0, 0);
				addOffset('singDOWNmiss', 0, 0);
				addOffset('singUPmiss', 0, 0);
				addOffset('singRIGHTmiss', 0, 0);
				addOffset('singLEFT-beautiful', 0, 0);
				addOffset('singDOWN-beautiful', 0, 0);
				addOffset('singUP-beautiful', 0, 0);
				addOffset('singRIGHT-beautiful', 0, 0);
				addOffset('singLEFTmiss-beautiful', 0, 0);
				addOffset('singDOWNmiss-beautiful', 0, 0);
				addOffset('singUPmiss-beautiful', 0, 0);
				addOffset('singRIGHTmiss-beautiful', 0, 0);

				imageFile = 'characters/sserafim/sserafim-gf';
				jsonScale = 1;
				scale.set(1, 1);
				updateHitbox();
				positionArray = [0, 0];
				cameraPosition = [0, 0];
				healthIcon = 'gf';
				singDuration = 4;
				flipX = (false != isPlayer);
				healthColorArray = [49, 176, 209];
				vocalsFile = '';
				originalFlipX = false;
				editorIsPlayer = null;
				noAntialiasing = false;
				setAntialiasingDirect(this, ClientPrefs.data.antialiasing);
				copyAtlasValues();
				return;
				#end

			case 'sserafim-sakura':
				#if flxanimate
				isAnimateAtlas = true;
				atlas = new FlxAnimate();
				atlas.showPivot = false;
				Paths.loadAnimateAtlas(atlas, 'characters/sserafim/sakura');

				atlas.anim.addBySymbol('idle', 'idle', 24, false);
				atlas.anim.addBySymbol('singLEFT', 'sakura pose left', 24, false);
				atlas.anim.addBySymbol('singDOWN', 'sakura pose down', 24, false);
				atlas.anim.addBySymbol('singUP', 'sakura pose up', 24, false);
				atlas.anim.addBySymbol('singRIGHT', 'sakura pose right', 24, false);
				atlas.anim.addBySymbol('singLEFTmiss', 'sakura left miss', 24, false);
				atlas.anim.addBySymbol('singDOWNmiss', 'sakura down miss', 24, false);
				atlas.anim.addBySymbol('singUPmiss', 'sakura up miss', 24, false);
				atlas.anim.addBySymbol('singRIGHTmiss', 'sakura right miss', 24, false);

				atlas.anim.addBySymbol('singLEFT-joint', 'joint pose left', 24, false);
				atlas.anim.addBySymbol('singDOWN-joint', 'joint pose down', 24, false);
				atlas.anim.addBySymbol('singUP-joint', 'joint pose up', 24, false);
				atlas.anim.addBySymbol('singRIGHT-joint', 'joint pose right', 24, false);
				atlas.anim.addBySymbol('singLEFTmiss-joint', 'joint left miss', 24, false);
				atlas.anim.addBySymbol('singDOWNmiss-joint', 'joint down miss', 24, false);
				atlas.anim.addBySymbol('singUPmiss-joint', 'joint up miss', 24, false);
				atlas.anim.addBySymbol('singRIGHTmiss-joint', 'joint right miss', 24, false);

				atlas.anim.addBySymbol('singLEFT-bf1', 'bf left pose 1', 24, false);
				atlas.anim.addBySymbol('singDOWN-bf1', 'bf down pose 1', 24, false);
				atlas.anim.addBySymbol('singUP-bf1', 'bf up pose 1', 24, false);
				atlas.anim.addBySymbol('singRIGHT-bf1', 'bf right pose 1', 24, false);

				atlas.anim.addBySymbol('singLEFT-bf2', 'bf left pose 2', 24, false);
				atlas.anim.addBySymbol('singDOWN-bf2', 'bf down pose 2', 24, false);
				atlas.anim.addBySymbol('singUP-bf2', 'bf up pose 2', 24, false);
				atlas.anim.addBySymbol('singRIGHT-bf2', 'bf right pose 2', 24, false);
				atlas.anim.addBySymbol('singLEFTmiss-bf2', 'bf left miss', 24, false);
				atlas.anim.addBySymbol('singDOWNmiss-bf2', 'bf down miss', 24, false);
				atlas.anim.addBySymbol('singUPmiss-bf2', 'bf up miss', 24, false);
				atlas.anim.addBySymbol('singRIGHTmiss-bf2', 'bf right miss', 24, false);

				atlas.anim.addBySymbol('firstDeath', 'Death Intro', 24, false);
				atlas.anim.addBySymbol('deathLoop', 'Death Loop', 24, true);
				atlas.anim.addBySymbol('deathConfirm', 'Death Confirm', 24, false);

				for (animName in [
					'idle', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT', 'singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss', 'singLEFT-joint',
					'singDOWN-joint', 'singUP-joint', 'singRIGHT-joint', 'singLEFTmiss-joint', 'singDOWNmiss-joint', 'singUPmiss-joint',
					'singRIGHTmiss-joint', 'singLEFT-bf1', 'singDOWN-bf1', 'singUP-bf1', 'singRIGHT-bf1', 'singLEFT-bf2', 'singDOWN-bf2', 'singUP-bf2',
					'singRIGHT-bf2', 'singLEFTmiss-bf2', 'singDOWNmiss-bf2', 'singUPmiss-bf2', 'singRIGHTmiss-bf2'
				])
					addOffset(animName, 0, 0);

				addOffset('firstDeath', 20, -220);
				addOffset('deathLoop', 20, -220);
				addOffset('deathConfirm', 20, -220);

				imageFile = 'characters/sserafim/sakura';
				jsonScale = 1;
				scale.set(1, 1);
				updateHitbox();
				positionArray = [0, 0];
				cameraPosition = [0, 0];
				healthIcon = 'bf';
				singDuration = 4;
				flipX = (true != isPlayer);
				healthColorArray = [49, 176, 209];
				vocalsFile = '';
				originalFlipX = true;
				editorIsPlayer = null;
				noAntialiasing = false;
				setAntialiasingDirect(this, ClientPrefs.data.antialiasing);
				copyAtlasValues();
				return;
				#end

			case 'sserafim-yunjin':
				#if flxanimate
				isAnimateAtlas = true;
				atlas = new FlxAnimate();
				atlas.showPivot = false;
				Paths.loadAnimateAtlas(atlas, 'characters/sserafim/yunjin');

				atlas.anim.addBySymbol('doorclosed', 'doorclosed', 24, false);
				atlas.anim.addBySymbol('kick1', 'kick1', 24, false);
				atlas.anim.addBySymbol('kick2', 'kick2', 24, false);
				atlas.anim.addBySymbol('idle', 'idle', 24, false);
				atlas.anim.addBySymbol('singLEFT', 'left', 24, false);
				atlas.anim.addBySymbol('singDOWN', 'down', 24, false);
				atlas.anim.addBySymbol('singUP', 'up', 24, false);
				atlas.anim.addBySymbol('singRIGHT', 'right', 24, false);
				atlas.anim.addBySymbol('singLEFTmiss', 'left miss', 24, false);
				atlas.anim.addBySymbol('singDOWNmiss', 'down miss', 24, false);
				atlas.anim.addBySymbol('singUPmiss', 'up miss', 24, false);
				atlas.anim.addBySymbol('singRIGHTmiss', 'right miss', 24, false);

				addOffset('doorclosed', 0, 0);
				addOffset('kick1', 0, 0);
				addOffset('kick2', 0, 0);
				addOffset('idle', 0, 0);
				addOffset('singLEFT', 0, 0);
				addOffset('singDOWN', 0, 0);
				addOffset('singUP', 0, 0);
				addOffset('singRIGHT', 0, 0);
				addOffset('singLEFTmiss', 0, 0);
				addOffset('singDOWNmiss', 0, 0);
				addOffset('singUPmiss', 0, 0);
				addOffset('singRIGHTmiss', 0, 0);

				imageFile = 'characters/sserafim/yunjin';
				jsonScale = 1;
				scale.set(1, 1);
				updateHitbox();
				positionArray = [2, 347];
				cameraPosition = [2, 347];
				healthIcon = 'bf';
				singDuration = 4;
				flipX = (false != isPlayer);
				healthColorArray = [49, 176, 209];
				vocalsFile = '';
				originalFlipX = false;
				editorIsPlayer = null;
				noAntialiasing = false;
				setAntialiasingDirect(this, ClientPrefs.data.antialiasing);
				copyAtlasValues();
				return;
				#end
			
			case 'cube':
				modelName = "cube";
				modelScale = 50;
				modelOrigBPM = 75;
				isModel = true;
				loadGraphicFromSprite(loadFrom);
				scale.x = scale.y = 1.3;
				initYaw = -45;
				updateHitbox();

			case 'round':
				modelName = "round";
				initAlpha = 0.86;
				shimmer = true;
				modelScale = 50;
				modelOrigBPM = 75;
				isModel = true;
				loadGraphicFromSprite(loadFrom);
				scale.x = scale.y = 1.3;
				initYaw = -45;
				updateHitbox();
			
			case 'prisma':
				modelName = "prisma";
				modelScale = 50;
				var multiplier = Conductor.bpm / 100;
				animSpeed = [
					"default" => 2.1 * multiplier,
					"idle" => 1.5 * multiplier,
					"singLEFT" => 2.5 * multiplier
				];
				for (thing in ["singUPEnd", "singLEFTEnd", "singRIGHTEnd", "singDOWNEnd"])
					animSpeed[thing] = 1.5;
				isModel = true;
				noLoopList = [
					"idle", "singUP", "singLEFT", "singRIGHT", "singDOWN", "singUPEnd", "singLEFTEnd", "singRIGHTEnd", "singDOWNEnd", "idleEnd"
				];
				ambient = 1;
				specular = 1;
				diffuse = 1;
				initYaw = -50;
				isGlass = true;
				viewX = 600;
				viewY = 600;
				if (isPlayer)
					posOffsets = [viewX / 2, -550];
				else
					posOffsets = [-viewX / 2, -550];
				if (isPlayer)
					camOffsets = [-viewX / 2, viewY / 2];
				else
					camOffsets = [viewX / 2, viewY / 2];
			
			case 'monkey':
				// DD: Okay, don't load models here cuz the engine will crash with more than one model

				// model = new ModelThing("monkey", Main.modelView, 100, 80);
				// model = new ModelThing("boyfriend", Main.modelView, 1.5, 80);
				modelName = "monkey";
				modelScale = 90;
				modelOrigBPM = 75;
				isModel = true;
				loadGraphicFromSprite(loadFrom);
				scale.x = scale.y = 1.4;
				initYaw = 0;
				updateHitbox();

			case 'bf-poly':
				// model = new ModelThing("boyfriend", Main.modelViewBF, 1.5, 80);
				modelName = "boyfriend";
				modelScale = 1.2;
				modelOrigBPM = 75;
				isModel = true;
				loadGraphicFromSprite(loadFrom);
				scale.x = scale.y = 1.6;
				updateHitbox();
				initYaw = 45;
				flipX = true;
		}
	}

	public function changeCharacter(character:String) {
		animationsArray = [];
		animOffsets = [];
		curCharacter = character;
		var characterPath:String = 'characters/$character.json';

		var path:String = Paths.getPath(characterPath, TEXT);
		#if MODS_ALLOWED
		if (!FileSystem.exists(path))
		#else
		if (!Assets.exists(path))
		#end
		{
			path = Paths.getSharedPath('characters/' + DEFAULT_CHARACTER +
				'.json'); // If a character couldn't be found, change him to BF just to prevent a crash
			missingCharacter = true;
			missingText = new FlxText(0, 0, 300, 'ERROR:\n$character.json', 16);
			missingText.alignment = CENTER;
		}

		try {
			#if MODS_ALLOWED
			loadCharacterFile(Json.parse(File.getContent(path)));
			#else
			loadCharacterFile(Json.parse(Assets.getText(path)));
			#end
		} catch (e:Dynamic) {
			trace('Error loading character file of "$character": $e');
		}

		skipDance = false;
		hasMissAnimations = hasAnimation('singLEFTmiss') || hasAnimation('singDOWNmiss') || hasAnimation('singUPmiss') || hasAnimation('singRIGHTmiss');
		recalculateDanceIdle();
		dance();
	}

	public function loadCharacterFile(json:Dynamic) {
		isAnimateAtlas = false;
		isModel = (json.model != null);

		#if flxanimate
		var animToFind:String = Paths.getPath('images/' + json.image + '/Animation.json', TEXT);
		if (!isModel && (#if MODS_ALLOWED FileSystem.exists(animToFind) || #end Assets.exists(animToFind)))
			isAnimateAtlas = true;
		#end

		scale.set(1, 1);
		updateHitbox();
		noAntialiasing = (json.no_antialiasing == true);

		if (isModel) {
			loadModelCharacter(json.model);
		} else if (!isAnimateAtlas) {
			frames = Paths.getMultiAtlas(json.image.split(','));
		}
		#if flxanimate
		else {
			atlas = new FlxAnimate();
			atlas.showPivot = false;
			try {
				Paths.loadAnimateAtlas(atlas, json.image);
			} catch (e:haxe.Exception) {
				FlxG.log.warn('Could not load atlas ${json.image}: $e');
				trace(e.stack);
			}
		}
		#end

		imageFile = json.image;
		jsonScale = json.scale;
		if (json.scale != 1) {
			scale.set(jsonScale, jsonScale);
			updateHitbox();
		}

		// positioning
		positionArray = json.position;
		cameraPosition = json.camera_position;

		// data
		healthIcon = json.healthicon;
		singDuration = json.sing_duration;
		flipX = (json.flip_x != isPlayer);
		healthColorArray = (json.healthbar_colors != null && json.healthbar_colors.length > 2) ? json.healthbar_colors : [161, 161, 161];
		vocalsFile = json.vocals_file != null ? json.vocals_file : '';
		originalFlipX = (json.flip_x == true);
		editorIsPlayer = json._editor_isPlayer;

		// antialiasing
		setAntialiasingDirect(this, ClientPrefs.data.antialiasing ? !noAntialiasing : false);

		// animations
		animationsArray = json.animations;
		if (animationsArray != null && animationsArray.length > 0) {
			for (anim in animationsArray) {
				var animAnim:String = '' + anim.anim;
				var animName:String = '' + anim.name;
				var animFps:Int = anim.fps;
				var animLoop:Bool = !!anim.loop; // Bruh
				var animIndices:Array<Int> = anim.indices;

				if (!isAnimateAtlas) {
					if (animIndices != null && animIndices.length > 0)
						animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
					else
						animation.addByPrefix(animAnim, animName, animFps, animLoop);
				}
				#if flxanimate
				else {
					if (animIndices != null && animIndices.length > 0)
						atlas.anim.addBySymbolIndices(animAnim, animName, animIndices, animFps, animLoop);
					else
						atlas.anim.addBySymbol(animAnim, animName, animFps, animLoop);
				}
				#end

				if (anim.offsets != null && anim.offsets.length > 1)
					addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				else
					addOffset(anim.anim, 0, 0);
			}
		}
		#if flxanimate
		if (isAnimateAtlas)
			copyAtlasValues();
		#end
		// trace('Loaded file to character ' + curCharacter);
	}

	function loadModelCharacter(modelFile:CharacterModelFile):Void {
		if (modelView != null && ownsModelView)
			modelView.destroy();
		if (model != null)
			model.destroy();

		modelName = modelFile.name;
		modelType = modelFile.type != null ? modelFile.type : 'md2';
		modelScale = modelFile.scale != null ? modelFile.scale : 1;
		modelYaw = modelFile.yaw != null ? modelFile.yaw : 0;
		modelPitch = modelFile.pitch != null ? modelFile.pitch : 0;
		modelRoll = modelFile.roll != null ? modelFile.roll : 0;
		modelX = modelFile.x != null ? modelFile.x : 0;
		modelY = modelFile.y != null ? modelFile.y : 0;
		modelZ = modelFile.z != null ? modelFile.z : 0;
		modelViewWidth = modelFile.view_width != null ? modelFile.view_width : 720;
		modelViewHeight = modelFile.view_height != null ? modelFile.view_height : 720;
		modelAmbient = modelFile.ambient != null ? modelFile.ambient : 1;
		modelSpecular = modelFile.specular != null ? modelFile.specular : 1;
		modelDiffuse = modelFile.diffuse != null ? modelFile.diffuse : 1;
		modelAlpha = modelFile.alpha != null ? modelFile.alpha : 1;
		modelNoLoop = modelFile.no_loop != null ? modelFile.no_loop : [];
		modelAnimSpeed = parseModelAnimSpeed(modelFile.anim_speed);
		modelMD5Animations = parseModelMD5Animations(modelFile.md5_animations);
		modelGeoMap = parseModelStringMap(modelFile.geo_map);
		modelAtf = modelFile.atf == true;
		modelLight = modelFile.light == true;
		modelJointsPerVertex = modelFile.joints_per_vertex != null ? modelFile.joints_per_vertex : 4;

		modelView = new ModelView(modelViewWidth, modelViewHeight, modelAmbient, modelSpecular, modelDiffuse);
		ownsModelView = true;
		model = new ModelThing(modelType, modelName, modelView, modelScale, modelAnimSpeed, modelYaw, modelPitch, modelRoll, modelAlpha, modelX, modelY,
			modelZ, modelNoLoop, modelMD5Animations, modelAtf, !noAntialiasing, modelAmbient, modelSpecular, modelDiffuse, modelLight,
			modelJointsPerVertex);
		loadGraphic(modelView.sprite.graphic);
	}

	function parseModelAnimSpeed(data:Dynamic):Map<String, Float> {
		var result:Map<String, Float> = ["default" => 1.0];
		if (data != null) {
			for (field in Reflect.fields(data)) {
				var value:Null<Float> = cast Reflect.field(data, field);
				if (value != null && !Math.isNaN(value))
					result[field] = value;
			}
		}
		return result;
	}

	function parseModelMD5Animations(data:Dynamic):Map<String, String> {
		return parseModelStringMap(data);
	}

	function parseModelStringMap(data:Dynamic):Map<String, String> {
		var result:Map<String, String> = [];
		if (data != null) {
			for (field in Reflect.fields(data)) {
				var value:Dynamic = Reflect.field(data, field);
				if (value != null)
					result[field] = Std.string(value);
			}
		}
		return result;
	}

	override function update(elapsed:Float) {
		if (isModel && modelView != null)
			modelView.update();

		if (isAnimateAtlas)
			atlas.update(elapsed);

		if (debugMode
			|| (!isAnimateAtlas && animation.curAnim == null)
			|| (isAnimateAtlas && (atlas.anim.curInstance == null || atlas.anim.curSymbol == null))) {
			super.update(elapsed);
			return;
		}

		if (heyTimer > 0) {
			var rate:Float = (PlayState.instance != null ? PlayState.instance.playbackRate : 1.0);
			heyTimer -= elapsed * rate;
			if (heyTimer <= 0) {
				var anim:String = getAnimationName();
				if (specialAnim && (anim == 'hey' || anim == 'cheer')) {
					specialAnim = false;
					dance();
				}
				heyTimer = 0;
			}
		} else if (specialAnim && isAnimationFinished()) {
			specialAnim = false;
			dance();
		} else if (getAnimationName().endsWith('miss') && isAnimationFinished()) {
			dance();
			finishAnimation();
		}

		switch (curCharacter) {
			case 'pico-speaker':
				if (animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0]) {
					var noteData:Int = 1;
					if (animationNotes[0][1] > 2)
						noteData = 3;

					noteData += FlxG.random.int(0, 1);
					playAnim('shoot' + noteData, true);
					animationNotes.shift();
				}
				if (isAnimationFinished())
					playAnim(getAnimationName(), false, false, animation.curAnim.frames.length - 3);
		}

		if (getAnimationName().startsWith('sing'))
			holdTimer += elapsed;
		else if (isPlayer)
			holdTimer = 0;

		if (!isPlayer
			&& holdTimer >= Conductor.stepCrochet * (0.0011 #if FLX_PITCH / (FlxG.sound.music != null ? FlxG.sound.music.pitch : 1) #end) * singDuration) {
			dance();
			holdTimer = 0;
		}

		var name:String = getAnimationName();
		if (isAnimationFinished() && hasAnimation('$name-loop'))
			playAnim('$name-loop');

		super.update(elapsed);
	}

	inline public function isAnimationNull():Bool {
		if (isModel)
			return _lastPlayedAnimation == null;
		return !isAnimateAtlas ? (animation.curAnim == null) : (atlas.anim.curInstance == null || atlas.anim.curSymbol == null);
	}

	var _lastPlayedAnimation:String;

	inline public function getAnimationName():String {
		return _lastPlayedAnimation;
	}

	public function isAnimationFinished():Bool {
		if (isModel)
			return false;
		if (isAnimationNull())
			return false;
		return !isAnimateAtlas ? animation.curAnim.finished : atlas.anim.finished;
	}

	public function finishAnimation():Void {
		if (isAnimationNull())
			return;

		if (!isAnimateAtlas)
			animation.curAnim.finish();
		else
			atlas.anim.curFrame = atlas.anim.length - 1;
	}

	public function hasAnimation(anim:String):Bool {
		return animOffsets.exists(anim);
	}

	public var animPaused(get, set):Bool;

	private function get_animPaused():Bool {
		if (isModel)
			return false;
		if (isAnimationNull())
			return false;
		return !isAnimateAtlas ? animation.curAnim.paused : atlas.anim.isPlaying;
	}

	private function set_animPaused(value:Bool):Bool {
		if (isModel)
			return value;
		if (isAnimationNull())
			return value;
		if (!isAnimateAtlas)
			animation.curAnim.paused = value;
		else {
			if (value)
				atlas.pauseAnimation();
			else
				atlas.resumeAnimation();
		}

		return value;
	}

	public var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance() {
		if (!debugMode && !skipDance && !specialAnim) {
			if (danceIdle) {
				danced = !danced;

				if (danced)
					playAnim('danceRight' + idleSuffix);
				else
					playAnim('danceLeft' + idleSuffix);
			} else if (hasAnimation('idle' + idleSuffix))
				playAnim('idle' + idleSuffix);
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
		specialAnim = false;
		if (isModel) {
			if (model != null)
				model.playAnim(AnimName, Force, Frame, modelGeoMap.exists(AnimName) ? modelGeoMap[AnimName] : "");
		} else if (!isAnimateAtlas) {
			animation.play(AnimName, Force, Reversed, Frame);
		} else {
			atlas.anim.play(AnimName, Force, Reversed, Frame);
			atlas.update(0);
		}
		_lastPlayedAnimation = AnimName;

		if (hasAnimation(AnimName)) {
			var daOffset = animOffsets.get(AnimName);
			offset.set(daOffset[0], daOffset[1]);
		}
		// else offset.set(0, 0);

		if (curCharacter.startsWith('gf-') || curCharacter == 'gf') {
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	function loadMappedAnims():Void {
		try {
			var songData:SwagSong = Song.getChart('picospeaker', Paths.formatToSongPath(Song.loadedSongName));
			if (songData != null)
				for (section in songData.notes)
					for (songNotes in section.sectionNotes)
						animationNotes.push(songNotes);

			TankmenBG.animationNotes = animationNotes;
			animationNotes.sort(sortAnims);
		} catch (e:Dynamic) {}
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int {
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	public var danceEveryNumBeats:Int = 2;

	private var settingCharacterUp:Bool = true;

	public function recalculateDanceIdle() {
		var lastDanceIdle:Bool = danceIdle;
		danceIdle = (hasAnimation('danceLeft' + idleSuffix) && hasAnimation('danceRight' + idleSuffix));

		if (settingCharacterUp) {
			danceEveryNumBeats = (danceIdle ? 1 : 2);
		} else if (lastDanceIdle != danceIdle) {
			var calc:Float = danceEveryNumBeats;
			if (danceIdle)
				calc /= 2;
			else
				calc *= 2;

			danceEveryNumBeats = Math.round(Math.max(calc, 1));
		}
		settingCharacterUp = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0) {
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String) {
		animation.addByPrefix(name, anim, 24, false);
	}

	// Atlas support
	// special thanks ne_eo for the references, you're the goat!!
	@:allow(states.editors.CharacterEditorState)
	public var isAnimateAtlas(default, null):Bool = false;
	#if flxanimate
	public var atlas:FlxAnimate;

	public override function draw() {
		var lastAlpha:Float = alpha;
		var lastColor:FlxColor = color;
		if (missingCharacter) {
			alpha *= 0.6;
			color = FlxColor.BLACK;
		}

		if (isAnimateAtlas) {
			if (atlas.anim.curInstance != null) {
				copyAtlasValues();
				atlas.draw();
				alpha = lastAlpha;
				color = lastColor;
				if (missingCharacter && visible) {
					missingText.x = getMidpoint().x - 150;
					missingText.y = getMidpoint().y - 10;
					missingText.draw();
				}
			}
			return;
		}
		if (isModel) {
			if (modelView != null && modelView.sprite != null) {
				copyModelValues();
				modelView.sprite.draw();
			}
			return;
		}
		super.draw();
		if (missingCharacter && visible) {
			alpha = lastAlpha;
			color = lastColor;
			missingText.x = getMidpoint().x - 150;
			missingText.y = getMidpoint().y - 10;
			missingText.draw();
		}
	}

	public function copyAtlasValues() {
		@:privateAccess
		{
			atlas.cameras = cameras;
			atlas.scrollFactor = scrollFactor;
			atlas.scale = scale;
			atlas.offset = offset;
			atlas.origin = origin;
			atlas.x = x;
			atlas.y = y;
			atlas.angle = angle;
			atlas.alpha = alpha;
			atlas.visible = visible;
			atlas.flipX = flipX;
			atlas.flipY = flipY;
			atlas.shader = shader;
			setAntialiasingDirect(atlas, antialiasing);
			atlas.colorTransform = colorTransform;
			atlas.color = color;
		}
	}

	public function copyModelValues() {
		var spr:FlxSprite = modelView.sprite;
		spr.cameras = cameras;
		spr.scrollFactor = scrollFactor;
		spr.scale = scale;
		spr.offset = offset;
		spr.origin = origin;
		spr.x = x;
		spr.y = y;
		spr.angle = angle;
		spr.alpha = alpha;
		spr.visible = visible;
		spr.flipX = flipX;
		spr.flipY = flipY;
		spr.shader = shader;
		setAntialiasingDirect(spr, antialiasing);
		spr.colorTransform = colorTransform;
		spr.color = color;
	}

	public override function destroy() {
		if (model != null) {
			model.destroy();
			model = null;
		}
		if (modelView != null && ownsModelView) {
			modelView.destroy();
			modelView = null;
		}
		atlas = FlxDestroyUtil.destroy(atlas);
		super.destroy();
	}
	#end
}
