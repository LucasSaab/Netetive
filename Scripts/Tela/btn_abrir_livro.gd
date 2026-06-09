extends TextureButton

@export var cena_livro: PackedScene
@export var container_central: CenterContainer # Nova variável para receber o container!

var instancia_livro_atual: Control = null 

func _ready() -> void:
	pressed.connect(_on_btn_pressed)

func _on_btn_pressed() -> void:
	# Verifica se você preencheu as coisas no Inspetor
	if cena_livro == null or container_central == null:
		print("ERRO: Cena do livro ou Container Central não atribuídos no Inspetor!")
		return
		
	# Se o livro já existe, só abre
	if instancia_livro_atual != null and is_instance_valid(instancia_livro_atual):
		instancia_livro_atual.abrir_livro()
		return
		
	# Cria o livro
	instancia_livro_atual = cena_livro.instantiate()
	
	container_central.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Joga o livro dentro do CenterContainer que criamos na cena!
	container_central.add_child(instancia_livro_atual)
	
	if instancia_livro_atual.has_method("abrir_livro"):
		instancia_livro_atual.abrir_livro()
