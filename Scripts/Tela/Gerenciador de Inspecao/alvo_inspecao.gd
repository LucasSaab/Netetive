class_name AlvoInspecao
extends Resource

enum Tipo { SUSPEITO, NEUTRO }

@export var tipo: Tipo = Tipo.NEUTRO
@export var quadrante: int = 0
@export var altura_real: float = 0.0
@export var capitulo_relacionado: int = -1
@export var dica: String = ""   # texto curto mostrado pelo botão Investigar
