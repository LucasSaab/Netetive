extends TextureButton

# =====================================================================
# BtnUpgrades
# ---------------------------------------------------------------------
# Botão do Escritório que abre o PainelUpgrades. Mesmo padrão de
# Quadro_avisos/Iniciar.gd: conectado ao sinal `pressed` diretamente
# pelo editor (aba Node > Signals), não via connect() em código — por
# isso a função se chama _on_pressed(), convenção já usada no projeto.
# =====================================================================

@export var painel_upgrades: Control   # arraste o nó PainelUpgrades aqui no Inspetor


func _on_pressed() -> void:
	if painel_upgrades == null:
		push_warning("BtnUpgrades: painel_upgrades não atribuído no Inspetor.")
		return

	if painel_upgrades.has_method("abrir"):
		painel_upgrades.abrir()
	else:
		push_warning("BtnUpgrades: painel_upgrades atribuído não tem o método abrir().")
