function sourcePortApplyAltAnim(note:Note)
{
    if (note == null || note.noteType != 'altAnim') return;
    note.noteType = 'Alt Animation';
    note.animSuffix = '-alt';
}

function onCreatePost()
{
    for (note in game.unspawnNotes) sourcePortApplyAltAnim(note);
}

function onSpawnNote(note:Note)
{
    sourcePortApplyAltAnim(note);
}


