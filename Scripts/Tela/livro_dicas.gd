extends CanvasLayer

# =====================================================================
# LivroDicas — cena reutilizável (Escritorio.tscn e Tela.tscn)
# ---------------------------------------------------------------------
# Raiz da cena: CanvasLayer. Os nós abaixo precisam existir com
# "Access as Unique Name" (%) na cena LivroDicas.tscn:
#   PaginaVazia, Titulo, VBoxIndice, VBoxSubcapitulos, Texto,
#   AbaIndice, AbaReconhecer, AbaProteger, BtnFechar
#
# Abrir de qualquer lugar (sem referência no Inspetor):
#   get_tree().call_group("livro_dicas", "abrir")
#   get_tree().call_group("livro_dicas", "abrir_em", capitulo, sub, 0)
#
# Lê ConteudoLivro.CAPITULOS. Sem class_name de propósito (evita conflito
# de classe global oculta).
# =====================================================================

signal aberto
signal fechado

enum Estado { INDICE, SUBCAPITULOS, TEXTO }
enum Aba { RECONHECER, PROTEGER }

# Tamanho da fonte do livro. O nó Livro é escalado (2x), então use o
# tamanho "de pixel art", não o padrão de 16 do Godot.
# 11 foi o valor que ficou bom em jogo. Se estourar a página, baixe.
const TAMANHO_FONTE := 11

# Botões de capítulo/subcapítulo (estilo Papers, Please)
const COR_BOTAO := Color(0.09, 0.12, 0.22)
const COR_BOTAO_HOVER := Color(0.36, 0.42, 0.6)
const COR_TEXTO_BOTAO := Color(0.93, 0.94, 0.9)
const SEPARACAO_BOTOES := 2

# Abas laterais: um único sprite; a aba atual fica na cor cheia e as
# outras ficam levemente escurecidas (sem deslocamento).
const COR_ABA_INATIVA := Color(0.78, 0.82, 0.92)
const COR_TEXTO_ABA := Color(0.09, 0.12, 0.22)

@onready var pagina_vazia: ColorRect = %PaginaVazia
@onready var titulo: Label = %Titulo
@onready var vbox_indice: VBoxContainer = %VBoxIndice
@onready var vbox_subcapitulos: VBoxContainer = %VBoxSubcapitulos
@onready var texto: RichTextLabel = %Texto
@onready var aba_indice: BaseButton = %AbaIndice
@onready var aba_reconhecer: BaseButton = %AbaReconhecer
@onready var aba_proteger: BaseButton = %AbaProteger
@onready var btn_fechar: BaseButton = %BtnFechar

var _estado: Estado = Estado.INDICE
var _aba: Aba = Aba.RECONHECER
var _capitulo_atual: int = -1
var _subcapitulo_atual: int = -1


func _ready() -> void:
	layer = 10
	add_to_group("popups")        # pausa o cursor virtual enquanto aberto
	add_to_group("livro_dicas")   # qualquer script chama via call_group

	for aba in [aba_indice, aba_reconhecer, aba_proteger]:
		_trazer_aba_para_frente(aba)
		_ajustar_rotulo_aba(aba)

	aba_indice.pressed.connect(_ir_para_indice)
	aba_reconhecer.pressed.connect(_trocar_aba.bind(Aba.RECONHECER))
	aba_proteger.pressed.connect(_trocar_aba.bind(Aba.PROTEGER))
	btn_fechar.pressed.connect(fechar)

	# Força o tamanho de fonte mesmo que o tema não esteja atribuído.
	titulo.add_theme_font_size_override("font_size", TAMANHO_FONTE)
	texto.add_theme_font_size_override("normal_font_size", TAMANHO_FONTE)
	texto.add_theme_font_size_override("bold_font_size", TAMANHO_FONTE)
	btn_fechar.add_theme_font_size_override("font_size", TAMANHO_FONTE)

	# Listas de botões: pouco espaço entre eles e nada vaza da página.
	for caixa in [vbox_indice, vbox_subcapitulos]:
		caixa.add_theme_constant_override("separation", SEPARACAO_BOTOES)
		caixa.clip_contents = true

	_montar_indice()
	_ir_para_indice()
	hide()


# ---------------- API pública ----------------

func abrir() -> void:
	if visible:
		return
	_ir_para_indice()
	show()
	aberto.emit()


# Usado pela dica do Investigar: abre direto no tópico certo.
func abrir_em(capitulo: int, subcapitulo: int = -1, aba: Aba = Aba.RECONHECER) -> void:
	if capitulo < 0 or capitulo >= ConteudoLivro.CAPITULOS.size():
		abrir()
		return
	if not visible:
		show()
		aberto.emit()
	_aba = aba
	_mostrar_subcapitulos(capitulo)
	if subcapitulo >= 0:
		_mostrar_texto(subcapitulo)


func fechar() -> void:
	if not visible:
		return
	hide()
	fechado.emit()


# _input (não _unhandled_input): a Raiz com mouse_filter = Stop consome
# o clique antes de ele chegar no unhandled.
func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("clique_direito"):
		_voltar_um_nivel()
		get_viewport().set_input_as_handled()


# ---------------- Navegação ----------------

func _voltar_um_nivel() -> void:
	match _estado:
		Estado.TEXTO:
			_mostrar_subcapitulos(_capitulo_atual)
		Estado.SUBCAPITULOS:
			_ir_para_indice()
		Estado.INDICE:
			fechar()


func _ir_para_indice() -> void:
	_estado = Estado.INDICE
	_capitulo_atual = -1
	_subcapitulo_atual = -1
	pagina_vazia.hide()          # mostra a capa pintada no fundo
	vbox_subcapitulos.hide()
	vbox_indice.show()
	texto.hide()
	titulo.text = "CAPÍTULOS"
	_atualizar_abas()


func _mostrar_subcapitulos(indice_capitulo: int) -> void:
	_estado = Estado.SUBCAPITULOS
	_capitulo_atual = indice_capitulo
	_subcapitulo_atual = -1
	pagina_vazia.show()          # cobre a capa
	vbox_indice.hide()
	vbox_subcapitulos.show()
	texto.show()

	var capitulo: Dictionary = ConteudoLivro.CAPITULOS[indice_capitulo]
	titulo.text = String(capitulo["titulo"]).to_upper()
	texto.text = str(capitulo.get("resumo", "Escolha um tópico na página ao lado."))

	_limpar(vbox_subcapitulos)
	var subs: Array = capitulo["subcapitulos"]
	for i in range(subs.size()):
		var sub: Dictionary = subs[i]
		var botao := _criar_botao_papel(String(sub["titulo"]))
		botao.pressed.connect(_mostrar_texto.bind(i))
		vbox_subcapitulos.add_child(botao)
	_atualizar_abas()


func _mostrar_texto(indice_sub: int) -> void:
	_estado = Estado.TEXTO
	_subcapitulo_atual = indice_sub
	_atualizar_texto()
	_atualizar_abas()


func _trocar_aba(aba: Aba) -> void:
	if _estado != Estado.TEXTO:
		return
	_aba = aba
	_atualizar_texto()
	_atualizar_abas()


func _atualizar_texto() -> void:
	var capitulo: Dictionary = ConteudoLivro.CAPITULOS[_capitulo_atual]
	var subs: Array = capitulo["subcapitulos"]
	var sub: Dictionary = subs[_subcapitulo_atual]
	var chave: String = "reconhecer" if _aba == Aba.RECONHECER else "proteger"
	texto.text = "[b]%s[/b]\n\n%s" % [String(sub["titulo"]), String(sub[chave])]


# ---------------- Abas ----------------

func _atualizar_abas() -> void:
	var em_texto: bool = _estado == Estado.TEXTO
	aba_indice.disabled = _estado == Estado.INDICE
	# Reconhecer/Proteger só existem dentro de um subcapítulo.
	aba_reconhecer.visible = em_texto
	aba_proteger.visible = em_texto
	aba_reconhecer.disabled = _aba == Aba.RECONHECER
	aba_proteger.disabled = _aba == Aba.PROTEGER

	for aba in [aba_indice, aba_reconhecer, aba_proteger]:
		_estilizar_aba(aba)


# disabled == aba atual (o script usa disabled para marcar a selecionada).
# Com texture_disabled vazio, o Godot desenha a texture_normal mesmo
# desabilitado, então um único sprite basta.
# self_modulate (e não modulate) para o Label filho não escurecer junto.
func _estilizar_aba(aba: BaseButton) -> void:
	var ativa: bool = aba.disabled
	aba.self_modulate = Color.WHITE if ativa else COR_ABA_INATIVA


# Garante que a aba é desenhada por cima de tudo no livro e que nenhum
# Control pai a corta. Se a aba aparecia cortada, o culpado era um
# irmão desenhado depois dela (Fundo, PaginaVazia...) ou um pai com
# "Clip Contents" ligado.
func _trazer_aba_para_frente(aba: BaseButton) -> void:
	aba.move_to_front()   # último filho do pai = desenhado por último
	aba.z_index = 10      # reforço: acima de qualquer irmão no mesmo CanvasLayer
	aba.clip_contents = false

	var pai := aba.get_parent()
	while pai is Control:
		(pai as Control).clip_contents = false
		pai = pai.get_parent()


# Centraliza o rótulo girado dentro da aba e escolhe o maior tamanho de
# fonte (até TAMANHO_FONTE) que cabe no comprimento da aba. Assim todas
# as abas ficam com o mesmo tamanho de letra e nada é cortado.
# Para o texto ler de baixo para cima, troque PI / 2.0 por -PI / 2.0.
func _ajustar_rotulo_aba(aba: BaseButton) -> void:
	aba.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	aba.clip_contents = false

	var encontrados := aba.find_children("*", "Label", true, false)
	if encontrados.is_empty():
		push_warning("LivroDicas: aba '%s' não tem um Label filho." % aba.name)
		return
	var rotulo := encontrados[0] as Label

	if aba.size.x <= 0.0 or aba.size.y <= 0.0:
		return

	var tamanho := _tamanho_fonte_que_cabe(rotulo, aba.size.y - 6.0)
	rotulo.add_theme_font_size_override("font_size", tamanho)
	rotulo.add_theme_color_override("font_color", COR_TEXTO_ABA)
	rotulo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rotulo.autowrap_mode = TextServer.AUTOWRAP_OFF
	rotulo.clip_text = false
	rotulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rotulo.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Caixa do rótulo: comprimento = altura da aba, espessura = largura da
	# aba. Girada 90° em torno do próprio centro, cobre a aba exatamente.
	rotulo.size = Vector2(aba.size.y, aba.size.x)
	rotulo.pivot_offset = rotulo.size / 2.0
	rotulo.rotation = PI / 2.0
	rotulo.position = aba.size / 2.0 - rotulo.size / 2.0


func _tamanho_fonte_que_cabe(rotulo: Label, comprimento_max: float) -> int:
	var fonte := rotulo.get_theme_font("font")
	var tamanho := TAMANHO_FONTE
	while tamanho > 6 and fonte.get_string_size(rotulo.text, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho).x > comprimento_max:
		tamanho -= 1
	return tamanho


# ---------------- Montagem ----------------

func _montar_indice() -> void:
	_limpar(vbox_indice)
	for i in range(ConteudoLivro.CAPITULOS.size()):
		var capitulo: Dictionary = ConteudoLivro.CAPITULOS[i]
		var botao := _criar_botao_papel(String(capitulo["titulo"]))
		botao.pressed.connect(_mostrar_subcapitulos.bind(i))
		vbox_indice.add_child(botao)


func _limpar(caixa: Container) -> void:
	for filho in caixa.get_children():
		caixa.remove_child(filho)   # tira da árvore já, sem esperar o queue_free
		filho.queue_free()


func _criar_botao_papel(rotulo: String) -> Button:
	var botao := Button.new()
	botao.text = rotulo
	botao.alignment = HORIZONTAL_ALIGNMENT_LEFT
	botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL   # ocupa só a largura da página
	botao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART     # quebra a linha em vez de vazar
	botao.clip_text = true                                   # texto não impõe largura mínima
	botao.focus_mode = Control.FOCUS_NONE   # Espaço/Enter não reaciona o último botão
	botao.add_theme_font_size_override("font_size", TAMANHO_FONTE)
	botao.add_theme_color_override("font_color", COR_TEXTO_BOTAO)
	botao.add_theme_color_override("font_hover_color", Color.WHITE)
	botao.add_theme_stylebox_override("normal", _estilo_botao(COR_BOTAO))
	botao.add_theme_stylebox_override("hover", _estilo_botao(COR_BOTAO_HOVER))
	botao.add_theme_stylebox_override("pressed", _estilo_botao(COR_BOTAO_HOVER))
	return botao


func _estilo_botao(cor: Color) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = cor
	estilo.set_corner_radius_all(2)
	estilo.content_margin_left = 6
	estilo.content_margin_right = 6
	estilo.content_margin_top = 1
	estilo.content_margin_bottom = 1
	return estilo
