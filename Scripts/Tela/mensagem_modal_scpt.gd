extends Control

const MSG_VERIFICANDO   := "🔍 Verificando..."
const MSG_INTERSECTANDO := "⚠️ Alvo detectado!"
const MSG_FORA          := "Nenhum alvo encontrado."

const TEMPO_TOTAL_BASE := 4.0   # sem nenhum tier do PC comprado


func _ready() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE


# Lê a linha de upgrade "pc" na hora — nunca guarda cópia, então se o
# jogador comprar um tier novo no meio do dia, a próxima verificação já
# usa o tempo atualizado automaticamente (mesmo padrão de todo o resto
# do sistema de upgrades). Público de propósito: gerenciador_inspecao.gd
# usa o mesmo valor pra sincronizar quando revela a cor do quadrante.
func tempo_total_atual() -> float:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_PC)
	if linha == null:
		return TEMPO_TOTAL_BASE
	return linha.valor_efeito_atual(TEMPO_TOTAL_BASE)


func mostrar(intersectou: bool) -> void:
	var tempo_total := tempo_total_atual()
	var metade := tempo_total / 2.0

	# 1. Mostra "Verificando..." primeiro
	$Label.text = MSG_VERIFICANDO
	z_index = 100
	show()

	# 2. Espera metade do tempo total (0 no tier 4 = instantâneo, sem esperar nada)
	if metade > 0.0:
		await get_tree().create_timer(metade).timeout

	# 3. Mostra o resultado
	$Label.text = MSG_INTERSECTANDO if intersectou else MSG_FORA

	# 4. Espera a outra metade antes de fechar
	if metade > 0.0:
		await get_tree().create_timer(metade).timeout
	esconder()

# Usado pelo botão Investigar. Sem a etapa "Verificando...", é uma
# resposta instantânea, exibida por 3s. Não é afetado pelo upgrade do
# PC de propósito — Investigar já é uma mecânica separada, com seu
# próprio limite de uso.
func mostrar_texto(texto: String) -> void:
	$Label.text = texto
	z_index = 100
	show()
	await get_tree().create_timer(3.0).timeout
	esconder()

func esconder() -> void:
	hide()
