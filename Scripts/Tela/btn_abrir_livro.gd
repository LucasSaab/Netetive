extends TextureButton

@export var cena_livro: PackedScene
@export var container_central: CenterContainer

var instancia_livro_atual: Control = null

func _ready() -> void:
	pressed.connect(_on_btn_pressed)

func _on_btn_pressed() -> void:
	if cena_livro == null or container_central == null:
		print("ERRO: Cena do livro ou Container Central não atribuídos no Inspetor!")
		return

	# Se o livro já está aberto, fecha
	if instancia_livro_atual != null and is_instance_valid(instancia_livro_atual):
		_fechar_livro()
		return

	# Cria e abre o livro
	instancia_livro_atual = cena_livro.instantiate()
	container_central.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container_central.add_child(instancia_livro_atual)

	if instancia_livro_atual.has_method("abrir_livro"):
		instancia_livro_atual.abrir_livro()

func _fechar_livro() -> void:
	if instancia_livro_atual != null and is_instance_valid(instancia_livro_atual):
		instancia_livro_atual.queue_free()
		instancia_livro_atual = null
