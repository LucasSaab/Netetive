extends Control

const MSG_VERIFICANDO   := "🔍 Verificando..."
const MSG_INTERSECTANDO := "⚠️ Alvo detectado!"
const MSG_FORA          := "Nenhum alvo encontrado."

func _ready() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func mostrar(intersectou: bool) -> void:
	# 1. Mostra "Verificando..." primeiro
	$Label.text = MSG_VERIFICANDO
	z_index = 100
	show()

	# 2. Espera alguns segundos
	await get_tree().create_timer(2.0).timeout

	# 3. Mostra o resultado
	$Label.text = MSG_INTERSECTANDO if intersectou else MSG_FORA

	# 4. Fecha depois de mais alguns segundos
	await get_tree().create_timer(2.0).timeout
	esconder()

func esconder() -> void:
	hide()
