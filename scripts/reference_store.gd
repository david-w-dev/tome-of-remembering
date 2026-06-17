extends Node

signal references_changed

const REFERENCES_SAVE_PATH := "user://references.json"

var references: Dictionary = {}


func _ready() -> void:
	load_references()


func load_references() -> void:
	if not FileAccess.file_exists(REFERENCES_SAVE_PATH):
		references = {}
		print("No references save file found yet.")
		return
	
	var file := FileAccess.open(REFERENCES_SAVE_PATH, FileAccess.READ)
	
	if file == null:
		references = {}
		print("Failed to open references save file for reading: ", REFERENCES_SAVE_PATH)
		return
	
	var json_string := file.get_as_text()
	file.close()
	
	print("Raw references JSON:")
	print(json_string)
	
	var parsed_data = JSON.parse_string(json_string)
	
	if parsed_data == null:
		references = {}
		print("Failed to parse references JSON.")
		return
	
	if typeof(parsed_data) != TYPE_DICTIONARY:
		references = {}
		print("References JSON root is not a dictionary.")
		return
	
	if parsed_data.has("references"):
		var loaded_references = parsed_data["references"]
		
		if typeof(loaded_references) == TYPE_DICTIONARY:
			references = loaded_references
			print("References loaded from wrapped JSON: ", references.size())
			return
		
		references = {}
		print("References field exists but is not a dictionary.")
		return
	
	references = parsed_data
	print("References loaded from raw dictionary JSON: ", references.size())

func save_references() -> void:
	if references.is_empty():
		print("WARNING: Saving empty references dictionary.")
	
	print(ProjectSettings.globalize_path(REFERENCES_SAVE_PATH))
	
	var save_data := {
		"schema_version": 1,
		"references": references
	}
	
	var json_string := JSON.stringify(save_data, "\t")
	
	var file := FileAccess.open(REFERENCES_SAVE_PATH, FileAccess.WRITE)
	
	if file == null:
		print("Failed to open references save file for writing: ", REFERENCES_SAVE_PATH)
		return
	
	file.store_string(json_string)
	file.close()
	
	print("References saved: ", references.size())

func get_all_references() -> Dictionary:
	return references


func get_reference(reference_title: String) -> Dictionary:
	if not references.has(reference_title):
		return {}
	
	return references[reference_title]


func add_note_to_references(note_data: Dictionary) -> void:
	add_note_to_references_without_saving(note_data)
	save_references()
	references_changed.emit()

func remove_note_id_from_all_references(note_id: String) -> void:
	var references_to_delete: Array[String] = []
	
	for reference_title in references.keys():
		var reference_data: Dictionary = references[reference_title]
		var note_ids: Array = reference_data.get("note_ids", [])
		
		if note_ids.has(note_id):
			note_ids.erase(note_id)
			reference_data["note_ids"] = note_ids
			references[reference_title] = reference_data
		
		if note_ids.is_empty():
			references_to_delete.append(reference_title)
	
	for reference_title in references_to_delete:
		references.erase(reference_title)
	
	save_references()
	references_changed.emit()


func get_valid_note_ids(reference_title: String) -> Array:
	if not references.has(reference_title):
		return []
	
	var reference_data: Dictionary = references[reference_title]
	var note_ids: Array = reference_data.get("note_ids", [])
	var valid_note_ids: Array = []
	
	if not has_node("/root/NotesStore"):
		return note_ids
	
	if NotesStore.get_all_notes().is_empty():
		return note_ids
	
	for note_id in note_ids:
		var note_id_string := str(note_id)
		
		if NotesStore.has_note(note_id_string):
			valid_note_ids.append(note_id_string)
	
	return valid_note_ids

func rebuild_references_from_notes() -> void:
	print("Rebuilding references from notes.")
	
	references = {}
	
	if not has_node("/root/NotesStore"):
		print("Cannot rebuild references. NotesStore not found.")
		return
	
	var all_notes: Array = NotesStore.get_all_notes()
	
	for note_data in all_notes:
		add_note_to_references_without_saving(note_data)
	
	save_references()
	references_changed.emit()
	
	print("References rebuilt: ", references.size())


func add_note_to_references_without_saving(note_data: Dictionary) -> void:
	var note_id: String = note_data.get("id", "")
	var created_at: String = note_data.get("created_at", "")
	var updated_at: String = note_data.get("updated_at", created_at)
	var note_references: Array = note_data.get("references", [])
	
	if note_id == "":
		print("Cannot add note to references. Note has no ID.")
		return
	
	for reference_name in note_references:
		var reference_key := str(reference_name).strip_edges().to_upper()
		
		if reference_key == "":
			continue
		
		var display_title := NotesStore.reference_key_to_display_name(reference_key)
		
		if not references.has(reference_key):
			references[reference_key] = {
				"key": reference_key,
				"title": display_title,
				"note_ids": [],
				"created_at": created_at,
				"updated_at": updated_at
			}
		
		var reference_data: Dictionary = references[reference_key]
		var note_ids: Array = reference_data.get("note_ids", [])
		
		if not note_ids.has(note_id):
			note_ids.append(note_id)
		
		reference_data["key"] = reference_key
		reference_data["title"] = display_title
		reference_data["note_ids"] = note_ids
		reference_data["updated_at"] = updated_at
		references[reference_key] = reference_data
