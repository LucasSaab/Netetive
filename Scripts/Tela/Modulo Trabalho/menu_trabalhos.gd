extends Control

signal trabalho_aceito(agendado: TrabalhoAgendado)
signal trabalho_selecionado(agendado: TrabalhoAgendado)

@onready var vbox_disponiveis: VBoxContainer = $VBoxDisponiveis
@onready var vbox_ativos: VBoxContainer = $VBoxAtivos


func _ready() -> void:
	hide()


func abrir() -> void:
	atualizar()
	show()


func fechar() -> void:
	hide()


func atualizar() -> void:
	_limpar(vbox_disponiveis)
	_limpar(vbox_ativos)

	for agendado in DadosJogo.trabalhos_disponiveis:
		vbox_disponiveis.add_child(_criar_linha_disponivel(agendado))

	for agendado in DadosJogo.trabalhos_ativos:
		vbox_ativos.add_child(_criar_linha_ativo(agendado))


func _limpar(container: VBoxContainer) -> void:
	for filho in container.get_children():
		filho.queue_free()


func _criar_linha_disponivel(agendado: TrabalhoAgendado) -> Control:
	var linha := HBoxContainer.new()

	var label := Label.new()
	label.text = "%s — R$ %d | Fama +%d" % [
		agendado.trabalho.titulo, agendado.recompensa_dinheiro, agendado.trabalho.recompensa_fama
	]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(label)

	var btn := Button.new()
	btn.text = "Aceitar"
	btn.pressed.connect(func(): _on_aceitar_pressionado(agendado))
	linha.add_child(btn)

	return linha


func _on_aceitar_pressionado(agendado: TrabalhoAgendado) -> void:
	trabalho_aceito.emit(agendado)
	atualizar()


func _criar_linha_ativo(agendado: TrabalhoAgendado) -> Control:
	var linha := HBoxContainer.new()
	var em_andamento: bool = (agendado == DadosJogo.trabalho_atual)

	var label := Label.new()
	label.text = ("▶ " if em_andamento else "   ") + agendado.trabalho.titulo
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(label)

	var btn := Button.new()
	if em_andamento:
		btn.text = "Em andamento"
		btn.disabled = true
	else:
		btn.text = "Inspecionar"
		btn.pressed.connect(func(): _on_selecionar_pressionado(agendado))
	linha.add_child(btn)

	return linha


func _on_selecionar_pressionado(agendado: TrabalhoAgendado) -> void:
	trabalho_selecionado.emit(agendado)
	atualizar()


func _gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("clique_direito"):
		fechar()
		get_viewport().set_input_as_handled()
