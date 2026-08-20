extends Panel
class_name PainelUpgrades

# =====================================================================
# PainelUpgrades
# ---------------------------------------------------------------------
# UI pura — só desenha o estado atual das 5 linhas (lidas via
# DadosJogo.obter_linha_upgrade) e delega o clique de compra pra
# DadosJogo.comprar_upgrade(). Não calcula preço, não decide bloqueio
# por conta própria além de checar chave_pre_requisito (mesma regra que
# DadosJogo já aplica antes de debitar — aqui é só pra desenhar o
# cadeado, a validação de verdade continua centralizada lá).
#
# Estrutura de cena esperada (raiz Panel):
#   PainelUpgrades (Panel)
#   ├── LabelDinheiro (Label)
#   ├── ScrollContainer (ScrollContainer)
#   │   └── VBoxLinhas (VBoxContainer)
#   └── BtnFechar (Button)
# =====================================================================

@onready var vbox_linhas: VBoxContainer = get_node_or_null("ScrollContainer/VBoxLinhas")
@onready var label_dinheiro: Label = get_node_or_null("LabelDinheiro")
@onready var btn_fechar: Button = get_node_or_null("BtnFechar")

# Ordem fixa de exibição — não depende da ordem de inserção do Dictionary
# (Dictionary em GDScript preserva ordem de inserção, mas depender disso
# seria frágil se BancoDeUpgrades.criar_todas() mudar de ordem no futuro).
const ORDEM_EXIBICAO := [
	"pc",
	"assistente_treinamento",
	"assistente_quantidade",
	"ia_capacidade",
	"ia_eficiencia",
]


func _ready() -> void:
	hide()

	if vbox_linhas == null:
		push_warning("PainelUpgrades: nó 'ScrollContainer/VBoxLinhas' não encontrado — confira a estrutura da cena.")
	if label_dinheiro == null:
		push_warning("PainelUpgrades: nó 'LabelDinheiro' não encontrado — confira a estrutura da cena.")
	if btn_fechar == null:
		push_warning("PainelUpgrades: nó 'BtnFechar' não encontrado — confira a estrutura da cena.")
	else:
		btn_fechar.pressed.connect(fechar)


func abrir() -> void:
	montar_linhas()
	show()


func fechar() -> void:
	hide()


func montar_linhas() -> void:
	if vbox_linhas == null:
		return

	for filho in vbox_linhas.get_children():
		filho.queue_free()

	if label_dinheiro != null:
		label_dinheiro.text = "Saldo: R$ %d" % DadosJogo.dinheiro_jogador

	for chave in ORDEM_EXIBICAO:
		var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(chave)
		if linha == null:
			push_warning("PainelUpgrades: linha '%s' não encontrada em DadosJogo.upgrades." % chave)
			continue
		vbox_linhas.add_child(_criar_linha_ui(linha))


func _criar_linha_ui(linha: LinhaUpgrade) -> Control:
	var caixa := VBoxContainer.new()

	var titulo := Label.new()
	titulo.text = "%s — tier %d/%d" % [linha.nome, linha.tier_atual, linha.tiers.size()]
	caixa.add_child(titulo)

	var bloqueada := linha.chave_pre_requisito != "" and not _pre_requisito_atendido(linha.chave_pre_requisito)

	if bloqueada:
		var msg := Label.new()
		var linha_pre: LinhaUpgrade = DadosJogo.obter_linha_upgrade(linha.chave_pre_requisito)
		var nome_pre := linha_pre.nome if linha_pre != null else linha.chave_pre_requisito
		msg.text = "🔒 Bloqueada até comprar \"%s\" tier 1" % nome_pre
		caixa.add_child(msg)
	elif linha.esta_no_maximo():
		var msg := Label.new()
		msg.text = "✅ Tier máximo atingido"
		caixa.add_child(msg)
	else:
		var tier: TierUpgrade = linha.proximo_tier()
		var linha_h := HBoxContainer.new()

		var descricao := Label.new()
		descricao.text = tier.descricao
		descricao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		linha_h.add_child(descricao)

		var btn_comprar := Button.new()
		var pode_pagar := DadosJogo.dinheiro_jogador >= tier.preco
		btn_comprar.text = "Comprar (R$ %d)" % tier.preco
		btn_comprar.disabled = not pode_pagar
		btn_comprar.pressed.connect(_on_comprar_pressionado.bind(linha.chave))
		linha_h.add_child(btn_comprar)

		caixa.add_child(linha_h)

	caixa.add_child(HSeparator.new())
	return caixa


func _pre_requisito_atendido(chave_pre_requisito: String) -> bool:
	var linha_pre: LinhaUpgrade = DadosJogo.obter_linha_upgrade(chave_pre_requisito)
	return linha_pre != null and linha_pre.tier_atual >= 1


# Delega a compra de verdade pra DadosJogo — essa é a ÚNICA porta de
# entrada que muda dinheiro_jogador/tier_atual (ver comentário em
# DadosJogo.comprar_upgrade()). Remonta a lista inteira depois, pra
# atualizar saldo, preços e desbloqueios de uma vez.
func _on_comprar_pressionado(chave: String) -> void:
	var sucesso := DadosJogo.comprar_upgrade(chave)
	if not sucesso:
		push_warning("PainelUpgrades: compra de '%s' falhou (ver warning anterior de DadosJogo)." % chave)
	montar_linhas()


func _on_btn_upgrades_pressed() -> void:
	pass # Replace with function body.
