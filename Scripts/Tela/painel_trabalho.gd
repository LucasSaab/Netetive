extends Panel

signal trabalho_aceito(recompensa: int)

@onready var label_titulo := $LabelTitulo
@onready var label_descricao := $LabelDescricao
@onready var label_recompensa := $LabelRecompensa
@onready var btn_aceitar := $BtnAceitar
@onready var btn_ignorar := $BtnIgnorar

var _recompensa_atual := 0
var _lembrete_origem: TextureButton = null # Guarda qual post-it foi clicado

func _ready() -> void:
	hide() # Começa escondido
	btn_ignorar.pressed.connect(fechar)
	btn_aceitar.pressed.connect(_on_aceitar_pressionado)

# Função chamada pela Main passando os dados do post-it clicado
func abrir(lembrete: TextureButton, titulo: String, descricao: String, recompensa: int) -> void:
	_lembrete_origem = lembrete
	_recompensa_atual = recompensa
	
	# Preenche os textos
	label_titulo.text = titulo
	label_descricao.text = descricao
	label_recompensa.text = "Recompensa: R$ " + str(recompensa)
	
	# --- CÓDIGO NOVO PARA CENTRALIZAR O PAINEL NA TELA ---
	# 1. Descobre o tamanho total da janela do seu jogo
	var tamanho_tela := get_viewport_rect().size
	
	# 2. Calcula a posição para ficar exatamente no meio (Tamanho da tela - Tamanho do Painel divido por 2)
	global_position = (tamanho_tela - size) / 2
	
	# 3. Garante que a tela de detalhes fique por cima de TUDO (incluindo o próprio post-it)
	z_index = 101 
	# -----------------------------------------------------
	
	show()

func fechar() -> void:
	hide()

func _on_aceitar_pressionado() -> void:
	emit_signal("trabalho_aceito", _recompensa_atual)
	fechar()
	
	# Se o jogador aceitou, o papelzinho some da tela (foi descolado do monitor)
	if is_instance_valid(_lembrete_origem):
		_lembrete_origem.queue_free()

func _gui_input(event: InputEvent) -> void:
	# Verifica se o painel está visível e se a ação "clique_direito" mapeada foi acionada
	if visible and event.is_action_pressed("clique_direito"):
		# Se a sua função original se chama fechar, chamamos ela com o prefixo 'self.'
		# para garantir que o Godot saiba que é para fechar ESTE painel.
		if self.has_method("fechar"):
			self.fechar()
		else:
			hide() # Caso de emergência se a função não existir
			
		# Avisa o sistema para não passar esse clique para os objetos que estão atrás
		get_viewport().set_input_as_handled()
