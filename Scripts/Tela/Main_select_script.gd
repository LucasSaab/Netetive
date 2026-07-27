extends Node2D

var cena_livro = preload("res://Scenes/LivroInstrucao.tscn")

# Caminhos baseados na estrutura documentada do projeto. Se algum desses
# não bater com a árvore real da sua cena Tela.tscn, ajuste o caminho
# (ou troque por @export e arraste o nó no Inspetor, que é mais seguro
# contra mudanças futuras na árvore).
@onready var painel_trabalho: Panel = $PainelTrabalho
@onready var gerenciador_inspecao: Node = $ModuloInspecao/AreaCliqueInspecao/GerenciadorInspecao
@onready var site_textura: TextureRect = $Sprite2D/TextureRect


func _ready() -> void:
	print("Cena iniciada. Os gerenciadores estão cuidando de tudo!")

	if painel_trabalho != null:
		painel_trabalho.trabalho_aceito.connect(_on_trabalho_aceito)
	else:
		push_warning("Main_select_script: painel_trabalho não encontrado.")

	# TEMPORÁRIO: o sistema de trabalho (Lembrete/PainelTrabalho) vai ser
	# remodelado depois. Enquanto isso, monta o primeiro trabalho direto,
	# sem depender do post-it, para poder testar/ajustar os alvos.
	# Remover esta chamada quando o novo sistema de trabalho estiver pronto.
	_testar_montagem_direta()


func _testar_montagem_direta() -> void:
	if DadosJogo.banco_de_trabalhos.size() == 0:
		push_warning("Main_select_script (teste): banco_de_trabalhos vazio.")
		return

	var trabalho_teste: TrabalhoInspecao = DadosJogo.banco_de_trabalhos[0]

	if site_textura != null and trabalho_teste.imagem_site != null:
		site_textura.texture = trabalho_teste.imagem_site

	if gerenciador_inspecao != null and gerenciador_inspecao.has_method("montar_alvos"):
		gerenciador_inspecao.montar_alvos(trabalho_teste)
	else:
		push_warning("Main_select_script (teste): gerenciador_inspecao não encontrado ou sem montar_alvos().")


# Chamado quando o jogador clica em "Aceitar" no PainelTrabalho.
# Aqui é o único lugar que conhece tanto o PainelTrabalho quanto o
# GerenciadorInspecao — por isso a ponte entre os dois fica aqui,
# e não dentro de nenhum dos dois scripts.
func _on_trabalho_aceito(trabalho: TrabalhoInspecao, recompensa: int) -> void:
	print("Trabalho aceito! Recompensa: R$ ", recompensa)

	if trabalho == null:
		push_warning("Main_select_script: trabalho_aceito chegou com trabalho nulo.")
		return

	if site_textura != null and trabalho.imagem_site != null:
		site_textura.texture = trabalho.imagem_site

	if gerenciador_inspecao != null and gerenciador_inspecao.has_method("montar_alvos"):
		gerenciador_inspecao.montar_alvos(trabalho)
	else:
		push_warning("Main_select_script: gerenciador_inspecao não encontrado ou sem montar_alvos().")


func _on_btn_abrir_livro_pressed() -> void:
	var instancia_livro = cena_livro.instantiate()
	add_child(instancia_livro)
	instancia_livro.abrir_livro()


func _on_botao_inspecionar_pressed() -> void:
	pass # A lógica de inspeção já mora inteiramente em GerenciadorInspecao.
