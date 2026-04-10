function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'SetTargetBopSpeed') return;
    setVar('sourcePortTargetBopSpeed', value1);
}


