extends Node

const NOTES_SAVE_PATH := "user://notes.json"

var notes: Array = []


func load_notes() -> void:
	if not FileAccess.file_exists(NOTES_SAVE_PATH):
		notes = []
		print("No notes save file found yet.")
		return
	
	var file := FileAccess.open(NOTES_SAVE_PATH, FileAccess.READ)
	
	if file == null:
		notes = []
		print("Failed to open notes save file for reading: ", NOTES_SAVE_PATH)
		return
	
	var json_string := file.get_as_text()
	file.close()
	
	var parsed_data = JSON.parse_string(json_string)
	
	if parsed_data == null:
		notes = []
		print("Failed to parse notes JSON.")
		return
	
	if not parsed_data.has("notes"):
		notes = []
		print("Notes JSON does not contain a notes array.")
		return
	
	notes = parsed_data["notes"]
	repair_loaded_notes()
	
	print("Notes loaded: ", notes.size())

func get_all_references() -> Array[String]:
	var all_references: Array[String] = []
	var seen_reference_keys: Array[String] = []
	
	for note_data in notes:
		var note_references: Array = note_data.get("references", [])
		
		for reference_name in note_references:
			var display_name := str(reference_name).strip_edges()
			
			if display_name == "":
				continue
			
			var reference_key := display_name.to_lower()
			
			if seen_reference_keys.has(reference_key):
				continue
			
			seen_reference_keys.append(reference_key)
			all_references.append(display_name)
	
	all_references.sort()
	return all_references

func save_notes() -> void:
	print(ProjectSettings.globalize_path(NOTES_SAVE_PATH))
	var save_data := {
		"schema_version": 1,
		"notes": notes
	}
	
	var json_string := JSON.stringify(save_data, "\t")
	
	var file := FileAccess.open(NOTES_SAVE_PATH, FileAccess.WRITE)
	
	if file == null:
		print("Failed to open notes save file for writing: ", NOTES_SAVE_PATH)
		return
	
	file.store_string(json_string)
	file.close()
	
	print("Notes saved: ", notes.size())


func get_all_notes() -> Array:
	return notes


func create_note(note_text: String) -> Dictionary:
	var timestamp := get_timestamp()
	
	var note_data := {
		"id": create_note_id(),
		"campaign_id": "default",
		"text": note_text,
		"created_at": timestamp,
		"updated_at": timestamp,
		"references": extract_references(note_text),
		"links": [],
		"tags": []
	}
	
	notes.append(note_data)
	save_notes()
	
	return note_data


func delete_note(note_id: String) -> bool:
	var note_index := get_note_index_by_id(note_id)
	
	if note_index == -1:
		print("Could not find note to delete: ", note_id)
		return false
	
	notes.remove_at(note_index)
	save_notes()
	
	print("Deleted note: ", note_id)
	return true


func get_note_index_by_id(note_id: String) -> int:
	for i in range(notes.size()):
		var note_data: Dictionary = notes[i]
		
		if note_data.get("id", "") == note_id:
			return i
	
	return -1


func extract_references(note_text: String) -> Array[String]:
	var references: Array[String] = []
	var regex := RegEx.new()
	var error := regex.compile("\\[([^\\]]+)\\]")
	
	if error != OK:
		print("Reference regex failed to compile.")
		return references
	
	for result in regex.search_all(note_text):
		var reference_name := result.get_string(1).strip_edges()
		
		if reference_name == "":
			continue
		
		if not references.has(reference_name):
			references.append(reference_name)
	
	return references


func repair_loaded_notes() -> void:
	var changed := false
	
	for i in range(notes.size()):
		var note_data: Dictionary = notes[i]
		var note_text: String = note_data.get("text", "")
		
		if not note_data.has("references"):
			note_data["references"] = extract_references(note_text)
			changed = true
		
		notes[i] = note_data
	
	if changed:
		save_notes()


func get_timestamp() -> String:
	var datetime := Time.get_datetime_dict_from_system()
	
	var year: int = datetime["year"]
	var month: int = datetime["month"]
	var day: int = datetime["day"]
	var hour: int = datetime["hour"]
	var minute: int = datetime["minute"]
	var second: int = datetime["second"]
	
	return "%04d-%02d-%02d %02d:%02d:%02d" % [year, month, day, hour, minute, second]


func create_note_id() -> String:
	var datetime := Time.get_datetime_dict_from_system()
	
	var year: int = datetime["year"]
	var month: int = datetime["month"]
	var day: int = datetime["day"]
	var hour: int = datetime["hour"]
	var minute: int = datetime["minute"]
	var second: int = datetime["second"]
	var unix_time: int = Time.get_unix_time_from_system()
	
	return "note_%04d%02d%02d_%02d%02d%02d_%d" % [
		year,
		month,
		day,
		hour,
		minute,
		second,
		unix_time
	]
