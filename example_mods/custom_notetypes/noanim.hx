function sourcePortApplyNoAnim(note:Note)
{
    if (note == null || note.noteType != 'noanim') return;
    note.noteType = 'No Animation';
    note.noAnimation = true;
    note.noMissAnimation = true;
}

function onCreatePost()
{
    for (note in game.unspawnNotes) sourcePortApplyNoAnim(note);
}

function onSpawnNote(note:Note)
{
    sourcePortApplyNoAnim(note);
}


