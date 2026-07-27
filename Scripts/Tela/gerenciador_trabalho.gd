extends Node

@export var painel_trabalho: Panel


func _on_lembrete_foi_clicado(
	trabalho: TrabalhoInspecao,
	titulo: String,
	descricao: String,
	recompensa: int,
	lembrete_clicado: TextureButton
) -> void:
	print("MÓDULO TRABALHO: Lembrete clicado! Título: ", titulo)
	if painel_trabalho != null:
		painel_trabalho.abrir(trabalho, lembrete_clicado, titulo, descricao, recompensa)


func _on_trabalho_iniciado(recompensa: int) -> void:
	print("MÓDULO TRABALHO: Trabalho aceito! Recompensa: R$ ", recompensa)
