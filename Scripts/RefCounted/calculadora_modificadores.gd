class_name CalculadoraModificadores
extends RefCounted

const FAMA_MINIMA_T1 := 50
const FAMA_MINIMA_T2 := 200
const FAMA_MINIMA_T3 := 500

const QUANTIDADE_MAXIMA_T1 := 1
const QUANTIDADE_MAXIMA_T2 := 2
const QUANTIDADE_MAXIMA_T3 := 3

const NIVEL_MAXIMO_T1_BASE := 2
const NIVEL_MAXIMO_T1_COM_T2 := 3
const NIVEL_MAXIMO_T1_COM_T3 := 4
const NIVEL_MAXIMO_T2_BASE := 2
const NIVEL_MAXIMO_T2_COM_T3 := 3
const NIVEL_T3_FIXO := 1

const TAXA_BONUS_T1 := 0.03
const TAXA_BONUS_T2 := 0.05
const TAXA_BONUS_T3 := 0.20
const BONUS_COMBO_POR_MODIFICADOR_EXTRA := 0.05

const SEGUNDOS_CONEXAO_LENTA_POR_NIVEL := 0.5
const OPCOES_EXTRA_POR_NIVEL_MAIS_OPCOES := 1
const QUANTIDADE_DIAGNOSTICO_BASE := 3
const QUANTIDADE_DIAGNOSTICO_TETO := 6

const DURACAO_ARMADILHA_SEGUNDOS := 1.0
const ESCALA_MOUSE_GRANDE_POR_NIVEL := 1.0
const TEMPO_MAXIMO_HORAS := 6.0

const QUADRANTES_CHAMARIZ_POR_NIVEL_MISDIRECAO := 1
const CURSORES_FALSOS_POR_NIVEL_COPIAS := 1

const QUANTIDADE_SUB_MODIFICADORES_CAOS := 3

# --- Surtos de velocidade (Mouse Rápido / Travamento) ---
const INTERVALO_SURTO_VELOCIDADE_MIN := 6.0
const INTERVALO_SURTO_VELOCIDADE_MAX := 10.0
const DURACAO_SURTO_VELOCIDADE := 2.0
const MULTIPLICADOR_TRAVAMENTO := 0.0   # congelamento total durante o surto

static var TIPOS_T1: Array = [
	ModificadorAtivo.Tipo.DESCONHECIDO,
	ModificadorAtivo.Tipo.CONEXAO_LENTA,
	ModificadorAtivo.Tipo.MAIS_OPCOES,
	ModificadorAtivo.Tipo.ARMADILHA,
	ModificadorAtivo.Tipo.MOUSE_GRANDE,
	ModificadorAtivo.Tipo.AO_CONTRARIO,
]

static var TIPOS_T2: Array = [
	ModificadorAtivo.Tipo.MISDIRECAO,
	ModificadorAtivo.Tipo.TEMPO_LIMITADO,
	ModificadorAtivo.Tipo.COPIAS,
	ModificadorAtivo.Tipo.MOUSE_RAPIDO,
]

static var TIPOS_T3: Array = [
	ModificadorAtivo.Tipo.CAOS,
	ModificadorAtivo.Tipo.TRAVAMENTO,
]

static var TIPOS_NIVEL_UNICO: Array = [
	ModificadorAtivo.Tipo.DESCONHECIDO,
	ModificadorAtivo.Tipo.AO_CONTRARIO,
]


static func tier_do_tipo(tipo: int) -> int:
	if TIPOS_T1.has(tipo):
		return 1
	if TIPOS_T2.has(tipo):
		return 2
	if TIPOS_T3.has(tipo):
		return 3
	return 0


static func tier_maximo_desbloqueado(fama: int) -> int:
	if fama >= FAMA_MINIMA_T3:
		return 3
	if fama >= FAMA_MINIMA_T2:
		return 2
	if fama >= FAMA_MINIMA_T1:
		return 1
	return 0


static func quantidade_maxima_por_fama(fama: int) -> int:
	var tier := tier_maximo_desbloqueado(fama)
	match tier:
		3:
			return QUANTIDADE_MAXIMA_T3
		2:
			return QUANTIDADE_MAXIMA_T2
		1:
			return QUANTIDADE_MAXIMA_T1
	return 0


static func nivel_maximo_para(tipo: int, tier_desbloqueado: int) -> int:
	if TIPOS_NIVEL_UNICO.has(tipo):
		return 1

	var tier_do_modificador := tier_do_tipo(tipo)
	match tier_do_modificador:
		1:
			if tier_desbloqueado >= 3:
				return NIVEL_MAXIMO_T1_COM_T3
			if tier_desbloqueado >= 2:
				return NIVEL_MAXIMO_T1_COM_T2
			return NIVEL_MAXIMO_T1_BASE
		2:
			if tier_desbloqueado >= 3:
				return NIVEL_MAXIMO_T2_COM_T3
			return NIVEL_MAXIMO_T2_BASE
		3:
			return NIVEL_T3_FIXO
	return 1


# ---------------------------------------------------------------------
# SORTEIO — sem mais exclusividade entre Mouse Rápido/Travamento: os
# dois podem coexistir no mesmo trabalho (o surto de velocidade sorteia
# qual dos dois dispara a cada janela, nunca os dois ao mesmo tempo —
# ver GerenciadorCursorVirtual._iniciar_surto_velocidade()).
# ---------------------------------------------------------------------
static func sortear_modificadores(fama: int) -> Array[ModificadorAtivo]:
	var vazio: Array[ModificadorAtivo] = []
	var tier_desbloqueado := tier_maximo_desbloqueado(fama)
	if tier_desbloqueado <= 0:
		return vazio

	var quantidade_maxima := quantidade_maxima_por_fama(fama)
	var quantidade := randi_range(0, quantidade_maxima)
	if quantidade <= 0:
		return vazio

	var pool: Array = TIPOS_T1.duplicate()
	if tier_desbloqueado >= 2:
		pool.append_array(TIPOS_T2)
	if tier_desbloqueado >= 3:
		var candidatos_t3: Array = TIPOS_T3.duplicate()
		candidatos_t3.shuffle()
		pool.append(candidatos_t3[0])   # só 1 T3 por trabalho

	pool.shuffle()
	var tipos_escolhidos: Array = pool.slice(0, quantidade)

	var modificadores: Array[ModificadorAtivo] = []
	for tipo in tipos_escolhidos:
		var teto_nivel := nivel_maximo_para(tipo, tier_desbloqueado)
		var nivel := randi_range(1, teto_nivel)
		var modificador := ModificadorAtivo.new(tipo, nivel)

		if tipo == ModificadorAtivo.Tipo.CAOS:
			modificador.sub_modificadores = _sortear_sub_modificadores_caos(tier_desbloqueado)

		modificadores.append(modificador)

	return modificadores


static func _sortear_sub_modificadores_caos(tier_desbloqueado: int) -> Array[ModificadorAtivo]:
	var pool: Array = TIPOS_T1.duplicate()
	pool.erase(ModificadorAtivo.Tipo.DESCONHECIDO)
	if tier_desbloqueado >= 2:
		pool.append_array(TIPOS_T2)

	var sub: Array[ModificadorAtivo] = []
	for i in range(QUANTIDADE_SUB_MODIFICADORES_CAOS):
		if pool.is_empty():
			break
		var tipo = pool[randi() % pool.size()]
		sub.append(ModificadorAtivo.new(tipo, 1))
	return sub


static func calcular_segundos_conexao_lenta(nivel: int) -> float:
	return float(nivel) * SEGUNDOS_CONEXAO_LENTA_POR_NIVEL


static func calcular_quantidade_diagnostico(nivel_mais_opcoes: int) -> int:
	var quantidade := QUANTIDADE_DIAGNOSTICO_BASE + nivel_mais_opcoes * OPCOES_EXTRA_POR_NIVEL_MAIS_OPCOES
	return clamp(quantidade, QUANTIDADE_DIAGNOSTICO_BASE, QUANTIDADE_DIAGNOSTICO_TETO)


static func calcular_quantidade_armadilhas(nivel: int) -> int:
	return nivel


static func calcular_escala_mouse_grande(nivel: int) -> float:
	return 1.0 + float(nivel) * ESCALA_MOUSE_GRANDE_POR_NIVEL


static func calcular_horas_prazo(nivel_tempo_limitado: int) -> float:
	if nivel_tempo_limitado <= 0:
		return TEMPO_MAXIMO_HORAS
	return TEMPO_MAXIMO_HORAS / float(nivel_tempo_limitado)


static func calcular_quantidade_chamarizes(nivel_misdirecao: int) -> int:
	return nivel_misdirecao * QUADRANTES_CHAMARIZ_POR_NIVEL_MISDIRECAO


static func calcular_quantidade_cursores_falsos(nivel_copias: int) -> int:
	return nivel_copias * CURSORES_FALSOS_POR_NIVEL_COPIAS


static func calcular_multiplicador_velocidade_rapido(nivel: int = 1) -> float:
	return 1.0 + (float(nivel) * 0.75)


static func calcular_multiplicador_recompensa(modificadores: Array[ModificadorAtivo]) -> float:
	if modificadores.is_empty():
		return 1.0

	var bonus := 0.0
	for mod in modificadores:
		bonus += _bonus_de_um_modificador(mod)
		if mod.tipo == ModificadorAtivo.Tipo.CAOS:
			for sub in mod.sub_modificadores:
				bonus += _bonus_de_um_modificador(sub)

	if modificadores.size() > 1:
		bonus += float(modificadores.size() - 1) * BONUS_COMBO_POR_MODIFICADOR_EXTRA

	return 1.0 + bonus


static func _bonus_de_um_modificador(mod: ModificadorAtivo) -> float:
	var taxa := TAXA_BONUS_T1
	match tier_do_tipo(mod.tipo):
		2:
			taxa = TAXA_BONUS_T2
		3:
			taxa = TAXA_BONUS_T3
	return float(mod.nivel) * taxa


static func obter_nivel(modificadores: Array[ModificadorAtivo], tipo: int) -> int:
	for mod in modificadores:
		if mod.tipo == tipo:
			return mod.nivel
		if mod.tipo == ModificadorAtivo.Tipo.CAOS:
			for sub in mod.sub_modificadores:
				if sub.tipo == tipo:
					return sub.nivel
	return 0


static func tem_modificador(modificadores: Array[ModificadorAtivo], tipo: int) -> bool:
	return obter_nivel(modificadores, tipo) > 0


static func texto_badges(modificadores: Array[ModificadorAtivo]) -> String:
	if modificadores.is_empty():
		return ""
	var textos: Array[String] = []
	for mod in modificadores:
		if mod.tipo == ModificadorAtivo.Tipo.CAOS:
			textos.append("%s (%s)" % [mod.nome_exibicao(), ", ".join(mod.sub_modificadores.map(func(s): return s.nome_exibicao()))])
		else:
			textos.append("%s %d" % [mod.nome_exibicao(), mod.nivel])
	return " | ".join(textos)
