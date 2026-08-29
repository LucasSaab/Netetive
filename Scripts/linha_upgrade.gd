class_name LinhaUpgrade
extends Resource

# =====================================================================
# LinhaUpgrade
# ---------------------------------------------------------------------
# Uma progressão sequencial de TierUpgrade (ex: "Assistente — Treinamento").
# Guarda tanto a DEFINIÇÃO (tiers, pré-requisito) quanto o PROGRESSO em
# runtime (tier_atual) — diferente de BancoDeTrabalhos/TrabalhoInspecao,
# aqui não faz sentido separar dado de estado, porque cada jogador só
# tem UMA instância de cada linha (não é sorteada nem repetida).
#
# tier_atual = 0   → nenhum tier comprado ainda (linha "no zero")
# tier_atual = N   → já comprou os tiers[0..N-1]; tiers[N] é o próximo
#                    disponível para compra (se existir)
# =====================================================================

@export var chave: String = ""                # identificador único, ex: "assistente_treinamento"
@export var nome: String = ""                  # nome de exibição na UI
@export var tiers: Array[TierUpgrade] = []
@export var chave_pre_requisito: String = ""   # vazio = sem pré-requisito; senão exige tier_atual >= 1 na linha referenciada (ver banco_de_upgrades.gd pelas chaves)

var tier_atual: int = 0


func esta_no_maximo() -> bool:
	return tier_atual >= tiers.size()


# Tier ainda não comprado, disponível para compra agora (null se já no máximo).
func proximo_tier() -> TierUpgrade:
	if esta_no_maximo():
		return null
	return tiers[tier_atual]


# Tier já comprado, pelo índice 0-based (null se esse índice ainda não foi comprado).
func tier_comprado(indice: int) -> TierUpgrade:
	if indice < 0 or indice >= tier_atual:
		return null
	return tiers[indice]


# Valor efetivo atual da linha, considerando o tier comprado mais recente.
# Se nada foi comprado ainda (tier_atual == 0), devolve valor_base — útil
# pra linhas onde o "estado sem upgrade" já tem um valor próprio (ex: PC
# começa em 4.0s antes do tier 1).
func valor_efeito_atual(valor_base: float = 0.0) -> float:
	if tier_atual <= 0:
		return valor_base
	return tiers[tier_atual - 1].valor_efeito


func valor_efeito_secundario_atual(valor_base: float = 0.0) -> float:
	if tier_atual <= 0:
		return valor_base
	return tiers[tier_atual - 1].valor_efeito_secundario


# Upkeep do tier atualmente comprado (0.0 se nenhum tier comprado ainda).
func upkeep_atual() -> float:
	if tier_atual <= 0:
		return 0.0
	return tiers[tier_atual - 1].upkeep
