function bfGooeyChar()
{
    if (game == null) return null;
    if (game.boyfriend != null && game.boyfriend.curCharacter == 'bf-gooey') return game.boyfriend;
    if (game.dad != null && game.dad.curCharacter == 'bf-gooey') return game.dad;
    return null;
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;

    var target = value2 != null ? value2.split('|')[0].toLowerCase().trim() : '';
    if (target != 'bf' && target != 'boyfriend' && target != '1') return;

    var char = bfGooeyChar();
    if (char == null) return;

    if (value1 == 'hey' || value1 == 'cheer')
        char.specialAnim = true;
}
