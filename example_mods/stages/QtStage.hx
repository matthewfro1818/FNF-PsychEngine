var qtCurrentStageMode:String = 'Normal';
var qtRedPulseOn:Bool = false;

function qtProp(name:String)
{
    return getVar(name);
}

function qtSetVisible(name:String, visible:Bool)
{
    var obj = qtProp(name);
    if (obj != null) obj.visible = visible;
}

function qtSetAlpha(name:String, alpha:Float)
{
    var obj = qtProp(name);
    if (obj != null) obj.alpha = alpha;
}

function qtPlayStageAnim(name:String, anim:String)
{
    var obj = qtProp(name);
    if (obj != null && obj.animation != null) obj.animation.play(anim, true);
}

function qtResetBlackScreens()
{
    for (name in ['blackScreen', 'blackScreenVideo', 'spotLight', 'redScreen', 'blackScreenR'])
        qtSetAlpha(name, 0);
}

function qtApplyStageMode(mode:String)
{
    if (mode == null || mode.trim().length < 1) mode = 'Normal';
    qtCurrentStageMode = mode;

    qtPlayStageAnim('lightOverlay', mode);
    qtPlayStageAnim('tvLights', mode);

    qtSetVisible('tvStaticLeft', mode == 'Killer');
    qtSetVisible('tvStaticRight', mode == 'Killer');
    qtSetVisible('blueScreen', mode == 'Blue');
    qtSetVisible('warningScreen', mode == 'Red');
    qtSetVisible('tvLights', mode != 'Normal');

    switch (mode)
    {
        case 'Killer':
            if (qtProp('tvShine') != null) qtProp('tvShine').color = 0xFFB09AB1;
            if (qtProp('TVFrontShine') != null) qtProp('TVFrontShine').color = 0xFFB09AB1;
            qtSetAlpha('tvShine', 1);
            qtSetAlpha('TVFrontShine', 1);
            qtSetAlpha('fgWireBack', 1);
            qtSetAlpha('fgWireFront', 1);
            qtSetAlpha('tvLights', 1);
        case 'Blue':
            if (qtProp('tvShine') != null) qtProp('tvShine').color = 0xFF4B96C2;
            if (qtProp('TVFrontShine') != null) qtProp('TVFrontShine').color = 0xFF4B96C2;
            qtSetAlpha('tvShine', 1);
            qtSetAlpha('TVFrontShine', 1);
            qtSetAlpha('fgWireBack', 1);
            qtSetAlpha('fgWireFront', 1);
            qtSetAlpha('tvLights', 1);
        case 'Red':
            if (qtProp('tvShine') != null) qtProp('tvShine').color = 0xFFCE2029;
            if (qtProp('TVFrontShine') != null) qtProp('TVFrontShine').color = 0xFFCE2029;
            qtSetAlpha('tvShine', 1);
            qtSetAlpha('TVFrontShine', 1);
            qtSetAlpha('fgWireBack', 1);
            qtSetAlpha('fgWireFront', 1);
            qtSetAlpha('warningScreen', 1);
            qtSetAlpha('tvLights', 1);
        default:
            if (qtProp('wall') != null) qtProp('wall').loadGraphic(Paths.image('blissful/bg'));
            if (qtProp('TVFrontShine') != null) qtProp('TVFrontShine').color = 0xFFC986BD;
            qtPlayStageAnim('lightOverlay', 'Normal');
            qtPlayStageAnim('tvLights', 'Normal');
            qtSetAlpha('tvShine', 0);
            qtSetAlpha('fgWireBack', 0);
            qtSetAlpha('fgWireFront', 0);
            qtSetAlpha('tvLights', 0);
    }
}

function onCreatePost()
{
    qtResetBlackScreens();

    var initial = 'Normal';
    if (songName != null && songName.toLowerCase().indexOf('obliterated') == 0)
        initial = 'Killer';

    qtApplyStageMode(initial);
    setVar('sourcePortQtStageChange', '');
}

function onUpdatePost(elapsed:Float)
{
    var lights = qtProp('tvLights');
    if (lights != null)
    {
        if (qtProp('tvShine') != null) qtProp('tvShine').alpha = lights.alpha;
        if (qtProp('TVFrontShine') != null) qtProp('TVFrontShine').alpha = lights.alpha;
    }

    var requested = getVar('sourcePortQtStageChange');
    if (requested != null)
    {
        var nextMode = Std.string(requested);
        if (nextMode.length > 0 && nextMode != qtCurrentStageMode)
            qtApplyStageMode(nextMode);
        setVar('sourcePortQtStageChange', '');
    }
}

function onBeatHit()
{
    if (qtCurrentStageMode != 'Red' || curBeat % 2 != 0) return;

    qtRedPulseOn = !qtRedPulseOn;
    qtSetAlpha('warningScreen', qtRedPulseOn ? 1 : 0.15);
    qtSetAlpha('tvLights', qtRedPulseOn ? 1 : 0.3);
}


