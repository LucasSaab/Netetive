class_name AlvoInspecao
extends Resource

enum Tipo { SUSPEITO, NEUTRO }

@export var tipo: Tipo = Tipo.NEUTRO
@export var posicao: Vector2
@export var tamanho: Vector2 = Vector2(80, 80)
@export var capitulo_relacionado: int = -1
