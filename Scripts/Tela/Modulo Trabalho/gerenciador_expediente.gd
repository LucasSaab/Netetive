extends Node

signal expediente_iniciado
signal expediente_encerrado
signal relogio_atualizado(hora_formatada: String)
signal trabalho_disponibilizado(agendado: TrabalhoAgendado)

@export var quantidade_trabalhos_dia: int = 10
@export var quantidade_trabalhos_iniciais: int = 3
@export var minutos_por_segundo_real: float = 4.0

var hora_atual: float = 0.0
var _proximo_indice_agenda: int = 0
var _rodando: bool = false


func iniciar_expediente() -> void:
	DadosJogo.sortear_agenda_do_dia(quantidade_trabalhos_dia, quantidade_trabalhos_iniciais)

	hora_atual = DadosJogo.HORA_INICIO_EXPEDIENTE
	_proximo_indice_agenda = 0
	_rodando = true

	print("EXPEDIENTE: Iniciado às ", _formatar_hora(hora_atual))
	expediente_iniciado.emit()
	relogio_atualizado.emit(_formatar_hora(hora_atual))

	_verificar_disponibilidade()


func _process(delta: float) -> void:
	if not _rodando:
		return

	hora_atual += (delta * minutos_por_segundo_real) / 60.0
	relogio_atualizado.emit(_formatar_hora(hora_atual))
	_verificar_disponibilidade()

	if hora_atual >= DadosJogo.HORA_FIM_EXPEDIENTE:
		_encerrar_expediente()


func _verificar_disponibilidade() -> void:
	var agenda: Array[TrabalhoAgendado] = DadosJogo.trabalhos_do_dia
	while _proximo_indice_agenda < agenda.size() and agenda[_proximo_indice_agenda].horario_aparicao <= hora_atual:
		var agendado: TrabalhoAgendado = agenda[_proximo_indice_agenda]
		DadosJogo.disponibilizar_trabalho(agendado)
		trabalho_disponibilizado.emit(agendado)
		print("EXPEDIENTE: Trabalho disponível: ", agendado.trabalho.titulo, " às ", _formatar_hora(hora_atual))
		_proximo_indice_agenda += 1


func _encerrar_expediente() -> void:
	_rodando = false
	hora_atual = DadosJogo.HORA_FIM_EXPEDIENTE
	print("EXPEDIENTE: Encerrado. Trabalhos concluídos: ", DadosJogo.trabalhos_concluidos_hoje)
	expediente_encerrado.emit()


func _formatar_hora(hora: float) -> String:
	var h := int(hora)
	var m := int((hora - h) * 60.0)
	return "%02d:%02d" % [h, m]
