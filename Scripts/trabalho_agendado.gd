class_name TrabalhoAgendado
extends RefCounted

var trabalho: TrabalhoInspecao
var horario_aparicao: float = 0.0
var recompensa_dinheiro: int = 0
var recompensa_fama: int = 0        # novo — escala com o multiplicador de modificadores

var apareceu: bool = false
var aceito: bool = false
var concluido: bool = false
var investigar_usado: bool = false

# Sistema de modificadores de dificuldade (novo)
var modificadores: Array[ModificadorAtivo] = []
var hora_limite: float = -1.0       # -1 = sem prazo (nenhum modificador Relógio sorteado)
