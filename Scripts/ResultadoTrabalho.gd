extends Resource
class_name ResultadoTrabalho

var agendado: TrabalhoAgendado
@export var achou_alvo_correto: bool = false
@export var diagnostico_escolhido: String = ""
@export var diagnostico_correto: bool = false
@export var acertou_no_geral: bool = false
@export var recompensa: int = 0

func finalizar() -> void:
	acertou_no_geral = achou_alvo_correto and diagnostico_correto
	recompensa = agendado.recompensa_dinheiro if acertou_no_geral else 0
