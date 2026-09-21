class_name AreaAlvo
extends Area2D

var dados: AlvoInspecao
var tamanho_quadrante: Vector2 = Vector2.ZERO
var foi_encontrado: bool = false
var ignorado: bool = false
var ja_inspecionado_negativo: bool = false
var eh_armadilha: bool = false
var eh_chamariz: bool = false
