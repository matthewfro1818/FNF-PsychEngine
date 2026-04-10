var spitbucketStrumMoved:Bool = false;
var spitbucketBlackScreen:FlxSprite = null;
var spitbucketStoredComboOffset:Array<Int> = null;

function spitbucketProp(name:String)
{
    return getVar(name);
}

function spitbucketResetTargets()
{
    for (name in ['targetOne', 'targetTwo', 'targetThree', 'targetFour', 'targetFive', 'targetSix'])
    {
        var obj = spitbucketProp(name);
        if (obj != null && obj.animation != null)
            obj.animation.play('blank', true);
    }
}

function onCreatePost()
{
    if (spitbucketProp('lighting1') != null) spitbucketProp('lighting1').blend = 11;
    if (spitbucketProp('lighting2') != null)
    {
        spitbucketProp('lighting2').blend = 0;
        spitbucketProp('lighting2').alpha = 0.2;
    }
    if (spitbucketProp('itsHighNoon') != null)
    {
        spitbucketProp('itsHighNoon').blend = 21;
        spitbucketProp('itsHighNoon').alpha = 0;
    }

    spitbucketBlackScreen = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
    spitbucketBlackScreen.cameras = [game.camOther];
    add(spitbucketBlackScreen);

    if (!game.chartingMode)
        game.camHUD.alpha = 0;
    else
        spitbucketBlackScreen.alpha = 0;
}

function onStartCountdown()
{
    if (!FlxG.onMobile && !spitbucketStrumMoved)
    {
        game.playerStrums.x -= (game.playerStrums.x - FlxG.width * 0.5) * -1 + FlxG.width * 0.47;
        game.opponentStrums.x += (game.opponentStrums.x - FlxG.width * 0.5) + FlxG.width;
        spitbucketStrumMoved = true;
    }

    if (ClientPrefs != null && ClientPrefs.data != null)
    {
        spitbucketStoredComboOffset = ClientPrefs.data.comboOffset.copy();
        ClientPrefs.data.comboOffset = [90, -160, 90, -160];
    }

    return Function_Continue;
}

function onBeatHit()
{
    if (curBeat <= 20 || curBeat >= 360) return;

    if (FlxG.random.bool(65) && spitbucketProp('juan') != null && spitbucketProp('juan').animation != null)
        spitbucketProp('juan').animation.play('shoot', true);
    if (FlxG.random.bool(80) && spitbucketProp('marco') != null && spitbucketProp('marco').animation != null)
        spitbucketProp('marco').animation.play('shoot', true);
}

function onStepHit()
{
    if (curStep == 2 && spitbucketBlackScreen != null)
        FlxTween.tween(spitbucketBlackScreen, {alpha: 0}, 6);
    if (curStep == 120)
        FlxTween.tween(game.camHUD, {alpha: 1}, 1);
    if (curStep == 416 || curStep == 544 || curStep == 928)
        game.camGame.flash(0x40FFFFFF, 1);
    if (curStep == 1424)
    {
        if (game.boyfriend != null) FlxTween.tween(game.boyfriend, {alpha: 0}, 1);
        if (spitbucketProp('rock') != null) FlxTween.tween(spitbucketProp('rock'), {alpha: 0}, 1);
    }
    if (curStep == 1440)
    {
        game.camGame.flash(0x60FFFFFF, 1);
        if (spitbucketProp('itsHighNoon') != null) spitbucketProp('itsHighNoon').alpha = 0.8;
    }
    if (curStep == 1444 && spitbucketProp('targetOne') != null) spitbucketProp('targetOne').animation.play('xOne', true);
    if (curStep == 1446 && spitbucketProp('targetTwo') != null) spitbucketProp('targetTwo').animation.play('xTwo', true);
    if (curStep == 1450 && spitbucketProp('targetThree') != null) spitbucketProp('targetThree').animation.play('xThree', true);
    if (curStep == 1452 && spitbucketProp('targetFour') != null) spitbucketProp('targetFour').animation.play('xFour', true);
    if (curStep == 1456 && spitbucketProp('targetFive') != null) spitbucketProp('targetFive').animation.play('xFive', true);
    if (curStep == 1458 && spitbucketProp('targetSix') != null) spitbucketProp('targetSix').animation.play('xSix', true);
    if (curStep == 1464)
    {
        game.camGame.flash(0x40FFFFFF, 1);
        if (spitbucketProp('itsHighNoon') != null) spitbucketProp('itsHighNoon').alpha = 0;
        spitbucketResetTargets();
    }
    if (curStep == 1465 && spitbucketProp('juan') != null) spitbucketProp('juan').animation.play('dodge1', true);
    if (curStep == 1466 && spitbucketProp('marco') != null) spitbucketProp('marco').animation.play('dodge1', true);
    if (curStep == 1468 && spitbucketProp('juan') != null) spitbucketProp('juan').animation.play('dodge2', true);
    if (curStep == 1469 && spitbucketProp('marco') != null) spitbucketProp('marco').animation.play('dodge2', true);
    if (curStep == 1471 && spitbucketProp('juan') != null) spitbucketProp('juan').animation.play('dodge3', true);
    if (curStep == 1472 && spitbucketProp('marco') != null) spitbucketProp('marco').animation.play('dodge3', true);
    if (curStep == 1536 && spitbucketBlackScreen != null)
        spitbucketBlackScreen.alpha = 1;
}

function onDestroy()
{
    spitbucketStrumMoved = false;
    if (ClientPrefs != null && ClientPrefs.data != null && spitbucketStoredComboOffset != null)
        ClientPrefs.data.comboOffset = spitbucketStoredComboOffset.copy();
}
