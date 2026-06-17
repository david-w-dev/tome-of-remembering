extends Control

@onready var glossary_list: VBoxContainer = $VBoxContainer/GlossaryScroll/GlossaryList
@onready var empty_state_label: Label = $VBoxContainer/EmptyStateLabel

@export var glossary_entry_card_scene: PackedScene

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
	var glossary_card := glossary_entry_card_scene.instantiate()
	glossary_list.add_child(glossary_card)
	glossary_card.setup(reference_name)
