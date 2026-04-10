var floraQtDanceMode:Bool = false;
var floraQtAltMode:Bool = false;
var floraQtTransMode:Bool = false;
var floraQtLastDanceLeft:Bool = false;
var floraQtTransformTimer:FlxTimer = null;

function floraQtChar()
{
    if (game == null) return null;
    if (game.gf != null && game.gf.curCharacter == 'flora-qt') return game.gf;
    if (game.dad != null && game.dad.curCharacter == 'flora-qt') return game.dad;
    if (game.boyfriend != null && game.boyfriend.curCharacter == 'flora-qt') return game.boyfriend;
    return null;
}

function floraQtApplyDanceVariant(force:Bool = false)
{
    var char = floraQtChar();
    if (char == null || char.animation == null || char.specialAnim) return;

    var curAnim = char.animation.curAnim;
    var curName = curAnim != null ? curAnim.name : '';
    if (!force && curName != 'danceLeft' && curName != 'danceRight') return;

    var target = curName;
    if (target != 'danceLeft' && target != 'danceRight')
    {
        floraQtLastDanceLeft = !floraQtLastDanceLeft;
        target = floraQtLastDanceLeft ? 'danceLeft' : 'danceRight';
    }

    if (floraQtDanceMode)
        target += '-qt';
    else if (floraQtTransMode)
        target += '-trans';
    else if (floraQtAltMode)
        target += '-alt';

    if (char.hasAnimation != null && char.hasAnimation(target))
        char.playAnim(target, true);
}

function floraQtClearTransformTimer()
{
    if (floraQtTransformTimer != null)
    {
        floraQtTransformTimer.cancel();
        floraQtTransformTimer = null;
    }
}

function onCreatePost()
{
    setVar('sourcePortFloraQtDanceMode', false);
}

function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'PlayAnimation') return;

    var target = value2 != null ? value2.split('|')[0].toLowerCase().trim() : '';
    if (target != 'gf' && target != 'girlfriend' && target != '2') return;

    switch (value1)
    {
        case 'FloraQtIntro':
            floraQtDanceMode = true;
            setVar('sourcePortFloraQtDanceMode', true);
        case 'combo200':
            floraQtDanceMode = false;
            floraQtTransMode = true;
            floraQtAltMode = false;
            floraQtClearTransformTimer();
            floraQtTransformTimer = new FlxTimer().start(0.05, function(tmr)
            {
                floraQtTransMode = false;
                floraQtAltMode = true;
            });
        case 'drop70':
            floraQtDanceMode = false;
            floraQtAltMode = false;
            floraQtTransMode = false;
            floraQtClearTransformTimer();
    }
}

function onBeatHit()
{
    floraQtApplyDanceVariant();
}

function onStepHit()
{
    if (songPath == 'blissful-gooey' && curStep == 1408)
    {
        floraQtDanceMode = false;
        setVar('sourcePortFloraQtDanceMode', false);
    }
}

function onUpdatePost(elapsed:Float)
{
    var char = floraQtChar();
    if (char == null || char.animation == null) return;

    var curAnim = char.animation.curAnim;
    if (curAnim == null) return;

    if ((curAnim.name == 'danceLeft' || curAnim.name == 'danceRight') && (floraQtDanceMode || floraQtAltMode || floraQtTransMode))
        floraQtApplyDanceVariant();
}

function onDestroy()
{
    floraQtClearTransformTimer();
}
