var blissfulGooeyCutscenePlayed:Bool = false;
var blissfulGooeyCutsceneRunning:Bool = false;
var blissfulGooeyCutTimers:Array<FlxTimer> = [];
var blissfulGooeyStoredHudAlpha:Float = 1;
var blissfulGooeyStoredZoom:Float = 1;
var blissfulGooeyStoredCamX:Float = 0;
var blissfulGooeyStoredCamY:Float = 0;
var blissfulGooeyStoredComboOffset:Array<Int> = null;

function blissfulGooeyCancelTimers()
{
    for (timer in blissfulGooeyCutTimers)
        if (timer != null) timer.cancel();
    blissfulGooeyCutTimers = [];
}

function blissfulGooeyQueue(delay:Float, fn:Dynamic)
{
    var timer = new FlxTimer().start(delay, function(tmr)
    {
        fn();
    });
    blissfulGooeyCutTimers.push(timer);
}

function blissfulGooeyFocusOnBoyfriend()
{
    if (game.boyfriend == null || game.camFollow == null) return;

    blissfulGooeyStoredCamX = game.camFollow.x;
    blissfulGooeyStoredCamY = game.camFollow.y;
    game.camFollow.setPosition(game.boyfriend.getMidpoint().x - 70, game.boyfriend.getMidpoint().y - 30);
}

function blissfulGooeyRestoreCamera()
{
    if (game.camFollow == null) return;
    game.camFollow.setPosition(blissfulGooeyStoredCamX, blissfulGooeyStoredCamY);
}

function onCreatePost()
{
    if (ClientPrefs != null && ClientPrefs.data != null)
    {
        blissfulGooeyStoredComboOffset = ClientPrefs.data.comboOffset.copy();
        ClientPrefs.data.comboOffset = [-450, 350, -450, 350];
    }
}

function onStartCountdown()
{
    if (blissfulGooeyCutscenePlayed || blissfulGooeyCutsceneRunning || PlayState.chartingMode)
        return Function_Continue;

    blissfulGooeyCutsceneRunning = true;
    game.inCutscene = true;
    blissfulGooeyStoredHudAlpha = game.camHUD.alpha;
    blissfulGooeyStoredZoom = game.defaultCamZoom;
    game.camHUD.alpha = 0;
    FlxG.keys.enabled = false;

    blissfulGooeyFocusOnBoyfriend();

    blissfulGooeyQueue(2.5, function()
    {
        if (game == null) return;
        FlxTween.tween(game, {defaultCamZoom: blissfulGooeyStoredZoom * 1.5}, 4, {ease: FlxEase.smootherStepInOut});
        FlxTween.tween(game.camGame, {zoom: blissfulGooeyStoredZoom * 1.5}, 4, {ease: FlxEase.smootherStepInOut});
    });

    blissfulGooeyQueue(4.0, function()
    {
        if (game.boyfriend != null && game.boyfriend.hasAnimation('GooeyQTwave'))
        {
            game.boyfriend.playAnim('GooeyQTwave', true);
            game.boyfriend.specialAnim = true;
        }
    });

    blissfulGooeyQueue(7.0, function()
    {
        blissfulGooeyCutscenePlayed = true;
        blissfulGooeyCutsceneRunning = false;
        game.inCutscene = false;
        FlxG.keys.enabled = true;
        FlxTween.tween(game, {defaultCamZoom: blissfulGooeyStoredZoom}, 2, {ease: FlxEase.smoothStepInOut});
        FlxTween.tween(game.camGame, {zoom: blissfulGooeyStoredZoom}, 2, {ease: FlxEase.smoothStepInOut});
        FlxTween.tween(game.camHUD, {alpha: blissfulGooeyStoredHudAlpha}, 1, {ease: FlxEase.smoothStepInOut});
        blissfulGooeyRestoreCamera();
        if (ClientPrefs != null && ClientPrefs.data != null && blissfulGooeyStoredComboOffset != null)
            ClientPrefs.data.comboOffset = blissfulGooeyStoredComboOffset.copy();
        game.startCountdown();
    });

    return Function_Stop;
}

function onDestroy()
{
    blissfulGooeyCancelTimers();
    if (ClientPrefs != null && ClientPrefs.data != null && blissfulGooeyStoredComboOffset != null)
        ClientPrefs.data.comboOffset = blissfulGooeyStoredComboOffset.copy();
}
