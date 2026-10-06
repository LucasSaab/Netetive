class_name ModificadorAtivo
extends RefCounted

enum Tipo {
	DESCONHECIDO,
	CONEXAO_LENTA,
	MAIS_OPCOES,
	ARMADILHA,
	MOUSE_GRANDE,
	AO_CONTRARIO,
	MISDIRECAO,
	TEMPO_LIMITADO,
	COPIAS,
	CAOS,
	LABIRINTO,
	MOUSE_RAPIDO,
	TRAVAMENTO,
}

var tipo: Tipo
var nivel: int = 1
var sub_modificadores: Array[ModificadorAtivo] = []


func _init(tipo_inicial: Tipo = Tipo.CONEXAO_LENTA, nivel_inicial: int = 1) -> void:
	tipo = tipo_inicial
	nivel = nivel_inicial


func nome_exibicao() -> String:
	match tipo:
		Tipo.DESCONHECIDO:
			return "??? Desconhecido"
		Tipo.CONEXAO_LENTA:
			return "Conexão Lenta"
		Tipo.MAIS_OPCOES:
			return "Mais Opções"
		Tipo.ARMADILHA:
			return "Armadilha"
		Tipo.MOUSE_GRANDE:
			return "Mouse Grande"
		Tipo.AO_CONTRARIO:
			return "Ao Contrário"
		Tipo.MISDIRECAO:
			return "Misdireção"
		Tipo.TEMPO_LIMITADO:
			return "Tempo Limitado"
		Tipo.COPIAS:
			return "Cópias"
		Tipo.CAOS:
			return "Caos"
		Tipo.LABIRINTO:
			return "Labirinto"
		Tipo.MOUSE_RAPIDO:
			return "Mouse Rápido"
		Tipo.TRAVAMENTO:
			return "Travamento"
	return "?"


func caminho_icone() -> String:
	match tipo:
		Tipo.DESCONHECIDO:
			return "res://Sprites/Modificadores/desconhecido.png"
		Tipo.CONEXAO_LENTA:
			return "res://Sprites/Modificadores/conexao_lenta.png"
		Tipo.MAIS_OPCOES:
			return "res://Sprites/Modificadores/mais_opcoes.png"
		Tipo.ARMADILHA:
			return "res://Sprites/Modificadores/armadilha.png"
		Tipo.MOUSE_GRANDE:
			return "res://Sprites/Modificadores/mouse_grande.png"
		Tipo.AO_CONTRARIO:
			return "res://Sprites/Modificadores/ao_contrario.png"
		Tipo.MISDIRECAO:
			return "res://Sprites/Modificadores/misderacao.png"
		Tipo.TEMPO_LIMITADO:
			return "res://Sprites/Modificadores/tempo_limitado.png"
		Tipo.COPIAS:
			return "res://Sprites/Modificadores/copias.png"
		Tipo.CAOS:
			return "res://Sprites/Modificadores/chaos.png"
		Tipo.LABIRINTO:
			return "res://Sprites/Modificadores/labirinto.png"
		Tipo.MOUSE_RAPIDO:
			return "res://Sprites/Modificadores/mouse_rapido.png"
		Tipo.TRAVAMENTO:
			return "res://Sprites/Modificadores/travamento.png"
	return ""
