extends CanvasLayer

# =====================================================================
# GerenciadorCursorVirtual — AUTOLOAD
# ---------------------------------------------------------------------
# Controle de velocidade e sincronização do cursor virtual via
# Input.warp_mouse(): o cursor REAL do SO é constantemente realinhado
# com posicao_logica, então qualquer input nativo (clique em botão de
# UI, hover) já chega na posição certa sem precisar reescrever nada
# além do clique bruto. Processa via _input() (não _unhandled_input())
# pra interceptar antes de qualquer Control consumir o evento.
# =====================================================================

const TIPOS_QUE_EXIGEM_CAPTURA: Array = [
	ModificadorAtivo.Tipo.MOUSE_RAPIDO,
	ModificadorAtivo.Tipo.TRAVAMENTO,
]

@onready var sprite_cursor: Sprite2D = $SpriteCursor

var posicao_logica: Vector2 = Vector2.ZERO
var _pos_warp_esperada: Vector2 = Vector2(-99999, -99999)

var _modificadores_atuais: Array[ModificadorAtivo] = []
var _gerenciador_inspecao_atual: Node = null
var _exige_captura: bool = false
var _pausado_por_popup: bool = false
var _escape_manual_ativo: bool = false

var _tempo_ate_proximo_surto_velocidade: float = 0.0
var _surto_velocidade_ativo: bool = false
var _tempo_restante_surto_velocidade: float = 0.0
var _multiplicador_velocidade_surto: float = 1.0

var _cursores_falsos: Array[Sprite2D] = []


func _ready() -> void:
	layer = 4096
	show()
	if sprite_cursor != null:
		sprite_cursor.centered = false
		sprite_cursor.visible = true
	_entrar_modo_cosmetico()


func _entrar_modo_cosmetico() -> void:
	_exige_captura = false
	_pausado_por_popup = false
	_pos_warp_esperada = Vector2(-99999, -99999)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _entrar_modo_captura() -> void:
	posicao_logica = get_viewport().get_mouse_position()
	if not _escape_manual_ativo:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		_pos_warp_esperada = posicao_logica
		Input.warp_mouse(posicao_logica)


func configurar_para_trabalho(modificadores: Array[ModificadorAtivo], gerenciador_inspecao: Node = null) -> void:
	_modificadores_atuais = modificadores
	_gerenciador_inspecao_atual = gerenciador_inspecao
	_escape_manual_ativo = false
	_limpar_cursores_falsos()

	var tem_mouse_grande := CalculadoraModificadores.tem_modificador(modificadores, ModificadorAtivo.Tipo.MOUSE_GRANDE)
	var tem_copias := CalculadoraModificadores.tem_modificador(modificadores, ModificadorAtivo.Tipo.COPIAS)

	var precisa_captura := false
	for tipo in TIPOS_QUE_EXIGEM_CAPTURA:
		if CalculadoraModificadores.tem_modificador(modificadores, tipo):
			precisa_captura = true
			break

	var escala := 1.0
	if tem_mouse_grande:
		var nivel := CalculadoraModificadores.obter_nivel(modificadores, ModificadorAtivo.Tipo.MOUSE_GRANDE)
		escala = CalculadoraModificadores.calcular_escala_mouse_grande(nivel)

	if sprite_cursor != null:
		sprite_cursor.scale = Vector2.ONE * escala

	if tem_copias:
		var nivel_copias := CalculadoraModificadores.obter_nivel(modificadores, ModificadorAtivo.Tipo.COPIAS)
		_criar_cursores_falsos(CalculadoraModificadores.calcular_quantidade_cursores_falsos(nivel_copias))

	_agendar_proximo_surto_velocidade()

	_exige_captura = precisa_captura
	if precisa_captura:
		_entrar_modo_captura()
	else:
		_entrar_modo_cosmetico()


func limpar_modificadores_de_trabalho() -> void:
	_modificadores_atuais.clear()
	_gerenciador_inspecao_atual = null
	_limpar_cursores_falsos()
	if sprite_cursor != null:
		sprite_cursor.scale = Vector2.ONE
	_entrar_modo_cosmetico()


func obter_posicao_clique() -> Vector2:
	if _exige_captura and not _pausado_por_popup and not _escape_manual_ativo:
		return posicao_logica
	return get_viewport().get_mouse_position()


func _input(event: InputEvent) -> void:
	if not _exige_captura or _pausado_por_popup or _escape_manual_ativo:
		return

	if event is InputEventMouseMotion:
		if _pos_warp_esperada != Vector2(-99999, -99999) and event.position.is_equal_approx(_pos_warp_esperada):
			_pos_warp_esperada = Vector2(-99999, -99999)
			return

		var delta: Vector2 = event.relative
		var multiplicador_velocidade := 1.0
		if _surto_velocidade_ativo:
			multiplicador_velocidade = _multiplicador_velocidade_surto

		if multiplicador_velocidade == 1.0:
			posicao_logica = event.position
		else:
			posicao_logica += delta * multiplicador_velocidade
			var tamanho_tela := get_viewport().get_visible_rect().size
			posicao_logica.x = clamp(posicao_logica.x, 0.0, tamanho_tela.x)
			posicao_logica.y = clamp(posicao_logica.y, 0.0, tamanho_tela.y)

			_pos_warp_esperada = posicao_logica
			Input.warp_mouse(posicao_logica)

	elif event is InputEventMouseButton:
		event.position = posicao_logica
		event.global_position = posicao_logica

	elif event.is_action_pressed("ui_cancel"):
		_escape_manual_ativo = not _escape_manual_ativo
		if _escape_manual_ativo:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		else:
			posicao_logica = get_viewport().get_mouse_position()
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
			_pos_warp_esperada = posicao_logica
			Input.warp_mouse(posicao_logica)


func _notification(what: int) -> void:
	if not _exige_captura or _escape_manual_ativo:
		return

	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		if not _pausado_por_popup:
			posicao_logica = get_viewport().get_mouse_position()
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
			_pos_warp_esperada = posicao_logica
			Input.warp_mouse(posicao_logica)


func _process(delta: float) -> void:
	if _exige_captura and not _escape_manual_ativo:
		var popup_aberto: bool = false
		if is_instance_valid(_gerenciador_inspecao_atual) and _gerenciador_inspecao_atual.has_method("esta_com_popup_aberto"):
			popup_aberto = _gerenciador_inspecao_atual.esta_com_popup_aberto()

		if popup_aberto:
			_pausar_captura_temporariamente()
		else:
			_retomar_captura_se_pausado()

		if sprite_cursor != null:
			sprite_cursor.global_position = get_viewport().get_mouse_position() if _pausado_por_popup else posicao_logica
	else:
		if sprite_cursor != null:
			sprite_cursor.global_position = get_viewport().get_mouse_position()

	_atualizar_surto_velocidade(delta)
	_atualizar_cursores_falsos()


func _pausar_captura_temporariamente() -> void:
	if not _pausado_por_popup:
		_pausado_por_popup = true
		_pos_warp_esperada = Vector2(-99999, -99999)


func _retomar_captura_se_pausado() -> void:
	if not _pausado_por_popup:
		return
	_pausado_por_popup = false
	posicao_logica = get_viewport().get_mouse_position()
	_pos_warp_esperada = posicao_logica
	Input.warp_mouse(posicao_logica)


# ---------------------------------------------------------------------
# SURTOS DE VELOCIDADE — Mouse Rápido (acelera) e Travamento (congela,
# multiplicador 0.0). Se os dois estiverem no mesmo trabalho, cada
# surto sorteia qual dos dois dispara — nunca os dois ao mesmo tempo.
# ---------------------------------------------------------------------
func _agendar_proximo_surto_velocidade() -> void:
	_tempo_ate_proximo_surto_velocidade = randf_range(
		CalculadoraModificadores.INTERVALO_SURTO_VELOCIDADE_MIN,
		CalculadoraModificadores.INTERVALO_SURTO_VELOCIDADE_MAX
	)


func _atualizar_surto_velocidade(delta: float) -> void:
	if not _exige_captura:
		return

	if _surto_velocidade_ativo:
		_tempo_restante_surto_velocidade -= delta
		if _tempo_restante_surto_velocidade <= 0.0:
			_surto_velocidade_ativo = false
			_agendar_proximo_surto_velocidade()
		return

	_tempo_ate_proximo_surto_velocidade -= delta
	if _tempo_ate_proximo_surto_velocidade <= 0.0:
		_iniciar_surto_velocidade()


func _iniciar_surto_velocidade() -> void:
	var nivel_rapido := CalculadoraModificadores.obter_nivel(_modificadores_atuais, ModificadorAtivo.Tipo.MOUSE_RAPIDO)
	var tem_travamento := CalculadoraModificadores.tem_modificador(_modificadores_atuais, ModificadorAtivo.Tipo.TRAVAMENTO)

	if nivel_rapido <= 0 and not tem_travamento:
		_agendar_proximo_surto_velocidade()
		return

	var usar_travamento := tem_travamento and (nivel_rapido <= 0 or randf() < 0.5)

	if usar_travamento:
		_multiplicador_velocidade_surto = CalculadoraModificadores.MULTIPLICADOR_TRAVAMENTO
	else:
		_multiplicador_velocidade_surto = CalculadoraModificadores.calcular_multiplicador_velocidade_rapido(nivel_rapido)

	_surto_velocidade_ativo = true
	_tempo_restante_surto_velocidade = CalculadoraModificadores.DURACAO_SURTO_VELOCIDADE


func _criar_cursores_falsos(quantidade: int) -> void:
	for i in range(quantidade):
		var falso := Sprite2D.new()
		if sprite_cursor != null:
			falso.texture = sprite_cursor.texture
			falso.centered = false
			falso.scale = sprite_cursor.scale
		falso.modulate = Color(1, 1, 1)
		falso.global_position = get_viewport().get_mouse_position()
		falso.set_meta("velocidade_passeio", Vector2(randf_range(-70, 70), randf_range(-40, 40)))
		add_child(falso)
		_cursores_falsos.append(falso)


func _atualizar_cursores_falsos() -> void:
	if _cursores_falsos.is_empty():
		return

	var tamanho_tela := get_viewport().get_visible_rect().size
	for falso in _cursores_falsos:
		var velocidade: Vector2 = falso.get_meta("velocidade_passeio")
		var nova_posicao: Vector2 = falso.global_position + velocidade * get_process_delta_time()

		if nova_posicao.x < 0.0 or nova_posicao.x > tamanho_tela.x:
			velocidade.x = -velocidade.x
		if nova_posicao.y < 0.0 or nova_posicao.y > tamanho_tela.y:
			velocidade.y = -velocidade.y

		falso.set_meta("velocidade_passeio", velocidade)
		falso.global_position = nova_posicao.clamp(Vector2.ZERO, tamanho_tela)


func _limpar_cursores_falsos() -> void:
	for falso in _cursores_falsos:
		if is_instance_valid(falso):
			falso.queue_free()
	_cursores_falsos.clear()
