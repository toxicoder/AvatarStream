extends CanvasLayer

@onready var label = $PanelContainer/VBoxContainer/Label

func set_message(message: String):
	label.text = message

func _on_Button_pressed():
	queue_free()
