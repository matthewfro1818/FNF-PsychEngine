package objects;

import away3d.animators.SkeletonAnimationSet;
import away3d.animators.SkeletonAnimator;
import away3d.animators.VertexAnimationSet;
import away3d.animators.VertexAnimator;
import away3d.animators.data.Skeleton;
import away3d.animators.nodes.SkeletonClipNode;
import away3d.animators.nodes.VertexClipNode;
import away3d.animators.transitions.CrossfadeTransition;
import away3d.core.base.Geometry;
import away3d.entities.Mesh;
import away3d.events.Asset3DEvent;
import away3d.events.LoaderEvent;
import away3d.library.Asset3DLibrary;
import away3d.library.assets.Asset3DType;
import away3d.loaders.parsers.AWDParser;
import away3d.loaders.parsers.MD2Parser;
import away3d.loaders.parsers.MD5AnimParser;
import away3d.loaders.parsers.MD5MeshParser;
import away3d.materials.TextureMaterial;
import away3d.materials.methods.CelSpecularMethod;
import away3d.textures.ATFTexture;
import away3d.textures.BitmapTexture;
import away3d.utils.Cast;
import openfl.Assets;
import openfl.utils.ByteArray;

class ModelThing
{
	var modelBytes:ByteArray;
	public var modelMaterial:TextureMaterial;
	var animationSet:VertexAnimationSet;
	var vertexAnimator:VertexAnimator;
	public var animationSetSkeleton:SkeletonAnimationSet;
	var skeletonAnimator:SkeletonAnimator;
	var skeleton:Skeleton;
	var stateTransition:CrossfadeTransition;
	var animationMap:Map<String, ByteArray>;
	var animSpeed:Map<String, Float>;
	var scaleValue:Float;
	var fileName:String;
	var jointsPerVertex:Int = 4;
	var geos:Map<String, Geometry> = [];
	var bitmapTexture:BitmapTexture;
	var atfTexture:ATFTexture;
	var atfBytes:ByteArray;

	public var mesh:Mesh;
	public var modelView:ModelView;
	public var fullyLoaded:Bool = false;
	public var currentAnim:String = "";
	public var modelType:String;
	public var noLoopList:Array<String>;
	public var xOffset:Float = 0;
	public var yOffset:Float = 0;
	public var zOffset:Float = 0;
	public var currentTime(get, never):Int;

	public function new(type:String, fileName:String, modelView:ModelView, scale:Float = 1, animSpeed:Map<String, Float> = null, yaw:Float = 0,
			pitch:Float = 0, roll:Float = 0, alpha:Float = 1, x:Float = 0, y:Float = 0, z:Float = 0, noLoopList:Array<String> = null,
			md5Anims:Map<String, String> = null, atf:Bool = false, antialiasing:Bool = true, ambient:Float = 1, specular:Float = 1,
			diffuse:Float = 1, light:Bool = false, jointsPerVertex:Int = 4)
	{
		this.modelType = type;
		this.fileName = fileName;
		this.modelView = modelView;
		this.scaleValue = scale;
		this.animSpeed = animSpeed != null ? animSpeed : ["default" => 1.0];
		this.noLoopList = noLoopList != null ? noLoopList : [];
		this.jointsPerVertex = jointsPerVertex;
		xOffset = x;
		yOffset = y;
		zOffset = z;

		if (atf)
		{
			var texturePath = 'assets/models/$fileName/$fileName.atf';
			if (!Assets.exists(texturePath))
			{
				trace('ERROR: TEXTURE "$texturePath" CAN NOT BE FOUND!');
				return;
			}
			atfBytes = Assets.getBytes(texturePath);
			atfTexture = new ATFTexture(atfBytes);
			modelMaterial = new TextureMaterial(atfTexture, antialiasing);
		}
		else
		{
			var texturePath = 'assets/models/$fileName/$fileName.png';
			if (!Assets.exists(texturePath))
			{
				trace('ERROR: TEXTURE "$texturePath" CAN NOT BE FOUND!');
				return;
			}
			bitmapTexture = Cast.bitmapTexture(texturePath);
			modelMaterial = new TextureMaterial(bitmapTexture, antialiasing);
		}

		if (light)
		{
			modelMaterial.lightPicker = modelView.lightPicker;
			modelMaterial.shadowMethod = modelView.shadowMapMethod;
		}
		modelMaterial.gloss = 30;
		modelMaterial.specularMethod = new CelSpecularMethod();
		modelMaterial.ambient = ambient;
		modelMaterial.specular = specular;
		if (modelView.light != null)
			modelView.light.diffuse = diffuse;
		modelMaterial.alpha = alpha;

		modelView.cameraController.panAngle = 90;
		modelView.cameraController.tiltAngle = 0;
		meshYaw = yaw;
		meshPitch = pitch;
		meshRoll = roll;

		switch (modelType)
		{
			case "md2":
				loadMD2();
			case "md5":
				loadMD5(md5Anims != null ? md5Anims : []);
			case "awd":
				loadAWD();
			default:
				trace('Unsupported model type "$type" for "$fileName".');
		}
	}

	var meshYaw:Float = 0;
	var meshPitch:Float = 0;
	var meshRoll:Float = 0;

	function loadMD2():Void
	{
		var modelPath = 'assets/models/$fileName/$fileName.md2';
		if (!Assets.exists(modelPath))
		{
			trace('ERROR: MODEL "$modelPath" CAN NOT BE FOUND!');
			return;
		}
		modelBytes = Assets.getBytes(modelPath);
		Asset3DLibrary.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetCompleteMD2);
		Asset3DLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceCompleteMD2);
		Asset3DLibrary.loadData(modelBytes, null, null, new MD2Parser());
	}

	function loadMD5(md5Anims:Map<String, String>):Void
	{
		var modelPath = 'assets/models/$fileName/$fileName.md5mesh';
		if (!Assets.exists(modelPath))
		{
			trace('ERROR: MODEL "$modelPath" CAN NOT BE FOUND!');
			return;
		}
		stateTransition = new CrossfadeTransition(0.15);
		modelBytes = Assets.getBytes(modelPath);
		animationMap = [];
		for (animName in md5Anims.keys())
		{
			var animPath = 'assets/models/$fileName/${md5Anims[animName]}.md5anim';
			if (!Assets.exists(animPath))
			{
				trace('ERROR: MD5 ANIMATION "$animPath" CAN NOT BE FOUND!');
				continue;
			}
			animationMap[animName] = Assets.getBytes(animPath);
		}

		Asset3DLibrary.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetCompleteMD5);
		Asset3DLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceCompleteMD5);
		Asset3DLibrary.loadData(modelBytes, null, null, new MD5MeshParser());
	}

	function loadAWD():Void
	{
		var modelPath = 'assets/models/$fileName/$fileName.awd';
		if (!Assets.exists(modelPath))
		{
			trace('ERROR: MODEL "$modelPath" CAN NOT BE FOUND!');
			return;
		}
		animationSetSkeleton = new SkeletonAnimationSet(jointsPerVertex);
		stateTransition = new CrossfadeTransition(0.15);
		modelBytes = Assets.getBytes(modelPath);
		Asset3DLibrary.enableParser(AWDParser);
		Asset3DLibrary.addEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetCompleteAWD);
		Asset3DLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceCompleteAWD);
		Asset3DLibrary.loadData(modelBytes);
	}

	function onAssetCompleteMD2(event:Asset3DEvent):Void
	{
		switch (event.asset.assetType)
		{
			case Asset3DType.MESH:
				mesh = cast event.asset;
				mesh.scaleX = scaleValue;
				mesh.scaleY = scaleValue;
				mesh.scaleZ = scaleValue;
				mesh.yaw(meshYaw);
				mesh.pitch(meshPitch);
				mesh.roll(meshRoll);
			case Asset3DType.ANIMATION_NODE:
				var node:VertexClipNode = cast event.asset;
				if (noLoopList.contains(node.name))
					node.looping = false;
			case Asset3DType.ANIMATION_SET:
				animationSet = cast event.asset;
		}
	}

	function onResourceCompleteMD2(event:LoaderEvent):Void
	{
		if (mesh == null || animationSet == null)
			return;

		vertexAnimator = new VertexAnimator(animationSet);
		mesh.animator = vertexAnimator;
		render();
	}

	function onAssetCompleteMD5(event:Asset3DEvent):Void
	{
		switch (event.asset.assetType)
		{
			case Asset3DType.ANIMATION_NODE:
				var node:SkeletonClipNode = cast event.asset;
				node.name = event.asset.assetNamespace;
				if (animationSetSkeleton != null)
					animationSetSkeleton.addAnimation(node);
				if (noLoopList.contains(node.name))
					node.looping = false;
			case Asset3DType.ANIMATION_SET:
				animationSetSkeleton = cast event.asset;
				skeletonAnimator = new SkeletonAnimator(animationSetSkeleton, skeleton);
				if (animationMap != null)
					for (name in animationMap.keys())
						Asset3DLibrary.loadData(animationMap[name], null, name, new MD5AnimParser());
			case Asset3DType.SKELETON:
				skeleton = cast event.asset;
			case Asset3DType.MESH:
				setupMesh(cast event.asset);
		}
	}

	function onResourceCompleteMD5(event:LoaderEvent):Void
	{
		if (mesh == null || skeletonAnimator == null)
			return;
		mesh.animator = skeletonAnimator;
		render();
	}

	function onAssetCompleteAWD(event:Asset3DEvent):Void
	{
		var assetName:String = event.asset.name;
		var hasPrefix:Bool = assetName != null && assetName.startsWith(fileName + "_");
		switch (event.asset.assetType)
		{
			case Asset3DType.SKELETON:
				if (hasPrefix || skeleton == null)
					skeleton = cast event.asset;
				skeletonAnimator = new SkeletonAnimator(animationSetSkeleton, skeleton, true);
			case Asset3DType.ANIMATION_NODE:
				var node:SkeletonClipNode = cast event.asset;
				if (hasPrefix)
					node.name = assetName.substr(fileName.length + 1);
				if (animationSetSkeleton != null)
					animationSetSkeleton.addAnimation(node);
				if (noLoopList.contains(node.name))
					node.looping = false;
			case Asset3DType.MESH:
				if (hasPrefix || mesh == null)
					setupMesh(cast event.asset);
			case Asset3DType.GEOMETRY:
				var geo:Geometry = cast event.asset;
				if (hasPrefix)
					geo.name = assetName.substr(fileName.length + 1);
				if (geo.name != null && geo.name.length > 0)
					geos[geo.name] = geo;
		}
	}

	function onResourceCompleteAWD(event:LoaderEvent):Void
	{
		if (mesh == null || skeletonAnimator == null)
			return;
		mesh.animator = skeletonAnimator;
		render();
	}

	function setupMesh(newMesh:Mesh):Void
	{
		mesh = newMesh;
		mesh.material = modelMaterial;
		mesh.scaleX = scaleValue;
		mesh.scaleY = scaleValue;
		mesh.scaleZ = scaleValue;
		mesh.yaw(meshYaw);
		mesh.pitch(meshPitch);
		mesh.roll(meshRoll);
	}

	function render():Void
	{
		if (mesh == null)
			return;
		mesh.x = xOffset;
		mesh.y = yOffset;
		mesh.z = zOffset;
		if (modelType == "md2")
		{
			mesh.castsShadows = false;
			mesh.material = modelMaterial;
		}
		modelView.addModel(mesh);
		modelView.addedModels.push(this);
		fullyLoaded = true;
		playAnim("idle", true);
	}

	public function update():Void {}

	public function isAnimationFinished():Bool
	{
		if (modelType == "md2")
		{
			if (vertexAnimator == null)
				return false;
			return vertexAnimator.animationState == null || !vertexAnimator.playing;
		}
		else
		{
			if (skeletonAnimator == null)
				return false;
			return skeletonAnimator.animationState == null || !skeletonAnimator.playing;
		}
	}

	public function animExists(anim:String):Bool
	{
		return switch (modelType)
		{
			case "md2": animationSet != null && animationSet.animationNames.indexOf(anim) != -1;
			default: animationSetSkeleton != null && animationSetSkeleton.animationNames.indexOf(anim) != -1;
		}
	}

	public function playAnim(anim:String = "", force:Bool = false, offset:Int = 0, geo:String = ""):Void
	{
		if (!fullyLoaded)
			return;

		if (!animExists(anim))
		{
			trace('ANIMATION NAME $anim NOT FOUND.');
			return;
		}

		if (force || currentAnim != anim)
		{
			var newSpeed:Float = animSpeed.exists(anim) ? animSpeed[anim] : animSpeed["default"];
			if (modelType == "md2")
			{
				vertexAnimator.playbackSpeed = newSpeed;
				vertexAnimator.play(anim, null, offset);
			}
			else
			{
				if (geo != null && geo.length > 0)
				{
					if (geos.exists(geo))
						mesh.geometry = geos[geo];
					else
						trace('GEO NAME $geo NOT FOUND FOR $fileName');
				}
				skeletonAnimator.playbackSpeed = newSpeed;
				skeletonAnimator.play(anim, stateTransition, offset);
			}
			currentAnim = anim;
		}
	}

	public function begoneEventListeners():Void
	{
		Asset3DLibrary.removeEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetCompleteMD2);
		Asset3DLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceCompleteMD2);
		Asset3DLibrary.removeEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetCompleteMD5);
		Asset3DLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceCompleteMD5);
		Asset3DLibrary.removeEventListener(Asset3DEvent.ASSET_COMPLETE, onAssetCompleteAWD);
		Asset3DLibrary.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceCompleteAWD);
	}

	public function destroy():Void
	{
		begoneEventListeners();
		if (mesh != null) {
			if (mesh.parent != null)
				mesh.parent.removeChild(mesh);
			mesh.disposeWithChildren();
			mesh = null;
		}
		if (modelBytes != null)
			modelBytes.clear();
		if (animationSet != null)
			animationSet.dispose();
		if (animationSetSkeleton != null)
			animationSetSkeleton.dispose();
		if (skeleton != null)
			skeleton.dispose();
		if (vertexAnimator != null)
			vertexAnimator.dispose();
		if (skeletonAnimator != null)
			skeletonAnimator.dispose();
		if (animationMap != null)
			for (bytes in animationMap)
				bytes.clear();
		if (geos != null)
		{
			for (geo in geos)
				if (geo != null)
					geo.dispose();
			geos.clear();
		}
		if (bitmapTexture != null)
			bitmapTexture.dispose();
		if (atfTexture != null)
			atfTexture.dispose();
		if (atfBytes != null)
			atfBytes.clear();
		if (modelMaterial != null)
			modelMaterial.dispose();
		stateTransition = null;
		animationMap = null;
		geos = null;
		bitmapTexture = null;
		atfTexture = null;
		atfBytes = null;
		modelMaterial = null;
		modelView = null;
	}

	public function addYaw(angle:Float):Void
	{
		if (mesh != null)
			mesh.yaw(angle);
	}

	public function addPitch(angle:Float):Void
	{
		if (mesh != null)
			mesh.pitch(angle);
	}

	public function addRoll(angle:Float):Void
	{
		if (mesh != null)
			mesh.roll(angle);
	}

	function get_currentTime():Int
	{
		if (skeletonAnimator != null)
			return skeletonAnimator.time;
		return 0;
	}
}
