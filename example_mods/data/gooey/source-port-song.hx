var gooeyCutscenePlayed:Bool = false;
var gooeyCutsceneRunning:Bool = false;
var gooeyCutsceneHudAlpha:Float = 1;
var gooeyCutsceneZoom:Float = 1;
var gooeyCutsceneCamX:Float = 0;
var gooeyCutsceneCamY:Float = 0;
var gooeyCutsceneTimers:Array<FlxTimer> = [];

function gooeyCutsceneCancelTimers()
{
    for (timer in gooeyCutsceneTimers)
        if (timer != null) timer.cancel();
    gooeyCutsceneTimers = [];
}

function gooeyCutsceneQueue(delay:Float, fn:Dynamic)
{
    gooeyCutsceneTimers.push(new FlxTimer().start(delay, function(tmr)
    {
        fn();
    }));
}

function gooeyCutsceneFocusOnDad()
{
    if (game.camFollow == null || game.dad == null) return;

    gooeyCutsceneCamX = game.camFollow.x;
    gooeyCutsceneCamY = game.camFollow.y;
    game.camFollow.setPosition(game.dad.getMidpoint().x + 50, game.dad.getMidpoint().y - 50);
}

function gooeyCutsceneRestoreCamera()
{
    if (game.camFollow == null) return;
    game.camFollow.setPosition(gooeyCutsceneCamX, gooeyCutsceneCamY);
}

function onStartCountdown()
{
    if (gooeyCutscenePlayed || gooeyCutsceneRunning || PlayState.chartingMode || !game.isStoryMode)
        return Function_Continue;

    gooeyCutscenePlayed = true;
    gooeyCutsceneRunning = true;
    game.inCutscene = true;
    gooeyCutsceneHudAlpha = game.camHUD.alpha;
    gooeyCutsceneZoom = game.defaultCamZoom;
    game.camHUD.alpha = 0;

    gooeyCutsceneFocusOnDad();

    if (game.dad != null && game.dad.hasAnimation('hey'))
    {
        game.dad.playAnim('hey', true);
        game.dad.specialAnim = true;
    }

    if (game.boyfriend != null && game.boyfriend.hasAnimation('hey'))
    {
        game.boyfriend.playAnim('hey', true);
        game.boyfriend.specialAnim = true;
    }

    FlxTween.tween(game, {defaultCamZoom: gooeyCutsceneZoom * 1.15}, 1.2, {ease: FlxEase.quadOut});
    FlxTween.tween(game.camGame, {zoom: gooeyCutsceneZoom * 1.15}, 1.2, {ease: FlxEase.quadOut});

    gooeyCutsceneQueue(3.0, function()
    {
        gooeyCutsceneRunning = false;
        game.inCutscene = false;
        gooeyCutsceneRestoreCamera();
        FlxTween.tween(game, {defaultCamZoom: gooeyCutsceneZoom}, 1.2, {ease: FlxEase.quadInOut});
        FlxTween.tween(game.camGame, {zoom: gooeyCutsceneZoom}, 1.2, {ease: FlxEase.quadInOut});
        FlxTween.tween(game.camHUD, {alpha: gooeyCutsceneHudAlpha}, 0.8, {ease: FlxEase.quadInOut});
        game.startCountdown();
    });

    return Function_Stop;
}

function onDestroy()
{
    gooeyCutsceneCancelTimers();
}
