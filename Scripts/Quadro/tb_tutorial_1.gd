extends TextureButton

@onready var layer_tutorial: CanvasLayer = $"../Layer_Tutorial_1"

func _on_pressed() -> void:
	print("Abriu o tutorial!")
	if layer_tutorial != null:
		layer_tutorial.show()
