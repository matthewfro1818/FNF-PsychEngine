var blissfulOutroPlayed:Bool = false;
var blissfulOutroRunning:Bool = false;
var blissfulOutroHudAlpha:Float = 1;
var blissfulOutroTimers:Array<FlxTimer> = [];

function blissfulOutroCancelTimers()
{
    for (timer in blissfulOutroTimers)
        if (timer != null) timer.cancel();
    blissfulOutroTimers = [];
}

function blissfulOutroQueue(delay:Float, fn:Dynamic)
{
    blissfulOutroTimers.push(new FlxTimer().start(delay, function(tmr)
    {
        fn();
    }));
}

function blissfulStageProp(name:String)
{
    return getVar(name);
}

function onEndSong()
{
    if (blissfulOutroPlayed || blissfulOutroRunning || !game.isStoryMode)
        return Function_Continue;

    blissfulOutroPlayed = true;
    blissfulOutroRunning = true;
    game.inCutscene = true;
    blissfulOutroHudAlpha = game.camHUD.alpha;

    FlxTween.tween(game.camHUD, {alpha: 0}, 0.8, {ease: FlxEase.quadInOut});
    FlxTween.tween(game, {defaultCamZoom: 0.68}, 1.0, {ease: FlxEase.quadInOut});

    if (blissfulStageProp('spotLight') != null)
        FlxTween.tween(blissfulStageProp('spotLight'), {alpha: 1}, 1.1, {ease: FlxEase.linear});
    if (blissfulStageProp('blackScreen') != null)
        FlxTween.tween(blissfulStageProp('blackScreen'), {alpha: 1}, 1.1, {ease: FlxEase.linear});
    if (blissfulStageProp('lightOverlay') != null)
        FlxTween.tween(blissfulStageProp('lightOverlay'), {alpha: 0}, 1.1, {ease: FlxEase.linear});

    blissfulOutroQueue(2.8, function()
    {
        if (blissfulStageProp('redScreen') != null)
            FlxTween.tween(blissfulStageProp('redScreen'), {alpha: 1}, 0.7, {ease: FlxEase.linear});
        game.camGame.shake(0.002, 1.2);
    });

    blissfulOutroQueue(4.5, function()
    {
        blissfulOutroRunning = false;
        game.inCutscene = false;
        game.camHUD.alpha = blissfulOutroHudAlpha;
        game.endSong();
    });

    return Function_Stop;
}

function onDestroy()
{
    blissfulOutroCancelTimers();
}
