function sourcePortIconTarget(value:String)
{
    if (value == null) return 'dad';

    switch (value.toLowerCase().trim())
    {
        case 'bf', 'boyfriend', 'player', 'p1', '1':
            return 'bf';
        case 'gf', 'girlfriend', 'p3', '3':
            return 'gf';
        default:
            return 'dad';
    }
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'SetHealthIcon' || value1 == null || value1.trim().length < 1) return;

    switch (sourcePortIconTarget(value2))
    {
        case 'bf':
            if (game.iconP1 != null) game.iconP1.changeIcon(value1);
        case 'gf':
            if (game.iconP2 != null) game.iconP2.changeIcon(value1);
        default:
            if (game.iconP2 != null) game.iconP2.changeIcon(value1);
    }
}


