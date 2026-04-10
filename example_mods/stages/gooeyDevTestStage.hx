var gooeyDevCrowdNames:Array<String> = ['morphoBop', 'blueBop', 'noodleBop', 'cerealBop', 'radBop', 'radEyeBop'];
var gooeyDevStoredComboOffset:Array<Int> = null;

function gooeyDevProp(name:String)
{
    return getVar(name);
}

function gooeyDevSetAlpha(name:String, alpha:Float)
{
    var obj = gooeyDevProp(name);
    if (obj != null) obj.alpha = alpha;
}

function gooeyDevSetBlend(name:String, blendMode:Dynamic)
{
    var obj = gooeyDevProp(name);
    if (obj != null) obj.blend = blendMode;
}

function gooeyDevSetDanceEvery(name:String, value:Int)
{
    var obj = gooeyDevProp(name);
    if (obj != null) obj.danceEvery = value;
}

function gooeyDevHideCrowdForChar(charId:String)
{
    if (charId == null) return;

    switch (charId)
    {
        case 'morpho', 'morpho-player':
            gooeyDevSetAlpha('morphoBop', 0);
        case 'rad':
            gooeyDevSetAlpha('radBop', 0);
            gooeyDevSetAlpha('radEyeBop', 0);
        case 'blue', 'blue-player':
            gooeyDevSetAlpha('blueBop', 0);
        case 'noodle', 'noodle-player':
            gooeyDevSetAlpha('noodleBop', 0);
        case 'cereal', 'cereal-player':
            gooeyDevSetAlpha('cerealBop', 0);
    }
}

function gooeyDevResetCrowdTiming(slow:Bool)
{
    if (slow)
    {
        for (name in gooeyDevCrowdNames)
            gooeyDevSetDanceEvery(name, 20);
        return;
    }

    gooeyDevSetDanceEvery('morphoBop', 2);
    gooeyDevSetDanceEvery('blueBop', 2);
    gooeyDevSetDanceEvery('noodleBop', 2);
    gooeyDevSetDanceEvery('cerealBop', 2);
    gooeyDevSetDanceEvery('radBop', 4);
    gooeyDevSetDanceEvery('radEyeBop', 4);
}

function gooeyDevSetFastCrowdTiming()
{
    gooeyDevSetDanceEvery('morphoBop', 1);
    gooeyDevSetDanceEvery('blueBop', 1);
    gooeyDevSetDanceEvery('noodleBop', 1);
    gooeyDevSetDanceEvery('cerealBop', 1);
    gooeyDevSetDanceEvery('radBop', 2);
    gooeyDevSetDanceEvery('radEyeBop', 2);
}

function onCreatePost()
{
    gooeyDevSetBlend('lighting', 0);
    gooeyDevSetBlend('lighting2', 9);
    gooeyDevSetBlend('stageLighting', 9);
    gooeyDevSetBlend('spotlight1', 9);
    gooeyDevSetBlend('spotlight2', 0);
    gooeyDevSetBlend('spotlight3', 0);
    gooeyDevSetBlend('extraSpotlight', 9);
    gooeyDevSetBlend('extraSpotlight2', 9);
    gooeyDevSetBlend('topLantern1Light', 0);
    gooeyDevSetBlend('topLantern2Light', 0);
    gooeyDevSetBlend('candleFrontLight', 0);
    gooeyDevSetBlend('candleBackLight', 0);
    gooeyDevSetBlend('bottomLantern1Light', 0);
    gooeyDevSetBlend('bottomLantern2Light', 0);
    gooeyDevSetBlend('radEyeBop', 0);

    gooeyDevSetAlpha('spotlight1', 1);
    gooeyDevSetAlpha('spotlight2', 0.05);
    gooeyDevSetAlpha('spotlight3', 0.5);
    gooeyDevSetAlpha('extraSpotlight', 0);
    gooeyDevSetAlpha('extraSpotlight2', 0);

    if (songPath == 'starcraft')
        gooeyDevResetCrowdTiming(false);
}

function onStartCountdown()
{
    if (game.dad != null) gooeyDevHideCrowdForChar(game.dad.curCharacter);
    if (game.gf != null)
    {
        gooeyDevHideCrowdForChar(game.gf.curCharacter);
        game.gf.flipX = false;
        game.gf.alpha = 1;
    }
    if (game.boyfriend != null)
    {
        gooeyDevHideCrowdForChar(game.boyfriend.curCharacter);
        game.boyfriend.alpha = 0.5;
    }
    if (game.dad != null)
        game.dad.alpha = 0;

    if (ClientPrefs != null && ClientPrefs.data != null)
    {
        gooeyDevStoredComboOffset = ClientPrefs.data.comboOffset.copy();
        ClientPrefs.data.comboOffset = [-450, 350, -450, 350];
    }

    return Function_Continue;
}

function onSongStart()
{
    if (songPath == 'starcraft')
        gooeyDevResetCrowdTiming(false);
}

function onStepHit()
{
    if (songPath == 'starcraft')
    {
        if (curStep == 885)
        {
            if (gooeyDevProp('extraSpotlight') != null) FlxTween.tween(gooeyDevProp('extraSpotlight'), {alpha: 0.5}, 2.8, {ease: FlxEase.quartIn});
            if (gooeyDevProp('extraSpotlight2') != null) FlxTween.tween(gooeyDevProp('extraSpotlight2'), {alpha: 0.5}, 2.8, {ease: FlxEase.quartIn});
            if (gooeyDevProp('spotlight2') != null) FlxTween.tween(gooeyDevProp('spotlight2'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
        }

        if (curStep == 911 || curStep == 16 || curStep == 1310 || curStep == 530)
            gooeyDevResetCrowdTiming(false);

        if (curStep == 1038 || curStep == 1 || curStep == 275 || curStep == 786 || curStep == 1343 || curStep == 658 || curStep == 1182)
            gooeyDevSetFastCrowdTiming();

        if (curStep == 1169 || curStep == 755 || curStep == 885)
            gooeyDevResetCrowdTiming(true);

        if (curStep == 1182)
        {
            if (gooeyDevProp('extraSpotlight') != null) FlxTween.tween(gooeyDevProp('extraSpotlight'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
            if (gooeyDevProp('extraSpotlight2') != null) FlxTween.tween(gooeyDevProp('extraSpotlight2'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
            if (gooeyDevProp('spotlight2') != null) FlxTween.tween(gooeyDevProp('spotlight2'), {alpha: 0.05}, 1.2, {ease: FlxEase.quartIn});
        }
    }
}

function onDestroy()
{
    if (ClientPrefs != null && ClientPrefs.data != null && gooeyDevStoredComboOffset != null)
        ClientPrefs.data.comboOffset = gooeyDevStoredComboOffset.copy();
}
