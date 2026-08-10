class_name AreaAlvo
extends Area2D

# =====================================================================
# AreaAlvo
# ---------------------------------------------------------------------
# Nó real criado dinamicamente pelo GerenciadorInspecao para representar,
# na cena, um AlvoInspecao. A propriedade `dados` é o que amarra este
# nó (posição/colisão) ao Resource (tipo/capítulo).
# =====================================================================

var dados: AlvoInspecao
var foi_encontrado: bool = false        # true quando um alvo SUSPEITO é encontrado
var ignorado: bool = false
var ja_inspecionado_negativo: bool = false  # true se o jogador marcou "limpo" sem diagnosticar
