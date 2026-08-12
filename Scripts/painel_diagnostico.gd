extends Control
class_name PainelDiagnostico

signal diagnostico_escolhido(agendado: TrabalhoAgendado, opcao: String)

@onready var vbox_opcoes: VBoxContainer = $VBoxOpcoes
@onready var label_titulo: Label = $LabelTitulo

var _agendado_atual: TrabalhoAgendado


func _ready() -> void:
	hide()


func abrir(agendado: TrabalhoAgendado) -> void:
	_agendado_atual = agendado
	label_titulo.text = "Qual o problema deste site?"

	for filho in vbox_opcoes.get_children():
		filho.queue_free()

	var opcoes := DadosJogo.gerar_opcoes_diagnostico(agendado.trabalho)
	for opcao in opcoes:
		var botao := Button.new()
		botao.text = opcao
		botao.pressed.connect(_on_opcao_pressionada.bind(opcao))
		vbox_opcoes.add_child(botao)

	show()


func _on_opcao_pressionada(opcao: String) -> void:
	diagnostico_escolhido.emit(_agendado_atual, opcao)
	hide()
