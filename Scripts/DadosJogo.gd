# DadosJogo.gd
extends Node

# Este é o banco de dados global do seu jogo
var banco_de_trabalhos: Array[Dictionary] = [
	{
		"titulo": "Remover Cavalo de Tróia",
		"descricao": "O usuário baixou um ativador falso e agora o computador está travando muito.",
		"recompensa_base": 150
	},
	{
		"titulo": "Limpeza de Disco",
		"descricao": "O armazenamento está 100% cheio com arquivos temporários e lixo eletrônico.",
		"recompensa_base": 60
	},
	{
		"titulo": "Otimizar Inicialização",
		"descricao": "Existem mais de 40 programas abrindo junto com o sistema. Deixe o boot mais rápido.",
		"recompensa_base": 80
	},
	{
		"titulo": "Atualizar Drivers de Vídeo",
		"descricao": "A placa de vídeo está dando tela azul por falta de atualizações críticas.",
		"recompensa_base": 110
	},
	{
		"titulo": "Substituir Pasta Térmica",
		"descricao": "O processador está atingindo 95°C em tarefas básicas. Manutenção urgente.",
		"recompensa_base": 130
	}
]

# DICA EXTRA: Você já pode deixar o dinheiro do jogador guardado aqui globalmente!
var dinheiro_jogador: int = 0
