class_name ConteudoLivro
extends RefCounted

# =====================================================================
# ConteudoLivro
# ---------------------------------------------------------------------
# CAPITULOS: estrutura nova, usada pelo LivroDicas.tscn.
#   capítulo -> subcapítulos -> duas partes fixas (reconhecer / proteger)
#
# O diagnóstico do jogo continua no nível do CAPÍTULO (10 opções).
# Subcapítulo é só detalhe de ensino e de relatório.
#
# Os textos de Phishing, Perfil Falso, Site Malicioso, Ransomware,
# Engenharia Social, Scareware, Wi-Fi Público, Atualização Ignorada,
# Permissões Excessivas e Vazamento de Dados vieram do antigo PAGINAS
# (campo descricao -> reconhecer, solucao -> proteger). O antigo
# ConteudoLivro.PAGINAS foi removido: DadosJogo.gd lê só CAPITULOS.
#
# Índices dos capítulos (0 a 9), na ordem abaixo:
#   0 Golpes por Mensagem          5 Engenharia Social
#   1 Fraudes Financeiras          6 Segurança Física
#   2 Identidade Falsa             7 Contas e Acesso
#   3 Sites e Downloads Maliciosos 8 Sistemas e Redes
#   4 Malware                      9 Privacidade e Dados
# =====================================================================

const CAPITULOS: Array = [
	# ---------------------------------------------------------- 0
	{
		"titulo": "Golpes por Mensagem",
		"resumo": "Golpes que chegam por e-mail, SMS, ligação ou aplicativo de mensagens e tentam fazer você agir com pressa, antes de pensar.",
		"subcapitulos": [
			{
				"titulo": "Phishing",
				"reconhecer": "Sabe aquele e-mail que parece ser do seu banco mas algo parece errado? Provavelmente é phishing. Olha sempre quem está mandando — o endereço do remetente costuma entregar o golpe. Link encurtado ou com nome estranho? Não clica. Mensagem com aquela urgência toda de 'sua conta será bloqueada em 24h'? Respira. É pressão psicológica pra você agir sem pensar.",
				"proteger": "Não clica em nenhum link. Não responde. Marca como spam e reporta pro time de segurança da empresa. Se tiver dúvida se é legítimo, entra em contato com a empresa pelo site oficial — nunca pelo contato que veio no e-mail suspeito.",
			},
			{
				"titulo": "Smishing",
				"reconhecer": "SMS de número desconhecido sobre encomenda retida, multa ou taxa pendente, com link encurtado e prazo curto.",
				"proteger": "Não toque no link. Consulte o rastreio no site da transportadora, bloqueie o número e denuncie.",
			},
			{
				"titulo": "Vishing",
				"reconhecer": "Ligação de suposto atendente do banco ou da empresa, com tom de urgência, pedindo dados, senhas ou que você transfira dinheiro para uma conta segura.",
				"proteger": "Desligue e ligue você mesmo para o número oficial. Nenhuma empresa séria pede senha ou código por telefone.",
			},
			{
				"titulo": "Golpe do código",
				"reconhecer": "Alguém, às vezes com a foto de um conhecido, pede o código de seis dígitos que chegou por SMS ou e-mail para confirmar algo.",
				"proteger": "Nunca compartilhe códigos de verificação. Ligue para o conhecido por outro canal para confirmar.",
			},
		],
	},
	# ---------------------------------------------------------- 1
	{
		"titulo": "Fraudes Financeiras",
		"resumo": "Golpes que miram diretamente o seu dinheiro ou o da empresa, usando pagamentos, boletos e promessas de lucro fácil.",
		"subcapitulos": [
			{
				"titulo": "Falso executivo (BEC)",
				"reconhecer": "E-mail ou mensagem do suposto diretor pedindo transferência urgente e sigilosa, com domínio ligeiramente diferente do da empresa.",
				"proteger": "Confirme o pedido por outro canal, como ligação ou conversa presencial, e siga sempre o processo oficial de pagamento.",
			},
			{
				"titulo": "Pix/boleto falso",
				"reconhecer": "Boleto com beneficiário diferente do esperado, valor alterado ou QR Code de Pix colado sobre o original.",
				"proteger": "Confira o nome do beneficiário antes de pagar e peça o boleto novamente pelo canal oficial se algo parecer estranho.",
			},
			{
				"titulo": "Falso investimento",
				"reconhecer": "Promessa de lucro alto e garantido, como 10% ao mês, com pressa para entrar e bônus por indicar amigos.",
				"proteger": "Desconfie de retorno garantido. Pesquise a empresa em fontes oficiais, como o site da CVM, antes de investir.",
			},
		],
	},
	# ---------------------------------------------------------- 2
	{
		"titulo": "Identidade Falsa",
		"resumo": "Pessoas, empresas e endereços que fingem ser quem não são para ganhar a sua confiança.",
		"subcapitulos": [
			{
				"titulo": "Perfil Falso",
				"reconhecer": "Chegou pedido de conexão de alguém que você não conhece? Dá uma olhada no perfil antes de aceitar. Foto genérica, sem postagens, criado há pouco tempo e já mandando mensagem pedindo alguma coisa — sinal vermelho. Perfis falsos existem pra coletar informação ou aplicar golpe. Na dúvida, não aceita.",
				"proteger": "Rejeita o pedido e reporta o perfil na plataforma. Se a pessoa alegar ser alguém que você conhece, confirma por outro canal — manda mensagem pro contato real pelo número que você já tem. Nunca confirma identidade pelo mesmo canal do suspeito.",
			},
			{
				"titulo": "Typosquatting",
				"reconhecer": "Endereço de site com letra trocada ou acrescentada, como gooogle.com, ou com letras parecidas, como rn no lugar de m.",
				"proteger": "Leia o endereço com calma antes de digitar dados e salve nos favoritos os sites que você usa.",
			},
			{
				"titulo": "Anúncio falso",
				"reconhecer": "Resultado patrocinado da busca que imita o site oficial, com endereço levemente diferente ou oferta boa demais.",
				"proteger": "Prefira acessar o site oficial pelos favoritos e confira o endereço antes de entrar com login ou pagamento.",
			},
			{
				"titulo": "Deepfake",
				"reconhecer": "Vídeo ou áudio de alguém conhecido com boca fora de sincronia, piscar estranho ou voz robótica, e um pedido urgente.",
				"proteger": "Confirme o pedido por outro canal e combine com familiares e colegas uma palavra de segurança.",
			},
		],
	},
	# ---------------------------------------------------------- 3
	{
		"titulo": "Sites e Downloads Maliciosos",
		"resumo": "Páginas e arquivos feitos para enganar você e instalar algo ruim ou roubar seus dados.",
		"subcapitulos": [
			{
				"titulo": "Site Malicioso",
				"reconhecer": "Antes de digitar qualquer coisa num site, dá uma olhada na barra de endereço. O nome está certo, sem letras trocadas? Tem o cadeado ali do lado? Sites falsos costumam imitar os originais quase perfeitamente — a diferença tá nos detalhes. Se tiver em dúvida, fecha e digita o endereço do zero.",
				"proteger": "Fecha o site imediatamente sem inserir nenhum dado. Limpa o histórico e os cookies do navegador. Se já tiver digitado alguma coisa, troca a senha do serviço afetado na hora e avisa o time de segurança. Reporta o site malicioso pro navegador — no Chrome e Firefox tem a opção 'Reportar site enganoso'.",
			},
			{
				"titulo": "Scareware",
				"reconhecer": "Sabe aquela tela que aparece do nada dizendo que seu computador está infectado, com um contador regressivo e uma lista enorme de 'ameaças detectadas'? Isso é scareware — um site ou pop-up falso que finge ser um antivírus pra te assustar e fazer você clicar em 'baixar' rápido demais, sem pensar. O visual é sempre exagerado: alertas em vermelho, ícones piscando, sirene de urgência. O objetivo não é te proteger, é te apressar.",
				"proteger": "- Nenhum navegador ou sistema operacional detecta vírus sozinho — se o alerta veio de uma aba do navegador, é falso.\n- Desconfie de qualquer coisa com contador regressivo pedindo pra você agir 'antes que seja tarde'.\n- Nunca baixe a 'ferramenta de remoção' oferecida na própria tela do alerta — feche a aba ou o navegador inteiro.\n- Rode um antivírus de verdade, já instalado, separadamente — nunca o que a tela suspeita está recomendando.",
			},
			{
				"titulo": "QR Code malicioso",
				"reconhecer": "QR Code colado por cima do original, em cartaz, mesa ou parquímetro, que leva a um site desconhecido.",
				"proteger": "Passe a mão para ver se há adesivo por cima e confira o endereço que o celular mostra antes de abrir.",
			},
			{
				"titulo": "Extensões suspeitas",
				"reconhecer": "Extensão de navegador simples, como um tema, que pede permissão para ler e alterar os dados de todos os sites.",
				"proteger": "Instale só extensões de lojas oficiais, com muitos usuários e boa reputação, e remova as que você não usa.",
			},
		],
	},
	# ---------------------------------------------------------- 4
	{
		"titulo": "Malware",
		"resumo": "Programas criados para danificar, espionar ou sequestrar o seu computador.",
		"subcapitulos": [
			{
				"titulo": "Ransomware",
				"reconhecer": "Ransomware é um programa que sequestra seus arquivos e cobra resgate pra devolver. Ele chega disfarçado — um anexo de e-mail, um arquivo baixado de lugar duvidoso. Regra simples: não abre arquivo de quem você não conhece. PDF pedindo pra habilitar macros? Fecha na hora.",
				"proteger": "Se perceber que foi infectado, desconecta o dispositivo da rede imediatamente — tira o cabo ou desativa o Wi-Fi. Não paga o resgate, pois não há garantia de recuperação e você financia o criminoso. Aciona o time de segurança e verifica se existe backup dos arquivos. A recuperação vem do backup, não da negociação.",
			},
			{
				"titulo": "Cavalo de Tróia",
				"reconhecer": "Programa que parece útil, como um instalador pirata ou um arquivo com dupla extensão, tipo nota.pdf.exe, mas esconde uma função maliciosa.",
				"proteger": "Baixe programas só de fontes oficiais e ative a exibição das extensões de arquivo no sistema.",
			},
			{
				"titulo": "Spyware/Keylogger",
				"reconhecer": "Computador mais lento, programas desconhecidos rodando e contas com atividade que você não fez. O programa registra o que você digita.",
				"proteger": "Mantenha antivírus e sistema atualizados, revise os programas instalados e troque as senhas a partir de outro dispositivo se desconfiar.",
			},
		],
	},
	# ---------------------------------------------------------- 5
	{
		"titulo": "Engenharia Social",
		"resumo": "Em vez de invadir máquinas, o golpista engana pessoas para que elas entreguem o acesso por conta própria.",
		"subcapitulos": [
			{
				"titulo": "Engenharia Social",
				"reconhecer": "Alguém ligou dizendo ser do suporte técnico e pedindo sua senha? Desliga. Banco mandou mensagem pedindo seus dados? Desconfia. Nenhuma empresa séria pede senha por telefone ou mensagem. Se achar que pode ser verdade, liga você mesmo pro número oficial — nunca o que eles te passaram.",
				"proteger": "Encerra o contato imediatamente sem fornecer nenhuma informação. Anota o número ou canal usado pelo golpista e reporta. Se já tiver fornecido algum dado, troca as senhas afetadas na hora e avisa o time de segurança. Nunca instala programas de acesso remoto pedidos por 'suporte técnico' não solicitado.",
			},
			{
				"titulo": "Pretexting",
				"reconhecer": "História inventada e bem detalhada, como uma auditoria ou um problema na sua conta, usada para justificar pedidos de informação.",
				"proteger": "Pergunte quem pediu e para quê, e confirme com o setor responsável antes de entregar qualquer dado.",
			},
			{
				"titulo": "Baiting (pendrive)",
				"reconhecer": "Pendrive ou outro dispositivo achado no chão ou na mesa, com etiqueta tentadora, como Salários 2026.",
				"proteger": "Não conecte dispositivos desconhecidos no computador. Entregue ao setor de segurança.",
			},
		],
	},
	# ---------------------------------------------------------- 6
	{
		"titulo": "Segurança Física",
		"resumo": "Nem toda ameaça vem pela rede: o acesso físico ao escritório e à sua tela também abre portas para o golpe.",
		"subcapitulos": [
			{
				"titulo": "Shoulder surfing",
				"reconhecer": "Pessoa parada atrás ou ao lado olhando a tela ou o teclado enquanto você digita senhas ou lê dados.",
				"proteger": "Posicione a tela longe da passagem, use película de privacidade e cubra o teclado ao digitar senhas.",
			},
			{
				"titulo": "Tailgating",
				"reconhecer": "Pessoa sem crachá entrando logo atrás de você por uma porta de acesso controlado, com um pretexto simples, como estar com as mãos ocupadas.",
				"proteger": "Não segure a porta para desconhecidos. Peça que passem o próprio crachá ou chame a segurança.",
			},
			{
				"titulo": "Tela desbloqueada",
				"reconhecer": "Computador deixado ligado e aberto na mesa, sem ninguém por perto, ou senha anotada num papel colado no monitor.",
				"proteger": "Bloqueie a tela sempre que se levantar (Windows + L) e guarde as senhas num gerenciador, não em papel.",
			},
		],
	},
	# ---------------------------------------------------------- 7
	{
		"titulo": "Contas e Acesso",
		"resumo": "As senhas e os fatores de verificação são a porta de entrada das suas contas.",
		"subcapitulos": [
			{
				"titulo": "Senha Fraca",
				"reconhecer": "Senhas curtas e previsíveis, como 123456, nome do time ou data de nascimento, aceitas sem nenhuma exigência de força.",
				"proteger": "Use frases longas, com 12 caracteres ou mais, e um gerenciador de senhas.",
			},
			{
				"titulo": "2FA",
				"reconhecer": "Conta importante sem verificação em duas etapas, ou pedido de um código de verificação que você não solicitou.",
				"proteger": "Ative a verificação em duas etapas, de preferência por aplicativo autenticador, e nunca compartilhe os códigos.",
			},
			{
				"titulo": "Reutilização de senha",
				"reconhecer": "A mesma senha usada em vários serviços, de modo que o vazamento de um deles expõe todos os outros.",
				"proteger": "Use uma senha diferente para cada serviço e troque na hora a de qualquer conta que apareça em vazamento.",
			},
		],
	},
	# ---------------------------------------------------------- 8
	{
		"titulo": "Sistemas e Redes",
		"resumo": "Programas desatualizados, redes abertas e aplicativos curiosos criam brechas sem que ninguém precise enganar você.",
		"subcapitulos": [
			{
				"titulo": "Atualização Ignorada",
				"reconhecer": "Aquela notificação de atualização que você fica adiando? Ela existe por um motivo. Atualizações corrigem brechas que invasores já sabem explorar. Sistema desatualizado é porta aberta. Atualiza logo e segue em frente.",
				"proteger": "Ativa as atualizações automáticas sempre que possível — sistema operacional, navegador e aplicativos. Se trabalha numa empresa, segue a política de atualização do time de TI. Nunca baixa atualizações de fontes não oficiais, apenas do site do fabricante ou da loja oficial do sistema.",
			},
			{
				"titulo": "Wi-Fi Público",
				"reconhecer": "Wi-Fi de shopping, aeroporto, café — qualquer um conectado nessa rede pode bisbilhotar o que você está fazendo. Evita acessar banco ou e-mail nessas redes. Se não tiver escolha, usa uma VPN. Melhor gastar a internet do celular do que ter seus dados interceptados.",
				"proteger": "Desativa a conexão automática a redes abertas no seu dispositivo. Se precisar usar Wi-Fi público, acessa apenas sites com HTTPS e evita qualquer serviço que exija login com dados sensíveis. Usa a internet do celular como alternativa — é mais seguro. Se usar com frequência redes públicas, investe numa VPN confiável.",
			},
			{
				"titulo": "Permissões Excessivas",
				"reconhecer": "Um app de lanterna pedindo acesso aos seus contatos e câmera? Isso não faz o menor sentido. Todo app pede permissões, mas você não é obrigado a aceitar tudo. Nega o que não faz sentido e, se o app não funcionar sem uma permissão estranha, talvez seja melhor desinstalar.",
				"proteger": "Revisa as permissões dos apps instalados no seu celular — tanto no Android quanto no iPhone dá pra ver e revogar uma por uma nas configurações. Antes de instalar um app novo, lê as permissões que ele pede. Se pedir algo além do necessário pra funcionar, pesquisa sobre ele antes de aceitar.",
			},
		],
	},
	# ---------------------------------------------------------- 9
	{
		"titulo": "Privacidade e Dados",
		"resumo": "O que você compartilha, deixa para trás ou entrega em formulários pode ser usado contra você e contra a empresa.",
		"subcapitulos": [
			{
				"titulo": "Vazamento de Dados",
				"reconhecer": "Ficou sabendo que algum serviço que você usa sofreu vazamento? Age rápido. Troca a senha daquele serviço e de qualquer outro onde você usava a mesma. Ativa autenticação em dois fatores onde puder — é uma camada extra que faz muita diferença.",
				"proteger": "Usa o site haveibeenpwned.com pra verificar se seu e-mail foi comprometido em algum vazamento conhecido. Troca as senhas afetadas imediatamente e ativa autenticação em dois fatores. Fique de olho em movimentações estranhas em contas bancárias ou e-mails nos dias seguintes ao vazamento.",
			},
			{
				"titulo": "Oversharing",
				"reconhecer": "Foto ou post mostrando crachá, cartão, documento, tela do computador ou a rotina e o local de trabalho.",
				"proteger": "Pense no que aparece ao fundo antes de postar e apague o que expõe dados pessoais ou da empresa.",
			},
			{
				"titulo": "Metadados",
				"reconhecer": "Foto ou documento carregando informações escondidas, como localização, autor, data e modelo do aparelho.",
				"proteger": "Remova os metadados antes de compartilhar arquivos e desative a localização nas fotos.",
			},
			{
				"titulo": "LGPD",
				"reconhecer": "Formulário que pede mais dados do que o necessário, sem explicar para que serão usados e sem opção de recusar.",
				"proteger": "Forneça só o essencial, leia a finalidade do uso dos dados e lembre que a LGPD garante o direito de acesso e de exclusão.",
			},
		],
	},
]


# ---------------------------------------------------------------------
# Auxiliares estáticos (úteis na migração do DadosJogo.gd)
# ---------------------------------------------------------------------
static func total_capitulos() -> int:
	return CAPITULOS.size()


static func titulo_capitulo(indice: int) -> String:
	if indice < 0 or indice >= CAPITULOS.size():
		return ""
	var capitulo: Dictionary = CAPITULOS[indice]
	return String(capitulo["titulo"])


static func titulos_capitulos() -> Array[String]:
	var titulos: Array[String] = []
	for capitulo in CAPITULOS:
		titulos.append(String(capitulo["titulo"]))
	return titulos


static func titulo_subcapitulo(indice_capitulo: int, indice_sub: int) -> String:
	if indice_capitulo < 0 or indice_capitulo >= CAPITULOS.size():
		return ""
	var capitulo: Dictionary = CAPITULOS[indice_capitulo]
	var subs: Array = capitulo["subcapitulos"]
	if indice_sub < 0 or indice_sub >= subs.size():
		return ""
	var sub: Dictionary = subs[indice_sub]
	return String(sub["titulo"])
