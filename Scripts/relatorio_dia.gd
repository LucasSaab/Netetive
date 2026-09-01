extends Control
class_name RelatorioDia

@onready var vbox_resultados: VBoxContainer = get_node_or_null("ScrollContainer/VBoxResultados")
@onready var label_resumo: Label = get_node_or_null("LabelResumo")
@onready var label_dinheiro: Label = get_node_or_null("LabelDinheiro")
@onready var label_fama: Label = get_node_or_null("LabelFama")
@onready var btn_voltar: Button = get_node_or_null("BtnVoltar")


func _ready() -> void:
	if vbox_resultados == null:
		push_warning("RelatorioDia: nó 'ScrollContainer/VBoxResultados' não encontrado — confira a estrutura da cena.")

	if label_resumo == null:
		push_warning("RelatorioDia: nó 'LabelResumo' não encontrado — confira a estrutura da cena.")

	if label_dinheiro == null:
		push_warning("RelatorioDia: nó 'LabelDinheiro' não encontrado — confira a estrutura da cena.")

	if label_fama == null:
		push_warning("RelatorioDia: nó 'LabelFama' não encontrado — confira a estrutura da cena.")

	if btn_voltar == null:
		push_warning("RelatorioDia: nó 'BtnVoltar' não encontrado — confira a estrutura da cena.")
	else:
		btn_voltar.pressed.connect(_on_voltar_pressed)

	montar_relatorio()


func montar_relatorio() -> void:
	if vbox_resultados == null:
		return

	for filho in vbox_resultados.get_children():
		filho.queue_free()

	var total_certos := 0
	var total_dinheiro := 0
	var total_fama := 0

	for resultado in DadosJogo.resultados_do_dia:
		vbox_resultados.add_child(_criar_linha(resultado))

		if resultado.acertou_no_geral:
			total_certos += 1

		total_dinheiro += resultado.recompensa
		total_fama += resultado.fama_ganha

	# Calcula a manutenção diária
	var upkeep_total := CalculadoraUpkeep.calcular_total()

	# Atualiza o dinheiro e a fama do jogador
	DadosJogo.dinheiro_jogador += total_dinheiro - upkeep_total
	DadosJogo.fama_jogador += total_fama

	# Mostra somente o que foi ganho no dia
	if label_dinheiro != null:
		label_dinheiro.text = "+R$ %d" % total_dinheiro

	if label_fama != null:
		label_fama.text = "+%d fama" % total_fama

	# Resumo geral
	if label_resumo != null:
		label_resumo.text = "%d/%d trabalhos corretos " % [
			total_certos,
			DadosJogo.resultados_do_dia.size(),
		]


func _criar_linha(resultado: ResultadoTrabalho) -> Control:
	var vbox := VBoxContainer.new()

	var titulo := Label.new()
	var veredito := "✅" if resultado.acertou_no_geral else "❌"

	titulo.text = "%s  %s" % [
		veredito,
		resultado.agendado.trabalho.titulo
	]

	vbox.add_child(titulo)

	var detalhe := Label.new()

	detalhe.text = "Alvo encontrado: %s | Diagnóstico: %s (%s) | Tentativas: %d certas / %d erradas | Tempo: %.0f min | R$ %d | +%d fama" % [
		"Sim" if resultado.achou_alvo_correto else "Não",
		resultado.diagnostico_escolhido if resultado.diagnostico_escolhido != "" else "nenhum",
		"correto" if resultado.diagnostico_correto else "incorreto",
		resultado.tentativas_certas,
		resultado.tentativas_erradas,
		resultado.tempo_gasto_minutos(),
		resultado.recompensa,
		resultado.fama_ganha
	]

	vbox.add_child(detalhe)

	vbox.add_child(HSeparator.new())

	return vbox


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Escritorio.tscn")
