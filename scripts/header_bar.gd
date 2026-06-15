extends Control

signal menu_requested

@onready var title = $Title

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_title(new_title: String):
	print("new title set")
	title.text = new_title.capitalize()

func _on_menu_button_pressed() -> void:
	print("Burger Pressed")
	menu_requested.emit()
