var hotelCastleCrowdNames:Array<String> = ['morphoBop', 'blueBop', 'noodleBop', 'cerealBop', 'radBop', 'radEyeBop'];

function hotelCastleProp(name:String)
{
    return getVar(name);
}

function hotelCastleSetAlpha(name:String, alpha:Float)
{
    var obj = hotelCastleProp(name);
    if (obj != null) obj.alpha = alpha;
}

function hotelCastleSetBlend(name:String, blendMode:Dynamic)
{
    var obj = hotelCastleProp(name);
    if (obj != null) obj.blend = blendMode;
}

function hotelCastleSetDanceEvery(name:String, value:Int)
{
    var obj = hotelCastleProp(name);
    if (obj != null) obj.danceEvery = value;
}

function hotelCastleHideCrowdForChar(charId:String)
{
    if (charId == null) return;

    switch (charId)
    {
        case 'morpho', 'morpho-player':
            hotelCastleSetAlpha('morphoBop', 0);
        case 'rad':
            hotelCastleSetAlpha('radBop', 0);
            hotelCastleSetAlpha('radEyeBop', 0);
        case 'blue', 'blue-player':
            hotelCastleSetAlpha('blueBop', 0);
        case 'noodle', 'noodle-player':
            hotelCastleSetAlpha('noodleBop', 0);
        case 'cereal', 'cereal-player':
            hotelCastleSetAlpha('cerealBop', 0);
    }
}

function hotelCastleResetCrowdTiming(slow:Bool)
{
    if (slow)
    {
        for (name in hotelCastleCrowdNames)
            hotelCastleSetDanceEvery(name, 20);
        return;
    }

    hotelCastleSetDanceEvery('morphoBop', 2);
    hotelCastleSetDanceEvery('blueBop', 2);
    hotelCastleSetDanceEvery('noodleBop', 2);
    hotelCastleSetDanceEvery('cerealBop', 2);
    hotelCastleSetDanceEvery('radBop', 4);
    hotelCastleSetDanceEvery('radEyeBop', 4);
}

function hotelCastleSetFastCrowdTiming()
{
    hotelCastleSetDanceEvery('morphoBop', 1);
    hotelCastleSetDanceEvery('blueBop', 1);
    hotelCastleSetDanceEvery('noodleBop', 1);
    hotelCastleSetDanceEvery('cerealBop', 1);
    hotelCastleSetDanceEvery('radBop', 2);
    hotelCastleSetDanceEvery('radEyeBop', 2);
}

function onCreatePost()
{
    hotelCastleSetBlend('lighting', 0);
    hotelCastleSetBlend('lighting2', 9);
    hotelCastleSetBlend('stageLighting', 9);
    hotelCastleSetBlend('spotlight1', 9);
    hotelCastleSetBlend('spotlight2', 0);
    hotelCastleSetBlend('spotlight3', 0);
    hotelCastleSetBlend('extraSpotlight', 9);
    hotelCastleSetBlend('extraSpotlight2', 9);
    hotelCastleSetBlend('topLantern1Light', 0);
    hotelCastleSetBlend('topLantern2Light', 0);
    hotelCastleSetBlend('candleFrontLight', 0);
    hotelCastleSetBlend('candleBackLight', 0);
    hotelCastleSetBlend('bottomLantern1Light', 0);
    hotelCastleSetBlend('bottomLantern2Light', 0);
    hotelCastleSetBlend('radEyeBop', 0);

    hotelCastleSetAlpha('spotlight1', 1);
    hotelCastleSetAlpha('spotlight2', 0.05);
    hotelCastleSetAlpha('spotlight3', 0.5);
    hotelCastleSetAlpha('extraSpotlight', 0.0001);
    hotelCastleSetAlpha('extraSpotlight2', 0.0001);

    if (songPath == 'starcraft')
        hotelCastleResetCrowdTiming(false);
}

function onStartCountdown()
{
    if (game.dad != null) hotelCastleHideCrowdForChar(game.dad.curCharacter);
    if (game.gf != null) hotelCastleHideCrowdForChar(game.gf.curCharacter);
    if (game.boyfriend != null) hotelCastleHideCrowdForChar(game.boyfriend.curCharacter);

    return Function_Continue;
}

function onSongStart()
{
    if (songPath == 'starcraft')
        hotelCastleResetCrowdTiming(false);
}

function onStepHit()
{
    if (songPath != 'starcraft') return;

    if (curStep == 885)
    {
        if (hotelCastleProp('extraSpotlight') != null) FlxTween.tween(hotelCastleProp('extraSpotlight'), {alpha: 0.5}, 2.8, {ease: FlxEase.quartIn});
        if (hotelCastleProp('extraSpotlight2') != null) FlxTween.tween(hotelCastleProp('extraSpotlight2'), {alpha: 0.5}, 2.8, {ease: FlxEase.quartIn});
        if (hotelCastleProp('spotlight2') != null) FlxTween.tween(hotelCastleProp('spotlight2'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
    }

    if (curStep == 911 || curStep == 16 || curStep == 1310 || curStep == 530)
        hotelCastleResetCrowdTiming(false);

    if (curStep == 1038 || curStep == 1 || curStep == 275 || curStep == 786 || curStep == 1343 || curStep == 658 || curStep == 1182)
        hotelCastleSetFastCrowdTiming();

    if (curStep == 1169 || curStep == 755 || curStep == 885)
        hotelCastleResetCrowdTiming(true);

    if (curStep == 1182)
    {
        if (hotelCastleProp('extraSpotlight') != null) FlxTween.tween(hotelCastleProp('extraSpotlight'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
        if (hotelCastleProp('extraSpotlight2') != null) FlxTween.tween(hotelCastleProp('extraSpotlight2'), {alpha: 0}, 1.2, {ease: FlxEase.quartIn});
        if (hotelCastleProp('spotlight2') != null) FlxTween.tween(hotelCastleProp('spotlight2'), {alpha: 0.05}, 1.2, {ease: FlxEase.quartIn});
    }
}
