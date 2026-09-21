class_name AlvoInspecao
extends Resource

enum Tipo { SUSPEITO, NEUTRO }

@export var tipo: Tipo = Tipo.NEUTRO
@export var quadrantes: Array[int] = [] 
@export var capitulo_relacionado: int = -1
@export var dica: String = ""        
