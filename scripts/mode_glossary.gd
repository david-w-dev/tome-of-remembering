extends Control

@onready var glossary_list: VBoxContainer = $VBoxContainer/GlossaryScroll/GlossaryList
@onready var empty_state_label: Label = $VBoxContainer/EmptyStateLabel

@onready var all_mentions_popup: PopupPanel = $AllMentionsPopup
@onready var popup_title_label: Label = $AllMentionsPopup/PopupPanelMargin/PopupVBox/HeaderRow/Label_PopupTitle
@onready var close_popup_button: Button = $AllMentionsPopup/PopupPanelMargin/PopupVBox/HeaderRow/Button_ClosePopup
@onready var popup_notes_list: VBoxContainer = $AllMentionsPopup/PopupPanelMargin/PopupVBox/PopupScroll/PopupNotesList

@export var glossary_entry_card_scene: PackedScene
@export var note_card_scene: PackedScene


func _ready() -> void:
	if has_node("/root/ReferenceStore"):
		ReferenceStore.references_changed.connect(refresh_glossary)
	
	close_popup_button.pressed.connect(_on_close_popup_pressed)
	
	refresh_glossary()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			refresh_glossary()


func refresh_glossary() -> void:
	clear_glossary_list()
	
	var references: Dictionary = ReferenceStore.get_all_references()
	var reference_titles := references.keys()
	reference_titles.sort()
	
	var has_references := reference_titles.size() > 0
	
	print("Refreshing glossary. References found: ", reference_titles.size())
	
	if not has_references:
		empty_state_label.text = "No references yet."
		empty_state_label.visible = true
		glossary_list.visible = false
		print("Glossary has no references.")
		return
	
	glossary_list.visible = true
	empty_state_label.visible = false
	
	for reference_title in reference_titles:
		var reference_data: Dictionary = references[reference_title]
		add_reference_to_list(reference_data)


func clear_glossary_list() -> void:
	for child in glossary_list.get_children():
		child.queue_free()


func add_reference_to_list(reference_data: Dictionary) -> void:
	var glossary_card := glossary_entry_card_scene.instantiate()
	glossary_list.add_child(glossary_card)
	
	glossary_card.note_card_scene = note_card_scene
	glossary_card.setup(reference_data)
	
	if glossary_card.has_signal("show_all_requested"):
		glossary_card.show_all_requested.connect(_on_glossary_card_show_all_requested)


func _on_glossary_card_show_all_requested(reference_name: String, note_ids: Array) -> void:
	show_all_mentions_popup(reference_name, note_ids)


func show_all_mentions_popup(reference_name: String, note_ids: Array) -> void:
	clear_popup_notes_list()
	
	popup_title_label.text = reference_name
	
	for note_id in note_ids:
		var note_data := NotesStore.get_note_by_id(str(note_id))
		
		if note_data.is_empty():
			continue
		
		add_note_to_popup(note_data)
	
	all_mentions_popup.popup_centered(Vector2i(600, 1400))

func add_note_to_popup(note_data: Dictionary) -> void:
	if note_card_scene == null:
		var fallback_label := Label.new()
		fallback_label.text = note_data.get("text", "")
		fallback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		popup_notes_list.add_child(fallback_label)
		return
	
	var note_card := note_card_scene.instantiate()
	popup_notes_list.add_child(note_card)
	
	if note_card.has_method("setup"):
		note_card.setup(note_data)


func clear_popup_notes_list() -> void:
	for child in popup_notes_list.get_children():
		child.queue_free()


func _on_close_popup_pressed() -> void:
	all_mentions_popup.hide()
