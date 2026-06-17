extends PanelContainer

signal note_pressed(note_id: String)
signal note_long_pressed(note_id: String)

@onready var timestamp_label: Label = $MarginContainer/VBoxContainer/Label_Timestamp
@onready var note_text_label: RichTextLabel = $MarginContainer/VBoxContainer/Label_NoteText

var note_data: Dictionary = {}

var is_pressing := false
var long_press_triggered := false
var press_time := 0.0
var press_start_position := Vector2.ZERO
var has_moved_too_far := false

const LONG_PRESS_TIME := 0.5
const DRAG_CANCEL_DISTANCE := 20.0
const REFERENCE_COLOR := "#8fd3ff"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	timestamp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	note_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(new_note_data: Dictionary) -> void:
	note_data = new_note_data
	
	timestamp_label.text = note_data.get("created_at", "")
	
	note_text_label.bbcode_enabled = true
	note_text_label.fit_content = true
	note_text_label.scroll_active = false
	note_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_text_label.text = note_text_to_bbcode(note_data.get("text", ""))


func note_text_to_bbcode(note_text: String) -> String:
	var regex := RegEx.new()
	var error := regex.compile("\\[([^\\]]+)\\]")
	
	if error != OK:
		print("Reference regex failed to compile.")
		return note_text
	
	var output := note_text
	var matches := regex.search_all(note_text)
	
	for i in range(matches.size() - 1, -1, -1):
		var result := matches[i]
		var reference_name := result.get_string(1).strip_edges()
		var replacement := "[color=" + REFERENCE_COLOR + "]" + escape_bbcode(reference_name) + "[/color]"
		
		output = output.substr(0, result.get_start()) + replacement + output.substr(result.get_end())
	
	return output


func escape_bbcode(text: String) -> String:
	return text.replace("[", "&#91;").replace("]", "&#93;")


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_start_press(event.position)
		else:
			_end_press()
	
	elif event is InputEventScreenDrag:
		_update_drag(event.position)
	
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_press(event.position)
			else:
				_end_press()
		
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				note_long_pressed.emit(note_data.get("id", ""))
	
	elif event is InputEventMouseMotion:
		if is_pressing:
			_update_drag(event.position)


func _process(delta: float) -> void:
	if not is_pressing:
		return
	
	if has_moved_too_far:
		return
	
	press_time += delta
	
	if press_time >= LONG_PRESS_TIME and not long_press_triggered:
		long_press_triggered = true
		note_long_pressed.emit(note_data.get("id", ""))


func _start_press(position: Vector2) -> void:
	is_pressing = true
	long_press_triggered = false
	has_moved_too_far = false
	press_time = 0.0
	press_start_position = position


func _update_drag(position: Vector2) -> void:
	if not is_pressing:
		return
	
	var distance := press_start_position.distance_to(position)
	
	if distance > DRAG_CANCEL_DISTANCE:
		has_moved_too_far = true


func _end_press() -> void:
	if is_pressing and not long_press_triggered and not has_moved_too_far:
		note_pressed.emit(note_data.get("id", ""))
	
	is_pressing = false
