function radChar()
{
    if (game == null) return null;
    for (char in [game.dad, game.boyfriend, game.gf])
        if (char != null && char.curCharacter == 'rad') return char;
    return null;
}

function radEyeProp()
{
    return getVar('radEyeBop');
}

function radSyncEye()
{
    var char = radChar();
    var eye = radEyeProp();
    if (char == null || eye == null) return;

    eye.x = char.x;
    eye.y = char.y;
    eye.alpha = char.alpha;
    eye.visible = char.visible;
    eye.flipX = char.flipX;
    if (eye.animation != null && char.animation != null && char.animation.curAnim != null)
        eye.animation.play(char.animation.curAnim.name, true);
}

function onCreatePost()
{
    radSyncEye();
}

function onUpdatePost(elapsed:Float)
{
    radSyncEye();
}
