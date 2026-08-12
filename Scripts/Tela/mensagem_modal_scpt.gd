extends Control

const MSG_VERIFICANDO   := "🔍 Verificando..."
const MSG_INTERSECTANDO := "⚠️ Alvo detectado!"
const MSG_FORA          := "Nenhum alvo encontrado."

func _ready() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func mostrar(intersectou: bool) -> void:
	$Label.text = MSG_VERIFICANDO
	z_index = 100
	show()
	await get_tree().create_timer(2.0).timeout
	$Label.text = MSG_INTERSECTANDO if intersectou else MSG_FORA
	await get_tree().create_timer(2.0).timeout
	esconder()

# Novo — usado pelo botão Investigar. Sem a etapa "Verificando...",
# é uma resposta instantânea, exibida por 3s.
func mostrar_texto(texto: String) -> void:
	$Label.text = texto
	z_index = 100
	show()
	await get_tree().create_timer(3.0).timeout
	esconder()

func esconder() -> void:
	hide()
