class_name CalculadoraUpkeep
extends RefCounted

# =====================================================================
# CalculadoraUpkeep
# ---------------------------------------------------------------------
# Função pura que soma o upkeep diário de todos os upgrades ativos.
# Isolada num arquivo próprio pra RelatorioDia não precisar conhecer a
# fórmula de cada categoria — só chama calcular_total() e desconta.
#
# Upkeep do Assistente = upkeep_atual(Treinamento) × quantidade de
# assistentes (linha Quantidade não tem upkeep próprio, ver
# banco_de_upgrades.gd). Upkeep da IA = soma fixa das duas linhas
# (Capacidade + Eficiência), sem multiplicação — só existe 1 IA.
#
# static func — sem estado, sem Node na árvore.
# =====================================================================

static func calcular_total() -> int:
	return _upkeep_assistente() + _upkeep_ia_capacidade() + _upkeep_ia_eficiencia()


static func _upkeep_assistente() -> int:
	var linha_treinamento: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_TREINAMENTO)
	if linha_treinamento == null or linha_treinamento.tier_atual <= 0:
		return 0   # nenhum assistente contratado ainda, sem upkeep

	var linha_quantidade: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_QUANTIDADE)
	var quantidade := 1   # Treinamento tier 1 já desbloqueia o 1º assistente, mesmo sem nenhum tier de Quantidade
	if linha_quantidade != null:
		quantidade = int(linha_quantidade.valor_efeito_atual(1.0))

	return int(linha_treinamento.upkeep_atual() * quantidade)


static func _upkeep_ia_capacidade() -> int:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_IA_CAPACIDADE)
	if linha == null:
		return 0
	return int(linha.upkeep_atual())


static func _upkeep_ia_eficiencia() -> int:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_IA_EFICIENCIA)
	if linha == null:
		return 0
	return int(linha.upkeep_atual())
