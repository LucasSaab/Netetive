extends TextureRect

signal inspecionar_pressionado
signal investigar_pressionado
signal diagnostico_pressionado
signal diagnostico_escolhido(opcao: String)
signal ignorar_pressionado
signal designorar_pressionado
signal encerrar_pressionado

@onready var vbox_padrao: VBoxContainer = $VBoxPadrao
@onready var btn_inspecionar: Button = $VBoxPadrao/BtnInspecionar
@onready var btn_investigar: Button = $VBoxPadrao/BtnInvestigar
@onready var btn_diagnosticar: Button = $VBoxPadrao/BtnDiagnosticar
@onready var btn_ignorar: Button = $VBoxPadrao/BtnIgnorar
@onready var btn_encerrar: Button = $VBoxPadrao/BtnEncerrar
@onready var vbox_diagnostico: VBoxContainer = $VBoxDiagnostico

var _ignorado_atual: bool = false


func _ready() -> void:
	hide()
	if btn_inspecionar != null:
		btn_inspecionar.pressed.connect(_on_inspecionar_pressed)
	if btn_investigar != null:
		btn_investigar.pressed.connect(_on_investigar_pressed)
	if btn_diagnosticar != null:
		btn_diagnosticar.pressed.connect(_on_diagnosticar_pressed)
	if btn_ignorar != null:
		btn_ignorar.pressed.connect(_on_ignorar_pressed)
	if btn_encerrar != null:
		btn_encerrar.pressed.connect(_on_encerrar_pressed)
	if vbox_diagnostico != null:
		vbox_diagnostico.hide()


func mostrar_em(pos: Vector2, diagnostico_disponivel: bool, ignorado: bool, inspecionar_disponivel: bool, investigar_disponivel: bool) -> void:
	global_position = pos
	_ignorado_atual = ignorado

	if btn_inspecionar != null:
		btn_inspecionar.disabled = not inspecionar_disponivel
	if btn_investigar != null:
		btn_investigar.disabled = not investigar_disponivel
	if btn_diagnosticar != null:
		btn_diagnosticar.disabled = not diagnostico_disponivel
	if btn_ignorar != null:
		btn_ignorar.text = "Designorar" if ignorado else "Ignorar"

	if vbox_diagnostico != null:
		vbox_diagnostico.hide()
	if vbox_padrao != null:
		vbox_padrao.show()
	show()


func mostrar_diagnostico(opcoes: Array[String]) -> void:
	if vbox_diagnostico == null:
		push_warning("NovaAba: vbox_diagnostico não encontrado na cena.")
		return

	for filho in vbox_diagnostico.get_children():
		filho.queue_free()

	for opcao in opcoes:
		var botao := Button.new()
		botao.text = opcao
		botao.pressed.connect(_on_opcao_diagnostico_pressionada.bind(opcao))
		vbox_diagnostico.add_child(botao)

	if btn_diagnosticar != null and vbox_padrao != null:
		vbox_diagnostico.position = Vector2(
			vbox_padrao.size.x + 4,
			btn_diagnosticar.position.y
		)

	vbox_diagnostico.show()


func esconder() -> void:
	hide()
	if vbox_diagnostico != null:
		vbox_diagnostico.hide()


func _on_inspecionar_pressed() -> void:
	emit_signal("inspecionar_pressionado")
	esconder()


func _on_investigar_pressed() -> void:
	investigar_pressionado.emit()
	esconder()


func _on_diagnosticar_pressed() -> void:
	diagnostico_pressionado.emit()


func _on_ignorar_pressed() -> void:
	if _ignorado_atual:
		designorar_pressionado.emit()
	else:
		ignorar_pressionado.emit()
	esconder()


func _on_encerrar_pressed() -> void:
	encerrar_pressionado.emit()
	esconder()


func _on_opcao_diagnostico_pressionada(opcao: String) -> void:
	diagnostico_escolhido.emit(opcao)
	esconder()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not get_global_rect().has_point(event.position):
			get_viewport().set_input_as_handled()
			esconder()
