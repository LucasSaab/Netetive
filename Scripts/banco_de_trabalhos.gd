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
		_criar_trabalho_site_malicioso(),
		_criar_trabalho_remover_ransomware(),
		_criar_trabalho_ransomware(),
		_criar_trabalho_phishing(),
	]


# ---------------------------------------------------------------------
# TODO: trocar "imagem_site" por preload da arte real quando estiver pronta.
# TODO: ajustar quadrante/altura_real conforme a arte final do site.
# ---------------------------------------------------------------------
static func _criar_trabalho_site_malicioso() -> TrabalhoInspecao:
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

static func _criar_trabalho_remover_ransomware() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Alerta estranho"
	trabalho.descricao = "O usuário recebeu um alerta assustador de vírus no navegador e quase baixou uma 'ferramenta de segurança'."
	trabalho.recompensa_base = 150
	trabalho.imagem_site = preload("res://Sprites/tela_trabalho_scareware.png")
	trabalho.linhas_grid = 5

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.quadrante = 10        # linha 3, coluna 1
	suspeito.altura_real = 60.0   
	suspeito.capitulo_relacionado = 5  # Scareware
	suspeito.dica = "Aquele botão verde 'mais popular' promete resolver tudo rápido demais — sites legítimos de segurança não empurram um único download com tanta pressa e destaque."


	trabalho.alvos = [suspeito]
	return trabalho

static func _criar_trabalho_ransomware() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Remover Ransomware"
	trabalho.descricao = "Os arquivos do usuário foram criptografados e uma nota de resgate apareceu na tela, exigindo pagamento em Bitcoin."
	trabalho.recompensa_base = 200
	trabalho.imagem_site = preload("res://Sprites/tela_trabalho_ramsonware.png")
	trabalho.linhas_grid = 5

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.quadrante = 10       # linha 3, coluna 1 (centro) — botão "COMO PAGAR"
	suspeito.altura_real = 270.0  # cobre o bloco do resgate inteiro — calibrar
	suspeito.capitulo_relacionado = 3  # Ransomware
	suspeito.dica = "Pagar o resgate não garante que você vai recuperar os arquivos — e só financia o próximo ataque. A defesa de verdade é ter backup feito antes disso acontecer."

	trabalho.alvos = [suspeito]
	return trabalho

static func _criar_trabalho_phishing() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Email malicioso"
	trabalho.descricao = "Cliente enviou um email que recebeu."
	trabalho.recompensa_base = 350
	trabalho.imagem_site = preload("res://Sprites/emailFalsoPhishing.png")
	trabalho.linhas_grid = 5
	
	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.quadrante = 10        # linha 3, coluna 1 (centro) — IP DE OUTRO PAIS
	suspeito.altura_real = 60.0   # em recalibração
	suspeito.capitulo_relacionado = 0  # Phising, por exemplo
	suspeito.dica = "Email acessado por IP de outro pais"
	
	trabalho.alvos = [suspeito]
	return trabalho
