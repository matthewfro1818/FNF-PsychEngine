function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'fadeStart') return;

    var black = getVar('blackScreenR');
    if (black != null) FlxTween.tween(black, {alpha: 1}, 0.35);
    FlxTween.tween(game.camHUD, {alpha: 0}, 0.35);
}

