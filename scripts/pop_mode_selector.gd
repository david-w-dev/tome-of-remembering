extends PopupPanel

signal mode_selected(mode_id: String)

@onready var notes_button: Button = $VBoxContainer/btn_Notes
@onready var glossary_button: Button = $VBoxContainer/btn_Glossary
@onready var settings_button: Button = $VBoxContainer/btn_Settings

func _ready() -> void:
	notes_button.pressed.connect(_on_mode_button_pressed.bind("notes"))
	glossary_button.pressed.connect(_on_mode_button_pressed.bind("glossary"))
	settings_button.pressed.connect(_on_mode_button_pressed.bind("settings"))

func _on_mode_button_pressed(mode_id: String) -> void:
	mode_selected.emit(mode_id)
	hide()
