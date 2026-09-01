# Netetive — Apêndice de Código: Sistema de Diagnóstico e Veredito Diferido

> Scripts criados ou modificados durante a implementação do sistema de trabalho com diagnóstico por múltipla escolha e resultado revelado apenas no fim do expediente. Complementa `netetive.md` (seção 3.4) e `netetive_status.md`.
>
> **Última atualização deste documento:** 26/08/2026

---

## Sumário

**HUD + Trabalhos de Scareware/Ransomware v3.5 (estado atual):**

34. [`hud_manager.gd`](#34-hud_managergd-v35--novo-le-dadosjogo-em-vez-de-global) — novo, `Node`, portado/adaptado de `score_system`
35. [`icone_dinheiro.gd`](#35-icone_dinheirogd-v35--novo-troca-de-sprite-da-carteira) — novo, `TextureRect`, portado/adaptado de `score_system`
36. [`banco_de_trabalhos.gd`](#24-banco_de_trabalhosgd-novo--módulo-de-dados-extraído-de-dadosjogogd) — v3.5, adiciona `_criar_trabalho_scareware()` e `_criar_trabalho_ransomware()` (ver seção 24)
37. [`conteudo_livro.gd`](#7-conteudo_livrogd) — v3.5, capítulo 6 trocado de "Senha Fraca" pra "Scareware" (ver seção 7)

**Sistema de Fama v3.4 (estado atual):**

33. [`calculadora_fama.gd`](#33-calculadora_famagd-v34--novo-curva-não-linear-de-trabalhosdia) — novo, `RefCounted` estático

**Sistema de Upgrades v3.3 (PC, Assistente, IA):**

25. [`tier_upgrade.gd`](#25-tier_upgradegd-v33--novo-degrau-individual-de-upgrade) — novo, `Resource`
26. [`linha_upgrade.gd`](#26-linha_upgradegd-v33--novo-progressão--tier_atual) — novo, `Resource`
27. [`banco_de_upgrades.gd`](#27-banco_de_upgradesgd-v33--novo-módulo-de-dados-das-5-linhas) — novo, módulo estático
28. [`gerenciador_assistente.gd`](#28-gerenciador_assistentegd-v33--novo-fila-com-tempo-simulado) — novo, `Node`
29. [`gerenciador_ia_noturna.gd`](#29-gerenciador_ia_noturnagd-v33--novo-resolução-overnight) — v3.4, `fama_ganha` com Eficiência
30. [`calculadora_upkeep.gd`](#30-calculadora_upkeepgd-v33--novo-soma-do-upkeep-diário) — novo, `RefCounted` estático
31. [`painel_upgrades.gd`](#31-painel_upgradesgd-v33--novo-ui-de-compra) — novo, `Panel`
32. [`btn_upgrades.gd`](#32-btn_upgradesgd-v33--novo-botão-do-escritório) — novo, `TextureButton`

**Ciclo do Dia v3.2 (Iniciar Dia + Relatório de Fim de Expediente):**

0. [`relatorio_dia.gd`](#0-relatorio_diagd-v32--novo-tela-de-resumo-do-dia) — v3.3, desconta upkeep antes de creditar

**Sistema de trabalho v3.1 (grid + popup unificado + botão Investigar):**

1. [`resultado_trabalho.gd`](#1-resultado_trabalhogd) — v3.2, campos novos (tentativas/horário)
2. [`painel_diagnostico.gd`](#2-painel_diagnosticogd-️-descontinuado-v2v3) — 🗑️ descontinuado
3. [`DadosJogo.gd`](#3-dadosjogogd-v3--enxuto-dados-extraídos-pra-banco_de_trabalhosgd) — v3.3, `upgrades` + `comprar_upgrade()`
4. [`coordenador_trabalho.gd`](#4-coordenador_trabalhogd-v31--integração-com-investigar) — v3.3, integração com GerenciadorAssistente
5. [`gerenciador_trabalho.gd`](#5-gerenciador_trabalhogd-v3--item-ativo-simplificado-sem-diagnosticarterminar) — v3.3, botão Delegar
6. [`gerenciador_inspecao.gd`](#6-gerenciador_inspecaogd-v31--grid-3xn--popup-unificado--investigar) — v3.3, tempo de verificação lê o upgrade PC
7. [`conteudo_livro.gd`](#7-conteudo_livrogd) — modificado (só a linha alterada)
8. [`alvo_inspecao.gd`](#8-alvo_inspecaogd-v31--campo-dica-pro-botão-investigar) — v3.1 (campo `dica`)
9. [`trabalho_inspecao.gd`](#9-trabalho_inspecaogd-v3--linhas_grid-campos-órfãos-removidos) — v3
12. [`nova_aba_script.gd`](#12-nova_aba_scriptgd-v31--popup-com-5-botões-incluindo-investigar) — v3.1 (5º botão)
13. [`mensagem_modal_scpt.gd`](#13-mensagem_modal_scptgd-v31--novo-método-mostrar_texto-pro-investigar) — v3.3, tempo lê o upgrade PC
20. [`area_alvo.gd`](#20-area_alvogd-v3--campos-de-estado-por-quadrante) — v3
21. [`trabalho_agendado.gd`](#21-trabalho_agendadogd-v31--campo-investigar_usado) — v3.1 (campo `investigar_usado`)
24. [`banco_de_trabalhos.gd`](#24-banco_de_trabalhosgd-novo--módulo-de-dados-extraído-de-dadosjogogd) — módulo de dados, agora com `dica`

**Scripts confirmados sem alteração desde as rodadas anteriores:**

10. [`gerenciador_expediente.gd`](#10-gerenciador_expedientegd) — relógio do dia
11. [`area_clique_inspecao.gd`](#11-area_clique_inspecaogd)
14. [`CaixaDeSelecao.gd`](#14-caixadeselecaogd) — vazio de propósito
15. [`livro_dicas.gd`](#15-livro_dicasgd)
16. [`btn_abrir_livro.gd`](#16-btn_abrir_livrogd)
17. [`Main_select_script.gd`](#17-main_select_scriptgd) — v3.3, dispara GerenciadorIANoturna antes do RelatorioDia
18. [`menu_trabalhos.gd`](#18-menu_trabalhosgd) — ⚠️ possível sistema órfão/duplicado
19. [Scripts legados do sistema de post-it](#19-scripts-legados-sistema-de-post-it--candidatos-a-remoção) — `lembrete.gd`, `painel_trabalho.gd`, `mensagem_modal.gd`, `button-inspecionar.gd`
22. [`Para_inicial.gd`](#22-para_inicialgd) — caminho hardcoded (pendência catalogada)
23. [`caixa_selecao.gd`](#23-caixa_selecaogd--órfão-confirmado) — ⚠️ órfão confirmado, candidato a remoção

---

## 0. `relatorio_dia.gd` (v3.2 — novo, tela de resumo do dia)

**Status:** modificado (v3.4 — labels separados + fama) | **Tipo:** `Control`, `class_name RelatorioDia` | **Cena:** `res://Scenes/RelatorioDia.tscn`

> **Atualização v3.3 (Sistema de Upgrades):** `montar_relatorio()` passou a descontar `CalculadoraUpkeep.calcular_total()` (seção 30) antes de creditar dinheiro — pode deixar `dinheiro_jogador` **negativo de propósito** (dívida realista).
>
> **Atualização v3.4 (Sistema de Fama):** `LabelResumo` deixou de concentrar todos os números numa string só — virou 3 labels separados. `LabelResumo` agora é só um texto fixo de status ("Dia concluído"). `LabelDinheiro` (novo) mostra só o dinheiro ganho no dia (`"R$ %d"`). `LabelFama` (novo) mostra só a fama ganha no dia (`"+%d fama"`). O cálculo interno não muda — soma de `resultado.recompensa`/`resultado.fama_ganha`, upkeep só no dinheiro, crédito em `DadosJogo.dinheiro_jogador`/`DadosJogo.fama_jogador`. Cada linha individual (`_criar_linha()`) também passou a mostrar a fama daquele trabalho específico.

Tela exibida quando `GerenciadorExpediente.expediente_encerrado` dispara. Itera `DadosJogo.resultados_do_dia`, monta uma linha por trabalho com o veredito completo, e credita o dinheiro/fama do dia — é aqui, não durante o expediente, que o resultado é finalmente revelado ao jogador.

**Estrutura de cena exigida** (raiz `Control`):
```
RelatorioDia (Control)
├── LabelResumo (Label)             ← v3.4: texto fixo "Dia concluído"
├── LabelDinheiro (Label)           ← v3.4, novo
├── LabelFama (Label)               ← v3.4, novo
├── ScrollContainer (ScrollContainer)
│   └── VBoxResultados (VBoxContainer)
└── BtnVoltar (Button)
```

```gdscript
extends Control
class_name RelatorioDia

@onready var vbox_resultados: VBoxContainer = get_node_or_null("ScrollContainer/VBoxResultados")
@onready var label_resumo: Label = get_node_or_null("LabelResumo")
@onready var label_dinheiro: Label = get_node_or_null("LabelDinheiro")
@onready var label_fama: Label = get_node_or_null("LabelFama")
@onready var btn_voltar: Button = get_node_or_null("BtnVoltar")


func _ready() -> void:
	if vbox_resultados == null:
		push_warning("RelatorioDia: nó 'ScrollContainer/VBoxResultados' não encontrado — confira a estrutura da cena.")

	if label_resumo == null:
		push_warning("RelatorioDia: nó 'LabelResumo' não encontrado — confira a estrutura da cena.")

	if label_dinheiro == null:
		push_warning("RelatorioDia: nó 'LabelDinheiro' não encontrado — confira a estrutura da cena.")

	if label_fama == null:
		push_warning("RelatorioDia: nó 'LabelFama' não encontrado — confira a estrutura da cena.")

	if btn_voltar == null:
		push_warning("RelatorioDia: nó 'BtnVoltar' não encontrado — confira a estrutura da cena.")
	else:
		btn_voltar.pressed.connect(_on_voltar_pressed)

	montar_relatorio()


func montar_relatorio() -> void:
	if vbox_resultados == null:
		return

	for filho in vbox_resultados.get_children():
		filho.queue_free()

	var total_certos := 0
	var total_dinheiro := 0
	var total_fama := 0

	for resultado in DadosJogo.resultados_do_dia:
		vbox_resultados.add_child(_criar_linha(resultado))

		if resultado.acertou_no_geral:
			total_certos += 1

		total_dinheiro += resultado.recompensa
		total_fama += resultado.fama_ganha

	# Calcula a manutenção diária
	var upkeep_total := CalculadoraUpkeep.calcular_total()

	# Atualiza o dinheiro e a fama do jogador
	DadosJogo.dinheiro_jogador += total_dinheiro - upkeep_total
	DadosJogo.fama_jogador += total_fama

	# Mostra somente o que foi ganho no dia
	if label_dinheiro != null:
		label_dinheiro.text = "R$ %d" % total_dinheiro

	if label_fama != null:
		label_fama.text = "+%d fama" % total_fama

	# Resumo geral
	if label_resumo != null:
		label_resumo.text = "%d/%d trabalhos corretos — R$ %d ganhos, R$ %d de manutenção — saldo: R$ %d | +%d fama (total: %d)" % [
			total_certos,
			DadosJogo.resultados_do_dia.size(),
			total_dinheiro,
			upkeep_total,
			DadosJogo.dinheiro_jogador,
			total_fama,
			DadosJogo.fama_jogador
		]


func _criar_linha(resultado: ResultadoTrabalho) -> Control:
	var vbox := VBoxContainer.new()

	var titulo := Label.new()
	var veredito := "✅" if resultado.acertou_no_geral else "❌"

	titulo.text = "%s  %s" % [
		veredito,
		resultado.agendado.trabalho.titulo
	]

	vbox.add_child(titulo)

	var detalhe := Label.new()

	detalhe.text = "Alvo encontrado: %s | Diagnóstico: %s (%s) | Tentativas: %d certas / %d erradas | Tempo: %.0f min | R$ %d | +%d fama" % [
		"Sim" if resultado.achou_alvo_correto else "Não",
		resultado.diagnostico_escolhido if resultado.diagnostico_escolhido != "" else "nenhum",
		"correto" if resultado.diagnostico_correto else "incorreto",
		resultado.tentativas_certas,
		resultado.tentativas_erradas,
		resultado.tempo_gasto_minutos(),
		resultado.recompensa,
		resultado.fama_ganha
	]

	vbox.add_child(detalhe)

	vbox.add_child(HSeparator.new())

	return vbox


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Escritorio.tscn")
```

> **Nós lidos via `get_node_or_null()`, não `$caminho`:** essa escolha foi deliberada depois de um bug real — anexar o script num nó fora da hierarquia esperada (ex: dentro de `Tela.tscn`, raiz `Node2D`, em vez de numa cena própria com raiz `Control`) gerava `Node not found` fatal com `$`. Com `get_node_or_null()`, o pior caso é um `push_warning()` específico dizendo qual nó está faltando, sem derrubar a cena inteira.
>
> **Nota:** o `LabelResumo` continua existindo e sendo o mais "completo" tecnicamente (mostra todos os números numa string), mas visualmente a intenção da v3.4 é que ele fique só com "Dia concluído" — o texto detalhado com todos os números foi movido pro código, mas o campo `label_resumo.text` no script atual ainda escreve a string longa por cima. Se quiser seguir exatamente o design pedido (label_resumo só com "Dia concluído"), o texto detalhado precisa ser removido dessa atribuição e simplificado — ver observação em `netetive.md` seção 3.7.
>
> **Melhoria pendente:** `Main_select_script._on_expediente_encerrado()` (seção 17) carrega essa cena por string de caminho (`"res://Scenes/RelatorioDia.tscn"`), o que já causou um erro de carregamento por divergência de nome/pasta. Trocar por `@export var cena_relatorio: PackedScene` no Inspetor resolveria isso de forma mais robusta.

---

## 1. `resultado_trabalho.gd`

**Status:** modificado (v3.4 — campo `fama_ganha`) | **Tipo:** `Resource`, `class_name ResultadoTrabalho`

> **Atualização v3.4 (Sistema de Fama):** novo `@export var fama_ganha: int = 0`, calculado dentro de `finalizar()` junto com `recompensa`. Qualquer caminho que já chama `DadosJogo.finalizar_trabalho()` (jogador manual, Assistente) ganha fama automaticamente, sem mudança adicional nesses arquivos. Só `gerenciador_ia_noturna.gd` (seção 29) define `fama_ganha` manualmente, porque aplica a % de Eficiência, que `finalizar()` não conhece.

Guarda o veredito (pendente ou já fechado) de uma ocorrência específica de trabalho no dia.

```gdscript
extends Resource
class_name ResultadoTrabalho

var agendado: TrabalhoAgendado   # sem @export: TrabalhoAgendado é RefCounted, não Resource
@export var achou_alvo_correto: bool = false
@export var diagnostico_escolhido: String = ""
@export var diagnostico_correto: bool = false
@export var acertou_no_geral: bool = false
@export var recompensa: int = 0

# v3.2 — ciclo do dia / relatório detalhado
@export var tentativas_certas: int = 0
@export var tentativas_erradas: int = 0
@export var hora_inicio: float = 0.0
@export var hora_fim: float = 0.0

# v3.4 — sistema de fama
@export var fama_ganha: int = 0

func registrar_tentativa(acertou: bool) -> void:
	if acertou:
		tentativas_certas += 1
	else:
		tentativas_erradas += 1

func tempo_gasto_minutos() -> float:
	return max(0.0, hora_fim - hora_inicio) * 60.0

func finalizar() -> void:
	acertou_no_geral = achou_alvo_correto and diagnostico_correto
	recompensa = agendado.recompensa_dinheiro if acertou_no_geral else 0
	fama_ganha = agendado.trabalho.recompensa_fama if acertou_no_geral else 0
```

---

## 2. `painel_diagnostico.gd` 🗑️ descontinuado (v2/v3)

**Status:** órfão — sem uso desde que o diagnóstico migrou pra dentro da `NovaAba` | **Tipo:** `Control`, `class_name PainelDiagnostico`

Mantido aqui só como registro histórico. Nas versões v2/v3 do sistema de trabalho, toda a UI de diagnóstico passou a viver dentro de `nova_aba_script.gd` (seção 12) — este arquivo não é mais referenciado por nenhum `@export`. Candidato a remoção do projeto.

```gdscript
extends Control
class_name PainelDiagnostico

signal diagnostico_escolhido(agendado: TrabalhoAgendado, opcao: String)

@onready var vbox_opcoes: VBoxContainer = $VBoxOpcoes
@onready var label_titulo: Label = $LabelTitulo

var _agendado_atual: TrabalhoAgendado


func _ready() -> void:
	hide()


func abrir(agendado: TrabalhoAgendado) -> void:
	_agendado_atual = agendado
	label_titulo.text = "Qual o problema deste site?"

	for filho in vbox_opcoes.get_children():
		filho.queue_free()

	var opcoes := DadosJogo.gerar_opcoes_diagnostico(agendado.trabalho)
	for opcao in opcoes:
		var botao := Button.new()
		botao.text = opcao
		botao.pressed.connect(_on_opcao_pressionada.bind(opcao))
		vbox_opcoes.add_child(botao)

	show()


func _on_opcao_pressionada(opcao: String) -> void:
	diagnostico_escolhido.emit(_agendado_atual, opcao)
	hide()
```

---

## 3. `DadosJogo.gd` (v3 — enxuto, dados extraídos pra `banco_de_trabalhos.gd`)

**Status:** modificado — arquivo completo (Autoload) (v3.4 — sistema de fama)

> **Atualização v3.3 (Sistema de Upgrades):** novo `var upgrades: Dictionary = {}` (`String -> LinhaUpgrade`), populado por `BancoDeUpgrades.criar_todas()` no `_ready()`. Novo `comprar_upgrade(chave: String) -> bool` — única porta de entrada pra avançar um tier: valida existência da linha → tier máximo → pré-requisito (`chave_pre_requisito`) → saldo, nessa ordem, só então debita `dinheiro_jogador` e incrementa `linha.tier_atual`. Novo `obter_linha_upgrade(chave: String) -> LinhaUpgrade` (helper de leitura pra UI) e `_pre_requisito_atendido()` (privado). Ver `netetive.md` seção 3.6 pro código completo dessas funções.

> **Atualização v3.4 (Sistema de Fama):** novo `var fama_jogador: int = 0`, ao lado de `dinheiro_jogador`. Sem função própria pra creditar — é `relatorio_dia.gd` (seção 0) quem soma `resultado.fama_ganha` e incrementa direto, mesmo padrão já usado pro dinheiro.

A definição estática dos trabalhos (as 5 funções `_criar_trabalho_*()`) saiu daqui e foi pra um módulo próprio, `banco_de_trabalhos.gd` (seção 24) — `DadosJogo` agora cuida só de **estado em runtime**.

```gdscript
extends Node
# Banco de dados global do jogo. A DEFINIÇÃO dos trabalhos (textos,
# imagem, alvos) mora em banco_de_trabalhos.gd — este arquivo cuida só
# do ESTADO em runtime: dinheiro, agenda do dia, resultados pendentes.

var banco_de_trabalhos: Array[TrabalhoInspecao] = []

var dinheiro_jogador: int = 0
var fama_jogador: int = 0   # v3.4 — cresce com trabalhos concluídos; controla quantidade_trabalhos_dia (ver GerenciadorExpediente + CalculadoraFama)

# ---------------------------------------------------------------------
# Sistema de expediente (agenda do dia) — usado por gerenciador_expediente.gd
# ---------------------------------------------------------------------
const HORA_INICIO_EXPEDIENTE: float = 8.0   # 08:00 — ajustar se o design pedir outro horário
const HORA_FIM_EXPEDIENTE: float = 17.0     # 17:00 — ajustar se o design pedir outro horário

var trabalhos_do_dia: Array[TrabalhoAgendado] = []
var trabalhos_concluidos_hoje: int = 0

# ---------------------------------------------------------------------
# Sistema de diagnóstico/veredito diferido — resultado só é revelado
# no fim do expediente. Chave = TrabalhoAgendado (não TrabalhoInspecao!),
# porque o mesmo TrabalhoInspecao pode ser sorteado mais de uma vez no
# mesmo dia (pick_random em sortear_agenda_do_dia) e cada ocorrência
# precisa do seu próprio resultado.
# ---------------------------------------------------------------------
var resultados_pendentes: Dictionary = {}   # TrabalhoAgendado -> ResultadoTrabalho
var resultados_do_dia: Array[ResultadoTrabalho] = []


func _ready() -> void:
	banco_de_trabalhos = BancoDeTrabalhos.criar_todos()


# ---------------------------------------------------------------------
# Monta a agenda do dia: sorteia `quantidade_trabalhos_dia` trabalhos do
# banco, deixa os `quantidade_trabalhos_iniciais` primeiros já disponíveis
# no início do expediente, e distribui o restante aleatoriamente ao longo
# do horário de trabalho. Ordenado por horario_aparicao para que
# gerenciador_expediente possa percorrer com um único índice crescente.
# ---------------------------------------------------------------------
func sortear_agenda_do_dia(quantidade_trabalhos_dia: int, quantidade_trabalhos_iniciais: int) -> void:
	trabalhos_do_dia.clear()
	trabalhos_concluidos_hoje = 0
	resetar_resultados_do_dia()

	if banco_de_trabalhos.is_empty():
		push_warning("DadosJogo: banco_de_trabalhos vazio, não há como sortear agenda.")
		return

	var duracao_expediente := HORA_FIM_EXPEDIENTE - HORA_INICIO_EXPEDIENTE
	var lista: Array[TrabalhoAgendado] = []

	for i in range(quantidade_trabalhos_dia):
		var agendado := TrabalhoAgendado.new()
		agendado.trabalho = banco_de_trabalhos.pick_random()
		agendado.recompensa_dinheiro = agendado.trabalho.recompensa_base + randi_range(-15, 25)

		if i < quantidade_trabalhos_iniciais:
			agendado.horario_aparicao = HORA_INICIO_EXPEDIENTE
		else:
			agendado.horario_aparicao = HORA_INICIO_EXPEDIENTE + randf() * duracao_expediente

		lista.append(agendado)

	lista.sort_custom(func(a, b): return a.horario_aparicao < b.horario_aparicao)
	trabalhos_do_dia = lista


# Chamado por gerenciador_expediente.gd quando o horário de um trabalho
# agendado chega. Aqui é só o registro de estado — a criação do post-it
# visual na tela ainda precisa ser conectada (ver observação abaixo).
func disponibilizar_trabalho(agendado: TrabalhoAgendado) -> void:
	agendado.apareceu = true


# ---------------------------------------------------------------------
# DIAGNÓSTICO / VEREDITO DIFERIDO
# ---------------------------------------------------------------------

# Chamado por gerenciador_trabalho.gd quando o jogador ACEITA um trabalho
# (some de Disponíveis, vai pra Ativos) — abre o resultado pendente daquela
# ocorrência específica.
func iniciar_resultado_pendente(agendado: TrabalhoAgendado, hora_atual: float = 0.0) -> void:
	var resultado := ResultadoTrabalho.new()
	resultado.agendado = agendado
	resultado.hora_inicio = hora_atual
	resultados_pendentes[agendado] = resultado


# Chamado por CoordenadorTrabalho a cada inspeção concluída (acerto ou erro),
# pra alimentar tentativas_certas/tentativas_erradas do relatório detalhado.
func registrar_tentativa_inspecao(agendado: TrabalhoAgendado, acertou: bool) -> void:
	if resultados_pendentes.has(agendado):
		resultados_pendentes[agendado].registrar_tentativa(acertou)


# Chamado quando o jogador confirma "Encerrar" no popup. Fecha o resultado
# pendente (calcula acertou_no_geral/recompensa, grava hora_fim) e move pra
# lista do dia. Retorna o ResultadoTrabalho pra quem chamou decidir o que
# fazer (ex: creditar dinheiro), sem revelar nada na tela.
func finalizar_trabalho(agendado: TrabalhoAgendado, hora_atual: float = 0.0) -> ResultadoTrabalho:
	if not resultados_pendentes.has(agendado):
		push_warning("DadosJogo: finalizar_trabalho chamado sem resultado pendente para esse agendado.")
		return null

	var resultado: ResultadoTrabalho = resultados_pendentes[agendado]
	resultado.hora_fim = hora_atual
	resultado.finalizar()
	resultados_do_dia.append(resultado)
	resultados_pendentes.erase(agendado)
	return resultado


func resetar_resultados_do_dia() -> void:
	resultados_pendentes.clear()
	resultados_do_dia.clear()


# Acha o alvo SUSPEITO do trabalho e devolve o título do capítulo do
# LivroDicas correspondente ao capitulo_relacionado dele.
func titulo_capitulo_correto(trabalho: TrabalhoInspecao) -> String:
	if trabalho == null:
		return ""
	for alvo in trabalho.alvos:
		if alvo.tipo == AlvoInspecao.Tipo.SUSPEITO:
			var indice: int = alvo.capitulo_relacionado
			if indice >= 0 and indice < ConteudoLivro.PAGINAS.size():
				return ConteudoLivro.PAGINAS[indice].get("titulo", "")
			push_warning("DadosJogo: capitulo_relacionado %d fora do range de ConteudoLivro.PAGINAS." % indice)
			return ""
	push_warning("DadosJogo: trabalho '%s' não tem alvo SUSPEITO." % trabalho.titulo)
	return ""


# Monta as opções de múltipla escolha do diagnóstico: a correta + distratores
# aleatórios tirados dos outros capítulos do livro.
func gerar_opcoes_diagnostico(trabalho: TrabalhoInspecao, quantidade: int = 3) -> Array[String]:
	var correta := titulo_capitulo_correto(trabalho)
	var opcoes: Array[String] = []
	if correta != "":
		opcoes.append(correta)

	var titulos_disponiveis: Array[String] = []
	for pagina in ConteudoLivro.PAGINAS:
		var titulo: String = pagina.get("titulo", "")
		if titulo != "" and titulo != correta:
			titulos_disponiveis.append(titulo)

	titulos_disponiveis.shuffle()
	for titulo in titulos_disponiveis:
		if opcoes.size() >= quantidade:
			break
		opcoes.append(titulo)

	opcoes.shuffle()
	return opcoes
```

---

## 4. `coordenador_trabalho.gd` (v3.2 — integração com o relógio simulado)

**Status:** modificado — arquivo completo (v3.3 — integração com GerenciadorAssistente)

> **Atualização v3.3 (Sistema de Upgrades):** novo `@export var gerenciador_assistente: Node`. Novo `_on_delegar_solicitado(agendado)` — escuta `gerenciador_trabalho.delegar_solicitado`, chama `gerenciador_assistente.delegar(agendado)`; se o trabalho delegado era o que estava aberto na inspeção, limpa a tela (mesma limpeza do "Encerrar" manual). Novo `_on_assistente_concluido(agendado, acertou)` — escuta `gerenciador_assistente.trabalho_assistente_concluido`, chama `gerenciador_trabalho.marcar_trabalho_concluido()` e mostra um toast próprio. O toast foi refatorado: `_mostrar_feedback_encerramento()` virou uma chamada pro novo `_mostrar_feedback(texto)` genérico, reaproveitado também por `_mostrar_feedback_assistente(titulo, acertou)`.

```gdscript
extends Node

@export var gerenciador_trabalho: Node
@export var gerenciador_inspecao: Node
@export var gerenciador_expediente: Node   # novo (v3.2) — lê hora_atual pro relatório
@export var site_textura: TextureRect

var _agendado_atual: TrabalhoAgendado = null
var _dialogo_confirmacao: ConfirmationDialog = null
var _label_feedback: Label = null


func _ready() -> void:
	if gerenciador_trabalho != null:
		gerenciador_trabalho.trabalho_selecionado.connect(_on_trabalho_selecionado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_trabalho não atribuído no Inspetor.")

	if gerenciador_inspecao != null and gerenciador_inspecao.has_signal("inspecao_concluida"):
		gerenciador_inspecao.inspecao_concluida.connect(_on_inspecao_concluida)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído (ou sem o sinal inspecao_concluida).")

	if gerenciador_inspecao != null and gerenciador_inspecao.has_signal("diagnostico_escolhido"):
		gerenciador_inspecao.diagnostico_escolhido.connect(_on_diagnostico_escolhido)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído (ou sem o sinal diagnostico_escolhido).")

	if gerenciador_inspecao != null and gerenciador_inspecao.has_signal("encerrar_solicitado"):
		gerenciador_inspecao.encerrar_solicitado.connect(_on_encerrar_solicitado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído (ou sem o sinal encerrar_solicitado).")

	if gerenciador_inspecao != null and gerenciador_inspecao.has_signal("investigar_usado"):
		gerenciador_inspecao.investigar_usado.connect(_on_investigar_usado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído (ou sem o sinal investigar_usado).")

	if gerenciador_expediente == null:
		push_warning("CoordenadorTrabalho: gerenciador_expediente não atribuído — horários do relatório ficarão zerados (0.0).")

	_dialogo_confirmacao = ConfirmationDialog.new()
	_dialogo_confirmacao.confirmed.connect(_on_confirmar_encerramento)
	add_child(_dialogo_confirmacao)

	_label_feedback = Label.new()
	_label_feedback.add_theme_font_size_override("font_size", 20)
	_label_feedback.add_theme_color_override("font_color", Color.WHITE)
	_label_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label_feedback.hide()
	_label_feedback.z_index = 200
	add_child(_label_feedback)


func _hora_atual() -> float:
	if gerenciador_expediente != null and "hora_atual" in gerenciador_expediente:
		return gerenciador_expediente.hora_atual
	return 0.0


func _on_trabalho_selecionado(agendado: TrabalhoAgendado) -> void:
	if agendado == null or agendado.trabalho == null:
		push_warning("CoordenadorTrabalho: trabalho_selecionado chegou com agendado/trabalho nulo.")
		return

	_agendado_atual = agendado
	var trabalho: TrabalhoInspecao = agendado.trabalho
	print("Inspecionando agora: ", trabalho.titulo)

	if site_textura != null and trabalho.imagem_site != null:
		site_textura.texture = trabalho.imagem_site

	if gerenciador_inspecao != null and gerenciador_inspecao.has_method("montar_alvos"):
		gerenciador_inspecao.montar_alvos(trabalho)
		gerenciador_inspecao.definir_investigar_disponivel(not agendado.investigar_usado)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_inspecao não atribuído ou sem montar_alvos().")

	# v3.2: iniciar_resultado_pendente() migrou de gerenciador_trabalho.gd pra
	# cá — faz mais sentido abrir aqui, com hora_inicio real do momento em
	# que a inspeção começa. Guarda contra recriar o resultado se o jogador
	# reentra no mesmo trabalho ativo mais de uma vez.
	if DadosJogo.resultados_pendentes.has(agendado):
		return
	DadosJogo.iniciar_resultado_pendente(agendado, _hora_atual())


func _on_inspecao_concluida(acertou: bool, trabalho: TrabalhoInspecao) -> void:
	if _agendado_atual == null or _agendado_atual.trabalho != trabalho:
		push_warning("CoordenadorTrabalho: inspecao_concluida não bate com o agendado atual.")
		return

	# v3.2: registra toda tentativa (certa ou errada) pro relatório detalhado.
	DadosJogo.registrar_tentativa_inspecao(_agendado_atual, acertou)

	if acertou and DadosJogo.resultados_pendentes.has(_agendado_atual):
		DadosJogo.resultados_pendentes[_agendado_atual].achou_alvo_correto = true


func _on_diagnostico_escolhido(opcao: String) -> void:
	if _agendado_atual == null or not DadosJogo.resultados_pendentes.has(_agendado_atual):
		return

	var resultado: ResultadoTrabalho = DadosJogo.resultados_pendentes[_agendado_atual]
	resultado.diagnostico_escolhido = opcao
	resultado.diagnostico_correto = (opcao == DadosJogo.titulo_capitulo_correto(_agendado_atual.trabalho))


func _on_investigar_usado() -> void:
	if _agendado_atual != null:
		_agendado_atual.investigar_usado = true


func _on_encerrar_solicitado() -> void:
	if _agendado_atual == null:
		push_warning("CoordenadorTrabalho: encerrar solicitado sem agendado atual.")
		return

	var diagnostico := ""
	if DadosJogo.resultados_pendentes.has(_agendado_atual):
		diagnostico = DadosJogo.resultados_pendentes[_agendado_atual].diagnostico_escolhido

	if diagnostico == "":
		_dialogo_confirmacao.dialog_text = "Você ainda não diagnosticou este problema.\nDeseja mesmo terminar o trabalho assim?"
	else:
		_dialogo_confirmacao.dialog_text = "Você está considerando o problema como:\n\"%s\"\n\nTem certeza que deseja terminar o trabalho?" % diagnostico

	_dialogo_confirmacao.popup_centered()


func _on_confirmar_encerramento() -> void:
	if _agendado_atual == null:
		return

	var titulo_trabalho := _agendado_atual.trabalho.titulo
	DadosJogo.finalizar_trabalho(_agendado_atual, _hora_atual())   # v3.2: fecha hora_fim

	if gerenciador_trabalho != null and gerenciador_trabalho.has_method("marcar_trabalho_concluido"):
		gerenciador_trabalho.marcar_trabalho_concluido(_agendado_atual)
	else:
		push_warning("CoordenadorTrabalho: gerenciador_trabalho não atribuído ou sem marcar_trabalho_concluido().")

	if gerenciador_inspecao != null and gerenciador_inspecao.has_method("limpar_alvos"):
		gerenciador_inspecao.limpar_alvos()

	if site_textura != null:
		site_textura.texture = null

	_agendado_atual = null
	_mostrar_feedback_encerramento(titulo_trabalho)


func _mostrar_feedback_encerramento(titulo_trabalho: String) -> void:
	_label_feedback.text = "Trabalho \"%s\" encerrado." % titulo_trabalho

	var tamanho_tela := get_viewport().get_visible_rect().size
	_label_feedback.size = Vector2(400, 40)
	_label_feedback.position = Vector2((tamanho_tela.x - 400) / 2, tamanho_tela.y - 80)

	_label_feedback.show()
	await get_tree().create_timer(2.0).timeout
	_label_feedback.hide()
```

**Mudanças em relação à v3:** conexão do sinal `investigar_usado` no `_ready()`; `_on_trabalho_selecionado()` agora chama `gerenciador_inspecao.definir_investigar_disponivel(not agendado.investigar_usado)` logo depois de `montar_alvos()`; novo `_on_investigar_usado()`, que persiste o limite no `TrabalhoAgendado` assim que uma dica real é revelada.

**Mudanças em relação à v3.1 (ciclo do dia, v3.2):** novo `@export var gerenciador_expediente` + `_hora_atual()`; `_on_trabalho_selecionado()` agora também abre o resultado pendente (`DadosJogo.iniciar_resultado_pendente()`, migrado de `gerenciador_trabalho.gd`) com `hora_inicio` real; `_on_inspecao_concluida()` chama `DadosJogo.registrar_tentativa_inspecao()` pra alimentar o relatório; `_on_confirmar_encerramento()` passa `_hora_atual()` pra `finalizar_trabalho()`.

---

## 5. `gerenciador_trabalho.gd` (v3.2 — corrige clique duplo pra entrar no trabalho)

**Status:** modificado — arquivo completo (v3.3 — botão Delegar)

> **Atualização v3.3 (Sistema de Upgrades):** novo sinal `delegar_solicitado(agendado: TrabalhoAgendado)`. `_adicionar_item_ativo()` reescrito: cada item ativo virou um `HBoxContainer` com 2 botões (título + **Delegar**, em vez do botão único da v3.2). Novo `_assistente_disponivel()` (lê `DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_TREINAMENTO).tier_atual >= 1`, decide se o botão Delegar nasce habilitado). Novo `_on_delegar_pressionado()` — desabilita o botão (feedback otimista) e emite o sinal; não conhece `GerenciadorAssistente` diretamente, quem processa é `CoordenadorTrabalho` (seção 4).

```gdscript
extends Node

# =====================================================================
# GerenciadorTrabalho
# ---------------------------------------------------------------------
# Menu de trabalhos: lista de Disponíveis (aparecem conforme
# GerenciadorExpediente os libera) e lista de Ativos (já aceitos).
# Cada item ativo agora é só um botão de seleção — inspecionar,
# diagnosticar, ignorar e encerrar acontecem todos dentro da NovaAba,
# no popup de clique do GerenciadorInspecao.
# =====================================================================

signal trabalho_selecionado(agendado: TrabalhoAgendado)

@export var auto_aceitar_para_teste: bool = true
@export var titulo_trabalho_teste: String = "Remover Cavalo de Tróia"
var _ja_auto_aceitou: bool = false

@export var btn_abrir_menu: TextureButton
@export var menu_trabalhos: Panel
@export var vbox_disponiveis: VBoxContainer
@export var vbox_ativos: VBoxContainer
@export var gerenciador_expediente: Node

var _agendados_disponiveis: Array[TrabalhoAgendado] = []
var _agendados_ativos: Array[TrabalhoAgendado] = []
var _itens_ativos: Dictionary = {}   # TrabalhoAgendado -> Button


func _ready() -> void:
	if menu_trabalhos != null:
		menu_trabalhos.hide()

	if btn_abrir_menu != null:
		btn_abrir_menu.pressed.connect(_on_btn_abrir_menu_pressed)
	else:
		push_warning("GerenciadorTrabalho: btn_abrir_menu não atribuído no Inspetor.")

	if gerenciador_expediente != null and gerenciador_expediente.has_signal("trabalho_disponibilizado"):
		gerenciador_expediente.trabalho_disponibilizado.connect(_on_trabalho_disponibilizado)
	else:
		push_warning("GerenciadorTrabalho: gerenciador_expediente não atribuído (ou sem o sinal trabalho_disponibilizado).")


func _on_btn_abrir_menu_pressed() -> void:
	if menu_trabalhos != null:
		menu_trabalhos.visible = not menu_trabalhos.visible


func _on_trabalho_disponibilizado(agendado: TrabalhoAgendado) -> void:
	_agendados_disponiveis.append(agendado)
	_adicionar_item_disponivel(agendado)

	var eh_o_trabalho_de_teste := agendado.trabalho.titulo == titulo_trabalho_teste
	if auto_aceitar_para_teste and eh_o_trabalho_de_teste and not _ja_auto_aceitou:
		_ja_auto_aceitou = true
		if vbox_disponiveis != null and vbox_disponiveis.get_child_count() > 0:
			var botao_recem_criado := vbox_disponiveis.get_child(vbox_disponiveis.get_child_count() - 1)
			_on_disponivel_pressionado(agendado, botao_recem_criado)


func _adicionar_item_disponivel(agendado: TrabalhoAgendado) -> void:
	if vbox_disponiveis == null:
		push_warning("GerenciadorTrabalho: vbox_disponiveis não atribuído no Inspetor.")
		return

	var botao := Button.new()
	botao.text = "%s — R$ %d" % [agendado.trabalho.titulo, agendado.recompensa_dinheiro]
	botao.pressed.connect(_on_disponivel_pressionado.bind(agendado, botao))
	vbox_disponiveis.add_child(botao)


func _on_disponivel_pressionado(agendado: TrabalhoAgendado, botao_origem: Button) -> void:
	agendado.aceito = true

	botao_origem.queue_free()
	_agendados_disponiveis.erase(agendado)

	_agendados_ativos.append(agendado)
	_adicionar_item_ativo(agendado)

	# v3.2: abre a inspeção direto ao aceitar, sem precisar de um segundo
	# clique no item ativo. DadosJogo.iniciar_resultado_pendente() foi
	# removido daqui — migrou pra coordenador_trabalho.gd, que abre o
	# resultado já com hora_inicio real do relógio simulado.
	trabalho_selecionado.emit(agendado)
	if menu_trabalhos != null:
		menu_trabalhos.hide()


func _adicionar_item_ativo(agendado: TrabalhoAgendado) -> void:
	if vbox_ativos == null:
		push_warning("GerenciadorTrabalho: vbox_ativos não atribuído no Inspetor.")
		return

	var btn_titulo := Button.new()
	btn_titulo.text = agendado.trabalho.titulo
	btn_titulo.pressed.connect(_on_ativo_pressionado.bind(agendado))

	vbox_ativos.add_child(btn_titulo)
	_itens_ativos[agendado] = btn_titulo


func _on_ativo_pressionado(agendado: TrabalhoAgendado) -> void:
	trabalho_selecionado.emit(agendado)
	if menu_trabalhos != null:
		menu_trabalhos.hide()


# Chamado pelo CoordenadorTrabalho depois que o jogador confirma o
# encerramento no ConfirmationDialog.
func marcar_trabalho_concluido(agendado: TrabalhoAgendado) -> void:
	if agendado == null:
		return
	agendado.concluido = true
	DadosJogo.trabalhos_concluidos_hoje += 1

	if _itens_ativos.has(agendado):
		_itens_ativos[agendado].queue_free()
		_itens_ativos.erase(agendado)
	_agendados_ativos.erase(agendado)
```

**Mudanças em relação à v1:** `_adicionar_item_ativo()` agora cria só **1** botão (título/seleção) em vez de 3 — os botões "Diagnosticar" e "Terminar trabalho" foram removidos, junto com `habilitar_botao_terminar()`, `_on_diagnosticar_pressionado()` e `@export var painel_diagnostico`. `_itens_ativos` mudou de `Dictionary[TrabalhoAgendado, HBoxContainer]` pra `Dictionary[TrabalhoAgendado, Button]` (não precisa mais de um container com múltiplos filhos, só o botão único).

**Mudanças em relação à v3.1 (correção do clique duplo, v3.2):** `_on_disponivel_pressionado()` agora emite `trabalho_selecionado.emit(agendado)` direto ao aceitar — antes disso, era preciso clicar de novo no item recém-criado em `VBoxAtivos` (via `_on_ativo_pressionado()`) pra esse sinal disparar e a inspeção abrir de fato. `DadosJogo.iniciar_resultado_pendente()` foi removido dessa função (esse arquivo não conhece mais `ResultadoTrabalho`).

---

## 6. `gerenciador_inspecao.gd` (v3.1 — grid 3xN + popup unificado + Investigar)

**Status:** modificado — arquivo completo (v3.3 — tempo de verificação lê o upgrade PC)

> **Atualização v3.3 (Sistema de Upgrades):** `_on_botao_inspecionar_pressed()` trocou `await get_tree().create_timer(4.0).timeout` fixo por:
> ```gdscript
> var tempo := _tempo_verificacao_atual()
> if tempo > 0.0:
>     await get_tree().create_timer(tempo).timeout
> ```
> Novo `_tempo_verificacao_atual()` — prioriza ler `mensagem_modal.tempo_total_atual()` (público, seção 13), com fallback pra ler `DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_PC)` direto se `mensagem_modal` não estiver atribuído. Motivo: sem essa sincronização, a revelação da cor do quadrante ficava fixa em 4s mesmo depois do popup de texto já estar mais rápido — dois timers independentes lendo o mesmo upgrade precisam da mesma fonte de verdade. No tier 4 do PC (verificação instantânea), o `if tempo > 0.0` pula o `await` inteiramente.

```gdscript
extends Node

signal inspecao_concluida(acertou: bool, trabalho: TrabalhoInspecao)
signal diagnostico_escolhido(opcao: String)
signal encerrar_solicitado
signal investigar_usado

const COLUNAS_GRID := 3
const LINHAS_PADRAO := 5
const GRUPO_ALVOS := "alvo_dinamico"

@onready var nova_aba: Control = $NovaAba
@onready var mensagem_modal: Control = $MensagemModal

# Control cujo `size`/`global_position` define a área total da grade
# (deve apontar pro TextureRect ImagemBase — se ficar vazio, cai no
# viewport inteiro como fallback, o que deixa o grid maior/deslocado
# em relação à imagem do site).
@export var area_referencia: Control

var trabalho_atual: TrabalhoInspecao
var posicao_do_clique: Vector2 = Vector2.ZERO
var _area_no_popup: AreaAlvo = null
var _algum_alvo_suspeito_encontrado: bool = false
var _investigar_disponivel: bool = true


func _ready() -> void:
	if nova_aba != null:
		if nova_aba.has_signal("inspecionar_pressionado"):
			nova_aba.inspecionar_pressionado.connect(_on_botao_inspecionar_pressed)
		if nova_aba.has_signal("investigar_pressionado"):
			nova_aba.investigar_pressionado.connect(_on_investigar_pressionado)
		if nova_aba.has_signal("diagnostico_pressionado"):
			nova_aba.diagnostico_pressionado.connect(_on_diagnosticar_pressionado)
		if nova_aba.has_signal("diagnostico_escolhido"):
			nova_aba.diagnostico_escolhido.connect(_on_diagnostico_no_popup)
		if nova_aba.has_signal("ignorar_pressionado"):
			nova_aba.ignorar_pressionado.connect(_on_ignorar_pressionado)
		if nova_aba.has_signal("designorar_pressionado"):
			nova_aba.designorar_pressionado.connect(_on_designorar_pressionado)
		if nova_aba.has_signal("encerrar_pressionado"):
			nova_aba.encerrar_pressionado.connect(_on_encerrar_pressionado)


# Chamado pelo CoordenadorTrabalho logo após montar_alvos(), lendo o
# estado real do TrabalhoAgendado (agendado.investigar_usado).
func definir_investigar_disponivel(disponivel: bool) -> void:
	_investigar_disponivel = disponivel


# =======================================================================
# MONTAGEM DA GRADE (3 colunas fixas × N linhas, com compensação de altura)
# =======================================================================
func montar_alvos(trabalho: TrabalhoInspecao) -> void:
	limpar_alvos()
	trabalho_atual = trabalho
	_area_no_popup = null
	_algum_alvo_suspeito_encontrado = false

	if trabalho == null:
		push_warning("GerenciadorInspecao: trabalho nulo em montar_alvos()")
		return

	var linhas := trabalho.linhas_grid if trabalho.linhas_grid > 0 else LINHAS_PADRAO
	var tamanho_area := area_referencia.size if area_referencia != null else get_viewport().get_visible_rect().size
	var origem := area_referencia.global_position if area_referencia != null else Vector2.ZERO
	var largura_coluna := tamanho_area.x / float(COLUNAS_GRID)

	# 1. Mapear quais quadrantes já têm um AlvoInspecao explícito (do trabalho).
	var mapa_alvos: Dictionary = {}   # indice -> AlvoInspecao
	for alvo in trabalho.alvos:
		if mapa_alvos.has(alvo.quadrante):
			push_warning("GerenciadorInspecao: quadrante %d já tem alvo atribuído — ignorando duplicata." % alvo.quadrante)
			continue
		mapa_alvos[alvo.quadrante] = alvo

	# 2. Calcular a altura de cada LINHA (não de cada quadrante — todos os
	#    quadrantes da mesma linha compartilham a mesma altura).
	var alturas_linha: Array[float] = []
	alturas_linha.resize(linhas)

	var linhas_fixas: Dictionary = {}   # linha -> altura forçada por algum AlvoInspecao.altura_real
	for indice in mapa_alvos.keys():
		@warning_ignore("integer_division")
		var linha: int = int(indice) / COLUNAS_GRID
		var alvo: AlvoInspecao = mapa_alvos[indice]
		if alvo.altura_real > 0.0:
			if linhas_fixas.has(linha) and linhas_fixas[linha] != alvo.altura_real:
				push_warning("GerenciadorInspecao: linha %d já tem altura fixa diferente (%.1f); mantendo a primeira." % [linha, linhas_fixas[linha]])
			else:
				linhas_fixas[linha] = alvo.altura_real

	var soma_fixa := 0.0
	for altura in linhas_fixas.values():
		soma_fixa += altura

	var linhas_livres := linhas - linhas_fixas.size()
	var altura_padrao := 0.0
	if linhas_livres > 0:
		altura_padrao = max(0.0, tamanho_area.y - soma_fixa) / float(linhas_livres)

	if soma_fixa > tamanho_area.y:
		push_warning("GerenciadorInspecao: soma das alturas fixas (%.1f) excede a altura total da área (%.1f)." % [soma_fixa, tamanho_area.y])

	for l in range(linhas):
		alturas_linha[l] = linhas_fixas[l] if linhas_fixas.has(l) else altura_padrao

	# 3. Criar um AreaAlvo por quadrante (linha × coluna). Quadrantes sem
	#    Resource explícito viram NEUTRO automático.
	var y_atual := 0.0
	for l in range(linhas):
		for c in range(COLUNAS_GRID):
			var indice := l * COLUNAS_GRID + c
			var dados: AlvoInspecao

			if mapa_alvos.has(indice):
				dados = mapa_alvos[indice]
			else:
				dados = AlvoInspecao.new()
				dados.quadrante = indice
				dados.tipo = AlvoInspecao.Tipo.NEUTRO

			var pos := origem + Vector2(c * largura_coluna, y_atual)
			var tamanho := Vector2(largura_coluna, alturas_linha[l])
			_criar_area_para_alvo(dados, pos, tamanho)

		y_atual += alturas_linha[l]


func _criar_area_para_alvo(dados: AlvoInspecao, pos: Vector2, tamanho: Vector2) -> void:
	var area := AreaAlvo.new()
	area.dados = dados
	area.tamanho_quadrante = tamanho
	area.position = pos

	var colisor := CollisionShape2D.new()
	var forma := RectangleShape2D.new()
	forma.size = tamanho
	colisor.shape = forma
	colisor.position = tamanho / 2.0

	area.add_child(colisor)
	area.add_to_group(GRUPO_ALVOS)
	add_child(area)


func limpar_alvos() -> void:
	for filho in get_tree().get_nodes_in_group(GRUPO_ALVOS):
		if filho.get_parent() == self:
			filho.queue_free()


# =======================================================================
# POPUPS
# =======================================================================
func esta_com_popup_aberto() -> bool:
	return (nova_aba != null and nova_aba.visible) or (mensagem_modal != null and mensagem_modal.visible)


func _encontrar_area_no_ponto(pos: Vector2) -> AreaAlvo:
	for area in get_tree().get_nodes_in_group(GRUPO_ALVOS):
		if not (area is AreaAlvo):
			continue
		var rect := Rect2(area.global_position, area.tamanho_quadrante)
		if rect.has_point(pos):
			return area
	return null


func registrar_clique_na_area(posicao_global: Vector2) -> void:
	posicao_do_clique = posicao_global

	var area := _encontrar_area_no_ponto(posicao_global)
	_area_no_popup = area

	var ignorado := area != null and area.ignorado

	var inspecionar_disponivel := true
	if area != null and area.dados.tipo == AlvoInspecao.Tipo.NEUTRO and area.ja_inspecionado_negativo:
		inspecionar_disponivel = false

	if nova_aba != null and nova_aba.has_method("mostrar_em"):
		nova_aba.mostrar_em(posicao_do_clique + Vector2(8, 8), _algum_alvo_suspeito_encontrado, ignorado, inspecionar_disponivel, _investigar_disponivel)


func fechar_todos_os_popups() -> void:
	if nova_aba != null:
		nova_aba.hide()
	if mensagem_modal != null:
		mensagem_modal.hide()


# =======================================================================
# VERIFICAÇÃO DO CLIQUE
# =======================================================================
func verificar_clique(pos: Vector2) -> Dictionary:
	var area := _encontrar_area_no_ponto(pos)
	if area != null:
		return {
			"encontrou_alvo": true,
			"acertou": area.dados.tipo == AlvoInspecao.Tipo.SUSPEITO,
			"capitulo": area.dados.capitulo_relacionado,
			"area": area,
		}
	return {"encontrou_alvo": false, "acertou": false, "capitulo": -1, "area": null}


func _on_botao_inspecionar_pressed() -> void:
	if nova_aba != null:
		nova_aba.hide()

	var resultado := verificar_clique(posicao_do_clique)

	if mensagem_modal != null and mensagem_modal.has_method("mostrar"):
		mensagem_modal.mostrar(resultado.acertou)

	await get_tree().create_timer(4.0).timeout

	if resultado.acertou:
		var area: AreaAlvo = resultado.area
		area.foi_encontrado = true
		_algum_alvo_suspeito_encontrado = true
		_revelar_alvo(area)
	elif resultado.encontrou_alvo:
		var area: AreaAlvo = resultado.area
		area.ja_inspecionado_negativo = true

	inspecao_concluida.emit(resultado.acertou, trabalho_atual)


# ---------------------------------------------------------------------
# INVESTIGAR — dá dica textual sobre o quadrante clicado, com 3 respostas
# possíveis dependendo do estado daquele quadrante específico. Consome
# o uso (limite de 1 por trabalho) só quando revela uma dica de verdade
# (caso 3) — os casos 1 e 2 não entregam informação, então são "grátis".
# ---------------------------------------------------------------------
func _on_investigar_pressionado() -> void:
	if _area_no_popup == null:
		return

	var area := _area_no_popup
	var texto := ""
	var revelou_dica := false

	if area.dados.tipo == AlvoInspecao.Tipo.SUSPEITO and area.foi_encontrado:
		texto = area.dados.dica if area.dados.dica != "" else "Não há dica disponível pra este problema."
		revelou_dica = true
	elif area.dados.tipo == AlvoInspecao.Tipo.NEUTRO and area.ja_inspecionado_negativo:
		texto = "Nada de interessante nesta parte."
	else:
		texto = "Preciso investigar."

	if mensagem_modal != null and mensagem_modal.has_method("mostrar_texto"):
		mensagem_modal.mostrar_texto(texto)

	if revelou_dica:
		_investigar_disponivel = false
		investigar_usado.emit()


func _on_diagnosticar_pressionado() -> void:
	if nova_aba != null and nova_aba.has_method("mostrar_diagnostico"):
		nova_aba.mostrar_diagnostico(DadosJogo.gerar_opcoes_diagnostico(trabalho_atual))


func _on_diagnostico_no_popup(opcao: String) -> void:
	diagnostico_escolhido.emit(opcao)


func _on_ignorar_pressionado() -> void:
	if _area_no_popup != null:
		_area_no_popup.ignorado = true


func _on_designorar_pressionado() -> void:
	if _area_no_popup != null:
		_area_no_popup.ignorado = false


func _on_encerrar_pressionado() -> void:
	encerrar_solicitado.emit()


func _revelar_alvo(area: AreaAlvo) -> void:
	if area == null:
		return
	var visual := ColorRect.new()
	visual.color = Color(0, 1, 0, 0.5)
	visual.size = area.tamanho_quadrante
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	area.add_child(visual)
```

**Mudanças em relação à v3:**
- Novo sinal `investigar_usado`, escutado por `CoordenadorTrabalho` pra persistir o limite no `TrabalhoAgendado`.
- Novo `definir_investigar_disponivel()`, chamado externamente ao trocar de trabalho ativo.
- `registrar_clique_na_area()` e `NovaAba.mostrar_em()` ganharam o parâmetro `_investigar_disponivel`.
- Nova função `_on_investigar_pressionado()` com as 3 respostas possíveis (preciso investigar / nada de interessante / dica real).
- Correção de origem do grid (`origem := area_referencia.global_position`) já estava presente desde a rodada anterior — mantida aqui.

> ⚠️ **Limitação conhecida, não resolvida:** `foi_encontrado`, `ignorado` e `ja_inspecionado_negativo` vivem no `AreaAlvo`, que é recriado do zero toda vez que `montar_alvos()` roda (ex: ao trocar de trabalho ativo e voltar pro mesmo depois). Isso reseta silenciosamente o progresso visual por quadrante, incluindo a condição que libera o Diagnosticar globalmente (`_algum_alvo_suspeito_encontrado`). Só `investigar_usado` está protegido disso, por morar no `TrabalhoAgendado` (que persiste). Ver `netetive_status.md` pra mais detalhes sobre esse ponto em aberto.

---

## 7. `conteudo_livro.gd`

**Status:** modificado — **só a linha alterada**

```gdscript
# antes:
var PAGINAS: Array[Dictionary] = [

# depois:
const PAGINAS: Array[Dictionary] = [
```

Necessário para permitir acesso estático (`ConteudoLivro.PAGINAS`) sem instanciar a classe, usado por `DadosJogo.titulo_capitulo_correto()` e `gerar_opcoes_diagnostico()`.

> **Confirmado por upload:** o arquivo real continua com **10 capítulos** (índices 0–9), apesar do comentário na linha 4 ainda dizer "12 capítulos estruturados e limpos". O "and" em inglês no meio do texto do Capítulo 5 (Engenharia Social) também segue sem correção: *"Anota o número ou canal usado pelo golpista **and** reporta."* — ambos continuam como pendências abertas.

**Atualização v3.5 — capítulo 6 trocado de "Senha Fraca" pra "Scareware":** a entrada de índice `5` em `PAGINAS` foi substituída (não adicionada — o array continua com 10 capítulos):

```gdscript
{
	"titulo": "Scareware",
	"descricao": "Sabe aquela tela que aparece do nada dizendo que seu computador está infectado, com um contador regressivo e uma lista enorme de 'ameaças detectadas'? Isso é scareware — um site ou pop-up falso que finge ser um antivírus pra te assustar e fazer você clicar em 'baixar' rápido demais, sem pensar. O visual é sempre exagerado: alertas em vermelho, ícones piscando, sirene de urgência. O objetivo não é te proteger, é te apressar.",
	"solucao": "Como agir:\n- Nenhum navegador ou sistema operacional detecta vírus sozinho — se o alerta veio de uma aba do navegador, é falso.\n- Desconfie de qualquer coisa com contador regressivo pedindo pra você agir 'antes que seja tarde'.\n- Nunca baixe a 'ferramenta de remoção' oferecida na própria tela do alerta — feche a aba ou o navegador inteiro.\n- Rode um antivírus de verdade, já instalado, separadamente — nunca o que a tela suspeita está recomendando."
}
```

Motivado pela integração dos trabalhos "Identificar Scareware" (v3.5, seção 24) — o `capitulo_relacionado` desse trabalho aponta pra esse índice. **Conteúdo antigo de "Senha Fraca" não foi descartado do histórico, só removido do array ativo** — candidato a virar um 11º capítulo futuro, se quiser recuperá-lo.

---

---

## 8. `alvo_inspecao.gd` (v3.1 — campo `dica` pro botão Investigar)

**Status:** modificado — arquivo completo | **Tipo:** `Resource`, `class_name AlvoInspecao`

```gdscript
class_name AlvoInspecao
extends Resource

enum Tipo { SUSPEITO, NEUTRO }

@export var tipo: Tipo = Tipo.NEUTRO
@export var quadrante: int = 0        # índice: linha * COLUNAS_GRID + coluna (0-based)
@export var altura_real: float = 0.0  # altura em px que a LINHA INTEIRA deve assumir; 0 = automática
@export var capitulo_relacionado: int = -1
@export var dica: String = ""         # texto curto mostrado pelo botão Investigar (só pra SUSPEITO)
```

**Mudanças:** `posicao: Vector2` e `tamanho: Vector2` (pixels livres) foram **removidos** na v3 e substituídos por `quadrante: int` + `altura_real: float`, alinhados ao sistema de grid do `GerenciadorInspecao` (seção 6). `dica: String` é novo — texto próprio da dica do botão Investigar, independente do conteúdo do `ConteudoLivro`/`LivroDicas`.

---

## 9. `trabalho_inspecao.gd` (v3 — `linhas_grid`, campos órfãos removidos)

**Status:** modificado — arquivo completo | **Tipo:** `Resource`, `class_name TrabalhoInspecao`

```gdscript
class_name TrabalhoInspecao
extends Resource

@export var titulo: String
@export var descricao: String
@export var recompensa_base: int = 0

@export var dificuldade: int = 1
@export var recompensa_fama: int = 10

@export var imagem_site: Texture2D
@export var alvos: Array[AlvoInspecao] = []

@export var linhas_grid: int = 5   # colunas são sempre 3 (constante em GerenciadorInspecao)
```

**Mudanças em relação à v1:**
- Novo `linhas_grid: int = 5` — controla quantas linhas o grid desse trabalho específico tem (colunas são sempre 3, fixo em `GerenciadorInspecao.COLUNAS_GRID`).
- `categoria_correta: String` e `opcoes_diagnostico: Array[String]` **removidos** — eram os campos órfãos identificados numa rodada anterior (nunca usados; a lógica real sempre usou `AlvoInspecao.capitulo_relacionado` via `DadosJogo.titulo_capitulo_correto()`).

---

## 10. `gerenciador_expediente.gd`

**Status:** modificado (v3.4 — quantidade de trabalhos escala com fama) | **Tipo:** `Node`

Controla o relógio simulado do dia (`hora_atual`) e dispara `trabalho_disponibilizado` conforme a agenda sorteada por `DadosJogo.sortear_agenda_do_dia()`.

> **Atualização v3.4 (Sistema de Fama):** `@export var quantidade_trabalhos_dia: int` virou `@export var trabalhos_base_dia: int = 6` (o mínimo/base, não mais o total fixo). `iniciar_expediente()` agora calcula a quantidade real do dia via `CalculadoraFama.calcular_quantidade_trabalhos_dia(DadosJogo.fama_jogador, trabalhos_base_dia)` antes de chamar `sortear_agenda_do_dia()`. `quantidade_trabalhos_iniciais` não muda — continua fixo, só o total do dia escala com fama.

```gdscript
extends Node

signal expediente_iniciado
signal expediente_encerrado
signal relogio_atualizado(hora_formatada: String)
signal trabalho_disponibilizado(agendado: TrabalhoAgendado)

@export var trabalhos_base_dia: int = 6   # mínimo garantido/dia — cresce com fama via CalculadoraFama, ver iniciar_expediente()
@export var quantidade_trabalhos_iniciais: int = 2
@export var minutos_por_segundo_real: float = 4.0

var hora_atual: float = 0.0
var _proximo_indice_agenda: int = 0
var _rodando: bool = false


func iniciar_expediente() -> void:
	var quantidade_hoje := CalculadoraFama.calcular_quantidade_trabalhos_dia(DadosJogo.fama_jogador, trabalhos_base_dia)
	DadosJogo.sortear_agenda_do_dia(quantidade_hoje, quantidade_trabalhos_iniciais)

	hora_atual = DadosJogo.HORA_INICIO_EXPEDIENTE
	_proximo_indice_agenda = 0
	_rodando = true

	print("EXPEDIENTE: Iniciado às ", _formatar_hora(hora_atual), " — ", quantidade_hoje, " trabalhos hoje (fama: ", DadosJogo.fama_jogador, ")")
	expediente_iniciado.emit()
	relogio_atualizado.emit(_formatar_hora(hora_atual))

	_verificar_disponibilidade()


func _process(delta: float) -> void:
	if not _rodando:
		return

	hora_atual += (delta * minutos_por_segundo_real) / 60.0
	relogio_atualizado.emit(_formatar_hora(hora_atual))
	_verificar_disponibilidade()

	if hora_atual >= DadosJogo.HORA_FIM_EXPEDIENTE:
		_encerrar_expediente()


func _verificar_disponibilidade() -> void:
	var agenda: Array[TrabalhoAgendado] = DadosJogo.trabalhos_do_dia
	while _proximo_indice_agenda < agenda.size() and agenda[_proximo_indice_agenda].horario_aparicao <= hora_atual:
		var agendado: TrabalhoAgendado = agenda[_proximo_indice_agenda]
		DadosJogo.disponibilizar_trabalho(agendado)
		trabalho_disponibilizado.emit(agendado)
		print("EXPEDIENTE: Trabalho disponível: ", agendado.trabalho.titulo, " às ", _formatar_hora(hora_atual))
		_proximo_indice_agenda += 1


func _encerrar_expediente() -> void:
	_rodando = false
	hora_atual = DadosJogo.HORA_FIM_EXPEDIENTE
	print("EXPEDIENTE: Encerrado. Trabalhos concluídos: ", DadosJogo.trabalhos_concluidos_hoje)
	expediente_encerrado.emit()


func _formatar_hora(hora: float) -> String:
	var h := int(hora)
	var m := int((hora - h) * 60.0)
	return "%02d:%02d" % [h, m]
```

> 💡 **Gancho pra tela de resumo:** o sinal `expediente_encerrado` já existe e já é emitido no lugar certo (`_encerrar_expediente()`). É o ponto natural pra conectar a futura tela de resumo de fim de dia — ela pode escutar esse sinal e então iterar `DadosJogo.resultados_do_dia`.

---

## 11. `area_clique_inspecao.gd`

**Status:** confirmado, sem alterações nesta sessão | **Tipo:** `Control`

```gdscript
extends Control

@onready var gerenciador_inspecao: Node = $GerenciadorInspecao


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE


func _unhandled_input(event: InputEvent) -> void:
	if gerenciador_inspecao != null and gerenciador_inspecao.esta_com_popup_aberto():
		return

	if event.is_action_pressed("clique_direito"):
		if gerenciador_inspecao != null:
			gerenciador_inspecao.fechar_todos_os_popups()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if gerenciador_inspecao != null:
			gerenciador_inspecao.registrar_clique_na_area(event.global_position)
		get_viewport().set_input_as_handled()
```

---

## 12. `nova_aba_script.gd` (v3.1 — popup com 5 botões, incluindo Investigar)

**Status:** modificado — arquivo completo

```gdscript
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


# diagnostico_disponivel: true se JÁ foi encontrado algum alvo suspeito
# neste trabalho. inspecionar_disponivel: false se este ponto é um alvo
# NEUTRO já checado. investigar_disponivel: false se a dica já foi usada
# neste trabalho (TrabalhoAgendado.investigar_usado).
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
	# Não esconde aqui — GerenciadorInspecao chama mostrar_diagnostico()
	# em seguida, abrindo o submenu ao lado.


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
```

**Mudança em relação à v3:** novo botão `BtnInvestigar` (e sinal `investigar_pressionado`), com a lógica de disponibilidade controlada externamente via parâmetro `investigar_disponivel` em `mostrar_em()`. Ele fecha o popup imediatamente ao clicar (`esconder()`), diferente do Diagnosticar (que mantém o popup aberto pra mostrar o submenu) — a resposta do Investigar aparece no `MensagemModal`, não dentro da própria `NovaAba`.

**Estrutura de nós atualizada no editor:**
```
NovaAba
├── VBoxPadrao
│   ├── BtnInspecionar
│   ├── BtnInvestigar    ← novo
│   ├── BtnDiagnosticar
│   ├── BtnIgnorar
│   └── BtnEncerrar
└── VBoxDiagnostico
```

---

## 13. `mensagem_modal_scpt.gd` (v3.1 — novo método `mostrar_texto()` pro Investigar)

**Status:** modificado — arquivo completo (v3.3 — tempo lê o upgrade PC) | **Tipo:** `Control` — modal ativo, usado por `GerenciadorInspecao`

> **Atualização v3.3 (Sistema de Upgrades):** `mostrar()` trocou os dois `create_timer(2.0)` fixos por um tempo total lido do upgrade PC, dividido em duas metades:
> ```gdscript
> func tempo_total_atual() -> float:
>     var linha := DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_PC)
>     return linha.valor_efeito_atual(4.0) if linha != null else 4.0
> ```
> `tempo_total_atual()` é **público** de propósito (sem `_` no nome) — `gerenciador_inspecao.gd` (seção 6) lê essa mesma função pra sincronizar quando a cor do quadrante é revelada com quando o popup fecha. No tier 4 do PC (`valor_efeito = 0.0`), `metade` vira `0.0` e os dois `await` são pulados (`if metade > 0.0`), tornando a verificação instantânea. `mostrar_texto()` (usado pelo Investigar) **não foi afetado** — continua com os 3s fixos, de propósito (mecânica separada, com seu próprio limite de uso).

```gdscript
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

# Usado pelo botão Investigar. Sem a etapa "Verificando...", é uma
# resposta instantânea, exibida por 3s.
func mostrar_texto(texto: String) -> void:
	$Label.text = texto
	z_index = 100
	show()
	await get_tree().create_timer(3.0).timeout
	esconder()

func esconder() -> void:
	hide()
```

**Mudança em relação à v3:** novo método `mostrar_texto()`, reaproveitando o mesmo `Label`/`z_index` de `mostrar()`, mas sem a etapa intermediária "Verificando..." — a resposta do Investigar é instantânea.

> 📝 Lembrete ainda válido: o texto "⚠️ Alvo detectado!" pode confundir o jogador agora que achar o alvo não fecha mais o trabalho — vale revisar a redação (ex: "Pista encontrada — não esqueça de diagnosticar!") quando for mexer neste arquivo de novo.

---

## 14. `CaixaDeSelecao.gd`

**Status:** confirmado, sem alterações nesta sessão | **Tipo:** `ColorRect` — intencionalmente vazio

```gdscript
extends ColorRect

# Este script permanece limpo e herda corretamente de ColorRect para evitar conflitos de tipo.
# Toda a manipulação de dimensões e posições é controlada pelo GerenciadorInspecao.

func _ready() -> void:
	pass
```

---

## 15. `livro_dicas.gd`

**Status:** confirmado, sem alterações nesta sessão | **Tipo:** `TextureRect`, `class_name LivroDicas`

```gdscript
class_name LivroDicas
extends TextureRect

@onready var label_titulo := $LabelTitulo
@onready var label_problema := $LabelProblema
@onready var label_solucao := $LabelSolucao
@onready var btn_anterior := $BtnAnterior
@onready var btn_proximo := $BtnProximo

var lista_paginas: Array = []
var pagina_atual: int = 0

func _ready() -> void:
	var tamanho_tela = get_viewport_rect().size
	custom_minimum_size = tamanho_tela * 0.8
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var script = load("res://Scripts/conteudo_livro.gd")
	if script == null:
		print("ERRO: arquivo conteudo_livro.gd não encontrado!")
		return

	var instancia = script.new()
	lista_paginas = instancia.PAGINAS

	if btn_anterior:
		btn_anterior.pressed.connect(_on_anterior_pressed)
	if btn_proximo:
		btn_proximo.pressed.connect(_on_proximo_pressed)

	atualizar_pagina()

func abrir_livro() -> void:
	pagina_atual = 0
	atualizar_pagina()
	mouse_filter = Control.MOUSE_FILTER_STOP
	show()

func atualizar_pagina() -> void:
	if lista_paginas.is_empty():
		return
	var dados_pagina = lista_paginas[pagina_atual]
	if label_titulo:
		label_titulo.text = str(dados_pagina.get("titulo", ""))
	if label_problema:
		label_problema.text = str(dados_pagina.get("descricao", ""))
	if label_solucao:
		label_solucao.text = str(dados_pagina.get("solucao", ""))
	if btn_anterior:
		btn_anterior.visible = (pagina_atual > 0)
	if btn_proximo:
		btn_proximo.visible = (pagina_atual < lista_paginas.size() - 1)

func _on_anterior_pressed() -> void:
	if pagina_atual > 0:
		pagina_atual -= 1
		atualizar_pagina()

func _on_proximo_pressed() -> void:
	if pagina_atual < lista_paginas.size() - 1:
		pagina_atual += 1
		atualizar_pagina()

func _gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("clique_direito"):
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		hide()
		get_viewport().set_input_as_handled()
```

> ✅ Continua compatível com a troca de `var PAGINAS` para `const PAGINAS` em `conteudo_livro.gd` — `instancia.PAGINAS` funciona normalmente acessando uma constante através de uma instância, então nenhuma mudança é necessária aqui.

---

## 16. `btn_abrir_livro.gd`

**Status:** confirmado, sem alterações nesta sessão | **Tipo:** `TextureButton`

```gdscript
extends TextureButton

@export var cena_livro: PackedScene
@export var container_central: CenterContainer # Nova variável para receber o container!

var instancia_livro_atual: Control = null

func _ready() -> void:
	pressed.connect(_on_btn_pressed)

func _on_btn_pressed() -> void:
	if cena_livro == null or container_central == null:
		print("ERRO: Cena do livro ou Container Central não atribuídos no Inspetor!")
		return

	if instancia_livro_atual != null and is_instance_valid(instancia_livro_atual):
		instancia_livro_atual.abrir_livro()
		return

	instancia_livro_atual = cena_livro.instantiate()
	container_central.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container_central.add_child(instancia_livro_atual)

	if instancia_livro_atual.has_method("abrir_livro"):
		instancia_livro_atual.abrir_livro()
```

---

## 17. `Main_select_script.gd` (v3.2 — dispara RelatorioDia ao fim do expediente)

**Status:** modificado (v3.3 — dispara GerenciadorIANoturna) | **Tipo:** `Node2D` (raiz da cena `Tela.tscn`)

> **Atualização v3.3 (Sistema de Upgrades):** `_on_expediente_encerrado()` ganhou uma chamada antes de trocar de cena:
> ```gdscript
> var hora_fim := 0.0
> if gerenciador_expediente != null and "hora_atual" in gerenciador_expediente:
>     hora_fim = gerenciador_expediente.hora_atual
> GerenciadorIANoturna.processar_noite(hora_fim)
>
> get_tree().change_scene_to_file("res://Scenes/RelatorioDia.tscn")
> ```
> Como `GerenciadorIANoturna` é `static func` (seção 29), não precisa de `@export` nem referência — só a chamada direta. Garante que os resultados da IA já estejam em `DadosJogo.resultados_do_dia` antes de `RelatorioDia.montar_relatorio()` rodar.

```gdscript
extends Node2D

var cena_livro = preload("res://Scenes/LivroInstrucao.tscn")

@onready var gerenciador_expediente: Node = $ModuloTrabalho/GerenciadorExpediente


func _ready() -> void:
	print("Cena iniciada. Os gerenciadores estão cuidando de tudo!")

	if gerenciador_expediente != null and gerenciador_expediente.has_method("iniciar_expediente"):
		gerenciador_expediente.iniciar_expediente()
		if gerenciador_expediente.has_signal("expediente_encerrado"):
			gerenciador_expediente.expediente_encerrado.connect(_on_expediente_encerrado)
	else:
		push_warning("Main_select_script: gerenciador_expediente não encontrado ou sem iniciar_expediente().")


func _on_expediente_encerrado() -> void:
	get_tree().change_scene_to_file("res://Scenes/RelatorioDia.tscn")


func _on_btn_abrir_livro_pressed() -> void:
	var instancia_livro = cena_livro.instantiate()
	add_child(instancia_livro)
	instancia_livro.abrir_livro()


func _on_botao_inspecionar_pressed() -> void:
	pass
```

> ✅ Confirma o ponto de entrada do expediente: `Main_select_script._ready()` chama `gerenciador_expediente.iniciar_expediente()`, que por sua vez chama `DadosJogo.sortear_agenda_do_dia()` — resetando `trabalhos_do_dia`/`trabalhos_concluidos_hoje` automaticamente a cada carregamento da cena `Tela.tscn`. Por isso o botão "Iniciar Dia" no Escritório (`Iniciar.gd`) não precisou de nenhuma mudança própria — só trocar pra `Tela.tscn` já é suficiente pra resetar o estado do dia.
>
> **Novo (v3.2):** `_on_expediente_encerrado()` troca a cena pra `RelatorioDia.tscn` assim que `GerenciadorExpediente.expediente_encerrado` dispara (17h simuladas). ⚠️ **Ponto de atenção real, já causou erro em produção:** o caminho é uma string literal — se `RelatorioDia.tscn` for salva em pasta/nome diferente do esperado, o Godot lança `Cannot open file` / `Failed loading resource` em runtime, sem aviso em tempo de edição. Recomendação (ainda não aplicada): trocar por `@export var cena_relatorio: PackedScene`, arrastando a cena no Inspetor — o Godot atualiza a referência sozinho se o arquivo for movido/renomeado.
>
> `_on_btn_abrir_livro_pressed()` ainda existe aqui **e também** em `btn_abrir_livro.gd` (script 16) — é a duplicação de lógica do livro já catalogada como dívida técnica no `netetive_status.md`; nenhuma mudança feita nela nesta sessão.

---

## 18. `menu_trabalhos.gd` ⚠️ possível sistema órfão/duplicado

**Status:** enviado nesta sessão, **não integrado** ao fluxo documentado em `netetive.md` 3.4

```gdscript
extends Control

signal trabalho_aceito(agendado: TrabalhoAgendado)
signal trabalho_selecionado(agendado: TrabalhoAgendado)

@onready var vbox_disponiveis: VBoxContainer = $VBoxDisponiveis
@onready var vbox_ativos: VBoxContainer = $VBoxAtivos


func _ready() -> void:
	hide()


func abrir() -> void:
	atualizar()
	show()


func fechar() -> void:
	hide()


func atualizar() -> void:
	_limpar(vbox_disponiveis)
	_limpar(vbox_ativos)

	for agendado in DadosJogo.trabalhos_disponiveis:
		vbox_disponiveis.add_child(_criar_linha_disponivel(agendado))

	for agendado in DadosJogo.trabalhos_ativos:
		vbox_ativos.add_child(_criar_linha_ativo(agendado))


func _limpar(container: VBoxContainer) -> void:
	for filho in container.get_children():
		filho.queue_free()


func _criar_linha_disponivel(agendado: TrabalhoAgendado) -> Control:
	var linha := HBoxContainer.new()

	var label := Label.new()
	label.text = "%s — R$ %d | Fama +%d" % [
		agendado.trabalho.titulo, agendado.recompensa_dinheiro, agendado.trabalho.recompensa_fama
	]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(label)

	var btn := Button.new()
	btn.text = "Aceitar"
	btn.pressed.connect(func(): _on_aceitar_pressionado(agendado))
	linha.add_child(btn)

	return linha


func _on_aceitar_pressionado(agendado: TrabalhoAgendado) -> void:
	trabalho_aceito.emit(agendado)
	atualizar()


func _criar_linha_ativo(agendado: TrabalhoAgendado) -> Control:
	var linha := HBoxContainer.new()
	var em_andamento: bool = (agendado == DadosJogo.trabalho_atual)

	var label := Label.new()
	label.text = ("▶ " if em_andamento else "   ") + agendado.trabalho.titulo
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	linha.add_child(label)

	var btn := Button.new()
	if em_andamento:
		btn.text = "Em andamento"
		btn.disabled = true
	else:
		btn.text = "Inspecionar"
		btn.pressed.connect(func(): _on_selecionar_pressionado(agendado))
	linha.add_child(btn)

	return linha


func _on_selecionar_pressionado(agendado: TrabalhoAgendado) -> void:
	trabalho_selecionado.emit(agendado)
	atualizar()


func _gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("clique_direito"):
		fechar()
		get_viewport().set_input_as_handled()
```

> ⚠️ **Isto não bate com a arquitetura documentada.** Este script assume que `DadosJogo` tem `trabalhos_disponiveis`, `trabalhos_ativos` e `trabalho_atual` — nenhum desses três existe no `DadosJogo.gd` desta sessão (lá as listas equivalentes, `_agendados_disponiveis`/`_agendados_ativos`, são variáveis **privadas dentro de `GerenciadorTrabalho`**, não em `DadosJogo`). Além disso, ele duplica responsabilidade que já pertence a `GerenciadorTrabalho` (mesmos sinais `trabalho_selecionado`/conceito de "trabalho_aceito", mesma estrutura `VBoxDisponiveis`/`VBoxAtivos`).
>
> Isso é bem parecido com o padrão de bug já visto no projeto — script trocado de aba, cópia esquecida de uma tentativa anterior, ou um protótipo paralelo nunca finalizado. **Antes de mexer em qualquer coisa:** confirme se este script está de fato anexado a algum nó ativo na cena, ou se é uma sobra sem uso. Se estiver anexado e ativo, ele vai quebrar em runtime assim que `atualizar()` for chamado (member not found em `DadosJogo`). Recomendo tratar como candidato a remoção, a menos que você tenha um plano específico de migrar `GerenciadorTrabalho` para usar esse padrão — nesse caso, é melhor decidirmos isso como uma conversa de arquitetura separada, não como parte da correção de bugs.

---

## 19. Scripts legados (sistema de post-it — candidatos a remoção)

Estes três continuam existindo no projeto mas pertencem ao fluxo **antigo** de post-its, já substituído pelo sistema de expedição (`GerenciadorExpediente`/`GerenciadorTrabalho`, seção 3.4 do `netetive.md`). Incluídos aqui só como registro — nenhuma mudança foi feita neles nesta sessão.

### `lembrete.gd`
```gdscript
extends TextureButton

signal foi_clicado(titulo: String, descricao: String, recompensa: int, lembrete_clicado: TextureButton)

var titulo_trabalho: String = ""
var descricao_trabalho: String = ""
var recompensa: int = 0

func _ready() -> void:
	show()
	z_index = 100
	pressed.connect(_on_pressed)
	sortear_trabalho_aleatorio()

func sortear_trabalho_aleatorio() -> void:
	if DadosJogo.banco_de_trabalhos.size() > 0:
		var trabalho_sorteado: TrabalhoInspecao = DadosJogo.banco_de_trabalhos.pick_random()
		titulo_trabalho = trabalho_sorteado.titulo
		descricao_trabalho = trabalho_sorteado.descricao
		var valor_base: int = trabalho_sorteado.recompensa_base
		recompensa = valor_base + randi_range(-15, 25)

func _on_pressed() -> void:
	emit_signal("foi_clicado", titulo_trabalho, descricao_trabalho, recompensa, self)

func _gui_input(event: InputEvent) -> void:
	if visible and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		hide()
		get_viewport().set_input_as_handled()
```

### `painel_trabalho.gd`
```gdscript
extends Panel

signal trabalho_aceito(recompensa: int)

@onready var label_titulo := $LabelTitulo
@onready var label_descricao := $LabelDescricao
@onready var label_recompensa := $LabelRecompensa
@onready var btn_aceitar := $BtnAceitar
@onready var btn_ignorar := $BtnIgnorar

var _recompensa_atual := 0
var _lembrete_origem: TextureButton = null

func _ready() -> void:
	hide()
	btn_ignorar.pressed.connect(fechar)
	btn_aceitar.pressed.connect(_on_aceitar_pressionado)

func abrir(lembrete: TextureButton, titulo: String, descricao: String, recompensa: int) -> void:
	_lembrete_origem = lembrete
	_recompensa_atual = recompensa
	label_titulo.text = titulo
	label_descricao.text = descricao
	label_recompensa.text = "Recompensa: R$ " + str(recompensa)
	var tamanho_tela := get_viewport_rect().size
	global_position = (tamanho_tela - size) / 2
	z_index = 101
	show()

func fechar() -> void:
	hide()

func _on_aceitar_pressionado() -> void:
	emit_signal("trabalho_aceito", _recompensa_atual)
	fechar()
	if is_instance_valid(_lembrete_origem):
		_lembrete_origem.queue_free()

func _gui_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("clique_direito"):
		if self.has_method("fechar"):
			self.fechar()
		else:
			hide()
		get_viewport().set_input_as_handled()
```

### `mensagem_modal.gd` (versão alternativa não usada, ver `PainelModal` em `netetive.md`)
```gdscript
extends Panel

@onready var label_texto = $Label

func _ready():
	hide()

func exibir_resultado(texto: String):
	label_texto.text = texto
	var tamanho_janela = get_viewport_rect().size
	var x_centralizado = (tamanho_janela.x - size.x) / 2
	var y_no_rodape = tamanho_janela.y - size.y - 20
	global_position = Vector2(x_centralizado, y_no_rodape)
	z_index = 100
	show()

func _on_button_pressed():
	hide()
```

### `button-inspecionar.gd` (versão pré-`GerenciadorInspecao`)
```gdscript
extends Node2D

@onready var modal = $Modal
@onready var mensagem_modal = $Modal/MensagemModal
@onready var alvo_1 = $Alvo1

func _on_botao_inspecionar_pressed() -> void:
	$NovaAba.hide()
	var area_selecionada = caixa_selecao.get_global_rect()
	var area_do_alvo = alvo_1.get_global_rect()
	if area_selecionada.intersects(area_do_alvo):
		mensagem_modal.text = "Sucesso! Você encontrou dados criptografados nesta pasta."
	else:
		mensagem_modal.text = "Nada de interessante aqui... Apenas arquivos de sistema inúteis."
	modal.show()

func _on_botao_ok_modal_pressed() -> void:
	modal.hide()
	caixa_selecao.hide()
```

> ⚠️ Este último (`button-inspecionar.gd`) referencia `caixa_selecao` sem declará-la em lugar nenhum do script — provavelmente quebraria em runtime se ainda estivesse anexado a algum nó ativo. Mais um indício de que é seguro remover.

---

## 20. `area_alvo.gd` (v3 — campos de estado por quadrante)

**Status:** modificado — arquivo completo | **Tipo:** `Area2D`, `class_name AreaAlvo`

```gdscript
class_name AreaAlvo
extends Area2D

var dados: AlvoInspecao
var tamanho_quadrante: Vector2 = Vector2.ZERO   # calculado pelo grid, não vem do Resource
var foi_encontrado: bool = false                # true quando um alvo SUSPEITO é encontrado
var ignorado: bool = false                      # alterna via botão Ignorar/Designorar no popup
var ja_inspecionado_negativo: bool = false       # true quando um NEUTRO já foi checado sem nada
```

**Mudanças em relação à v1:** `tamanho_quadrante`, `foi_encontrado`, `ignorado` e `ja_inspecionado_negativo` são todos novos — a v1 só tinha `dados: AlvoInspecao`. `tamanho_quadrante` existe porque o tamanho agora vem do cálculo do grid (`GerenciadorInspecao.montar_alvos()`), não do próprio Resource (que só guarda `altura_real`, a intenção de altura, não o tamanho final já compensado).

---

## 21. `trabalho_agendado.gd` (v3.1 — campo `investigar_usado`)

**Status:** modificado — arquivo completo | **Tipo:** `RefCounted`, `class_name TrabalhoAgendado`

```gdscript
class_name TrabalhoAgendado
extends RefCounted

var trabalho: TrabalhoInspecao
var horario_aparicao: float = 0.0
var recompensa_dinheiro: int = 0

var apareceu: bool = false
var aceito: bool = false
var concluido: bool = false
var investigar_usado: bool = false   # controla o limite de 1 dica (botão Investigar) por trabalho
```

> Confirma por que `ResultadoTrabalho.agendado` não pode ter `@export` (visto na seção 1): `TrabalhoAgendado` é `RefCounted`, não `Resource`.
>
> **`investigar_usado` fica aqui** (na ocorrência do trabalho, `TrabalhoAgendado`) e não em `AreaAlvo`/`GerenciadorInspecao`, de propósito — como o jogador pode trocar de trabalho ativo e voltar depois, guardar esse limite num objeto efêmero (recriado toda vez que `montar_alvos()` roda) resetaria o limite indevidamente. `TrabalhoAgendado` persiste durante toda a vida do trabalho no expediente.

---

## 22. `Para_inicial.gd`

**Status:** confirmado, sem alterações nesta sessão | **Tipo:** `Button`

```gdscript
extends Button

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/inicio.tscn")
```

> Confirma a pendência já catalogada em `netetive_status.md` ("Caminho hardcoded em `Para_inicial.gd`"): o caminho usado é `res://Scenes/inicio.tscn`, em minúsculas e sem o prefixo `Scenes/Escritorio.tscn` usado no resto do projeto (`Quadro_avisos`, `Iniciar.gd` etc. apontam pra `res://Scenes/Escritorio.tscn`). Se `inicio.tscn` for de fato um arquivo/cena diferente de `Escritorio.tscn`, vale confirmar qual dos dois é a cena inicial real — se for só uma inconsistência de nomenclatura (mesma cena, caminho escrito diferente), é a hora de padronizar.

---

---

## 23. `caixa_selecao.gd` — órfão confirmado

**Status:** confirmado **não anexado a nenhum nó ativo** | **Tipo:** `Control`

Não confundir com `CaixaDeSelecao.gd` (seção 14) — nome quase idêntico, mas conteúdo diferente. Confirmado via Inspector que o nó `CaixaSelecao` (dentro de `ModuloInspecao`) usa `res://Scripts/Tela/CaixaDeSelecao.gd` (o vazio), não este.

```gdscript
extends Control

signal clicou_em(pos: Vector2)

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE 

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("clicou_em", event.position)
```

> ✅ **Confirmado órfão.** Faz basicamente o mesmo trabalho que `area_clique_inspecao.gd` (seção 11) — captura clique esquerdo via `_unhandled_input` e emite um sinal com a posição — mas de uma versão anterior do sistema, antes de `AreaCliqueInspecao`/`GerenciadorInspecao` existirem. Seguro remover, mas antes de apagar: `Ctrl+Shift+F` no Godot buscando por `clicou_em` (o nome do sinal) pra garantir que nenhum outro script ainda esteja conectado nele. Se a busca não retornar nenhuma conexão, pode apagar com confiança.

---

## 24. `banco_de_trabalhos.gd` (novo — módulo de dados extraído de `DadosJogo.gd`)

**Status:** novo arquivo | **Tipo:** `RefCounted`, `class_name BancoDeTrabalhos`

Separa a **definição** dos trabalhos (dados estáticos) do **estado em runtime** que mora em `DadosJogo.gd`. Usa `static func`, então não precisa ser Autoload — é acessível globalmente por `class_name` sozinho.

```gdscript
class_name BancoDeTrabalhos
extends RefCounted

# =====================================================================
# BancoDeTrabalhos
# ---------------------------------------------------------------------
# Módulo isolado só pra montar os TrabalhoInspecao do jogo. Fica de fora
# de DadosJogo.gd de propósito — DadosJogo cuida de ESTADO (dinheiro,
# agenda do dia, resultados pendentes); este arquivo cuida só de DADOS
# (a definição de cada trabalho em si).
#
# Só entram aqui trabalhos já migrados pro sistema de grid (quadrante +
# altura_real em AlvoInspecao). Trabalhos sem arte calibrada ainda ficam
# de fora até terem imagem real — adicionar de volta quando a arte
# estiver pronta e os índices de quadrante forem calibrados.
# =====================================================================

static func criar_todos() -> Array[TrabalhoInspecao]:
	return [
		_criar_trabalho_cavalo_de_troia(),
		_criar_trabalho_scareware(),
		_criar_trabalho_ransomware(),
	]


# ---------------------------------------------------------------------
# TODO: trocar "imagem_site" por preload da arte real quando estiver pronta.
# TODO: ajustar quadrante/altura_real conforme a arte final do site.
# ---------------------------------------------------------------------
static func _criar_trabalho_cavalo_de_troia() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Remover Cavalo de Tróia"
	trabalho.descricao = "O usuário baixou um ativador falso e agora o computador está travando muito."
	trabalho.recompensa_base = 150
	trabalho.imagem_site = preload("res://Sprites/site_falso_1.png")
	trabalho.linhas_grid = 5

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.quadrante = 1        # linha 0, coluna 1 (centro) — em recalibração
	suspeito.altura_real = 60.0   # em recalibração
	suspeito.capitulo_relacionado = 3  # Ransomware, por exemplo
	suspeito.dica = "Esse botão de download promete resolver tudo rápido demais — desconfie de downloads não solicitados."

	trabalho.alvos = [suspeito]
	return trabalho


# ---------------------------------------------------------------------
# v3.5 — novo, adaptado da ideia da branch trabalho_malware. A imagem
# original dessa branch retratava scareware (falso alerta de vírus com
# botão de download disfarçado), não ransomware em ação — por isso o
# capitulo_relacionado aponta pro capítulo "Scareware" novo (índice 5
# em ConteudoLivro.PAGINAS, que substituiu "Senha Fraca"), não pro
# capítulo "Ransomware".
#
# TODO: quadrante/altura_real são estimativa por proporção da imagem
# original (fração de largura/altura, não pixels absolutos) — calibrar
# com print() em montar_alvos(), clicando no botão "SAFE BROWSER" da
# imagem em execução, antes de considerar pronto.
# ---------------------------------------------------------------------
static func _criar_trabalho_scareware() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Identificar Scareware"
	trabalho.descricao = "O usuário recebeu um alerta assustador de vírus no navegador e quase baixou uma 'ferramenta de segurança' que na verdade criptografaria os dados dele."
	trabalho.recompensa_base = 150
	trabalho.imagem_site = preload("res://Sprites/tela_ransomware/tela_trabalho_ransomware.png")
	trabalho.linhas_grid = 5

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.quadrante = 10       # linha 3, coluna 1 (centro) — botão "SAFE BROWSER"
	suspeito.altura_real = 280.0  # estimativa, calibrar
	suspeito.capitulo_relacionado = 5  # Scareware (novo capítulo, substitui Senha Fraca)
	suspeito.dica = "Aquele botão verde 'mais popular' promete resolver tudo rápido demais — sites legítimos de segurança não empurram um único download com tanta pressa e destaque."

	trabalho.alvos = [suspeito]
	return trabalho


# ---------------------------------------------------------------------
# v3.5 — novo. Imagem redesenhada nesta rodada pra retratar ransomware de
# verdade (arquivos criptografados, valor de resgate em Bitcoin, endereço
# de carteira, instruções de pagamento) — diferente da imagem de
# _criar_trabalho_scareware(), que é só a isca. capitulo_relacionado
# aponta pro capítulo "Ransomware" já existente (índice 3), que agora
# bate literalmente com o conteúdo mostrado.
#
# TODO: quadrante/altura_real são estimativa por proporção da imagem
# original — calibrar com print() em montar_alvos(), clicando no botão
# "COMO PAGAR / INSTRUÇÕES" da imagem em execução.
# ---------------------------------------------------------------------
static func _criar_trabalho_ransomware() -> TrabalhoInspecao:
	var trabalho := TrabalhoInspecao.new()
	trabalho.titulo = "Remover Ransomware"
	trabalho.descricao = "Os arquivos do usuário foram criptografados e uma nota de resgate apareceu na tela, exigindo pagamento em Bitcoin."
	trabalho.recompensa_base = 200
	trabalho.imagem_site = preload("res://Sprites/tela_ransomware/tela_trabalho_ransomware_real.png")
	trabalho.linhas_grid = 5

	var suspeito := AlvoInspecao.new()
	suspeito.tipo = AlvoInspecao.Tipo.SUSPEITO
	suspeito.quadrante = 10       # linha 3, coluna 1 (centro) — botão "COMO PAGAR"
	suspeito.altura_real = 270.0  # cobre o bloco do resgate inteiro — calibrar
	suspeito.capitulo_relacionado = 3  # Ransomware
	suspeito.dica = "Pagar o resgate não garante que você vai recuperar os arquivos — e só financia o próximo ataque. A defesa de verdade é ter backup feito antes disso acontecer."

	trabalho.alvos = [suspeito]
	return trabalho
```

> ⚠️ **4 trabalhos originais ainda de fora, 2 novos entraram:** "Limpeza de Disco", "Otimizar Inicialização", "Atualizar Drivers de Vídeo" e "Substituir Pasta Térmica" continuam removidos (sem arte calibrada). "Identificar Scareware" e "Remover Ransomware" (v3.5) entraram no lugar, recriados a partir da ideia da branch `trabalho_malware`, mas com arte e dados próprios, formato de grid desde o início — nenhum dos dois usou a cena solta `Tela_baixar_ransomware.tscn` dessa branch (tinha os `@export` do `CoordenadorTrabalho` vazios, arquitetura antiga).
>
> ⚠️ **Bug evitado, não herdado:** a função de trabalho original da `trabalho_malware` (`_criar_trabalho_remover_ransomware()`) existia no código-fonte, mas nunca tinha sido incluída no array de `_ready()`/`criar_todos()` daquela branch — o trabalho nunca era sorteado de fato. Confirmado que `_criar_trabalho_scareware()` e `_criar_trabalho_ransomware()` estão de fato dentro do array retornado por `criar_todos()` acima.

> ⚠️ **4 trabalhos removidos temporariamente:** "Limpeza de Disco", "Otimizar Inicialização", "Atualizar Drivers de Vídeo" e "Substituir Pasta Térmica" existiam na v1/v2 (com `posicao`/`tamanho` livres, que não existem mais em `AlvoInspecao`) e foram tirados daqui por dependerem de arte de site ainda não produzida. Precisam ser recriados — não só "reabilitados" — com `quadrante`/`altura_real`/`dica` calibrados manualmente assim que a arte de cada um estiver pronta, seguindo o padrão do `_criar_trabalho_cavalo_de_troia()` acima.
>
> **`quadrante = 1` / `altura_real = 60.0` ainda são placeholders em recalibração** — a posição visual real da URL falsa na imagem `site_falso_1.png` pareceu estar mais à esquerda (quadrante `0`) do que o centro (`1`) durante os primeiros testes. Confirmar com um `print()` temporário em `montar_alvos()` (`GerenciadorInspecao`, seção 6) antes de considerar calibrado.
>
> **`dica` é um campo manual, independente do `ConteudoLivro`.** Chegou a ser cogitada uma versão que puxava a dica do campo `descricao` do capítulo do livro (uma função `obter_dica_capitulo()` em `DadosJogo.gd`), mas essa abordagem foi descartada em favor de um texto próprio por alvo, mais curto e específico do contexto do site. Não existe (nem nunca chegou a ficar) nenhuma função `obter_dica_capitulo()` em `DadosJogo.gd`.

**Passo no editor:** salvar em qualquer pasta do projeto (sugestão: junto dos outros Resources, `res://Scripts/`). Não precisa configurar como Autoload.

---

## 25. `tier_upgrade.gd` (v3.3 — novo, degrau individual de upgrade)

**Status:** novo arquivo | **Tipo:** `Resource`, `class_name TierUpgrade`

```gdscript
class_name TierUpgrade
extends Resource

@export var preco: int = 0
@export var valor_efeito: float = 0.0
@export var valor_efeito_secundario: float = 0.0
@export var upkeep: float = 0.0
@export var descricao: String = ""
```

Um degrau individual dentro de uma `LinhaUpgrade` — dumb data, sem lógica própria. O *significado* de `valor_efeito`/`valor_efeito_secundario` muda por linha:

| Linha | `valor_efeito` | `valor_efeito_secundario` | `upkeep` |
|---|---|---|---|
| PC | tempo do popup (s) | não usado | não usado |
| Assistente — Treinamento | minutos/trabalho | taxa de sucesso (0.0–1.0) | custo diário **por assistente** |
| Assistente — Quantidade | nº de assistentes simultâneos | não usado | não usado |
| IA — Capacidade | trabalhos/noite | não usado | custo diário fixo |
| IA — Eficiência | % da recompensa entregue (0.0–1.0) | não usado | custo diário fixo |

**Passo no editor:** salvar em qualquer pasta do projeto (mesmo lugar dos outros Resources). Não precisa Autoload.

---

## 26. `linha_upgrade.gd` (v3.3 — novo, progressão + `tier_atual`)

**Status:** novo arquivo | **Tipo:** `Resource`, `class_name LinhaUpgrade`

```gdscript
class_name LinhaUpgrade
extends Resource

@export var chave: String = ""
@export var nome: String = ""
@export var tiers: Array[TierUpgrade] = []
@export var chave_pre_requisito: String = ""

var tier_atual: int = 0


func esta_no_maximo() -> bool:
	return tier_atual >= tiers.size()


func proximo_tier() -> TierUpgrade:
	if esta_no_maximo():
		return null
	return tiers[tier_atual]


func tier_comprado(indice: int) -> TierUpgrade:
	if indice < 0 or indice >= tier_atual:
		return null
	return tiers[indice]


func valor_efeito_atual(valor_base: float = 0.0) -> float:
	if tier_atual <= 0:
		return valor_base
	return tiers[tier_atual - 1].valor_efeito


func valor_efeito_secundario_atual(valor_base: float = 0.0) -> float:
	if tier_atual <= 0:
		return valor_base
	return tiers[tier_atual - 1].valor_efeito_secundario


func upkeep_atual() -> float:
	if tier_atual <= 0:
		return 0.0
	return tiers[tier_atual - 1].upkeep
```

Diferente de `BancoDeTrabalhos`/`TrabalhoInspecao`, aqui **não** existe separação entre definição estática e estado runtime — cada jogador só tem uma instância de cada linha (não é sorteada nem repetida), então `tier_atual` vive dentro do próprio `Resource`. `chave_pre_requisito` guarda a chave (`String`) de outra linha que precisa ter `tier_atual >= 1` antes desta poder ser comprada — vazio = sem pré-requisito, é a linha de entrada.

Todos os helpers leem `tier_atual` **na hora**, sem cache externo — qualquer script que compre um tier novo já reflete o efeito na próxima leitura, sem precisar notificar ninguém.

**Passo no editor:** salvar em qualquer pasta do projeto. Não precisa Autoload.

---

## 27. `banco_de_upgrades.gd` (v3.3 — novo, módulo de dados das 5 linhas)

**Status:** novo arquivo | **Tipo:** `RefCounted`, `class_name BancoDeUpgrades` (`static func`)

```gdscript
class_name BancoDeUpgrades
extends RefCounted

const CHAVE_PC := "pc"
const CHAVE_ASSISTENTE_TREINAMENTO := "assistente_treinamento"
const CHAVE_ASSISTENTE_QUANTIDADE := "assistente_quantidade"
const CHAVE_IA_CAPACIDADE := "ia_capacidade"
const CHAVE_IA_EFICIENCIA := "ia_eficiencia"


static func criar_todas() -> Dictionary:
	var linhas: Dictionary = {}
	linhas[CHAVE_PC] = _criar_linha_pc()
	linhas[CHAVE_ASSISTENTE_TREINAMENTO] = _criar_linha_assistente_treinamento()
	linhas[CHAVE_ASSISTENTE_QUANTIDADE] = _criar_linha_assistente_quantidade()
	linhas[CHAVE_IA_CAPACIDADE] = _criar_linha_ia_capacidade()
	linhas[CHAVE_IA_EFICIENCIA] = _criar_linha_ia_eficiencia()
	return linhas


static func _criar_linha_pc() -> LinhaUpgrade:
	var linha := LinhaUpgrade.new()
	linha.chave = CHAVE_PC
	linha.nome = "PC"
	linha.tiers = [
		_tier(500, 3.0, 0.0, 0.0, "Popup de verificação: 4s -> 3s"),
		_tier(900, 2.0, 0.0, 0.0, "Popup de verificação: 3s -> 2s"),
		_tier(1500, 1.0, 0.0, 0.0, "Popup de verificação: 2s -> 1s"),
		_tier(2500, 0.0, 0.0, 0.0, "Popup de verificação: instantâneo"),
	]
	return linha


# Bloqueada até Quantidade tier 1 — invertido em runtime depois de já
# implementado (ver netetive.md seção 3.6 e netetive_changelog.md v3.3
# pra histórico completo dessa decisão).
static func _criar_linha_assistente_treinamento() -> LinhaUpgrade:
	var linha := LinhaUpgrade.new()
	linha.chave = CHAVE_ASSISTENTE_TREINAMENTO
	linha.nome = "Assistente — Treinamento"
	linha.chave_pre_requisito = CHAVE_ASSISTENTE_QUANTIDADE
	linha.tiers = [
		_tier(800, 120.0, 0.70, 40.0, "120 min/trabalho, 70% de sucesso — desbloqueia o 1º assistente"),
		_tier(1400, 105.0, 0.80, 55.0, "105 min/trabalho, 80% de sucesso"),
		_tier(2200, 90.0, 0.90, 75.0, "90 min/trabalho, 90% de sucesso"),
		_tier(3200, 75.0, 1.00, 100.0, "75 min/trabalho, 100% de sucesso"),
	]
	return linha


# Linha de ENTRADA (sem pré-requisito) — quem desbloqueia o acesso ao
# Treinamento. Sem upkeep próprio (o custo já é coberto pelo
# Treinamento × quantidade, ver calculadora_upkeep.gd seção 30).
static func _criar_linha_assistente_quantidade() -> LinhaUpgrade:
	var linha := LinhaUpgrade.new()
	linha.chave = CHAVE_ASSISTENTE_QUANTIDADE
	linha.nome = "Assistente — Quantidade"
	linha.tiers = [
		_tier(1200, 2.0, 0.0, 0.0, "2 assistentes simultâneos"),
		_tier(2000, 3.0, 0.0, 0.0, "3 assistentes simultâneos"),
		_tier(3000, 4.0, 0.0, 0.0, "4 assistentes simultâneos"),
		_tier(4200, 5.0, 0.0, 0.0, "5 assistentes simultâneos"),
	]
	return linha


static func _criar_linha_ia_capacidade() -> LinhaUpgrade:
	var linha := LinhaUpgrade.new()
	linha.chave = CHAVE_IA_CAPACIDADE
	linha.nome = "IA — Capacidade"
	linha.tiers = [
		_tier(1400, 1.0, 0.0, 60.0, "1 trabalho/noite — desbloqueia a IA"),
		_tier(2400, 2.0, 0.0, 100.0, "2 trabalhos/noite"),
		_tier(3600, 3.0, 0.0, 150.0, "3 trabalhos/noite"),
		_tier(5000, 4.0, 0.0, 210.0, "4 trabalhos/noite"),
	]
	return linha


static func _criar_linha_ia_eficiencia() -> LinhaUpgrade:
	var linha := LinhaUpgrade.new()
	linha.chave = CHAVE_IA_EFICIENCIA
	linha.nome = "IA — Eficiência"
	linha.chave_pre_requisito = CHAVE_IA_CAPACIDADE
	linha.tiers = [
		_tier(1000, 0.50, 0.0, 45.0, "Recompensa entregue pela IA: 35% -> 50%"),
		_tier(1800, 0.65, 0.0, 70.0, "50% -> 65%"),
		_tier(2800, 0.80, 0.0, 100.0, "65% -> 80%"),
		_tier(4000, 0.95, 0.0, 140.0, "80% -> 95%"),
	]
	return linha


static func _tier(preco: int, valor_efeito: float, valor_efeito_secundario: float, upkeep: float, descricao: String) -> TierUpgrade:
	var t := TierUpgrade.new()
	t.preco = preco
	t.valor_efeito = valor_efeito
	t.valor_efeito_secundario = valor_efeito_secundario
	t.upkeep = upkeep
	t.descricao = descricao
	return t
```

Mesmo padrão de `banco_de_trabalhos.gd`: separa a **definição** (preços, efeitos, upkeep, aqui) do **estado em runtime** (`tier_atual` de cada linha, vive em `DadosJogo.upgrades`, seção 3). `static func`, não precisa Autoload.

**Passo no editor:** salvar em qualquer pasta do projeto (sugestão: junto dos outros Resources).

---

## 28. `gerenciador_assistente.gd` (v3.3 — novo, fila com tempo simulado)

**Status:** novo arquivo | **Tipo:** `Node`, `class_name GerenciadorAssistente` | **Cena:** filho de `ModuloTrabalho` (irmão de `GerenciadorExpediente`/`GerenciadorTrabalho`/`CoordenadorTrabalho`)

```gdscript
extends Node
class_name GerenciadorAssistente

signal trabalho_assistente_concluido(agendado: TrabalhoAgendado, acertou: bool)

@export var gerenciador_expediente: Node

var _fila_espera: Array[TrabalhoAgendado] = []
var _em_andamento: Dictionary = {}   # TrabalhoAgendado -> hora_conclusao_prevista (float)


func _ready() -> void:
	if gerenciador_expediente == null:
		push_warning("GerenciadorAssistente: gerenciador_expediente não atribuído no Inspetor.")


func esta_disponivel() -> bool:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_TREINAMENTO)
	return linha != null and linha.tier_atual >= 1


func trabalho_esta_na_fila_ou_andamento(agendado: TrabalhoAgendado) -> bool:
	return _em_andamento.has(agendado) or _fila_espera.has(agendado)


func delegar(agendado: TrabalhoAgendado) -> bool:
	if not esta_disponivel():
		push_warning("GerenciadorAssistente: nenhum assistente contratado ainda (compre Assistente — Treinamento tier 1).")
		return false

	if agendado == null or trabalho_esta_na_fila_ou_andamento(agendado):
		return false

	if not DadosJogo.resultados_pendentes.has(agendado):
		DadosJogo.iniciar_resultado_pendente(agendado, _hora_atual())

	if _em_andamento.size() < _capacidade_atual():
		_iniciar_processamento(agendado)
	else:
		_fila_espera.append(agendado)

	return true


func _iniciar_processamento(agendado: TrabalhoAgendado) -> void:
	var minutos := _tempo_por_trabalho_minutos()
	_em_andamento[agendado] = _hora_atual() + (minutos / 60.0)


func _puxar_proximo_da_fila() -> void:
	if _fila_espera.is_empty() or _em_andamento.size() >= _capacidade_atual():
		return
	var proximo: TrabalhoAgendado = _fila_espera.pop_front()
	_iniciar_processamento(proximo)


func _process(_delta: float) -> void:
	if _em_andamento.is_empty():
		return

	var hora_atual := _hora_atual()
	var concluidos: Array[TrabalhoAgendado] = []

	for agendado in _em_andamento.keys():
		if hora_atual >= _em_andamento[agendado]:
			concluidos.append(agendado)

	for agendado in concluidos:
		_em_andamento.erase(agendado)
		_resolver_trabalho(agendado, hora_atual)
		_puxar_proximo_da_fila()


func _resolver_trabalho(agendado: TrabalhoAgendado, hora_atual: float) -> void:
	var acertou := randf() < _taxa_sucesso_atual()

	if DadosJogo.resultados_pendentes.has(agendado):
		var resultado: ResultadoTrabalho = DadosJogo.resultados_pendentes[agendado]
		resultado.achou_alvo_correto = acertou
		resultado.diagnostico_correto = acertou
		if resultado.diagnostico_escolhido == "":
			resultado.diagnostico_escolhido = "Resolvido pelo Assistente"

	DadosJogo.finalizar_trabalho(agendado, hora_atual)
	trabalho_assistente_concluido.emit(agendado, acertou)


func _capacidade_atual() -> int:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_QUANTIDADE)
	if linha == null:
		return 1
	return int(linha.valor_efeito_atual(1.0))


func _tempo_por_trabalho_minutos() -> float:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_TREINAMENTO)
	if linha == null or linha.tier_atual <= 0:
		return 0.0
	return linha.valor_efeito_atual()


func _taxa_sucesso_atual() -> float:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_TREINAMENTO)
	if linha == null or linha.tier_atual <= 0:
		return 0.0
	return linha.valor_efeito_secundario_atual()


func _hora_atual() -> float:
	if gerenciador_expediente != null and "hora_atual" in gerenciador_expediente:
		return gerenciador_expediente.hora_atual
	return 0.0
```

Fila de trabalhos delegados pelo jogador. `delegar()` processa direto se há slot livre (capacidade = linha Quantidade) ou enfileira em FIFO (`_fila_espera`). `_process()` compara `hora_atual` do relógio simulado contra o horário de conclusão previsto de cada item em `_em_andamento` — barato mesmo rodando todo frame porque a lista nunca passa de 5 itens (capacidade máxima). `_resolver_trabalho()` sorteia acerto/erro pela taxa de sucesso do Treinamento e fecha o `ResultadoTrabalho` direto, sem passar pela `NovaAba`.

Todos os valores (tempo, taxa, capacidade) lidos **sob demanda** de `DadosJogo.obter_linha_upgrade()`, nunca cacheados — comprar um tier novo no meio do dia já afeta o próximo trabalho delegado.

**Passo no editor:** criar um `Node` filho de `ModuloTrabalho`, nomear `GerenciadorAssistente`, anexar este script, e arrastar `GerenciadorExpediente` (irmão) pro campo `@export`.

---

## 29. `gerenciador_ia_noturna.gd` (v3.3 — novo, resolução overnight)

**Status:** modificado (v3.4 — `fama_ganha` com Eficiência) | **Tipo:** `RefCounted`, `class_name GerenciadorIANoturna` (`static func`, sem nó na árvore)

> **Atualização v3.4 (Sistema de Fama):** `_resolver_trabalho()` agora também define `resultado.fama_ganha = int(agendado.trabalho.recompensa_fama * _eficiencia_atual()) if acertou else 0` — mesma % de Eficiência que já reduz o dinheiro. Trabalho malfeito pela IA rende menos reputação, não só menos grana.

```gdscript
class_name GerenciadorIANoturna
extends RefCounted

const TAXA_SUCESSO_IA := 0.75
const EFICIENCIA_BASE := 0.35


static func processar_noite(hora_fim_expediente: float) -> void:
	if not _ia_esta_disponivel():
		return

	var candidatos := _coletar_trabalhos_sobrados()
	if candidatos.is_empty():
		return

	candidatos.shuffle()

	var capacidade := _capacidade_atual()
	var processados := 0

	for agendado in candidatos:
		if processados >= capacidade:
			break
		_resolver_trabalho(agendado, hora_fim_expediente)
		processados += 1


static func _ia_esta_disponivel() -> bool:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_IA_CAPACIDADE)
	return linha != null and linha.tier_atual >= 1


static func _capacidade_atual() -> int:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_IA_CAPACIDADE)
	if linha == null or linha.tier_atual <= 0:
		return 0
	return int(linha.valor_efeito_atual())


static func _eficiencia_atual() -> float:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_IA_EFICIENCIA)
	if linha == null:
		return EFICIENCIA_BASE
	return linha.valor_efeito_atual(EFICIENCIA_BASE)


static func _coletar_trabalhos_sobrados() -> Array[TrabalhoAgendado]:
	var sobrados: Array[TrabalhoAgendado] = []
	for agendado in DadosJogo.trabalhos_do_dia:
		if agendado.concluido:
			continue
		if DadosJogo.resultados_pendentes.has(agendado):
			continue
		if agendado.apareceu:
			sobrados.append(agendado)
	return sobrados


static func _resolver_trabalho(agendado: TrabalhoAgendado, hora_fim_expediente: float) -> void:
	var acertou := randf() < TAXA_SUCESSO_IA

	var resultado := ResultadoTrabalho.new()
	resultado.agendado = agendado
	resultado.hora_inicio = hora_fim_expediente
	resultado.hora_fim = hora_fim_expediente
	resultado.achou_alvo_correto = acertou
	resultado.diagnostico_correto = acertou
	resultado.diagnostico_escolhido = "Resolvido pela IA (noturno)"
	resultado.acertou_no_geral = acertou
	resultado.recompensa = int(agendado.recompensa_dinheiro * _eficiencia_atual()) if acertou else 0
	resultado.fama_ganha = int(agendado.trabalho.recompensa_fama * _eficiencia_atual()) if acertou else 0

	agendado.concluido = true
	DadosJogo.trabalhos_concluidos_hoje += 1
	DadosJogo.resultados_do_dia.append(resultado)
```

`processar_noite()` é chamado **uma única vez**, por `Main_select_script._on_expediente_encerrado()` (seção 17), antes da troca de cena pra `RelatorioDia.tscn`. Coleta trabalhos "sobrados" (`apareceu == true` e `not concluido`, excluindo qualquer um que já tenha resultado pendente em outro lugar — ex: fila do Assistente, seção 28), sorteia acerto a 75% fixo, aplica a % de Eficiência sobre a recompensa, e grava direto em `resultados_do_dia` (sem passar por `resultados_pendentes`, já que não há `hora_inicio` real de expediente).

**Passo no editor:** salvar em qualquer pasta do projeto. Não precisa Autoload nem nó — a chamada é direta via `class_name`.

---

## 30. `calculadora_upkeep.gd` (v3.3 — novo, soma do upkeep diário)

**Status:** novo arquivo | **Tipo:** `RefCounted`, `class_name CalculadoraUpkeep` (`static func`, sem nó)

```gdscript
class_name CalculadoraUpkeep
extends RefCounted

static func calcular_total() -> int:
	return _upkeep_assistente() + _upkeep_ia_capacidade() + _upkeep_ia_eficiencia()


static func _upkeep_assistente() -> int:
	var linha_treinamento: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_TREINAMENTO)
	if linha_treinamento == null or linha_treinamento.tier_atual <= 0:
		return 0

	var linha_quantidade: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_ASSISTENTE_QUANTIDADE)
	var quantidade := 1
	if linha_quantidade != null:
		quantidade = int(linha_quantidade.valor_efeito_atual(1.0))

	return int(linha_treinamento.upkeep_atual() * quantidade)


static func _upkeep_ia_capacidade() -> int:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_IA_CAPACIDADE)
	if linha == null:
		return 0
	return int(linha.upkeep_atual())


static func _upkeep_ia_eficiencia() -> int:
	var linha: LinhaUpgrade = DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_IA_EFICIENCIA)
	if linha == null:
		return 0
	return int(linha.upkeep_atual())
```

Isola a fórmula de custo diário — `relatorio_dia.gd` (seção 0) só chama `calcular_total()`, sem precisar conhecer os detalhes de cada categoria. Upkeep do Assistente = `upkeep_atual(Treinamento) × quantidade` (a linha Quantidade não tem upkeep próprio); upkeep da IA = soma fixa das duas linhas, sem multiplicação (só existe 1 IA).

**Passo no editor:** salvar em qualquer pasta do projeto. Não precisa Autoload nem nó.

---

## 31. `painel_upgrades.gd` (v3.3 — novo, UI de compra)

**Status:** novo arquivo | **Tipo:** `Panel`, `class_name PainelUpgrades` | **Cena:** novo em `Escritorio.tscn`

```gdscript
extends Panel
class_name PainelUpgrades

@onready var vbox_linhas: VBoxContainer = get_node_or_null("ScrollContainer/VBoxLinhas")
@onready var label_dinheiro: Label = get_node_or_null("LabelDinheiro")
@onready var btn_fechar: Button = get_node_or_null("BtnFechar")

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


func _on_comprar_pressionado(chave: String) -> void:
	var sucesso := DadosJogo.comprar_upgrade(chave)
	if not sucesso:
		push_warning("PainelUpgrades: compra de '%s' falhou (ver warning anterior de DadosJogo)." % chave)
	montar_linhas()
```

UI **pura** — só desenha o estado atual (lido via `DadosJogo.obter_linha_upgrade()`) e delega o clique de compra pra `DadosJogo.comprar_upgrade()` (seção 3), remontando a lista inteira depois (atualiza saldo, preços e desbloqueios de uma vez).

**Estrutura de cena exigida** (raiz `Panel`):
```
PainelUpgrades (Panel)
├── LabelDinheiro (Label)
├── ScrollContainer (ScrollContainer)
│   └── VBoxLinhas (VBoxContainer)
└── BtnFechar (Button)
```

> ⚠️ **Bug já visto em produção:** o `Panel` nasceu com `Size` `0x0` na viewport, então `abrir() → show()` rodava sem erro, mas nada aparecia na tela (nenhum push_warning, porque tecnicamente tudo funcionou — só não tinha área pra desenhar). Corrigido redimensionando o `Panel` e o `ScrollContainer` no editor. Vale conferir sempre que um `Panel`/`Control` novo for criado do zero: tamanho padrão às vezes não é visível.

**Passo no editor:** criar a hierarquia acima em `Escritorio.tscn`, anexar este script na raiz `Panel`. Nasce oculto (`hide()` no `_ready()`).

---

## 32. `btn_upgrades.gd` (v3.3 — novo, botão do Escritório)

**Status:** novo arquivo | **Tipo:** `TextureButton` | **Cena:** novo em `Escritorio.tscn`

```gdscript
extends TextureButton

@export var painel_upgrades: Control


func _on_pressed() -> void:
	if painel_upgrades == null:
		push_warning("BtnUpgrades: painel_upgrades não atribuído no Inspetor.")
		return

	if painel_upgrades.has_method("abrir"):
		painel_upgrades.abrir()
	else:
		push_warning("BtnUpgrades: painel_upgrades atribuído não tem o método abrir().")
```

Mesmo padrão de conexão de `Quadro_avisos`/`Iniciar.gd` (seção 1 de `netetive.md`): sinal `pressed` conectado pelo editor (aba Node → Signals), não via `connect()` em código.

> ⚠️ **Bug já visto em produção:** ao conectar o sinal pelo editor, a seleção do nó-alvo ficou apontando pra `../Quadro_avisos` em vez do próprio `BtnUpgrades` — clique não executava nada, sem erro no console (o método simplesmente nunca era chamado). Corrigido desconectando e reconectando com o alvo certo (o próprio nó, aparece como `.` na lista de conexões). Fácil de confirmar: aba Node → Signals → `pressed()` deve mostrar `. :: _on_pressed()`, não um caminho relativo pra outro nó.

**Passo no editor:** anexar em `BtnUpgrades` (`TextureButton`), conectar `pressed` a si mesmo pelo editor, e arrastar `PainelUpgrades` pro campo `@export`.

---

## 33. `calculadora_fama.gd` (v3.4 — novo, curva não-linear de trabalhos/dia)

**Status:** novo arquivo | **Tipo:** `RefCounted`, `class_name CalculadoraFama` (`static func`, sem nó na árvore)

```gdscript
class_name CalculadoraFama
extends RefCounted

const TRABALHOS_BASE_PADRAO := 6
const FATOR_CRESCIMENTO := 1.0   # multiplica sqrt(fama); ajustar aqui pra calibrar a curva


static func calcular_quantidade_trabalhos_dia(fama: int, base: int = TRABALHOS_BASE_PADRAO) -> int:
	var fama_efetiva: int = max(0, fama)
	var bonus := int(floor(sqrt(float(fama_efetiva)) * FATOR_CRESCIMENTO))
	return base + bonus
```

Função pura que converte `fama_jogador` na quantidade de trabalhos que aparecem no dia — isolada aqui pra `gerenciador_expediente.gd` (seção 10) não precisar conhecer a fórmula, só chamar `calcular_quantidade_trabalhos_dia()`.

**Design pedido pelo usuário:** quanto menos fama, mais rápido a quantidade cresce; quanto mais fama, mais devagar (retornos decrescentes). A curva de raiz quadrada entrega isso sozinha, sem nenhum `if`/condicional extra — a derivada de `sqrt(x)` cai naturalmente conforme `x` cresce, então cada ponto de fama adicional rende cada vez menos trabalhos novos.

**Curva de referência** (fator `1.0`, base `6`):

| Fama | Trabalhos/dia |
|---|---|
| 0 | 6 |
| 25 | 11 |
| 100 | 16 |
| 400 | 26 |
| 900 | 36 |

> ⚠️ **Bug corrigido durante a integração:** a linha `var fama_efetiva := max(0, fama)` (sem tipo explícito) gerava o warning "The variable type is being inferred from a Variant value" tratado como erro pelo projeto — o `max()` built-in do GDScript pode devolver `Variant` dependendo dos tipos dos argumentos passados. Corrigido tipando explicitamente: `var fama_efetiva: int = max(0, fama)`.

**Passo no editor:** salvar em qualquer pasta do projeto (mesmo lugar dos outros módulos estáticos como `BancoDeUpgrades`/`CalculadoraUpkeep`). Não precisa Autoload nem nó.

---

## 34. `hud_manager.gd` (v3.5 — novo, lê `DadosJogo` em vez de `Global`)

**Status:** novo arquivo, portado e reescrito a partir da branch `score_system` | **Tipo:** `Node` | **Cena:** filho de `Score` (instância de `Scores.tscn`) em `Escritorio.tscn`

> A versão original desta branch escutava sinais do autoload `Global` (`fame_received`/`altered_money`). Esse autoload foi **descartado por completo** na integração — não entrou no `project.godot` — porque duplicaria o estado que já existe em `DadosJogo.dinheiro_jogador`/`DadosJogo.fama_jogador`. Como `DadosJogo` não emite sinal de mudança, o script passou a fazer **polling em `_process()`**.

```gdscript
extends Node

@onready var contador_dinheiro: Label = $control/container_dinheiro/icone_dinheiro/contador_dinheiro
@onready var contador_fama: Label = $control/container_fama/icone_fama/contador_fama

var _ultimo_dinheiro: int = -1
var _ultima_fama: int = -1


func _ready() -> void:
	if contador_dinheiro == null:
		push_warning("HudManager: nó 'contador_dinheiro' não encontrado — confira a estrutura da cena.")
	if contador_fama == null:
		push_warning("HudManager: nó 'contador_fama' não encontrado — confira a estrutura da cena.")

	_atualizar_se_mudou()


func _process(_delta: float) -> void:
	_atualizar_se_mudou()


func _atualizar_se_mudou() -> void:
	if DadosJogo.dinheiro_jogador != _ultimo_dinheiro:
		_ultimo_dinheiro = DadosJogo.dinheiro_jogador
		atualizar_dinheiro(_ultimo_dinheiro)

	if DadosJogo.fama_jogador != _ultima_fama:
		_ultima_fama = DadosJogo.fama_jogador
		atualizar_fama(_ultima_fama)


func atualizar_fama(nova_fama: int) -> void:
	if contador_fama != null:
		contador_fama.text = str(nova_fama)


func atualizar_dinheiro(novo_dinheiro: int) -> void:
	if contador_dinheiro != null:
		contador_dinheiro.text = "R$ %d" % novo_dinheiro
```

**Mudanças em relação ao script original da `score_system`:**
- `Global.fame_received.connect(...)`/`Global.altered_money.connect(...)` → removidos; substituídos por `_atualizar_se_mudou()` chamado em `_process()`.
- `novo_dinheiro: float` → `int` (tipo real de `DadosJogo.dinheiro_jogador`); `String.num(novo_dinheiro, 2)` (2 casas decimais) → `"%d"` (sem centavos).
- Adicionadas checagens `null` com `push_warning()`, seguindo o padrão já usado em `relatorio_dia.gd`/`painel_upgrades.gd`.

> ⚠️ **Bug corrigido nesta integração:** o caminho relativo original (`$control/container/container_dinheiro/...`) partia do pressuposto de um `MarginContainer` intermediário chamado `container` que não existe na estrutura real da cena — o caminho certo é `$control/container_dinheiro/...`, sem esse nível a mais. Gerava `Node not found` nos dois `@onready` e dois `push_warning()` em cascata no `_ready()`.
>
> ⚠️ **Efeito colateral esperado, não é bug:** como o crédito de dinheiro/fama só acontece uma vez, dentro de `RelatorioDia.montar_relatorio()`, o HUD fica parado o expediente inteiro e só salta pro valor final quando o relatório é gerado — diferente do comportamento "ao vivo" da versão original com `Global`.
>
> 💡 **Melhoria sugerida, não aplicada:** trocar os dois `@onready var ... = $caminho` por Unique Names (`%contador_dinheiro`/`%contador_fama`) evitaria o tipo de erro de caminho relativo que já aconteceu aqui — mesmo padrão de fragilidade já catalogado outras vezes neste projeto.

---

## 35. `icone_dinheiro.gd` (v3.5 — novo, troca de sprite da carteira)

**Status:** novo arquivo, portado e reescrito a partir da branch `score_system` | **Tipo:** `TextureRect` | **Cena:** dentro de `Scores.tscn` (`container_dinheiro/icone_dinheiro`)

```gdscript
extends TextureRect

@export var carteira_de_dinheiro_1: CompressedTexture2D
@export var carteira_de_dinheiro_2: CompressedTexture2D
@export var icone_dinheiro: TextureRect

var _ultimo_dinheiro: int = -1


func _ready() -> void:
	atualizar_aparencia()


func _process(_delta: float) -> void:
	if DadosJogo.dinheiro_jogador != _ultimo_dinheiro:
		_ultimo_dinheiro = DadosJogo.dinheiro_jogador
		atualizar_aparencia()


func atualizar_aparencia() -> void:
	if icone_dinheiro == null:
		push_warning("IconeDinheiro: icone_dinheiro não atribuído no Inspetor.")
		return

	if DadosJogo.dinheiro_jogador > 0:
		icone_dinheiro.texture = carteira_de_dinheiro_2
	else:
		icone_dinheiro.texture = carteira_de_dinheiro_1
```

**Mudanças em relação ao script original da `score_system`:**
- `Global.money > 0` → `DadosJogo.dinheiro_jogador > 0`, mesma lógica de troca de sprite.
- Adicionado polling em `_process()` (versão original só verificava uma vez em `_ready()`, dependendo do sinal do `Global` pra atualizar depois — sem esse sinal, precisa conferir a cada frame).
- Removido o `print()` de debug (`"Testando! Valor atual do dinheiro: "`) que existia na versão original.
- Adicionada checagem `null` em `icone_dinheiro` com `push_warning()`.

**Passo no editor:** os campos `@export var carteira_de_dinheiro_1`/`carteira_de_dinheiro_2`/`icone_dinheiro` precisam continuar atribuídos no Inspetor depois de trazer o script pra dentro do projeto atual — como o script foi só editado (não recriado do zero), essas referências devem persistir ao copiar o arquivo, mas vale confirmar visualmente.

---

## Pendências de integração (não são código, são passos no editor Godot)

1. Criar/confirmar o nó `BtnInvestigar` dentro de `VBoxPadrao` em `NovaAba` (entre `BtnInspecionar` e `BtnDiagnosticar`), como `Button` comum.
2. Preencher `dica` em cada `AlvoInspecao` do tipo `SUSPEITO` — sem isso, o botão Investigar mostra "Não há dica disponível pra este problema." em vez da dica real.
3. Confirmar `@export var area_referencia` em `GerenciadorInspecao` apontando pro `TextureRect` `ImagemBase` (já resolvido numa rodada anterior, mas vale conferir de novo se algum nó foi recriado).
4. `painel_diagnostico.gd` (seção 2) está descontinuado — pode ser removido do projeto com segurança; não precisa mais de nenhuma referência `@export` em `GerenciadorTrabalho` ou `CoordenadorTrabalho`.
5. Criar o nó `GerenciadorAssistente` (`Node`, script `gerenciador_assistente.gd`, seção 28) dentro de `ModuloTrabalho`, irmão de `GerenciadorExpediente`/`GerenciadorTrabalho`/`CoordenadorTrabalho`; arrastar `GerenciadorExpediente` pro campo `@export` dele.
6. Arrastar o nó `GerenciadorAssistente` pro campo `@export var gerenciador_assistente` de `CoordenadorTrabalho` (seção 4).
7. Confirmar que `CoordenadorTrabalho` está de fato **dentro** de `ModuloTrabalho` na árvore — já apareceu como filho direto da raiz da cena por engano numa rodada de integração.
8. Criar `BtnUpgrades` (`TextureButton`) e `PainelUpgrades` (`Panel`, com `LabelDinheiro`/`ScrollContainer > VBoxLinhas`/`BtnFechar`) em `Escritorio.tscn`; conferir que `PainelUpgrades` tem `Size` definido na viewport (não `0x0`, ver aviso na seção 31).
9. Conectar `pressed` de `BtnUpgrades` a si mesmo pelo editor (aba Node → Signals) — confirmar que a conexão aponta pro próprio nó (`.`), não pra outro botão da cena.
10. Arrastar `PainelUpgrades` pro campo `@export var painel_upgrades` de `BtnUpgrades` (seção 32).
11. Adicionar os nós `LabelDinheiro` e `LabelFama` em `RelatorioDia.tscn`, entre `LabelResumo` e `ScrollContainer` (ver estrutura atualizada na seção 0) — sem eles, `_ready()` gera dois `push_warning()` novos e o dinheiro/fama do dia não aparecem separados.
12. Salvar `calculadora_fama.gd` (seção 33) em alguma pasta do projeto — sem `class_name CalculadoraFama` registrado, `gerenciador_expediente.gd` não compila.
13. **(v3.5)** Copiar `Scenes/hud_manager.gd`, `Scenes/icone_dinheiro.gd`, `Scenes/Scores.tscn` da branch `score_system` — **não** copiar `Scenes/Global.gd` nem adicionar `Global` ao `[autoload]` do `project.godot`.
14. **(v3.5)** Instanciar `Scores.tscn` dentro de `Escritorio.tscn` como nó `Score`, filho da raiz (mesmo nível de `BtnUpgrades`/`PainelUpgrades`). Habilitar **Editable Children** no nó `Score` se precisar ajustar posição/tamanho dos elementos internos do HUD.
15. **(v3.5)** Conferir a estrutura real de nós dentro de `Scores.tscn` (`control/container_dinheiro/...`, sem o nível `container` intermediário) antes de colar o script `hud_manager.gd` — o caminho relativo já causou `Node not found` uma vez nesta integração.
16. **(v3.5)** Copiar o asset `Sprites/tela_ransomware/tela_trabalho_ransomware.png` da branch `trabalho_malware` (usado por `_criar_trabalho_scareware()`), e salvar a imagem redesenhada de ransomware como `Sprites/tela_ransomware/tela_trabalho_ransomware_real.png` (usado por `_criar_trabalho_ransomware()`).
17. **(v3.5)** Substituir a entrada de índice `5` em `ConteudoLivro.PAGINAS` (`conteudo_livro.gd`) pelo conteúdo de "Scareware" — ver seção 7.
18. **(v3.5)** Calibrar `quadrante`/`altura_real` dos trabalhos "Identificar Scareware" e "Remover Ransomware" com `print()` temporário em `montar_alvos()`, testando em jogo — os valores atuais são só estimativa por proporção da imagem.
