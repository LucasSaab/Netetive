class_name BancoDeTrabalhos
extends RefCounted

# =====================================================================
# BancoDeTrabalhos
# ---------------------------------------------------------------------
# Módulo isolado só pra montar os TrabalhoInspecao do jogo. Fica de fora
# de DadosJogo.gd de propósito — DadosJogo cuida de ESTADO (dinheiro,
# agenda do dia, resultados pendentes); este arquivo cuida só de DADOS
# (a definição de cada trabalho em si).
#
# Só entram aqui trabalhos já migrados pro sistema de grid (quadrante +
# altura_real em AlvoInspecao). Trabalhos sem arte calibrada ainda ficam
# de fora até terem imagem real — adicionar de volta quando a arte
# estiver pronta e os índices de quadrante forem calibrados.
# =====================================================================

static func criar_todos() -> Array[TrabalhoInspecao]:
	return [
		_criar_trabalho_cavalo_de_troia(),
		_criar_trabalho_phishing(),
	]


# ---------------------------------------------------------------------
# TODO: trocar "imagem_site" por preload da arte real quando estiver pronta.
# TODO: ajustar quadrante/altura_real conforme a arte final do site.
# ---------------------------------------------------------------------
static func _criar_trabalho_cavalo_de_troia() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Site duvidoso"
	trabalho.descricao = "Cliente pediu para invesstigar o site."
	trabalho.recompensa_base = 150
	trabalho.imagem_site = preload("res://Sprites/site_falso_1.png")
	trabalho.linhas_grid = 5

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.quadrante = 0        # em recalibração
	suspeito.altura_real = 60.0   # em recalibração
	suspeito.capitulo_relacionado = 2  # Ransomware, por exemplo
	suspeito.dica = "O nome do site não bate com o nome da url!"

	trabalho.alvos = [suspeito]
	return trabalho

static func _criar_trabalho_phishing() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Email malicioso"
	trabalho.descricao = "Cliente enviou um email que recebeu."
	trabalho.recompensa_base = 150
	trabalho.imagem_site = preload("res://Sprites/emailFalsoPhishing.png")
	trabalho.linhas_grid = 5

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.quadrante = 10        # em recalibração
	suspeito.altura_real = 60.0   # em recalibração
	suspeito.capitulo_relacionado = 0  # Phising, por exemplo
	suspeito.dica = "Email acessado por IP de outro pais"

	trabalho.alvos = [suspeito]
	return trabalho
