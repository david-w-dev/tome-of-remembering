extends PanelContainer

signal show_all_requested(reference_name: String, note_ids: Array)

@onready var reference_name_label: Label = $MarginContainer/VBoxContainer/HeaderRow/Label_ReferenceName
@onready var arrow_label: Label = $MarginContainer/VBoxContainer/HeaderRow/Label_Arrow
@onready var expanded_content: VBoxContainer = $MarginContainer/VBoxContainer/ExpandedContent

@onready var mention_count_label: Label = $MarginContainer/VBoxContainer/ExpandedContent/Label_MentionCount
@onready var first_title_label: Label = $MarginContainer/VBoxContainer/ExpandedContent/Label_FirstTitle
@onready var first_note_container: VBoxContainer = $MarginContainer/VBoxContainer/ExpandedContent/FirstNoteContainer
@onready var latest_title_label: Label = $MarginContainer/VBoxContainer/ExpandedContent/Label_LatestTitle
@onready var latest_note_container: VBoxContainer = $MarginContainer/VBoxContainer/ExpandedContent/LatestNoteContainer
@onready var show_all_button: Button = $MarginContainer/VBoxContainer/ExpandedContent/Button_ShowAll

@export var note_card_scene: PackedScene

var reference_data: Dictionary = {}
var reference_name := ""
var reference_key := ""
var current_note_ids: Array = []
var is_expanded := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	expanded_content.visible = false
	
	show_all_button.pressed.connect(_on_show_all_pressed)
	show_all_button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	_update_arrow()


func setup(new_reference_data: Dictionary) -> void:
	reference_data = new_reference_data
	
	reference_key = str(reference_data.get("key", "")).strip_edges()
	reference_name = str(reference_data.get("title", "")).strip_edges()
	
	if reference_key == "":
		reference_key = reference_name.to_upper()
	
	if reference_name == "":
		reference_name = NotesStore.reference_key_to_display_name(reference_key)
	
	reference_name_label.text = reference_name
	
	_refresh_expanded_content()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			toggle_expanded()
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			toggle_expanded()


func toggle_expanded() -> void:
	is_expanded = not is_expanded
	expanded_content.visible = is_expanded
	_update_arrow()


func _update_arrow() -> void:
	if is_expanded:
		arrow_label.text = "v"
	else:
		arrow_label.text = ">"


func _refresh_expanded_content() -> void:
	clear_container(first_note_container)
	clear_container(latest_note_container)
	
	current_note_ids = []
	
	if reference_key == "":
		mention_count_label.text = "0 mentions"
		show_all_button.visible = false
		return
	
	current_note_ids = ReferenceStore.get_valid_note_ids(reference_key)
	var mention_count := current_note_ids.size()
	
	mention_count_label.text = get_mention_count_text(mention_count)
	show_all_button.visible = mention_count > 1
	
	if mention_count == 0:
		first_title_label.visible = false
		first_note_container.visible = false
		latest_title_label.visible = false
		latest_note_container.visible = false
		return
	
	if mention_count == 1:
		first_title_label.text = "Mentioned in"
		first_title_label.visible = true
		first_note_container.visible = true
		
		latest_title_label.visible = false
		latest_note_container.visible = false
		
		var only_note := NotesStore.get_note_by_id(str(current_note_ids[0]))
		add_note_to_container(first_note_container, only_note)
		return
	
	first_title_label.text = "First mention"
	latest_title_label.text = "Latest mention"
	
	first_title_label.visible = true
	first_note_container.visible = true
	latest_title_label.visible = true
	latest_note_container.visible = true
	
	var first_note_id := str(current_note_ids.front())
	var latest_note_id := str(current_note_ids.back())
	
	var first_note := NotesStore.get_note_by_id(first_note_id)
	var latest_note := NotesStore.get_note_by_id(latest_note_id)
	
	add_note_to_container(first_note_container, first_note)
	add_note_to_container(latest_note_container, latest_note)


func add_note_to_container(target_container: VBoxContainer, note_data: Dictionary) -> void:
	if note_data.is_empty():
		return
	
	if note_card_scene == null:
		var fallback_label := Label.new()
		fallback_label.text = note_data.get("text", "")
		fallback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		target_container.add_child(fallback_label)
		return
	
	var note_card := note_card_scene.instantiate()
	target_container.add_child(note_card)
	
	if note_card.has_method("setup"):
		note_card.setup(note_data)


func clear_container(target_container: VBoxContainer) -> void:
	for child in target_container.get_children():
		child.queue_free()


func get_mention_count_text(mention_count: int) -> String:
	if mention_count == 1:
		return "1 mention"
	
	return "%d mentions" % mention_count


func _on_show_all_pressed() -> void:
	show_all_requested.emit(reference_name, current_note_ids)
