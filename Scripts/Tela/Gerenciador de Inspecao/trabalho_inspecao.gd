class_name TrabalhoInspecao
extends Resource

# =====================================================================
# TrabalhoInspecao
# ---------------------------------------------------------------------
# Empacota tudo que uma rodada de inspeção precisa: os textos exibidos
# no PainelTrabalho, a imagem do site mostrada na Tela, e a lista de
# alvos (AlvoInspecao) alinhada a essa imagem específica.
#
# Substitui/evolui as entradas de DadosJogo.banco_de_trabalhos.
# =====================================================================

@export var titulo: String
@export var descricao: String
@export var recompensa_base: int = 0

@export var imagem_site: Texture2D
@export var alvos: Array[AlvoInspecao] = []
