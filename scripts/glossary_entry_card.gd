extends PanelContainer

@onready var reference_name_label: Label = $MarginContainer/VBoxContainer/HeaderRow/Label_ReferenceName
@onready var arrow_label: Label = $MarginContainer/VBoxContainer/HeaderRow/Label_Arrow
@onready var expanded_content: VBoxContainer = $MarginContainer/VBoxContainer/ExpandedContent

var reference_name := ""
var is_expanded := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	expanded_content.visible = false
	_update_arrow()


func setup(new_reference_name: String) -> void:
	reference_name = new_reference_name
	reference_name_label.text = reference_name


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
