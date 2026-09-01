extends TextureButton

@export var cena_livro: PackedScene

var instancia_livro_atual: Control = null


func _ready() -> void:
	pressed.connect(_on_btn_pressed)


func _on_btn_pressed() -> void:
	if not cena_livro:
		print("ERRO: Atribua a 'cena_livro' no Inspetor!")
		return

	if not is_instance_valid(instancia_livro_atual):
		instancia_livro_atual = cena_livro.instantiate() as Control
		get_parent().add_child(instancia_livro_atual)
		
		# 1. Trava as âncoras no canto superior esquerdo (evita que a Godot puxe o nó)
		instancia_livro_atual.set_anchors_preset(Control.PRESET_TOP_LEFT)
		
		# 2. Usa a Posição Global na tela (independente de onde o pai esteja)
		instancia_livro_atual.global_position = Vector2(380, 1)
		
		_abrir()
		return

	if instancia_livro_atual.visible:
		instancia_livro_atual.hide()
	else:
		_abrir()


func _abrir() -> void:
	if instancia_livro_atual.has_method("abrir_livro"):
		instancia_livro_atual.abrir_livro()
	else:
		instancia_livro_atual.show()
