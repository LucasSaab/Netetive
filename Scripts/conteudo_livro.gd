extends RefCounted
class_name ConteudoLivro

# Base de dados do manual contendo os 12 capítulos estruturados e limpos
var PAGINAS: Array[Dictionary] = [
	{
		"titulo": "Capítulo 1 — Phishing",
		"descricao": "Sabe aquele e-mail que parece ser do seu banco mas algo parece errado? Provavelmente é phishing. Olha sempre quem está mandando — o endereço do remetente costuma entregar o golpe. Link encurtado ou com nome estranho? Não clica. Mensagem com aquela urgência toda de 'sua conta será bloqueada em 24h'? Respira. É pressão psicológica pra você agir sem pensar.",
		"solucao": "Como agir: Não clica em nenhum link. Não responde. Marca como spam e reporta pro time de segurança da empresa. Se tiver dúvida se é legítimo, entra em contato com a empresa pelo site oficial — nunca pelo contato que veio no e-mail suspeito."
	},
	{
		"titulo": "Capítulo 2 — Perfil Falso",
		"descricao": "Chegou pedido de conexão de alguém que você não conhece? Dá uma olhada no perfil antes de aceitar. Foto genérica, sem postagens, criado há pouco tempo e já mandando mensagem pedindo alguma coisa — sinal vermelho. Perfis falsos existem pra coletar informação ou aplicar golpe. Na dúvida, não aceita.",
		"solucao": "Como agir: Rejeita o pedido e reporta o perfil na plataforma. Se a pessoa alegar ser alguém que você conhece, confirma por outro canal — manda mensagem pro contato real pelo número que você já tem. Nunca confirma identidade pelo mesmo canal do suspeito."
	},
	{
		"titulo": "Capítulo 3 — Site Malicioso",
		"descricao": "Antes de digitar qualquer coisa num site, dá uma olhada na barra de endereço. O nome está certo, sem letras trocadas? Tem o cadeado ali do lado? Sites falsos costumam imitar os originais quase perfeitamente — a diferença tá nos detalhes. Se tiver em dúvida, fecha e digita o endereço do zero.",
		"solucao": "Como agir: Fecha o site imediatamente sem inserir nenhum dado. Limpa o histórico e os cookies do navegador. Se já tiver digitado alguma coisa, troca a senha do serviço afetado na hora e avisa o time de segurança. Reporta o site malicioso pro navegador — no Chrome e Firefox tem a opção 'Reportar site enganoso'."
	},
	{
		"titulo": "Capítulo 4 — Ransomware",
		"descricao": "Ransomware é um programa que sequestra seus arquivos e cobra resgate pra devolver. Ele chega disfarçado — um anexo de e-mail, um arquivo baixado de lugar duvidoso. Regra simples: não abre arquivo de quem você não conhece. PDF pedindo pra habilitar macros? Fecha na hora.",
		"solucao": "Como agir: Se perceber que foi infectado, desconecta o dispositivo da rede imediatamente — tira o cabo ou desativa o Wi-Fi. Não paga o resgate, pois não há garantia de recuperação e você financia o criminoso. Aciona o time de segurança e verifica se existe backup dos arquivos. A recuperação vem do backup, não da negociação."
	},
	{
		"titulo": "Capítulo 5 — Engenharia Social",
		"descricao": "Alguém ligou dizendo ser do suporte técnico e pedindo sua senha? Desliga. Banco mandou mensagem pedindo seus dados? Desconfia. Nenhuma empresa séria pede senha por telefone ou mensagem. Se achar que pode ser verdade, liga você mesmo pro número oficial — nunca o que eles te passaram.",
		"solucao": "Como agir: Encerra o contato imediatamente sem fornecer nenhuma informação. Anota o número ou canal usado pelo golpista and reporta. Se já tiver fornecido algum dado, troca as senhas afetadas na hora e avisa o time de segurança. Nunca instala programas de acesso remoto pedidos por 'suporte técnico' não solicitado."
	},
	{
		"titulo": "Capítulo 6 — Senha Fraca",
		"descricao": "'123456' não é senha, é tapete de boas-vindas pra invasor. Uma senha decente tem mais de 12 caracteres, mistura letras maiúsculas, minúsculas, números e símbolos. E não usa seu nome, data de nascimento ou 'senha123'. Ah, e cada site precisa de uma senha diferente — se um vazar, os outros ficam protegidos.",
		"solucao": "Como agir: Troca agora. Usa um gerenciador de senhas — programas como Bitwarden ou KeePass criam e guardam senhas fortes pra você, sem precisar memorizar. Ativa autenticação em dois fatores em todos os serviços que permitirem. Revisa suas senhas antigas pelo menos uma vez por ano."
	},
	{
		"titulo": "Capítulo 7 — Wi-Fi Público",
		"descricao": "Wi-Fi de shopping, aeroporto, café — qualquer um conectado nessa rede pode bisbilhotar o que você está fazendo. Evita acessar banco ou e-mail nessas redes. Se não tiver escolha, usa uma VPN. Melhor gastar a internet do celular do que ter seus dados interceptados.",
		"solucao": "Como agir: Desativa a conexão automática a redes abertas no seu dispositivo. Se precisar usar Wi-Fi público, acessa apenas sites com HTTPS e evita qualquer serviço que exija login com dados sensíveis. Usa a internet do celular como alternativa — é mais seguro. Se usar com frequência redes públicas, investe numa VPN confiável."
	},
	{
		"titulo": "Capítulo 8 — Atualização Ignorada",
		"descricao": "Aquela notificação de atualização que você fica adiando? Ela existe por um motivo. Atualizações corrigem brechas que invasores já sabem explorar. Sistema desatualizado é porta aberta. Atualiza logo e segue em frente.",
		"solucao": "Como agir: Ativa as atualizações automáticas sempre que possível — sistema operacional, navegador e aplicativos. Se trabalha numa empresa, segue a política de atualização do time de TI. Nunca baixa atualizações de fontes não oficiais, apenas do site do fabricante ou da loja oficial do sistema."
	},
	{
		"titulo": "Capítulo 9 — Permissões Excessivas",
		"descricao": "Um app de lanterna pedindo acesso aos seus contatos e câmera? Isso não faz o menor sentido. Todo app pede permissões, mas você não é obrigado a aceitar tudo. Nega o que não faz sentido e, se o app não funcionar sem uma permissão estranha, talvez seja melhor desinstalar.",
		"solucao": "Como agir: Revisa as permissões dos apps instalados no seu celular — tanto no Android quanto no iPhone dá pra ver e revogar uma por uma nas configurações. Antes de instalar um app novo, lê as permissões que ele pede. Se pedir algo além do necessário pra funcionar, pesquisa sobre ele antes de aceitar."
	},
	{
		"titulo": "Capítulo 10 — Vazamento de Dados",
		"descricao": "Ficou sabendo que algum serviço que você usa sofreu vazamento? Age rápido. Troca a senha daquele serviço e de qualquer outro onde você usava a mesma. Ativa autenticação em dois fatores onde puder — é uma camada extra que faz muita diferença.",
		"solucao": "Como agir: Usa o site haveibeenpwned.com pra verificar se seu e-mail foi comprometido em algum vazamento conhecido. Troca as senhas afetadas imediatamente e ativa autenticação em dois fatores. Fique de olho em movimentações estranhas em contas bancárias ou e-mails nos dias seguintes ao vazamento."
	}
]
