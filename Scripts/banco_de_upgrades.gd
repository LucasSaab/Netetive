class_name BancoDeUpgrades
extends RefCounted

# =====================================================================
# BancoDeUpgrades
# ---------------------------------------------------------------------
# Módulo isolado só pra montar as LinhaUpgrade do jogo, no mesmo
# espírito de banco_de_trabalhos.gd — fica de fora de DadosJogo.gd de
# propósito. DadosJogo guarda as instâncias retornadas por criar_todas()
# e cuida do PROGRESSO (tier_atual muda em runtime); este arquivo só
# define os valores fixos de preço/efeito/upkeep.
#
# static func — não precisa ser Autoload, acessível globalmente pelo
# class_name sozinho.
# =====================================================================

const CHAVE_PC := "pc"
const CHAVE_ASSISTENTE_TREINAMENTO := "assistente_treinamento"
const CHAVE_ASSISTENTE_QUANTIDADE := "assistente_quantidade"
const CHAVE_IA_CAPACIDADE := "ia_capacidade"
const CHAVE_IA_EFICIENCIA := "ia_eficiencia"


# Devolve um Dictionary[String, LinhaUpgrade] com as 5 linhas, prontas
# pra DadosJogo guardar como estado. Chamado uma vez em DadosJogo._ready().
static func criar_todas() -> Dictionary:
	var linhas: Dictionary = {}
	linhas[CHAVE_PC] = _criar_linha_pc()
	linhas[CHAVE_ASSISTENTE_TREINAMENTO] = _criar_linha_assistente_treinamento()
	linhas[CHAVE_ASSISTENTE_QUANTIDADE] = _criar_linha_assistente_quantidade()
	linhas[CHAVE_IA_CAPACIDADE] = _criar_linha_ia_capacidade()
	linhas[CHAVE_IA_EFICIENCIA] = _criar_linha_ia_eficiencia()
	return linhas


# ---------------------------------------------------------------------
# PC — linha única, sem upkeep. Base (sem upgrade) = 4.0s de popup.
# Tier 4 zera o tempo (verificação instantânea).
# ---------------------------------------------------------------------
static func _criar_linha_pc() -> LinhaUpgrade:
	var linha := LinhaUpgrade.new()
	linha.chave = CHAVE_PC
	linha.nome = "PC"
	linha.tiers = [
		_tier(500, 3.0, 0.0, 0.0, "Popup de verificação: 4s -> 3s"),
		_tier(900, 2.0, 0.0, 0.0, "Popup de verificação: 3s -> 2s"),
		_tier(1500, 1.0, 0.0, 0.0, "Popup de verificação: 2s -> 1s"),
		_tier(2500, 0.0, 0.0, 0.0, "Popup de verificação: instantâneo"),
	]
	return linha

# ---------------------------------------------------------------------
# Assistente — Treinamento — bloqueada até Quantidade tier 1 (agora é a
# linha de ENTRADA que contrata o 1º assistente). valor_efeito = minutos
# simulados/trabalho, valor_efeito_secundario = taxa de sucesso, upkeep
# = custo diário POR ASSISTENTE (multiplicado pela quantidade da linha
# Quantidade em outro lugar).
# ---------------------------------------------------------------------
static func _criar_linha_assistente_treinamento() -> LinhaUpgrade:
	var linha := LinhaUpgrade.new()
	linha.chave = CHAVE_ASSISTENTE_TREINAMENTO
	linha.nome = "Assistente — Treinamento"
	linha.chave_pre_requisito = CHAVE_ASSISTENTE_QUANTIDADE
	linha.tiers = [
		_tier(800, 120.0, 0.70, 40.0, "120 min/trabalho, 70% de sucesso"),
		_tier(1400, 105.0, 0.80, 55.0, "105 min/trabalho, 80% de sucesso"),
		_tier(2200, 90.0, 0.90, 75.0, "90 min/trabalho, 90% de sucesso"),
		_tier(3200, 75.0, 1.00, 100.0, "75 min/trabalho, 100% de sucesso"),
	]
	return linha
 
 
# ---------------------------------------------------------------------
# Assistente — Quantidade — linha de ENTRADA (sem pré-requisito), quem
# desbloqueia o acesso ao Treinamento. Sem upkeep próprio (o custo já é
# coberto pelo Treinamento × quantidade).
# ---------------------------------------------------------------------
static func _criar_linha_assistente_quantidade() -> LinhaUpgrade:
	var linha := LinhaUpgrade.new()
	linha.chave = CHAVE_ASSISTENTE_QUANTIDADE
	linha.nome = "Assistente — Quantidade"
	linha.tiers = [
		_tier(1200, 2.0, 0.0, 0.0, "2 assistentes simultâneos"),
		_tier(2000, 3.0, 0.0, 0.0, "3 assistentes simultâneos"),
		_tier(3000, 4.0, 0.0, 0.0, "4 assistentes simultâneos"),
		_tier(4200, 5.0, 0.0, 0.0, "5 assistentes simultâneos"),
	]
	return linha


# ---------------------------------------------------------------------
# IA — Capacidade — linha de entrada (tier 1 desbloqueia a IA).
# valor_efeito = trabalhos processados por noite. Upkeep fixo por tier
# (não multiplica por nada — só existe 1 IA).
# ---------------------------------------------------------------------
static func _criar_linha_ia_capacidade() -> LinhaUpgrade:
	var linha := LinhaUpgrade.new()
	linha.chave = CHAVE_IA_CAPACIDADE
	linha.nome = "IA — Capacidade"
	linha.tiers = [
		_tier(1400, 1.0, 0.0, 60.0, "1 trabalho/noite"),
		_tier(2400, 2.0, 0.0, 100.0, "2 trabalhos/noite"),
		_tier(3600, 3.0, 0.0, 150.0, "3 trabalhos/noite"),
		_tier(5000, 4.0, 0.0, 210.0, "4 trabalhos/noite"),
	]
	return linha


# ---------------------------------------------------------------------
# IA — Eficiência — bloqueada até IA Capacidade tier 1. valor_efeito =
# % da recompensa normal entregue pela IA (0.0–1.0). Base sem essa
# linha = 0.35 (35%), aplicada via valor_base em valor_efeito_atual().
# ---------------------------------------------------------------------
static func _criar_linha_ia_eficiencia() -> LinhaUpgrade:
	var linha := LinhaUpgrade.new()
	linha.chave = CHAVE_IA_EFICIENCIA
	linha.nome = "IA — Eficiência"
	linha.chave_pre_requisito = CHAVE_IA_CAPACIDADE
	linha.tiers = [
		_tier(1000, 0.50, 0.0, 45.0, "Recompensa entregue pela IA: 35% -> 50%"),
		_tier(1800, 0.65, 0.0, 70.0, "50% -> 65%"),
		_tier(2800, 0.80, 0.0, 100.0, "65% -> 80%"),
		_tier(4000, 0.95, 0.0, 140.0, "80% -> 95%"),
	]
	return linha


static func _tier(preco: int, valor_efeito: float, valor_efeito_secundario: float, upkeep: float, descricao: String) -> TierUpgrade:
	var t := TierUpgrade.new()
	t.preco = preco
	t.valor_efeito = valor_efeito
	t.valor_efeito_secundario = valor_efeito_secundario
	t.upkeep = upkeep
	t.descricao = descricao
	return t
