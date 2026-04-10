function gooeyChar()
{
    if (game == null) return null;
    if (game.dad != null && game.dad.curCharacter == 'gooey') return game.dad;
    if (game.boyfriend != null && game.boyfriend.curCharacter == 'gooey') return game.boyfriend;
    if (game.gf != null && game.gf.curCharacter == 'gooey') return game.gf;
    return null;
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;

    var char = gooeyChar();
    if (char == null) return;

    if (value1 == 'hey' || value1 == 'cheer')
        char.specialAnim = true;
}
