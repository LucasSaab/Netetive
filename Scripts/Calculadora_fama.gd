class_name CalculadoraFama
extends RefCounted

# =====================================================================
# CalculadoraFama
# ---------------------------------------------------------------------
# Função pura que converte fama_jogador na quantidade de trabalhos que
# aparecem no dia. Isolada aqui pra GerenciadorExpediente não precisar
# conhecer a fórmula — só chama calcular_quantidade_trabalhos_dia().
#
# Curva: base + floor(sqrt(fama) * FATOR_CRESCIMENTO).
# Raiz quadrada dá exatamente o formato pedido, sem precisar de nenhuma
# lógica condicional: a cada ponto de fama investido, o ganho marginal
# de trabalhos novos diminui sozinho (derivada de sqrt(x) cai conforme
# x cresce) — pouca fama já rende crescimento rápido, fama alta precisa
# de cada vez mais pontos pra render mais 1 trabalho.
# =====================================================================

const TRABALHOS_BASE_PADRAO := 6
const FATOR_CRESCIMENTO := 1.0   # multiplica sqrt(fama); ajustar aqui pra calibrar a curva


static func calcular_quantidade_trabalhos_dia(fama: int, base: int = TRABALHOS_BASE_PADRAO) -> int:
	var fama_efetiva : int = max(0, fama)
	var bonus := int(floor(sqrt(float(fama_efetiva)) * FATOR_CRESCIMENTO))
	return base + bonus
