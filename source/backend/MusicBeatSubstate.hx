package backend;

import flixel.FlxSubState;
#if HSCRIPT_ALLOWED
import psychlua.HScript;
#end

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return Controls.instance;

	#if HSCRIPT_ALLOWED
	public var stateScripts:Array<HScript> = [];

	function getStateScriptNames():Array<String>
	{
		var cls = Type.getClassName(Type.getClass(this));
		if (cls == null)
			return [];
		var split = cls.split('.');
		return [split[split.length - 1]];
	}

	function initStateScripts():Void
	{
		for (name in getStateScriptNames())
		{
			if (name == null || name.trim().length < 1)
				continue;
			for (key in ['substates/$name.hx', 'data/substates/$name.hx'])
			{
				var path = Paths.modFolders(key);
				if (!FileSystem.exists(path))
					path = Paths.getSharedPath(key);
				if (FileSystem.exists(path))
					stateScripts.push(new HScript(null, path));
			}
		}
	}

	function callOnStateScripts(funcToCall:String, args:Array<Dynamic> = null):Void
	{
		for (script in stateScripts)
		{
			@:privateAccess
			if (script != null && script.exists(funcToCall))
				script.call(funcToCall, args);
		}
	}
	#end

	override function create()
	{
		super.create();
		#if HSCRIPT_ALLOWED
		initStateScripts();
		callOnStateScripts('create', []);
		callOnStateScripts('onCreate', []);
		#end
	}

	override function update(elapsed:Float)
	{
		#if HSCRIPT_ALLOWED
		callOnStateScripts('update', [elapsed]);
		callOnStateScripts('onUpdate', [elapsed]);
		#end
		// everyStep();
		if (!persistentUpdate)
			MusicBeatState.timePassedOnState += elapsed;
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if (curStep > 0)
				stepHit();

			if (PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if (stepsToDo < 1)
			stepsToDo = Math.round(getBeatsOnSection() * 4);
		while (curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if (curStep < 0)
			return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if (stepsToDo > curStep)
					break;

				curSection++;
			}
		}

		if (curSection > lastSection)
			sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep / 4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		#if HSCRIPT_ALLOWED
		callOnStateScripts('beatHit', [curBeat]);
		callOnStateScripts('onBeatHit', [curBeat]);
		#end
	}

	public function sectionHit():Void
	{
		#if HSCRIPT_ALLOWED
		callOnStateScripts('sectionHit', [curSection]);
		callOnStateScripts('onSectionHit', [curSection]);
		#end
	}

	override function destroy()
	{
		#if HSCRIPT_ALLOWED
		if (stateScripts != null)
		{
			for (script in stateScripts)
				if (script != null)
					script.destroy();
			stateScripts.resize(0);
		}
		#end
		super.destroy();
	}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if (PlayState.SONG != null && PlayState.SONG.notes[curSection] != null)
			val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
