extends Node

@onready var player: AudioStreamPlayer = $Player
@onready var som_clique_menu: AudioStreamPlayer = $SomCliqueMenu
@onready var som_verificacao: AudioStreamPlayer = $SomVerificacao

@export var stream_principal: AudioStream
@export var stream_relatorio: AudioStream

const BUS_MUSICA := "Musica"

var _mudo: bool = false


func _ready() -> void:
	if player == null:
		push_warning("GerenciadorMusica: nó 'Player' (AudioStreamPlayer) não encontrado.")
		return

	if AudioServer.get_bus_index(BUS_MUSICA) == -1:
		push_warning("GerenciadorMusica: bus '%s' não existe — crie em Audio Bus Layout." % BUS_MUSICA)

	tocar_musica_principal()


# Chamado no início do jogo e ao voltar do RelatorioDia pro Escritório —
# sempre reinicia do zero (intro incluída), nunca retoma de onde parou.
func tocar_musica_principal() -> void:
	if player == null or stream_principal == null:
		push_warning("GerenciadorMusica: stream_principal não atribuído.")
		return
	player.stream = stream_principal
	player.play()


# Chamado por Main_select_script quando o expediente encerra — ainda
# dentro de Tela.tscn, ANTES da troca de cena pro RelatorioDia.
func tocar_musica_relatorio() -> void:
	if player == null or stream_relatorio == null:
		push_warning("GerenciadorMusica: stream_relatorio não atribuído.")
		return
	player.stream = stream_relatorio
	player.play()


# Efeito sonoro: menu de opções (NovaAba) abrindo ao clicar no site.
func tocar_som_clique_menu() -> void:
	if som_clique_menu != null:
		som_clique_menu.play()


# Efeito sonoro: início da verificação, logo após clicar em Inspecionar.
func tocar_som_verificacao() -> void:
	if som_verificacao != null:
		som_verificacao.play()


func alternar_mudo() -> bool:
	_mudo = not _mudo
	var indice_bus := AudioServer.get_bus_index(BUS_MUSICA)
	if indice_bus == -1:
		push_warning("GerenciadorMusica: bus '%s' não existe." % BUS_MUSICA)
		return _mudo
	AudioServer.set_bus_mute(indice_bus, _mudo)
	return _mudo


func esta_mudo() -> bool:
	return _mudo


func definir_volume(volume_linear: float) -> void:
	var indice_bus := AudioServer.get_bus_index(BUS_MUSICA)
	if indice_bus == -1:
		push_warning("GerenciadorMusica: bus '%s' não existe." % BUS_MUSICA)
		return
	AudioServer.set_bus_volume_db(indice_bus, linear_to_db(clamp(volume_linear, 0.0, 1.0)))
