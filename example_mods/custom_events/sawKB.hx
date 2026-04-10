function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'sawKB') return;

    var quantity = Std.int(Std.parseFloat(value1));
    if (Math.isNaN(quantity) || quantity < 1) quantity = 1;

    var red = getVar('redScreen');
    if (red != null)
    {
        red.alpha = 0.6;
        FlxTween.tween(red, {alpha: 0}, 0.5 + (quantity * 0.08));
    }

    game.camGame.flash(0x55FF0000, 0.35);
    if (game.boyfriend != null && game.boyfriend.hasAnimation != null && game.boyfriend.hasAnimation('dodge'))
    {
        game.boyfriend.playAnim('dodge', true);
        game.boyfriend.specialAnim = true;
    }
}

