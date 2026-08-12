extends Resource
class_name ResultadoTrabalho

var agendado: TrabalhoAgendado
@export var achou_alvo_correto: bool = false
@export var diagnostico_escolhido: String = ""
@export var diagnostico_correto: bool = false
@export var acertou_no_geral: bool = false
@export var recompensa: int = 0

@export var tentativas_certas: int = 0
@export var tentativas_erradas: int = 0
@export var hora_inicio: float = 0.0
@export var hora_fim: float = 0.0

func registrar_tentativa(acertou: bool) -> void:
	if acertou:
		tentativas_certas += 1
	else:
		tentativas_erradas += 1

func tempo_gasto_minutos() -> float:
	return max(0.0, hora_fim - hora_inicio) * 60.0

func finalizar() -> void:
	acertou_no_geral = achou_alvo_correto and diagnostico_correto
	recompensa = agendado.recompensa_dinheiro if acertou_no_geral else 0
