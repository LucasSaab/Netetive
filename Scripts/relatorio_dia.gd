extends Control
class_name RelatorioDia

@onready var vbox_resultados: VBoxContainer = $ScrollContainer/VBoxResultados
@onready var label_resumo: Label = $LabelResumo
@onready var btn_voltar: Button = $BtnVoltar


func _ready() -> void:
	btn_voltar.pressed.connect(_on_voltar_pressed)
	montar_relatorio()


func montar_relatorio() -> void:
	for filho in vbox_resultados.get_children():
		filho.queue_free()

	var total_certos := 0
	var total_dinheiro := 0

	for resultado in DadosJogo.resultados_do_dia:
		vbox_resultados.add_child(_criar_linha(resultado))
		if resultado.acertou_no_geral:
			total_certos += 1
		total_dinheiro += resultado.recompensa

	DadosJogo.dinheiro_jogador += total_dinheiro

	label_resumo.text = "%d/%d trabalhos corretos \n R$ %d ganhos hoje (saldo: R$ %d)" % [
		total_certos, DadosJogo.resultados_do_dia.size(), total_dinheiro, DadosJogo.dinheiro_jogador
	]


func _criar_linha(resultado: ResultadoTrabalho) -> Control:
	var vbox := VBoxContainer.new()

	var titulo := Label.new()
	var veredito := "✅" if resultado.acertou_no_geral else "❌"
	titulo.text = "%s  %s" % [veredito, resultado.agendado.trabalho.titulo]
	vbox.add_child(titulo)

	var detalhe := Label.new()
	detalhe.text = "Alvo encontrado: %s | Diagnóstico: %s (%s) | R$ %d" % [
		"Sim" if resultado.achou_alvo_correto else "Não",
		resultado.diagnostico_escolhido if resultado.diagnostico_escolhido != "" else "nenhum",
		"correto" if resultado.diagnostico_correto else "incorreto",
		resultado.recompensa,
	]
	vbox.add_child(detalhe)

	vbox.add_child(HSeparator.new())
	return vbox


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Escritorio.tscn")
