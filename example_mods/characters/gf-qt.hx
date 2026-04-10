var gfQtIdleAlt:Bool = false;
var gfQtLastDanceLeft:Bool = false;

function gfQtChar()
{
    if (game == null) return null;
    if (game.gf != null && game.gf.curCharacter == 'gf-qt') return game.gf;
    if (game.dad != null && game.dad.curCharacter == 'gf-qt') return game.dad;
    if (game.boyfriend != null && game.boyfriend.curCharacter == 'gf-qt') return game.boyfriend;
    return null;
}

function gfQtApplyIdle(force:Bool = false)
{
    var char = gfQtChar();
    if (char == null || char.animation == null || char.specialAnim) return;

    var curAnim = char.animation.curAnim;
    var curName = curAnim != null ? curAnim.name : '';
    if (!force && curName != 'danceLeft' && curName != 'danceRight') return;

    var target = curName;
    if (target != 'danceLeft' && target != 'danceRight')
    {
        gfQtLastDanceLeft = !gfQtLastDanceLeft;
        target = gfQtLastDanceLeft ? 'danceLeft' : 'danceRight';
    }

    if (gfQtIdleAlt)
        target += '-alt';

    if (char.hasAnimation != null && char.hasAnimation(target))
        char.playAnim(target, true);
}

function onBeatHit()
{
    gfQtApplyIdle();
}

function onUpdatePost(elapsed:Float)
{
    var char = gfQtChar();
    if (char == null || char.animation == null) return;

    var curAnim = char.animation.curAnim;
    if (curAnim == null) return;

    if (curAnim.name == 'preDance')
        gfQtIdleAlt = true;
    else if (curAnim.name == 'cheer')
        gfQtIdleAlt = false;
    else if ((curAnim.name == 'danceLeft' || curAnim.name == 'danceRight') && gfQtIdleAlt)
        gfQtApplyIdle();
}
