extends Control

@onready var header_bar = $HeaderBar
@onready var pop_mode_selector = $PopModeSelector
@onready var modes = {
	"notes": $ModeContainer/ModeNotes,
	"glossary": $ModeContainer/ModeGlossary,
	"settings": $ModeContainer/ModeSettings,
}
@export var default_mode = "notes"

func _ready() -> void:
	#Signals
	header_bar.menu_requested.connect(_on_menu_requested)
	pop_mode_selector.mode_selected.connect(_on_mode_selected)
	
	#Setup
	switch_mode(default_mode)

func _on_menu_requested():
	if not pop_mode_selector.visible:
		pop_mode_selector.popup()
		pop_mode_selector.exclusive = true
		pop_mode_selector.always_on_top = true

func _on_mode_selected(mode_id: String) -> void:
	print("Selected mode: ", mode_id)
	switch_mode(mode_id)

func switch_mode(mode_id: String) -> void:
	for mode in modes.values():
		mode.visible = false

	if modes.has(mode_id):
		modes[mode_id].visible = true

	header_bar.set_title(mode_id)
