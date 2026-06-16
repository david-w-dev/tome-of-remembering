extends PanelContainer

signal note_pressed(note_id: String)
signal note_long_pressed(note_id: String)

@onready var timestamp_label: Label = $MarginContainer/VBoxContainer/Label_Timestamp
@onready var note_text_label: Label = $MarginContainer/VBoxContainer/Label_NoteText

var note_data: Dictionary = {}

var is_pressing := false
var long_press_triggered := false
var press_time := 0.0
var press_start_position := Vector2.ZERO
var has_moved_too_far := false

const LONG_PRESS_TIME := 0.5
const DRAG_CANCEL_DISTANCE := 20.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	timestamp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	note_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(new_note_data: Dictionary) -> void:
	note_data = new_note_data
	
	timestamp_label.text = note_data.get("created_at", "")
	note_text_label.text = note_data.get("text", "")
	note_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


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
