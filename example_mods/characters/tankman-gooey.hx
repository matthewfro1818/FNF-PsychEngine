function tankmanGooeyChar()
{
    if (game == null) return null;
    for (char in [game.dad, game.boyfriend, game.gf])
        if (char != null && char.curCharacter == 'tankman-gooey') return char;
    return null;
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;

    var char = tankmanGooeyChar();
    if (char == null) return;

    if (value1 == 'hey' || value1 == 'cheer')
        char.specialAnim = true;
}
