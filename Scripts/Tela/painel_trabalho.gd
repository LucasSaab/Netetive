extends Panel

# O sinal agora carrega o TrabalhoInspecao inteiro também — quem escutar
# (a cena Tela) precisa dele para chamar GerenciadorInspecao.montar_alvos()
# e trocar a imagem do site exibida na tela.
signal trabalho_aceito(trabalho: TrabalhoInspecao, recompensa: int)

@onready var label_titulo := $LabelTitulo
@onready var label_descricao := $LabelDescricao
@onready var label_recompensa := $LabelRecompensa
@onready var btn_aceitar := $BtnAceitar
@onready var btn_ignorar := $BtnIgnorar

var _recompensa_atual := 0
var _trabalho_atual: TrabalhoInspecao = null
var _lembrete_origem: TextureButton = null  # Guarda qual post-it foi clicado


func _ready() -> void:
	hide()
	btn_ignorar.pressed.connect(fechar)
	btn_aceitar.pressed.connect(_on_aceitar_pressionado)


# Função chamada pelo GerenciadorTrabalho passando o trabalho sorteado inteiro
# além dos campos individuais que já eram usados pros textos do painel.
func abrir(trabalho: TrabalhoInspecao, lembrete: TextureButton, titulo: String, descricao: String, recompensa: int) -> void:
	_trabalho_atual = trabalho
	_lembrete_origem = lembrete
	_recompensa_atual = recompensa

	label_titulo.text = titulo
	label_descricao.text = descricao
	label_recompensa.text = "Recompensa: R$ " + str(recompensa)

	var tamanho_tela := get_viewport_rect().size
	global_position = (tamanho_tela - size) / 2
	z_index = 101

	show()


func fechar() -> void:
	hide()


func _on_aceitar_pressionado() -> void:
	emit_signal("trabalho_aceito", _trabalho_atual, _recompensa_atual)
	fechar()

	if is_instance_valid(_lembrete_origem):
		_lembrete_origem.queue_free()


func _gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("clique_direito"):
		if self.has_method("fechar"):
			self.fechar()
		else:
			hide()
		get_viewport().set_input_as_handled()
