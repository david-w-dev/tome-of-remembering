extends Control

@onready var note_input: TextEdit = $VBoxContainer/NoteInput
@onready var save_button: Button = $VBoxContainer/SaveButton
@onready var notes_list: VBoxContainer = $VBoxContainer/NotesScroll/NotesList
@onready var keyboard_spacer: Control = $VBoxContainer/KeyboardSpacer


func _ready() -> void:
	save_button.pressed.connect(_on_save_button_pressed)
	keyboard_spacer.custom_minimum_size.y = 0


func _process(_delta: float) -> void:
	update_keyboard_spacer()


func update_keyboard_spacer() -> void:
	var keyboard_height: int = DisplayServer.virtual_keyboard_get_height()
	
	if keyboard_height > 0:
		keyboard_spacer.custom_minimum_size.y = (keyboard_height * 0.5) + 200
	else:
		keyboard_spacer.custom_minimum_size.y = 0


func _on_save_button_pressed() -> void:
	var note_text: String = note_input.text.strip_edges()
	
	if note_text == "":
		return
	
	var timestamp: String = _get_timestamp()
	add_note_to_list(note_text, timestamp)
	
	note_input.clear()


func add_note_to_list(note_text: String, timestamp: String) -> void:
	var note_container := PanelContainer.new()
	var note_margin := MarginContainer.new()
	var note_vbox := VBoxContainer.new()
	
	var timestamp_label := Label.new()
	var note_label := Label.new()
	
	note_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timestamp_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	note_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	timestamp_label.text = timestamp
	note_label.text = note_text
	
	note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	note_margin.add_theme_constant_override("margin_left", 12)
	note_margin.add_theme_constant_override("margin_right", 12)
	note_margin.add_theme_constant_override("margin_top", 8)
	note_margin.add_theme_constant_override("margin_bottom", 8)
	
	note_vbox.add_child(timestamp_label)
	note_vbox.add_child(note_label)
	note_margin.add_child(note_vbox)
	note_container.add_child(note_margin)
	
	notes_list.add_child(note_container)


func _get_timestamp() -> String:
	var datetime := Time.get_datetime_dict_from_system()
	
	var year: int = datetime["year"]
	var month: int = datetime["month"]
	var day: int = datetime["day"]
	var hour: int = datetime["hour"]
	var minute: int = datetime["minute"]
	
	return "%04d-%02d-%02d %02d:%02d" % [year, month, day, hour, minute]
