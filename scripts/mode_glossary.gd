extends Control

@onready var glossary_list: VBoxContainer = $VBoxContainer/GlossaryScroll/GlossaryList
@onready var empty_state_label: Label = $VBoxContainer/EmptyStateLabel


func _ready() -> void:
	refresh_glossary()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			refresh_glossary()


func refresh_glossary() -> void:
	clear_glossary_list()
	
	var references := NotesStore.get_all_references()
	var has_references := references.size() > 0
	
	glossary_list.visible = has_references
	empty_state_label.visible = not has_references
	
	if not has_references:
		return
	
	for reference_name in references:
		add_reference_to_list(reference_name)


func clear_glossary_list() -> void:
	for child in glossary_list.get_children():
		child.queue_free()


func add_reference_to_list(reference_name: String) -> void:
	var label := Label.new()
	label.text = reference_name
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	glossary_list.add_child(label)
