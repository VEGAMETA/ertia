class_name CommandSave extends Command


var help_message : String = \
"""Saver and Loader
save - save (quicksave)
save savetype - save with type
load - load last save
load savefile - load specific savefile
quickload - load last quicksave
savefiles - show savefiles

savetype: 
	0 - ALL,
	1 - QUICKSAVE,
	2 - AUTOSAVE,
	3 - MANUAL,
	4 - UNKNOWN
"""


static func get_registered() -> Array[String]:
	return ["save", "load", "quickload", "savefiles"]


func execute() -> Error:
	match command.size():
		1: match command[0]:
			"save":
				if not Globals.get_tree().has_group("Player"): 
					return Console.printerr("Cannot save", ERR_CANT_CREATE)
				Saver.quicksave()
			"load": Saver.load_last_save()
			"quickload": Saver.quickload()
			"savefiles": Console.print("%s" % "\n".join(
				Saver.get_saves().map(func (x): return x.keys())
			))
		2: match command[0]:
			"save":
				if not Globals.get_tree().has_group("Player"): 
					return Console.printerr("Cannot save", ERR_CANT_CREATE)
				Saver.save(Saver.fetch_metadata(int(command[1])))
			"load": Saver.load_save(Saver.save_directory + \
				command[1].replace("\\", "").replace("/", ""))
			"savefiles": Console.print("%s" % "\n".join(Saver.get_saves()))
	return OK
