function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'SawbladeEvent') return;

    var red = getVar('redScreen');
    if (red != null)
    {
        red.alpha = 0.6;
        FlxTween.tween(red, {alpha: 0}, 0.6);
    }
    game.camGame.flash(0x55FF0000, 0.35);
}

