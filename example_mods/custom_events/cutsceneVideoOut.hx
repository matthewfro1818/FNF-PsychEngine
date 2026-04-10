function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'cutsceneVideoOut') return;

    var black = getVar('blackScreenVideo');
    if (black != null) FlxTween.tween(black, {alpha: 0}, 0.4);
    FlxTween.tween(game.camHUD, {alpha: 1}, 0.4);
}

