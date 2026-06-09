extends Control

# Mudamos o sinal para enviar apenas um ponto (Vector2) em vez de um Rect2
signal clicou_em(pos: Vector2)

func _ready() -> void:
	# Garante que ocupa a tela toda
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Ignora o mouse para não bloquear a UI, mas ainda lê os cliques pelo _unhandled_input
	mouse_filter = Control.MOUSE_FILTER_IGNORE 

func _unhandled_input(event: InputEvent) -> void:
	# Detecta apenas o clique esquerdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("clicou_em", event.position)
