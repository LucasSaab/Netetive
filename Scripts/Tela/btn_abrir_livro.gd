extends BaseButton

# =====================================================================
# Botão que abre o LivroDicas. O mesmo script serve ao livro fechado
# sobre a mesa (Escritorio.tscn) e ao BtnAbrirLivro (Tela.tscn).
# Não precisa de referência no Inspetor: acha o livro pelo grupo
# "livro_dicas" (o LivroDicas se registra nele no _ready()).
# =====================================================================

const COR_HOVER := Color(1.15, 1.15, 1.15)   # >1 clareia o sprite
const TAMANHO_FONTE := 8


func _ready() -> void:
	# O is_connected evita erro se o sinal já estiver ligado pelo editor.
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	print("LIVRO: _ready rodou em ", get_path())
	

func _on_pressed() -> void:
	var livros := get_tree().get_nodes_in_group("livro_dicas")
	print("LIVRO: clique ok | livros no grupo: ", livros.size())
	for l in livros:
		print("LIVRO: visible=", l.visible, " | tem abrir()=", l.has_method("abrir"))
	get_tree().call_group("livro_dicas", "abrir")


func _on_mouse_entered() -> void:
	self_modulate = COR_HOVER


func _on_mouse_exited() -> void:
	self_modulate = Color.WHITE
