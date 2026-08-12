class_name AreaAlvo
extends Area2D

var dados: AlvoInspecao
var tamanho_quadrante: Vector2 = Vector2.ZERO   # calculado pelo grid, não vem do Resource
var foi_encontrado: bool = false                # true quando um alvo SUSPEITO é encontrado
var ignorado: bool = false                      # alterna via botão Ignorar/Designorar no popup
var ja_inspecionado_negativo: bool = false       # true quando um NEUTRO já foi checado sem nada
