var sourcePortCamBopRate:Int = 4;
var sourcePortCamBopIntensity:Float = 1;
var sourcePortCamBopOffset:Float = 0;

function sourcePortSplitPipe(value:String)
{
    if (value == null || value.length < 1) return [];
    return value.split('|');
}

function sourcePortToFloat(value:Dynamic, fallback:Float):Float
{
    if (value == null) return fallback;
    var parsed = Std.parseFloat(Std.string(value));
    return Math.isNaN(parsed) ? fallback : parsed;
}

function sourcePortApplyCameraBop(rate:Float, intensity:Float, offset:Float)
{
    sourcePortCamBopRate = Std.int(Math.max(1, rate));
    sourcePortCamBopIntensity = intensity;
    sourcePortCamBopOffset = offset;
    setVar('sourcePortCamBopRate', sourcePortCamBopRate);
    setVar('sourcePortCamBopIntensity', sourcePortCamBopIntensity);
    setVar('sourcePortCamBopOffset', sourcePortCamBopOffset);
}

function onCreatePost()
{
    if (getVar('sourcePortCamBopRate') == null) setVar('sourcePortCamBopRate', sourcePortCamBopRate);
    if (getVar('sourcePortCamBopIntensity') == null) setVar('sourcePortCamBopIntensity', sourcePortCamBopIntensity);
    if (getVar('sourcePortCamBopOffset') == null) setVar('sourcePortCamBopOffset', sourcePortCamBopOffset);
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'SetCameraBop') return;

    var parts = sourcePortSplitPipe(value2);
    var rate = sourcePortToFloat(value1, 4);
    var intensity = sourcePortToFloat(parts.length > 0 ? parts[0] : value2, 1);
    var offset = sourcePortToFloat(parts.length > 1 ? parts[1] : 0, 0);
    sourcePortApplyCameraBop(rate, intensity, offset);
}

function onBeatHit()
{
    var rate = Std.int(sourcePortToFloat(getVar('sourcePortCamBopRate'), sourcePortCamBopRate));
    var intensity = sourcePortToFloat(getVar('sourcePortCamBopIntensity'), sourcePortCamBopIntensity);
    var offset = sourcePortToFloat(getVar('sourcePortCamBopOffset'), sourcePortCamBopOffset);
    if (rate <= 0 || intensity <= 0 || !ClientPrefs.data.camZooms) return;

    if (((curBeat - Std.int(offset)) % rate) != 0) return;

    FlxG.camera.zoom += 0.015 * intensity;
    game.camHUD.zoom += 0.03 * intensity;
}


