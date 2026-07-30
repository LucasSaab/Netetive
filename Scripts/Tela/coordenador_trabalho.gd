extends Node

# =====================================================================
# CoordenadorTrabalho
# ---------------------------------------------------------------------
# Único responsável por conectar GerenciadorTrabalho (menu de trabalhos)
# com GerenciadorInspecao (alvos/clique/detecção). Nenhum dos dois
# conhece o outro diretamente — essa é a única função deste nó, para
# manter Main_select_script.gd livre dessa responsabilidade.
#
# Fluxo:
#   GerenciadorTrabalho.trabalho_selecionado(agendado)
#           │
#           ▼
#   CoordenadorTrabalho: guarda agendado, troca imagem do site,
#                         chama GerenciadorInspecao.montar_alvos(trabalho)
#           │
#   (jogador inspeciona a tela...)
#           │
#           ▼
#   GerenciadorInspecao.inspecao_concluida(acertou, trabalho)
#           │
#           ▼
#   CoordenadorTrabalho: se acertou, chama
#                         GerenciadorTrabalho.marcar_trabalho_concluido(agendado)
# =====================================================================

@export var gerenciador_trabalho: Node
@export var gerenciador_inspecao: Node
@export var site_textura: TextureRect

var _agendado_atual: TrabalhoAgendado = null


func _ready() -> void:
	if gerenciador_trabalho != null:
		gerenciador_trabalho.trabalho_selecionado.connect(_on_trabalho_selecionado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_trabalho não atribuído no Inspetor.")

	if gerenciador_inspecao != null and gerenciador_inspecao.has_signal("inspecao_concluida"):
		gerenciador_inspecao.inspecao_concluida.connect(_on_inspecao_concluida)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído (ou sem o sinal inspecao_concluida).")


func _on_trabalho_selecionado(agendado: TrabalhoAgendado) -> void:
	if agendado == null or agendado.trabalho == null:
		push_warning("CoordenadorTrabalho: trabalho_selecionado chegou com agendado/trabalho nulo.")
		return

	_agendado_atual = agendado
	var trabalho: TrabalhoInspecao = agendado.trabalho
	print("Inspecionando agora: ", trabalho.titulo)

	if site_textura != null and trabalho.imagem_site != null:
		site_textura.texture = trabalho.imagem_site

	if gerenciador_inspecao != null and gerenciador_inspecao.has_method("montar_alvos"):
		gerenciador_inspecao.montar_alvos(trabalho)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído ou sem montar_alvos().")


func _on_inspecao_concluida(acertou: bool, trabalho: TrabalhoInspecao) -> void:
	if not acertou:
		return
	if _agendado_atual == null or _agendado_atual.trabalho != trabalho:
		push_warning("CoordenadorTrabalho: inspecao_concluida não bate com o agendado atual.")
		return
	if gerenciador_trabalho != null and gerenciador_trabalho.has_method("marcar_trabalho_concluido"):
		gerenciador_trabalho.marcar_trabalho_concluido(_agendado_atual)
