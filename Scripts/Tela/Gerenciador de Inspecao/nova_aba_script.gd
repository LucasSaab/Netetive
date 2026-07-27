extends TextureRect

signal inspecionar_pressionado

func _ready() -> void:
	hide()
	$VBoxContainer/Button.pressed.connect(_on_inspecionar_pressed)

func mostrar_em(pos: Vector2) -> void:
	global_position = pos
	show()

func esconder() -> void:
	hide()

func _on_inspecionar_pressed() -> void:
	emit_signal("inspecionar_pressionado")
	esconder()

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not get_global_rect().has_point(event.position):
			get_viewport().set_input_as_handled()
			esconder()
