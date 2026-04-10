var picoQtAltIdle:Bool = false;
var picoQtLastDanceLeft:Bool = false;

function picoQtChar()
{
    if (game == null) return null;
    if (game.boyfriend != null && game.boyfriend.curCharacter == 'pico-qt') return game.boyfriend;
    if (game.dad != null && game.dad.curCharacter == 'pico-qt') return game.dad;
    return null;
}

function picoQtApplyIdle(force:Bool = false)
{
    var char = picoQtChar();
    if (char == null || char.animation == null || char.specialAnim) return;

    var curAnim = char.animation.curAnim;
    var curName = curAnim != null ? curAnim.name : '';
    if (!force && curName != 'danceLeft' && curName != 'danceRight') return;

    var target = curName;
    if (target != 'danceLeft' && target != 'danceRight')
    {
        picoQtLastDanceLeft = !picoQtLastDanceLeft;
        target = picoQtLastDanceLeft ? 'danceLeft' : 'danceRight';
    }

    if (picoQtAltIdle)
        target += '-alt';

    if (char.hasAnimation != null && char.hasAnimation(target))
        char.playAnim(target, true);
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;

    var target = value2 != null ? value2.split('|')[0].toLowerCase().trim() : '';
    if (target != 'bf' && target != 'boyfriend' && target != '1') return;

    switch (value1)
    {
        case 'preDance':
            picoQtAltIdle = true;
        case 'hey':
            picoQtAltIdle = false;
    }
}

function onBeatHit()
{
    picoQtApplyIdle();
}

function onUpdatePost(elapsed:Float)
{
    var char = picoQtChar();
    if (char == null || char.animation == null) return;

    var curAnim = char.animation.curAnim;
    if (curAnim == null) return;

    if (curAnim.name == 'preDance')
        picoQtAltIdle = true;
    else if (curAnim.name == 'hey')
        picoQtAltIdle = false;
    else if ((curAnim.name == 'danceLeft' || curAnim.name == 'danceRight') && picoQtAltIdle)
        picoQtApplyIdle();
}
