class_name BancoDeTrabalhos
extends RefCounted

# =====================================================================
# BancoDeTrabalhos
# ---------------------------------------------------------------------
# Índices de capítulo (ConteudoLivro.CAPITULOS):
#   0 Golpes por Mensagem          5 Engenharia Social
#   1 Fraudes Financeiras          6 Segurança Física
#   2 Identidade Falsa             7 Contas e Acesso
#   3 Sites e Downloads Maliciosos 8 Sistemas e Redes
#   4 Malware                      9 Privacidade e Dados
#
# Grid padrão: 3 colunas x 5 linhas. Índice = linha * 3 + coluna:
#    0  1  2
#    3  4  5
#    6  7  8
#    9 10 11
#   12 13 14
#
# ATENÇÃO: preload() dá erro se o arquivo não existir. Os 8 sprites
# novos precisam estar em res://Sprites/Trabalhos/ com os nomes abaixo
# (480x320, PNG) antes de abrir o projeto.
# =====================================================================

static func criar_todos() -> Array[TrabalhoInspecao]:
	return [
		_criar_trabalho_site_malicioso(),
		_criar_trabalho_remover_scareware(),
		_criar_trabalho_ransomware(),
		_criar_trabalho_encomenda_retida(),
		_criar_trabalho_boleto_estranho(),
		_criar_trabalho_login_clonado(),
		_criar_trabalho_pendrive_esquecido(),
		_criar_trabalho_mesa_sem_dono(),
		_criar_trabalho_cadastro_fragil(),
		_criar_trabalho_cafe_com_wifi(),
		_criar_trabalho_foto_primeiro_dia(),
	]


# Monta um trabalho com 1 alvo suspeito (grid 3x5 padrão).
static func _montar(titulo: String, descricao: String, recompensa: int, imagem: Texture2D, quadrantes: Array[int], capitulo: int, dica: String) -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = titulo
	trabalho.descricao = descricao
	trabalho.recompensa_base = recompensa
	trabalho.imagem_site = imagem
	trabalho.linhas_grid = 5
	trabalho.colunas_grid = 3

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.quadrantes = quadrantes
	suspeito.capitulo_relacionado = capitulo
	suspeito.dica = dica

	trabalho.alvos = [suspeito]
	return trabalho


# ---------------------------------------------------------------------
# TRABALHOS ANTIGOS (capitulo_relacionado já na numeração nova)
# ---------------------------------------------------------------------
static func _criar_trabalho_site_malicioso() -> TrabalhoInspecao:
	return _montar(
		"Site duvidoso",
		"Cliente pediu para investigar o site.",
		150,
		preload("res://Sprites/site_falso_1.png"),
		[0],
		3,
		"O nome do site não bate com o nome da url!"
	)


static func _criar_trabalho_remover_scareware() -> TrabalhoInspecao:
	return _montar(
		"Alerta estranho",
		"O usuário recebeu um alerta assustador de vírus no navegador e quase baixou uma 'ferramenta de segurança'.",
		150,
		preload("res://Sprites/tela_trabalho_scareware.png"),
		[7, 10],
		3,
		"Aquele botão verde 'mais popular' promete resolver tudo rápido demais — sites legítimos de segurança não empurram um único download com tanta pressa e destaque."
	)


static func _criar_trabalho_ransomware() -> TrabalhoInspecao:
	var trabalho := _montar(
		"Remover Ransomware",
		"Os arquivos do usuário foram criptografados e uma nota de resgate apareceu na tela, exigindo pagamento em Bitcoin.",
		200,
		preload("res://Sprites/tela_trabalho_ramsonware.png"),
		[4],
		4,
		"Pagar o resgate não garante que você vai recuperar os arquivos — e só financia o próximo ataque. A defesa de verdade é ter backup feito antes disso acontecer."
	)
	trabalho.linhas_grid = 3
	trabalho.colunas_grid = 3
	return trabalho


# ---------------------------------------------------------------------
# TRABALHOS NOVOS — um por capítulo sem cobertura
# Quadrantes calibrados pelos prompts; CONFIRMAR traçando o grid em
# cada imagem final e ajustar aqui se o elemento caiu em outro lugar.
# ---------------------------------------------------------------------

# Cap. 0 — Golpes por Mensagem (Smishing). Link azul na bolha, centro.
static func _criar_trabalho_encomenda_retida() -> TrabalhoInspecao:
	return _montar(
		"Encomenda retida",
		"Uma funcionária recebeu uma mensagem no celular dizendo que sua encomenda ficou retida e que ela precisa pagar uma taxa pequena em até 24h. Ela quer saber se é seguro tocar no link.",
		150,
		preload("res://Sprites/Trabalhos/encomenda_retida.jpg"),
		[10],
		0,
		"A transportadora de verdade não cobra taxa por mensagem de celular, e esse link comprido esconde para onde você vai parar."
	)


# Cap. 1 — Fraudes Financeiras (Pix/boleto falso). Campo do beneficiário.
static func _criar_trabalho_boleto_estranho() -> TrabalhoInspecao:
	return _montar(
		"Boleto estranho",
		"O financeiro recebeu o boleto de um fornecedor, mas o valor parece diferente do combinado. Antes de pagar, pediram uma segunda opinião.",
		200,
		preload("res://Sprites/Trabalhos/boleto_estranho.jpg"),
		[3,6],
		1,
		"Confira para quem o dinheiro vai de fato, não só o valor e o visual do boleto. O nome do beneficiário tem algo trocado."
	)


# Cap. 2 — Identidade Falsa (Typosquatting). Barra de endereço, topo.
static func _criar_trabalho_login_clonado() -> TrabalhoInspecao:
	return _montar(
		"Login clonado",
		"Um colaborador digitou o endereço do portal do banco com pressa e caiu numa tela de login quase idêntica à original. Ele ainda não enviou a senha, mas ficou desconfiado.",
		150,
		preload("res://Sprites/Trabalhos/login_clonado.jpg"),
		[0,1],
		2,
		"Leia o endereço letra por letra. Um golpista só precisa que você não repare em uma letra trocada."
	)


# Cap. 5 — Engenharia Social (Baiting). Pendrive no canto inferior direito.
static func _criar_trabalho_pendrive_esquecido() -> TrabalhoInspecao:
	return _montar(
		"Pendrive esquecido",
		"Um pendrive com uma etiqueta que sugere dinheiro apareceu na mesa da recepção. Um colega já estava com ele na mão, pronto para conectar no computador.",
		150,
		preload("res://Sprites/Trabalhos/pendrive_esquecido.png"),
		[14],
		5,
		"Curiosidade é a isca. Nunca se conecta um dispositivo quando você não sabe de onde ele veio."
	)


# Cap. 6 — Segurança Física (Tela desbloqueada). Post-it ao lado do monitor.
static func _criar_trabalho_mesa_sem_dono() -> TrabalhoInspecao:
	return _montar(
		"Mesa sem dono",
		"Durante a ronda, a segurança encontrou um computador ligado e logado, com a cadeira vazia. Aponte o que deixou a empresa vulnerável.",
		150,
		preload("res://Sprites/Trabalhos/mesa_sem_dono.jpg"),
		[8],
		6,
		"O problema não está só no computador deixado aberto, está no papelzinho colado ao lado dele."
	)


# Cap. 7 — Contas e Acesso (Senha fraca). Campo de senha aceito.
static func _criar_trabalho_cadastro_fragil() -> TrabalhoInspecao:
	return _montar(
		"Cadastro frágil",
		"A equipe lançou um formulário de cadastro interno e notou colaboradores criando contas com senhas muito curtas. Ache o que o formulário está deixando passar.",
		150,
		preload("res://Sprites/Trabalhos/cadastro_fragil.jpg"),
		[7],
		7,
		"O formulário aceitou uma senha curtinha, com a barra de força quase vazia. O sistema deveria barrar isso antes de o cadastro terminar."
	)


# Cap. 8 — Sistemas e Redes (Wi-Fi público). Rede aberta com sinal máximo.
static func _criar_trabalho_cafe_com_wifi() -> TrabalhoInspecao:
	return _montar(
		"Café com Wi-Fi",
		"Um vendedor em viagem precisa enviar um relatório e encontrou uma rede aberta, sem senha, com um sinal forte demais para quem está longe do balcão. Ele quer saber se pode conectar.",
		200,
		preload("res://Sprites/Trabalhos/cafe_com_wifi.jpg"),
		[6,7],
		8,
		"Rede aberta não protege nada do que trafega nela, e qualquer um pode criar uma só para atrair gente. Sinal forte demais e sem cadeado é motivo para desconfiar."
	)


# Cap. 9 — Privacidade e Dados (Oversharing). Crachá (10) + monitor (5).
static func _criar_trabalho_foto_primeiro_dia() -> TrabalhoInspecao:
	return _montar(
		"Foto de primeiro dia",
		"Uma estagiária postou uma selfie animada comemorando o primeiro dia de trabalho. O time de segurança pediu para você ver o que a foto entrega sem querer.",
		150,
		preload("res://Sprites/Trabalhos/foto_primeiro_dia.jpg"),
		[8, 11],
		9,
		"Olhe para o fundo da foto e para o que está pendurado no peito, não para o sorriso. Tem informação da empresa à vista."
	)
