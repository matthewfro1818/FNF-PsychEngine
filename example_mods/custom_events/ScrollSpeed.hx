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
        default:
            return FlxEase.linear;
    }
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'ScrollSpeed' || game.songSpeedType == 'constant') return;

    var parts = sourcePortSplitPipe(value2);
    var scroll = sourcePortToFloat(value1, 1);
    var durationSteps = sourcePortToFloat(parts.length > 0 ? parts[0] : 0, 0);
    var easeName = parts.length > 1 ? parts[1] : 'linear';
    var absolute = parts.length > 3 ? parts[3].toLowerCase().trim() == 'true' : false;
    var durationSeconds = durationSteps * Conductor.stepCrochet / 1000 / game.playbackRate;
    var newValue = absolute ? scroll : PlayState.SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * scroll;

    if (game.songSpeedTween != null)
    {
        game.songSpeedTween.cancel();
        game.songSpeedTween = null;
    }

    if (durationSeconds <= 0)
    {
        game.songSpeed = newValue;
        return;
    }

    game.songSpeedTween = FlxTween.tween(game, {songSpeed: newValue}, durationSeconds, {
        ease: sourcePortEaseByName(easeName),
        onComplete: function(twn)
        {
            game.songSpeedTween = null;
        }
    });
}


