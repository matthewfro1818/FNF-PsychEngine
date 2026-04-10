function mallGooeyProp(name:String)
{
    return getVar(name);
}

function onCreatePost()
{
    if (mallGooeyProp('santa') != null)
        mallGooeyProp('santa').color = 0xFFFFE2E2;

    if (mallGooeyProp('bottomBoppers') != null)
    {
        mallGooeyProp('bottomBoppers').color = 0xFFFFF0DA;
        mallGooeyProp('bottomBoppers').alpha = 1;
    }
}
