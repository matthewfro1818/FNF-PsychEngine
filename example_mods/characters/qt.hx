var qtIdleAlt:Bool = false;
var qtLastDanceLeft:Bool = false;

function qtMainChar()
{
    if (game == null) return null;
    if (game.dad != null && game.dad.curCharacter == 'qt') return game.dad;
    if (game.boyfriend != null && game.boyfriend.curCharacter == 'qt') return game.boyfriend;
    if (game.gf != null && game.gf.curCharacter == 'qt') return game.gf;
    return null;
}

function qtApplyIdle(force:Bool = false)
{
    var char = qtMainChar();
    if (char == null || char.animation == null || char.specialAnim) return;

    var curAnim = char.animation.curAnim;
    var curName = curAnim != null ? curAnim.name : '';
    if (!force && curName != 'danceLeft' && curName != 'danceRight') return;

    var target = curName;
    if (target != 'danceLeft' && target != 'danceRight')
    {
        qtLastDanceLeft = !qtLastDanceLeft;
        target = qtLastDanceLeft ? 'danceLeft' : 'danceRight';
    }

    if (qtIdleAlt)
        target += '-alt';

    if (char.hasAnimation != null && char.hasAnimation(target))
        char.playAnim(target, true);
}

function onBeatHit()
{
    qtApplyIdle();
}

function onUpdatePost(elapsed:Float)
{
    var char = qtMainChar();
    if (char == null || char.animation == null) return;

    var curAnim = char.animation.curAnim;
    if (curAnim == null) return;

    if (curAnim.name == 'preDance')
        qtIdleAlt = true;
    else if (curAnim.name == 'cheer')
        qtIdleAlt = false;
    else if ((curAnim.name == 'danceLeft' || curAnim.name == 'danceRight') && qtIdleAlt)
        qtApplyIdle();
}
