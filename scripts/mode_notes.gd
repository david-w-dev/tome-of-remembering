extends Control

@export var note_card_scene: PackedScene

@onready var note_input: TextEdit = $VBoxContainer/NoteInput
@onready var save_button: Button = $VBoxContainer/SaveButton
@onready var notes_scroll: ScrollContainer = $VBoxContainer/NotesScroll
@onready var notes_list: VBoxContainer = $VBoxContainer/NotesScroll/NotesScrollContent/NotesList
@onready var empty_state_label: Label = $VBoxContainer/NotesScroll/NotesScrollContent/EmptyStateLabel
@onready var keyboard_spacer: Control = $VBoxContainer/KeyboardSpacer
@onready var notes_context_menu: PopupMenu = $NotesContextMenu

var selected_note_id := ""


func _ready() -> void:
	save_button.pressed.connect(_on_save_button_pressed)
	keyboard_spacer.custom_minimum_size.y = 0
	
	notes_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	notes_list.mouse_filter = Control.MOUSE_FILTER_PASS
	
	notes_context_menu.clear()
	notes_context_menu.add_item("Delete", 0)
	notes_context_menu.id_pressed.connect(_on_notes_context_menu_id_pressed)
	
	NotesStore.load_notes()
	rebuild_notes_list()


func _process(_delta: float) -> void:
	update_keyboard_spacer()


func update_keyboard_spacer() -> void:
	var keyboard_height: int = DisplayServer.virtual_keyboard_get_height()
	
	if keyboard_height > 0:
		keyboard_spacer.custom_minimum_size.y = (keyboard_height * 0.5) + 200
	else:
		keyboard_spacer.custom_minimum_size.y = 0

func update_empty_state() -> void:
	var has_notes := NotesStore.get_all_notes().size() > 0
	
	notes_list.visible = has_notes
	empty_state_label.visible = not has_notes

func scroll_to_bottom_deferred() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	
	var vertical_scroll_bar := notes_scroll.get_v_scroll_bar()
	notes_scroll.scroll_vertical = int(vertical_scroll_bar.max_value)

func _on_save_button_pressed() -> void:
	var note_text: String = note_input.text.strip_edges()
	
	if note_text == "":
		return
	
	var note_data: Dictionary = NotesStore.create_note(note_text)
	
	add_note_to_list(note_data)
	update_empty_state()
	scroll_to_bottom_deferred()
	
	note_input.clear()

func add_note_to_list(note_data: Dictionary) -> void:
	var note_card := note_card_scene.instantiate()
	
	notes_list.add_child(note_card)
	
	note_card.setup(note_data)
	note_card.note_pressed.connect(_on_note_pressed)
	note_card.note_long_pressed.connect(_on_note_long_pressed)


func clear_notes_list() -> void:
	for child in notes_list.get_children():
		child.queue_free()


func rebuild_notes_list() -> void:
	clear_notes_list()
	
	for note_data in NotesStore.get_all_notes():
		add_note_to_list(note_data)
	
	update_empty_state()
	scroll_to_bottom_deferred()

func _on_note_pressed(note_id: String) -> void:
	print("Note pressed: ", note_id)


func _on_note_long_pressed(note_id: String) -> void:
	selected_note_id = note_id
	
	var mouse_position := get_viewport().get_mouse_position()
	notes_context_menu.position = mouse_position
	notes_context_menu.popup()
	
	print("Note long pressed: ", note_id)


func _on_notes_context_menu_id_pressed(id: int) -> void:
	if id == 0:
		delete_selected_note()


func delete_selected_note() -> void:
	if selected_note_id == "":
		return
	
	var deleted: bool = NotesStore.delete_note(selected_note_id)
	
	if deleted:
		rebuild_notes_list()
	
	selected_note_id = ""
