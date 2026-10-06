extends Control
class_name BadgeModificador

const TAMANHO := Vector2(40, 40)


func _ready() -> void:
	custom_minimum_size = TAMANHO
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	clip_contents = true

	var icone := get_node_or_null("Icone") as TextureRect
	if icone != null:
		icone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.custom_minimum_size = Vector2.ZERO
		icone.clip_contents = true

	var label_nivel := get_node_or_null("LabelNivel") as Label
	if label_nivel != null:
		label_nivel.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		label_nivel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
		label_nivel.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label_nivel.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		label_nivel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label_nivel.add_theme_font_size_override("font_size", 16)
		label_nivel.add_theme_color_override("font_color", Color.WHITE)
		# CORRIGIDO: define 0 explicitamente em vez de "remover" o
		# override — se o contorno vier do TEMA GLOBAL do projeto (não de
		# uma customização local nesse Label), remover não tem efeito
		# nenhum, porque não havia nada local pra remover. Forçar o
		# valor sempre vence, não importa a origem.
		label_nivel.add_theme_constant_override("outline_size", 0)
		# Cobre também a possibilidade de ser sombra do texto, não contorno.
		label_nivel.add_theme_constant_override("shadow_offset_x", 0)
		label_nivel.add_theme_constant_override("shadow_offset_y", 0)
		label_nivel.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))


# Chamado ANTES do badge entrar na árvore (logo após instantiate(), em
# gerenciador_trabalho.gd) — _ready() ainda não rodou nesse momento,
# então usamos get_node() em vez de @onready, que só olha a hierarquia
# LOCAL de filhos (já existe desde a instanciação, sem depender do nó
# estar "vivo" na SceneTree).
func configurar(mod: ModificadorAtivo) -> void:
	var icone := get_node_or_null("Icone") as TextureRect
	if icone == null:
		push_warning("BadgeModificador: nó 'Icone' não encontrado — confira se o TextureRect na cena se chama exatamente 'Icone'.")
	else:
		var caminho := mod.caminho_icone()
		if caminho != "" and ResourceLoader.exists(caminho):
			icone.texture = load(caminho)
		else:
			push_warning("BadgeModificador: ícone não encontrado para '%s' (%s)." % [mod.nome_exibicao(), caminho])

	tooltip_text = _texto_tooltip(mod)

	var label_nivel := get_node_or_null("LabelNivel") as Label
	if label_nivel == null:
		push_warning("BadgeModificador: nó 'LabelNivel' não encontrado — confira se o Label na cena se chama exatamente 'LabelNivel'.")
		return

	var mostra_nivel := not CalculadoraModificadores.TIPOS_NIVEL_UNICO.has(mod.tipo)
	label_nivel.visible = mostra_nivel
	if mostra_nivel:
		label_nivel.text = str(mod.nivel)


func _texto_tooltip(mod: ModificadorAtivo) -> String:
	if mod.tipo == ModificadorAtivo.Tipo.CAOS:
		var nomes: Array = mod.sub_modificadores.map(func(s): return s.nome_exibicao())
		return "%s\n%s" % [mod.nome_exibicao(), ", ".join(nomes)]
	return mod.nome_exibicao()
