class_name TierUpgrade
extends Resource

# =====================================================================
# TierUpgrade
# ---------------------------------------------------------------------
# Um degrau individual dentro de uma LinhaUpgrade. O SIGNIFICADO de
# valor_efeito/valor_efeito_secundario muda dependendo de qual linha
# está usando esse tier — quem interpreta é o script que consome a
# LinhaUpgrade (ex: gerenciador_assistente.gd), não este arquivo.
#
# Uso por linha (referência rápida, ver banco_de_upgrades.gd):
#   PC                        → valor_efeito = tempo do popup em segundos
#   Assistente — Treinamento  → valor_efeito = minutos simulados por
#                                 trabalho | valor_efeito_secundario =
#                                 taxa de sucesso (0.0–1.0) | upkeep =
#                                 custo diário POR ASSISTENTE
#   Assistente — Quantidade   → valor_efeito = nº de assistentes
#                                 simultâneos (sem upkeep próprio)
#   IA — Capacidade           → valor_efeito = trabalhos processados
#                                 por noite | upkeep = custo diário fixo
#   IA — Eficiência           → valor_efeito = % da recompensa normal
#                                 entregue pela IA (0.0–1.0) | upkeep =
#                                 custo diário fixo
# =====================================================================

@export var preco: int = 0
@export var valor_efeito: float = 0.0
@export var valor_efeito_secundario: float = 0.0
@export var upkeep: float = 0.0
@export var descricao: String = ""
