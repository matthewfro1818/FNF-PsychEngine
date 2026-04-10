function onEvent(name:String, value1:String, value2:String, strumTime:Float)
{
    if (name != 'changeStage') return;
    setVar('sourcePortQtStageChange', value1);
}


