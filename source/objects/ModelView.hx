package objects;

import away3d.containers.View3D;
import away3d.controllers.HoverController;
import away3d.entities.Mesh;
import away3d.lights.DirectionalLight;
import away3d.materials.lightpickers.StaticLightPicker;
import away3d.materials.methods.FilteredShadowMapMethod;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lime.graphics.opengl.GLFramebuffer;
import openfl.display.BitmapData;
import openfl.display3D.textures.RectangleTexture;
import openfl.geom.Vector3D;

@:access(openfl.display3D.Context3D)
@:access(openfl.display3D.textures.RectangleTexture)
class ModelView implements IFlxDestroyable
{
	public var view:View3D;
	public var cameraController:HoverController;
	public var light:DirectionalLight;
	public var lightPicker:StaticLightPicker;
	public var shadowMapMethod:FilteredShadowMapMethod;
	public var sprite:FlxSprite = new FlxSprite();

	var lookAtPosition:Vector3D = new Vector3D();
	var renderTexture:RectangleTexture;
	var framebuffer:GLFramebuffer;
	var madeBuffer:Bool = false;

	public function new(viewWidth:Float = 720, viewHeight:Float = 720, ambient:Float = 1, specular:Float = 1, diffuse:Float = 1)
	{
		view = new View3D();
		view.width = viewWidth;
		view.height = viewHeight;
		view.backgroundAlpha = 0;

		FlxG.addChildBelowMouse(view);

		view.camera.lens.far = 5000;
		cameraController = new HoverController(view.camera, null, 90, 0, 300);
		cameraController.lookAtPosition = lookAtPosition;

		light = new DirectionalLight(-0.5, -1, -1);
		lightPicker = new StaticLightPicker([light]);
		view.scene.addChild(light);
		light.ambient = ambient;
		light.specular = specular;
		light.diffuse = diffuse;

		shadowMapMethod = new FilteredShadowMapMethod(light);

		renderTexture = FlxG.stage.context3D.createRectangleTexture(Std.int(viewWidth), Std.int(viewHeight),
			openfl.display3D.Context3DTextureFormat.COMPRESSED_ALPHA, true);
		var textureBitmap = BitmapData.fromTexture(renderTexture);
		if (textureBitmap != null)
			sprite.loadGraphic(textureBitmap);
		else
			sprite.makeGraphic(Std.int(viewWidth), Std.int(viewHeight), 0x00FFFFFF);
	}

	public function update():Void
	{
		if (view == null)
			return;
		view.render();
		bindRenderTexture();
	}

	function bindRenderTexture():Void
	{
		if (view.stage3DProxy == null || view.stage3DProxy.context3D == null || FlxG.stage == null || FlxG.stage.context3D == null)
			return;

		var gl = FlxG.stage.context3D.gl;
		if (gl == null)
			return;
		if (!madeBuffer)
		{
			framebuffer = gl.createFramebuffer();
			gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
			madeBuffer = true;
		}
		gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, renderTexture.__textureID, 0);
	}

	public function addModel(model:Mesh):Void
	{
		if (view == null || model == null)
			return;
		view.scene.addChild(model);
	}

	public function destroy():Void
	{
		cameraController = null;
		lookAtPosition = null;
		if (view != null && view.camera != null)
		{
			view.camera.disposeWithChildren();
			view.camera.disposeAsset();
		}
		if (light != null)
			light.disposeWithChildren();
		light = null;
		if (lightPicker != null)
			lightPicker.dispose();
		lightPicker = null;
		if (shadowMapMethod != null)
			shadowMapMethod.dispose();
		shadowMapMethod = null;
		if (renderTexture != null)
			renderTexture.dispose();
		renderTexture = null;
		if (sprite != null && sprite.graphic != null)
			sprite.graphic.destroy();
		sprite = FlxDestroyUtil.destroy(sprite);
		if (view != null)
		{
			while (view.scene.numChildren > 0)
			{
				var child = view.scene.getChildAt(0);
				view.scene.removeChildAt(0);
				if (child != null)
					child.disposeWithChildren();
			}
			FlxG.removeChild(view);
			view.dispose();
		}
		if (framebuffer != null && FlxG.stage != null && FlxG.stage.context3D != null && FlxG.stage.context3D.gl != null)
			FlxG.stage.context3D.gl.deleteFramebuffer(framebuffer);
		framebuffer = null;
		view = null;
	}
}
