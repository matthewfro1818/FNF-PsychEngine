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

function sourcePortEaseByName(name:String)
{
    if (name == null) return FlxEase.linear;

    switch (name.toLowerCase().trim())
    {
        case 'instant', 'none':
            return null;
        case 'expoin':
            return FlxEase.expoIn;
        case 'expoinout':
            return FlxEase.expoInOut;
        case 'expoout':
            return FlxEase.expoOut;
        case 'sinein':
            return FlxEase.sineIn;
        case 'sineout':
            return FlxEase.sineOut;
        case 'sineinout':
            return FlxEase.sineInOut;
        case 'smoothstepinout':
            return FlxEase.smoothStepInOut;
        case 'smoothstepout':
            return FlxEase.smoothStepOut;
        case 'smoothstepin':
            return FlxEase.smoothStepIn;
        case 'quadout':
            return FlxEase.quadOut;
        case 'quadin':
            return FlxEase.quadIn;
        case 'quadinout', 'classic':
            return FlxEase.quadInOut;
        default:
            return FlxEase.linear;
    }
}

function sourcePortZoomInstant(targetZoom:Float, mode:String)
{
    if (mode == 'hud' || mode == 'both')
        game.camHUD.zoom = targetZoom;

    if (mode != 'hud')
    {
        game.defaultCamZoom = targetZoom;
        game.camGame.zoom = targetZoom;
    }
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'ZoomCamera') return;

    var parts = sourcePortSplitPipe(value2);
    var zoom = sourcePortToFloat(value1, sourcePortToFloat(parts.length > 0 ? parts[0] : 1, 1));
    var durationSteps = sourcePortToFloat(parts.length > 0 ? parts[0] : 0, 0);
    var easeName = parts.length > 1 ? parts[1] : 'linear';
    var mode = parts.length > 2 ? parts[2].toLowerCase().trim() : 'stage';
    var durationSeconds = durationSteps * Conductor.stepCrochet / 1000 / game.playbackRate;
    var easeFunc = sourcePortEaseByName(easeName);

    if (durationSeconds <= 0 || easeFunc == null)
    {
        sourcePortZoomInstant(zoom, mode);
        return;
    }

    if (mode == 'hud' || mode == 'both')
        FlxTween.tween(game.camHUD, {zoom: zoom}, durationSeconds, {ease: easeFunc});

    if (mode != 'hud')
    {
        FlxTween.tween(game, {defaultCamZoom: zoom}, durationSeconds, {ease: easeFunc});
        FlxTween.tween(game.camGame, {zoom: zoom}, durationSeconds, {ease: easeFunc});
    }
}


