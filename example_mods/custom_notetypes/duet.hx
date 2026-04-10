function sourcePortApplyDuet(note:Note)
{
    if (note == null || note.noteType != 'duet') return;
    note.noteType = '';
}

function onCreatePost()
{
    for (note in game.unspawnNotes) sourcePortApplyDuet(note);
}

function onSpawnNote(note:Note)
{
    sourcePortApplyDuet(note);
}


