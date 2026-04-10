function drippyProp(name:String)
{
    return getVar(name);
}

function drippySetAlpha(name:String, alpha:Float)
{
    var obj = drippyProp(name);
    if (obj != null) obj.alpha = alpha;
}

function drippySetBlend(name:String, blendMode:Dynamic)
{
    var obj = drippyProp(name);
    if (obj != null) obj.blend = blendMode;
}

function onCreatePost()
{
    drippySetBlend('starShines1', 0);
    drippySetBlend('starShines2', 0);
    drippySetBlend('floorGlow', 0);
    drippySetBlend('purpleOverlay', 0);
    drippySetAlpha('starShines1', 0.0001);
    drippySetAlpha('starShines2', 0.0001);
}

function onStartCountdown()
{
    if (game.gf != null)
        game.gf.visible = false;

    return Function_Continue;
}

function onBeatHit()
{
    if (curBeat % 4 != 0) return;

    if (drippyProp('starShines1') != null)
    {
        drippyProp('starShines1').alpha = 1;
        FlxTween.tween(drippyProp('starShines1'), {alpha: 0}, 1);
    }

    if (drippyProp('starShines2') != null)
    {
        drippyProp('starShines2').alpha = 1;
        FlxTween.tween(drippyProp('starShines2'), {alpha: 0}, 1);
    }
}

function onStepHit()
{
    if (curStep == 1140 && game.gf != null)
        game.gf.visible = true;
}
