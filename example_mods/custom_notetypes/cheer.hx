function sourcePortApplyCheer(note:Note)
{
    if (note == null || note.noteType != 'cheer') return;
    note.noteType = 'Hey!';
}

function onCreatePost()
{
    for (note in game.unspawnNotes) sourcePortApplyCheer(note);
}

function onSpawnNote(note:Note)
{
    sourcePortApplyCheer(note);
}


