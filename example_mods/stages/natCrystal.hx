var natCrystalFloatTweens:Array<FlxTween> = [];

function natCrystalProp(name:String)
{
    return getVar(name);
}

function natCrystalTweenProp(name:String, props:Dynamic, duration:Float, options:Dynamic = null)
{
    var obj = natCrystalProp(name);
    if (obj == null) return null;
    var tween = FlxTween.tween(obj, props, duration, options);
    natCrystalFloatTweens.push(tween);
    return tween;
}

function natCrystalClearTweens()
{
    for (tween in natCrystalFloatTweens)
        if (tween != null) tween.cancel();
    natCrystalFloatTweens = [];
}

function onCreatePost()
{
    if (natCrystalProp('floorLight') != null) natCrystalProp('floorLight').blend = 11;
    if (natCrystalProp('bottomCrystalLight') != null) natCrystalProp('bottomCrystalLight').blend = 0;
    if (natCrystalProp('natCrystalLight') != null) natCrystalProp('natCrystalLight').blend = 0;
    if (natCrystalProp('natCrystalLight2') != null)
    {
        natCrystalProp('natCrystalLight2').blend = 0;
        natCrystalProp('natCrystalLight2').alpha = 0;
    }
    if (natCrystalProp('overlay1') != null) natCrystalProp('overlay1').blend = 9;
    if (natCrystalProp('overlay2') != null) natCrystalProp('overlay2').blend = 9;
    if (natCrystalProp('overlay3') != null)
    {
        natCrystalProp('overlay3').blend = 9;
        natCrystalProp('overlay3').alpha = 0.3;
    }
    if (natCrystalProp('backWallLights') != null)
    {
        natCrystalProp('backWallLights').blend = 0;
        natCrystalProp('backWallLights').alpha = 0.0001;
    }
    if (natCrystalProp('bottomCrystalLight2') != null)
    {
        natCrystalProp('bottomCrystalLight2').blend = 0;
        natCrystalProp('bottomCrystalLight2').alpha = 0.0001;
    }
    if (natCrystalProp('crystalReflections1') != null)
    {
        natCrystalProp('crystalReflections1').blend = 16;
        natCrystalProp('crystalReflections1').alpha = 0.0001;
    }
    if (natCrystalProp('crystalReflections2') != null)
    {
        natCrystalProp('crystalReflections2').blend = 11;
        natCrystalProp('crystalReflections2').alpha = 0.0001;
    }
    if (natCrystalProp('starcraftLight') != null)
    {
        natCrystalProp('starcraftLight').blend = 15;
        natCrystalProp('starcraftLight').alpha = 0.0001;
    }
    if (natCrystalProp('crystalBackWall') != null)
    {
        natCrystalProp('crystalBackWall').blend = 0;
        natCrystalProp('crystalBackWall').alpha = 0.0001;
    }

    natCrystalClearTweens();
    natCrystalTweenProp('natCrystalLight', {y: natCrystalProp('natCrystalLight') != null ? natCrystalProp('natCrystalLight').y + 50 : 0}, 5, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});
    natCrystalTweenProp('natCrystalLight2', {y: natCrystalProp('natCrystalLight2') != null ? natCrystalProp('natCrystalLight2').y + 50 : 0}, 5, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});
    natCrystalTweenProp('natCrystal', {y: natCrystalProp('natCrystal') != null ? natCrystalProp('natCrystal').y + 50 : 0}, 5, {ease: FlxEase.quadInOut, type: FlxTween.PINGPONG});
    natCrystalTweenProp('crystalReflections1', {angle: 360}, 30, {type: FlxTween.LOOPING});
    natCrystalTweenProp('crystalReflections2', {angle: -360}, 40, {type: FlxTween.LOOPING});

    if (game.gf != null && game.gf.curCharacter == 'gf')
    {
        game.gf.x += 60;
        game.gf.y -= 20;
    }
}

function onStepHit()
{
    if (songPath != 'starcraft') return;

    if (curStep == 885)
    {
        if (natCrystalProp('bottomCrystalLight2') != null) FlxTween.tween(natCrystalProp('bottomCrystalLight2'), {alpha: 1}, 2.8, {ease: FlxEase.quartIn});
        if (natCrystalProp('natCrystalLight2') != null) FlxTween.tween(natCrystalProp('natCrystalLight2'), {alpha: 1}, 2.8, {ease: FlxEase.quartIn});
        if (natCrystalProp('overlay3') != null) FlxTween.tween(natCrystalProp('overlay3'), {alpha: 1}, 2.8, {ease: FlxEase.quartIn});
        if (natCrystalProp('backWallLights') != null) FlxTween.tween(natCrystalProp('backWallLights'), {alpha: 1}, 2.8, {ease: FlxEase.quartIn});
        if (natCrystalProp('crystalReflections1') != null) FlxTween.tween(natCrystalProp('crystalReflections1'), {alpha: 0.4}, 2.8, {ease: FlxEase.quartIn});
        if (natCrystalProp('crystalReflections2') != null) FlxTween.tween(natCrystalProp('crystalReflections2'), {alpha: 0.7}, 2.8, {ease: FlxEase.quartIn});
        if (natCrystalProp('starcraftLight') != null) FlxTween.tween(natCrystalProp('starcraftLight'), {alpha: 0.75}, 2.8, {ease: FlxEase.quartIn});
        if (natCrystalProp('crystalBackWall') != null) FlxTween.tween(natCrystalProp('crystalBackWall'), {alpha: 0.5}, 2.8, {ease: FlxEase.quartIn});
    }
    if (curStep == 1182)
    {
        if (natCrystalProp('bottomCrystalLight2') != null) FlxTween.tween(natCrystalProp('bottomCrystalLight2'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
        if (natCrystalProp('natCrystalLight2') != null) FlxTween.tween(natCrystalProp('natCrystalLight2'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
        if (natCrystalProp('overlay3') != null) FlxTween.tween(natCrystalProp('overlay3'), {alpha: 0.3}, 1.2, {ease: FlxEase.quartIn});
        if (natCrystalProp('backWallLights') != null) FlxTween.tween(natCrystalProp('backWallLights'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
        if (natCrystalProp('crystalReflections1') != null) FlxTween.tween(natCrystalProp('crystalReflections1'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
        if (natCrystalProp('crystalReflections2') != null) FlxTween.tween(natCrystalProp('crystalReflections2'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
        if (natCrystalProp('starcraftLight') != null) FlxTween.tween(natCrystalProp('starcraftLight'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
        if (natCrystalProp('crystalBackWall') != null) FlxTween.tween(natCrystalProp('crystalBackWall'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
    }
}

function onDestroy()
{
    natCrystalClearTweens();
}
