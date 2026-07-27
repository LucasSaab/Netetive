class_name AlvoInspecao
extends Resource

# =====================================================================
# AlvoInspecao
# ---------------------------------------------------------------------
# Dado puro que representa UM alvo clicável dentro do módulo de
# inspeção: se é suspeito ou neutro, onde fica e a que tamanho,
# e (opcionalmente) a que capítulo do LivroDicas ele se relaciona.
# Não tem comportamento — só é lido pelo GerenciadorInspecao.
# =====================================================================

enum Tipo { SUSPEITO, NEUTRO }

@export var tipo: Tipo = Tipo.NEUTRO
@export var posicao: Vector2
@export var tamanho: Vector2 = Vector2(80, 80)
@export var capitulo_relacionado: int = -1  # índice em ConteudoLivro.PAGINAS, -1 = nenhum
