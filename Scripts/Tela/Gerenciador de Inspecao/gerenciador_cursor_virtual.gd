extends CanvasLayer

# =====================================================================
# GerenciadorCursorVirtual — AUTOLOAD
# ---------------------------------------------------------------------
# Garante a ocultação contínua do cursor nativo do SO (Input.mouse_mode)
# para que apenas o cursor customizado (sprite_cursor) fique visível,
# mesmo em modificadores cosméticos como MOUSE_GRANDE e COPIAS.
# =====================================================================

const TIPOS_QUE_EXIGEM_CAPTURA: Array = [
	ModificadorAtivo.Tipo.MOUSE_RAPIDO,
	ModificadorAtivo.Tipo.TRAVAMENTO,
	ModificadorAtivo.Tipo.LABIRINTO,
]

@onready var sprite_cursor: Sprite2D = $SpriteCursor
@onready var desenho_labirinto: DesenhoLabirinto = $DesenhoLabirinto

var posicao_logica: Vector2 = Vector2.ZERO
var _warps_pendentes: int = 0

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
	_warps_pendentes = 0
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if desenho_labirinto != null:
		desenho_labirinto.atualizar_segmentos([])


func _entrar_modo_captura() -> void:
	posicao_logica = get_viewport().get_mouse_position()
	if not _escape_manual_ativo:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
		_avisar_e_warpar(posicao_logica)


func _avisar_e_warpar(destino: Vector2) -> void:
	_warps_pendentes += 1
	Input.warp_mouse(destino)


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


func _tem_labirinto() -> bool:
	return CalculadoraModificadores.tem_modificador(_modificadores_atuais, ModificadorAtivo.Tipo.LABIRINTO)


func _input(event: InputEvent) -> void:
	if not _exige_captura or _pausado_por_popup or _escape_manual_ativo:
		return

	if event is InputEventMouseMotion:
		if _warps_pendentes > 0:
			_warps_pendentes -= 1
			return

		var delta: Vector2 = event.relative
		var multiplicador_velocidade := 1.0
		if _surto_velocidade_ativo:
			multiplicador_velocidade = _multiplicador_velocidade_surto

		var posicao_proposta := posicao_logica + delta * multiplicador_velocidade
		var tamanho_tela := get_viewport().get_visible_rect().size
		posicao_proposta.x = clamp(posicao_proposta.x, 0.0, tamanho_tela.x)
		posicao_proposta.y = clamp(posicao_proposta.y, 0.0, tamanho_tela.y)

		if _tem_labirinto() and is_instance_valid(_gerenciador_inspecao_atual) and _gerenciador_inspecao_atual.has_method("restringir_movimento_labirinto"):
			posicao_proposta = _gerenciador_inspecao_atual.restringir_movimento_labirinto(posicao_logica, posicao_proposta)

		posicao_logica = posicao_proposta

		# Evita acumular warps se a diferença for apenas de precisão decimal
		if posicao_logica.distance_squared_to(get_viewport().get_mouse_position()) > 1.0:
			_avisar_e_warpar(posicao_logica)

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
			_avisar_e_warpar(posicao_logica)


func _notification(what: int) -> void:
	if _escape_manual_ativo:
		return

	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		if not _pausado_por_popup:
			posicao_logica = get_viewport().get_mouse_position()
			if _exige_captura:
				Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
				_avisar_e_warpar(posicao_logica)
			else:
				Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(delta: float) -> void:
	if not _escape_manual_ativo and not _pausado_por_popup:
		var modo_esperado := Input.MOUSE_MODE_CONFINED_HIDDEN if _exige_captura else Input.MOUSE_MODE_HIDDEN
		if Input.mouse_mode != modo_esperado:
			Input.mouse_mode = modo_esperado

	if _exige_captura and not _escape_manual_ativo:
		var popup_aberto: bool = false
		if is_instance_valid(_gerenciador_inspecao_atual) and _gerenciador_inspecao_atual.has_method("esta_com_popup_aberto"):
			popup_aberto = _gerenciador_inspecao_atual.esta_com_popup_aberto()

		if popup_aberto:
			_pausar_captura_temporariamente()
		else:
			_retomar_captura_se_pausado()

		if sprite_cursor != null:
			sprite_cursor.visible = not _pausado_por_popup
			if not _pausado_por_popup:
				sprite_cursor.global_position = posicao_logica
	else:
		if sprite_cursor != null:
			sprite_cursor.visible = true
			sprite_cursor.global_position = get_viewport().get_mouse_position()

	_atualizar_surto_velocidade(delta)
	_atualizar_cursores_falsos()
	_atualizar_desenho_labirinto()


func _atualizar_desenho_labirinto() -> void:
	if desenho_labirinto == null:
		return

	var ativo := _exige_captura and not _pausado_por_popup and _tem_labirinto()
	if not ativo or not is_instance_valid(_gerenciador_inspecao_atual) or not _gerenciador_inspecao_atual.has_method("obter_segmentos_parede_proximos"):
		desenho_labirinto.atualizar_segmentos([])
		return

	var segmentos: Array = _gerenciador_inspecao_atual.obter_segmentos_parede_proximos(posicao_logica, CalculadoraModificadores.RAIO_REVELACAO_LABIRINTO)
	desenho_labirinto.atualizar_segmentos(segmentos)


func _pausar_captura_temporariamente() -> void:
	if not _pausado_por_popup:
		_pausado_por_popup = true
		_warps_pendentes = 0
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _retomar_captura_se_pausado() -> void:
	if not _pausado_por_popup:
		return
	_pausado_por_popup = false
	posicao_logica = get_viewport().get_mouse_position()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN if _exige_captura else Input.MOUSE_MODE_HIDDEN
	_avisar_e_warpar(posicao_logica)


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
		falso.modulate = Color(1, 1, 1, 1)
		falso.global_position = get_viewport().get_mouse_position()
		falso.set_meta("velocidade_passeio", Vector2(randf_range(-70, 70), randf_range(-70, 70)))
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
