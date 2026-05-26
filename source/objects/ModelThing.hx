package objects;

import away3d.animators.SkeletonAnimationSet;
import away3d.animators.SkeletonAnimator;
import away3d.animators.VertexAnimationSet;
import away3d.animators.VertexAnimator;
import away3d.animators.data.Skeleton;
import away3d.animators.nodes.SkeletonClipNode;
import away3d.animators.nodes.VertexClipNode;
import away3d.animators.transitions.CrossfadeTransition;
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
import away3d.utils.Cast;
import openfl.Assets;
import openfl.utils.ByteArray;

class ModelThing
{
	var modelBytes:ByteArray;
	var modelMaterial:TextureMaterial;
	var animationSet:VertexAnimationSet;
	var vertexAnimator:VertexAnimator;
	var animationSetSkeleton:SkeletonAnimationSet;
	var skeletonAnimator:SkeletonAnimator;
	var skeleton:Skeleton;
	var stateTransition:CrossfadeTransition;
	var animationMap:Map<String, ByteArray>;
	var animSpeed:Map<String, Float>;
	var scaleValue:Float;
	var fileName:String;

	public var mesh:Mesh;
	public var modelView:ModelView;
	public var fullyLoaded:Bool = false;
	public var currentAnim:String = "";
	public var modelType:String;
	public var noLoopList:Array<String>;
	public var xOffset:Float = 0;
	public var yOffset:Float = 0;
	public var zOffset:Float = 0;

	public function new(type:String, fileName:String, modelView:ModelView, scale:Float = 1, animSpeed:Map<String, Float> = null, yaw:Float = 0,
			pitch:Float = 0, roll:Float = 0, alpha:Float = 1, x:Float = 0, y:Float = 0, z:Float = 0, noLoopList:Array<String> = null,
			md5Anims:Map<String, String> = null)
	{
		this.modelType = type;
		this.fileName = fileName;
		this.modelView = modelView;
		this.scaleValue = scale;
		this.animSpeed = animSpeed != null ? animSpeed : ["default" => 1.0];
		this.noLoopList = noLoopList != null ? noLoopList : [];
		xOffset = x;
		yOffset = y;
		zOffset = z;

		var texturePath = 'assets/models/$fileName/$fileName.png';
		if (!Assets.exists(texturePath))
		{
			trace('ERROR: TEXTURE "$texturePath" CAN NOT BE FOUND!');
			return;
		}

		modelMaterial = new TextureMaterial(Cast.bitmapTexture(texturePath));
		modelMaterial.lightPicker = modelView.lightPicker;
		modelMaterial.gloss = 30;
		modelMaterial.specularMethod = new CelSpecularMethod();
		modelMaterial.ambient = 1;
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
		switch (event.asset.assetType)
		{
			case Asset3DType.SKELETON:
				skeleton = cast event.asset;
				animationSetSkeleton = new SkeletonAnimationSet();
				skeletonAnimator = new SkeletonAnimator(animationSetSkeleton, skeleton, true);
			case Asset3DType.ANIMATION_NODE:
				var node:SkeletonClipNode = cast event.asset;
				if (animationSetSkeleton != null)
					animationSetSkeleton.addAnimation(node);
				if (noLoopList.contains(node.name))
					node.looping = false;
			case Asset3DType.MESH:
				setupMesh(cast event.asset);
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

	public function playAnim(anim:String = "", force:Bool = false, offset:Int = 0):Void
	{
		if (!fullyLoaded)
			return;

		var hasAnim = switch (modelType)
		{
			case "md2": animationSet != null && animationSet.animationNames.indexOf(anim) != -1;
			default: animationSetSkeleton != null && animationSetSkeleton.animationNames.indexOf(anim) != -1;
		}
		if (!hasAnim)
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
		if (mesh != null)
			mesh.disposeWithChildren();
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
		stateTransition = null;
		animationMap = null;
		modelMaterial = null;
		modelView = null;
	}
}
