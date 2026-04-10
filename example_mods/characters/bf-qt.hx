var bfQtIdleAlt:Bool = false;
var bfQtLastDanceLeft:Bool = false;

function bfQtChar()
{
    if (game == null) return null;
    if (game.boyfriend != null && game.boyfriend.curCharacter == 'bf-qt') return game.boyfriend;
    if (game.dad != null && game.dad.curCharacter == 'bf-qt') return game.dad;
    return null;
}

function bfQtApplyIdle(force:Bool = false)
{
    var char = bfQtChar();
    if (char == null || char.animation == null || char.specialAnim) return;

    var curAnim = char.animation.curAnim;
    var curName = curAnim != null ? curAnim.name : '';
    if (!force && curName != 'danceLeft' && curName != 'danceRight') return;

    var target = curName;
    if (target != 'danceLeft' && target != 'danceRight')
    {
        bfQtLastDanceLeft = !bfQtLastDanceLeft;
        target = bfQtLastDanceLeft ? 'danceLeft' : 'danceRight';
    }

    if (bfQtIdleAlt)
        target += '-alt';

    if (char.hasAnimation != null && char.hasAnimation(target))
        char.playAnim(target, true);
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;

    var target = value2 != null ? value2.split('|')[0].toLowerCase().trim() : '';
    if (target != 'bf' && target != 'boyfriend' && target != '1') return;

    if (value1 == 'preDance')
        bfQtIdleAlt = true;
    else if (value1 == 'hey')
        bfQtIdleAlt = false;
}

function onBeatHit()
{
    bfQtApplyIdle();
}

function onUpdatePost(elapsed:Float)
{
    var char = bfQtChar();
    if (char == null || char.animation == null) return;

    var curAnim = char.animation.curAnim;
    if (curAnim == null) return;

    if (curAnim.name == 'preDance')
        bfQtIdleAlt = true;
    else if (curAnim.name == 'hey')
        bfQtIdleAlt = false;
    else if ((curAnim.name == 'danceLeft' || curAnim.name == 'danceRight') && bfQtIdleAlt)
        bfQtApplyIdle();
}
