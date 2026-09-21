class_name TrabalhoInspecao
extends Resource

@export var titulo: String
@export var descricao: String
@export var recompensa_base: int = 0

@export var dificuldade: int = 1
@export var recompensa_fama: int = 10

@export var imagem_site: Texture2D
@export var alvos: Array[AlvoInspecao] = []

@export var linhas_grid: int = 5     # mínimo efetivo 3 — aplicado em GerenciadorInspecao.montar_alvos()
@export var colunas_grid: int = 3    # mínimo efetivo 3 — mesma regra de linhas_grid
