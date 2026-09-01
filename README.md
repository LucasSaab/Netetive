# Netetive — Documentação do Projeto

> Jogo educativo de cibersegurança em Godot 4, inspirado em *Papers, Please*. O jogador assume o papel de alguém que precisa identificar ameaças digitais (phishing, sites maliciosos, perfis falsos etc.) durante o expediente de trabalho.
>
> **Última atualização deste documento:** 26/08/2026

---

## Sumário

1. [Escritório (cena inicial)](#1-escritório-cena-inicial)
2. [Quadro de Avisos](#2-quadro-de-avisos)
3. [Tela de Gameplay](#3-tela-de-gameplay)
   - [3.1 Visão geral e sistemas principais](#31-visão-geral-e-sistemas-principais)
   - [3.2 Módulo de Inspeção](#32-módulo-de-inspeção)
   - [3.3 Livro de Ajuda](#33-livro-de-ajuda-livrodicas)
   - [3.4 Sistema de Trabalho, Diagnóstico e Veredito Diferido](#34-sistema-de-trabalho-diagnóstico-e-veredito-diferido)
   - [3.5 Ciclo do Dia: Iniciar Dia e Relatório de Fim de Expediente](#35-ciclo-do-dia-iniciar-dia-e-relatório-de-fim-de-expediente)
   - [3.6 Sistema de Upgrades: PC, Assistente e IA](#36-sistema-de-upgrades-pc-assistente-e-ia)
   - [3.7 Sistema de Fama](#37-sistema-de-fama)
   - [3.8 HUD de Dinheiro/Fama e Trabalhos de Scareware/Ransomware](#38-hud-de-dinheirofama-e-trabalhos-de-scarewareransomware)
4. [Estado Geral do Projeto](#4-estado-geral-do-projeto)
5. [Observações Gerais para Desenvolvimento Futuro](#5-observações-gerais-para-desenvolvimento-futuro)

---

## 1. Escritório (cena inicial)

### Visão Geral

A cena do Escritório é a tela inicial de gameplay do Netetive. Ela serve como ponto de partida do dia de trabalho do jogador, apresentando o ambiente e oferecendo os primeiros pontos de interação. Por enquanto, sua função principal é redirecionar o jogador para o loop central de gameplay através do **Quadro de Avisos**.

### Estrutura da Cena

```
Node2D
├── Sprite2D
│   └── TextureRect          ← Fundo visual do escritório (pixel art)
├── Quadro_avisos            ← Botão interativo: abre o Quadro de tarefas
├── Cafeteira                ← Elemento decorativo/interativo
│   └── Label                ← Texto "Comece o dia!" exibido na tela
├── BtnUpgrades               ← v3.3, novo: abre o PainelUpgrades (btn_upgrades.gd)
├── PainelUpgrades            ← v3.3, novo: painel de compra (painel_upgrades.gd), começa oculto
│   ├── LabelDinheiro
│   ├── ScrollContainer
│   │   └── VBoxLinhas
│   └── BtnFechar
└── Score                     ← v3.5, novo: instância de Scores.tscn, HUD permanente de dinheiro/fama
	└── HUD (hud_manager.gd)
		└── control
			├── container_dinheiro
			│   └── icone_dinheiro (icone_dinheiro.gd)
			│       └── contador_dinheiro (Label)
			└── container_fama
				└── icone_fama
					└── contador_fama (Label)
```

> **v3.5:** o nó `Score` é uma instância de `Scores.tscn` — ver seção [3.8](#38-hud-de-dinheirofama-e-trabalhos-de-scarewareransomware) pra detalhes completos do HUD.

> **Engine:** Godot 4  
> **Arquivo da cena:** `res://Scenes/Escritorio.tscn` *(ou equivalente)*

### Nós e Funções

#### `Node2D` — Raiz da cena
Nó raiz da cena. Não possui script próprio; serve apenas como contêiner dos elementos filhos.

#### `Sprite2D > TextureRect` — Fundo do escritório
Exibe o background em pixel art do escritório (sala com mesa, computador, janela com vista da cidade, etc.). Não possui lógica de script.

#### `Quadro_avisos` — `TextureButton`
**Script:** `texture_button-Quadro.gd`

Botão interativo representado visualmente pelo quadro de cortiça na parede. Ao ser clicado, leva o jogador para a cena do Quadro de tarefas, iniciando o loop de gameplay.

```gdscript
extends TextureButton

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Quadro.tscn")
```

| Evento | Ação |
|---|---|
| Clique do jogador | Troca de cena para `Quadro.tscn` |

#### `Cafeteira` — Nó interativo (com Label)
Elemento presente no canto esquerdo da tela. Exibe o texto **"Comece o dia!"** via nó `Label` filho. Atualmente funciona como dica visual para o jogador iniciar a partida.

> **Observação:** O script `Iniciar.gd` (associado a um `TextureButton`) também realiza troca de cena, redirecionando para `res://Scenes/Tela.tscn`. Pode estar vinculado à Cafeteira ou a outro botão de início presente na cena.

```gdscript
extends TextureButton

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Tela.tscn")
```

#### `BtnUpgrades` — `TextureButton` (v3.3, novo)
**Script:** `btn_upgrades.gd`

Botão que abre o painel de compra de upgrades. Mesmo padrão de conexão de `Quadro_avisos`/`Iniciar.gd`: sinal `pressed` conectado pelo editor (aba Node → Signals), método `_on_pressed()`.

```gdscript
extends TextureButton

@export var painel_upgrades: Control   # arraste o nó PainelUpgrades aqui no Inspetor

func _on_pressed() -> void:
	if painel_upgrades != null and painel_upgrades.has_method("abrir"):
		painel_upgrades.abrir()
```

#### `PainelUpgrades` — `Panel` (v3.3, novo)
**Script:** `painel_upgrades.gd` | **class_name:** `PainelUpgrades`

UI que desenha dinamicamente as 5 linhas de upgrade — ver seção [3.6](#36-sistema-de-upgrades-pc-assistente-e-ia) pra detalhes completos. Começa oculto (`hide()` no `_ready()`), mostrado por `BtnUpgrades`.

### Fluxo de Navegação

```
[Escritório]
	 │
	 │  Jogador clica no Quadro_avisos
	 ▼
[Quadro.tscn]  ←── início do loop de gameplay
```

---

## 2. Quadro de Avisos

### Visão Geral

A cena do **Quadro** é uma tela de consulta **fora do loop de gameplay**. Ela centraliza informações de apoio ao jogador: controles, guias de como jogar, configurações iniciais, etc. É o espaço de onboarding do jogo — o jogador aprende as mecânicas aqui antes de entrar nos eventos do dia.

> O Quadro **não** instrui sobre como agir durante os eventos; isso faz parte do próprio gameplay.

### Estrutura da Cena

```
Node2D                        ← Script geral da cena (Script_geral_quadro.gd)
├── Sprite2D
│   └── TextureRect           ← Fundo visual: foto do quadro de cortiça
├── TB_Tutorial_1             ← Botão interativo: abre o tutorial (tb_tutorial_1.gd)
└── Layer_Tutorial_1          ← CanvasLayer que contém o painel do tutorial
	└── TextureRect           ← Conteúdo visual do tutorial (instruções, controles, etc.)
```

> **Engine:** Godot 4  
> **Arquivo da cena:** `res://Scenes/Quadro.tscn`

### Nós e Funções

#### `Node2D` — Raiz da cena
**Script:** `Script_geral_quadro.gd`

Gerencia toda a lógica da cena: conecta o botão de tutorial, controla visibilidade do `CanvasLayer` e trata inputs globais (teclado e mouse).

```gdscript
extends Node2D

@export var botao_tutorial: TextureButton
@export var layer_tutorial: CanvasLayer

func _ready() -> void:
	# Garante que o tutorial começa oculto
	if layer_tutorial != null:
		layer_tutorial.hide()
	# Conecta o sinal do botão manualmente (evita dupla conexão)
	if botao_tutorial != null and not botao_tutorial.pressed.is_connected(_on_botao_tutorial_pressionado):
		botao_tutorial.pressed.connect(_on_botao_tutorial_pressionado)

func _on_botao_tutorial_pressionado() -> void:
	if layer_tutorial != null:
		layer_tutorial.show()

func _input(event: InputEvent) -> void:
	# Atalho de teclado: Barra de Espaço abre o tutorial
	if event.is_action_pressed("ui_accept"):
		if layer_tutorial != null:
			layer_tutorial.show()
	# Clique direito: fecha tutorial SE aberto, senão volta ao escritório
	if event.is_action_pressed("clique_direito"):
		if layer_tutorial != null and layer_tutorial.visible:
			layer_tutorial.hide()
			get_viewport().set_input_as_handled()
		else:
			voltar_para_escritorio()

func voltar_para_escritorio() -> void:
	get_tree().change_scene_to_file("res://Scenes/Escritorio.tscn")
```

| Ação do jogador | Resultado |
|---|---|
| Clica em `TB_Tutorial_1` | Abre `Layer_Tutorial_1` |
| Pressiona `Espaço` | Abre `Layer_Tutorial_1` |
| Clique direito (tutorial aberto) | Fecha `Layer_Tutorial_1` |
| Clique direito (tutorial fechado) | Volta para `Escritorio.tscn` |

#### `Sprite2D > TextureRect` — Fundo do Quadro
Exibe a imagem do quadro de cortiça com o papel "Política de qualidade" fixado. Apenas visual, sem script.

#### `TB_Tutorial_1` — `TextureButton`
**Script:** `tb_tutorial_1.gd`

Botão visível sobre o quadro (representando o papel fixado). Ao ser pressionado, exibe o `Layer_Tutorial_1`.

```gdscript
extends TextureButton

@onready var layer_tutorial: CanvasLayer = $"../Layer_Tutorial_1"

func _on_pressed() -> void:
	if layer_tutorial != null:
		layer_tutorial.show()
```

> **Nota:** Este botão acessa o `CanvasLayer` via caminho relativo `$"../Layer_Tutorial_1"`. O script geral da cena também conecta este botão via `@export` — ambos produzem o mesmo efeito. Futuramente pode ser unificado para evitar redundância.

#### `Layer_Tutorial_1` — `CanvasLayer`
Camada de sobreposição que exibe o conteúdo do tutorial por cima da cena. Começa **oculto** (`hide()` no `_ready`) e é exibido apenas quando o jogador interage.

- Filho: `TextureRect` com o visual do tutorial (controles, guias, etc.)
- Fechado com **clique direito** pelo handler de `_input` no script geral.

### Fluxo de Navegação

```
[Escritório]
	 │  Clica no Quadro_avisos
	 ▼
[Quadro]  ──── Clica em TB_Tutorial_1 ou pressiona Espaço ────► [Layer_Tutorial_1 visível]
	 │                                                                    │
	 │                                                         Clique direito
	 │                                                                    │
	 │◄───────────────────────────────────────────────────────────────────┘
	 │
	 │  Clique direito (tutorial fechado)
	 ▼
[Escritório]
```

---

## 3. Tela de Gameplay

### 3.1 Visão geral e sistemas principais

> ⚠️ **Nota de manutenção:** esta subseção descreve o sistema **original** de post-its (`Lembrete`/`PainelTrabalho`). Esse sistema foi **substituído** pelo sistema de expedição (`GerenciadorExpediente` + `GerenciadorTrabalho` com `VBoxDisponiveis`/`VBoxAtivos`), documentado na seção [3.4](#34-sistema-de-trabalho-diagnóstico-e-veredito-diferido). O conteúdo abaixo foi mantido como registro histórico da arquitetura anterior.
>
> **Confirmado em runtime:** o ramo `Lembrete`/`GerenciadorTrabalho`(antigo)/`TimerLembrete` ainda existe fisicamente na árvore de `Tela.tscn`, solto no nível raiz, em paralelo ao `ModuloTrabalho` (onde vive o sistema novo). Ele não é mais referenciado por nenhum script ativo — `Main_select_script.gd` só acessa `$ModuloTrabalho/GerenciadorExpediente` — mas continua na cena e roda seu próprio `_ready()`. Existem, inclusive, **dois arquivos diferentes** chamados `gerenciador_trabalho.gd` no projeto, em pastas diferentes (o antigo em `res://Scripts/Tela/`, o novo em algum lugar dentro de `ModuloTrabalho`), o que gera confusão ao navegar pela lista de scripts do editor (que mostra só o nome curto). Recomendação: remover o ramo legado inteiro da árvore.

A cena **Tela** (`res://Scenes/Tela.tscn`) é onde o loop principal de gameplay ocorre. O jogador visualiza um site suspeito na tela do computador e interage com ele para identificar problemas de segurança. A cena é composta por vários sistemas independentes que se comunicam por sinais e referências exportadas.

#### Estrutura da Cena

```
Node2D                         ← Script principal (Main_select_script.gd)
├── Sprite2D
│   ├── Tela                   ← Imagem da tela do computador (fundo visual)
│   └── TextureRect            ← Sobreposição visual (site exibido na tela)
├── Lembrete                   ← Post-it clicável com tarefas aleatórias (lembrete.gd)
├── GerenciadorTrabalho        ← Coordena abertura do painel de tarefas (gerenciador_trabalho.gd)
├── PainelTrabalho             ← UI de detalhes da tarefa aceita/ignorada (painel_trabalho.gd)
├── TimerLembrete               ← Timer para controlar ciclo dos lembretes
├── BtnAbrirLivro               ← Botão que abre/fecha o LivroDicas (btn_abrir_livro.gd)
└── CanvasLayer                ← Camada de sobreposição para elementos UI
	├── CenterContainer        ← Centraliza o LivroDicas na tela
	└── ModuloInspecao         ← Contém toda a lógica de inspeção de elementos
		├── AreaCliqueInspecao ← Captura cliques na tela (area_clique_inspecao.gd)
		├── GerenciadorInspecao← Lógica central de inspeção (gerenciador_inspecao.gd)
		│   ├── NovaAba        ← Menu contextual de clique (nova_aba_script.gd)
		│   ├── MensagemModal  ← Resultado da inspeção (mensagem_modal_scpt.gd)
		│   ├── Alvo1          ← ColorRect oculto: região suspeita real (CaixaDeSelecao.gd)
		│   ├── Alvo2          ← ColorRect neutro (não suspeito)
		│   └── Alvo3          ← ColorRect neutro (não suspeito)
		└── PainelModal        ← Versão alternativa do modal (mensagem_modal.gd)
```

> **Arquivo da cena:** `res://Scenes/Tela.tscn`

#### Sistema de Lembretes (Tarefas)

Os **Lembretes** são post-its fixados na tela do computador que representam tarefas recebidas pelo jogador. Cada um sorteia seus dados aleatoriamente a partir de `DadosJogo.banco_de_trabalhos` (Autoload).

##### `Lembrete` — `TextureButton`
**Script:** `lembrete.gd`

```gdscript
signal foi_clicado(titulo, descricao, recompensa, lembrete_clicado)
```

| Comportamento | Detalhe |
|---|---|
| Ao entrar na cena | Sorteia título, descrição e recompensa aleatória (`valor_base ± randi_range(-15, 25)`) |
| Clique esquerdo | Emite `foi_clicado` com os dados do trabalho |
| Clique direito | Esconde o post-it (`hide()`) |
| `z_index` | 100 — garante que fique sobre o fundo |

##### `GerenciadorTrabalho` — `Node`
**Script:** `gerenciador_trabalho.gd`

Recebe o sinal `foi_clicado` do Lembrete e repassa os dados ao `PainelTrabalho`.

```gdscript
func _on_lembrete_foi_clicado(titulo, descricao, recompensa, lembrete_clicado):
	painel_trabalho.abrir(lembrete_clicado, titulo, descricao, recompensa)
```

##### `PainelTrabalho` — `Panel`
**Script:** `painel_trabalho.gd`

Painel centralizado na tela que exibe os detalhes do trabalho sorteado.

```gdscript
signal trabalho_aceito(recompensa: int)
```

| Ação do jogador | Resultado |
|---|---|
| Clica em **Aceitar** | Emite `trabalho_aceito`, fecha painel, remove o post-it da cena (`queue_free`) |
| Clica em **Ignorar** | Fecha o painel, post-it permanece na tela |
| Clique direito sobre o painel | Fecha o painel (`fechar()`) |

- Posicionamento: calculado dinamicamente para sempre aparecer no centro da viewport.
- `z_index = 101` — fica acima do Lembrete (`z_index 100`).

#### Sistema do Livro de Dicas (acesso)

O **Livro de Dicas** é um guia in-game de consulta durante o gameplay (diferente do tutorial do Quadro, que é pré-gameplay). Ele é instanciado dinamicamente e exibido centralizado na tela. *(conteúdo detalhado na seção [3.3](#33-livro-de-ajuda-livrodicas))*

##### `BtnAbrirLivro` — `TextureButton`
**Script:** `btn_abrir_livro.gd`

| Comportamento | Detalhe |
|---|---|
| 1º clique | Instancia `LivroInstrucao.tscn` dentro do `CenterContainer` e chama `abrir_livro()` |
| 2º clique (livro aberto) | Destroi a instância com `queue_free()` |
| `@export` necessários | `cena_livro: PackedScene` e `container_central: CenterContainer` devem ser atribuídos no Inspetor |

##### `LivroDicas` — `TextureRect`
**Script:** `livro_dicas.gd` | **class_name:** `LivroDicas`

Livro paginado carregado a partir de `res://Scripts/conteudo_livro.gd`. Cada página tem `titulo`, `descricao` e `solucao`.

| Elemento | Função |
|---|---|
| `BtnAnterior` / `BtnProximo` | Navega entre páginas; se escondem na primeira/última página |
| `abrir_livro()` | Reseta para página 0, ativa `MOUSE_FILTER_STOP` e exibe |
| Clique direito | Fecha o livro e reativa `MOUSE_FILTER_IGNORE` |
| Tamanho | 80% da viewport (`custom_minimum_size = tamanho_tela * 0.8`) |

#### Sistema de Inspeção (visão geral)

É o sistema central de gameplay. O jogador clica em regiões do site exibido para inspecioná-las e descobrir elementos suspeitos. *(estrutura detalhada na seção [3.2](#32-módulo-de-inspeção))*

##### `AreaCliqueInspecao` — `Control`
**Script:** `area_clique_inspecao.gd`

Camada invisível sobre o site que captura todos os cliques do jogador.

| Input | Comportamento |
|---|---|
| Clique esquerdo (popup fechado) | Registra posição e abre `NovaAba` via `GerenciadorInspecao` |
| Clique esquerdo (popup aberto) | Ignora — deixa o clique passar para o popup |
| Clique direito | Fecha todos os popups abertos |

##### `GerenciadorInspecao` — `Node`
**Script:** `gerenciador_inspecao.gd`

Coordena toda a lógica de inspeção: abertura da `NovaAba`, verificação de colisão com alvos e exibição do resultado.

**Fluxo de inspeção:**
```
Jogador clica na área
		│
		▼
AreaCliqueInspecao.registrar_clique_na_area(pos)
		│
		▼
NovaAba aparece próxima ao clique
		│
Jogador clica em "Inspecionar"
		│
		▼
_on_botao_inspecionar_pressed()
  ├── Verifica se pos está sobre Alvo1 (suspeito) ou Alvo2/3 (neutros)
  ├── MensagemModal.mostrar(resultado)
  │     ├── Exibe "🔍 Verificando..." por 2s
  │     └── Exibe "⚠️ Alvo detectado!" ou "Nenhum alvo encontrado." por 2s, depois fecha
  └── Após 4s: se acertou, Alvo1 muda de cor para vermelho semitransparente
```

| Nó | Tipo | Papel |
|---|---|---|
| `Alvo1` | `ColorRect` | Região suspeita real — invisível até ser detectada |
| `Alvo2`, `Alvo3` | `ColorRect` | Regiões neutras — não geram alerta |

##### `NovaAba` — `TextureRect`
**Script:** `nova_aba_script.gd`

Menu contextual que aparece próximo ao clique do jogador com o botão "Inspecionar".

```gdscript
signal inspecionar_pressionado
```

- Fecha automaticamente se o jogador clicar fora dela.
- Emite `inspecionar_pressionado` ao confirmar a inspeção.

##### `MensagemModal` — `Control`
**Script:** `mensagem_modal_scpt.gd`

Overlay de resultado da inspeção. Opera com sequência assíncrona via `await`:

```
mostrar(intersectou)
  → "🔍 Verificando..." (2s)
  → "⚠️ Alvo detectado!" ou "Nenhum alvo encontrado." (2s)
  → esconder()
```

- `mouse_filter = MOUSE_FILTER_IGNORE` — não bloqueia input durante exibição.
- `z_index = 100`.

#### Script Principal da Cena

**Script:** `Main_select_script.gd` — `extends Node2D`

Script raiz da cena. Atualmente atua como ponto de entrada e delegador: os gerenciadores filhos cuidam de toda a lógica.

```gdscript
func _on_btn_abrir_livro_pressed() -> void:
	var instancia_livro = cena_livro.instantiate()
	add_child(instancia_livro)
	instancia_livro.abrir_livro()
```

> **Nota:** `_on_botao_inspecionar_pressed()` está vazio no script principal — a lógica de inspeção foi migrada para o `GerenciadorInspecao`.

#### Fluxo Geral da Cena

```
[Tela carrega]
	  │
	  ├── PainelTrabalho ─── hide()
	  ├── LivroDicas ─────── hide() (instanciado sob demanda)
	  ├── NovaAba ─────────── hide()
	  └── MensagemModal ───── hide()

[Durante o gameplay]

  Post-it (Lembrete) clicado
	  │
	  └─► GerenciadorTrabalho → PainelTrabalho.abrir()
			   ├── Aceitar → trabalho_aceito + post-it some
			   └── Ignorar → painel fecha

  Clique na tela (AreaCliqueInspecao)
	  │
	  └─► NovaAba aparece → "Inspecionar"
			   └─► GerenciadorInspecao verifica alvos
						└─► MensagemModal exibe resultado (4s total)
								 └─► Alvo1 muda de cor se acertou

  BtnAbrirLivro clicado
	  └─► LivroDicas instanciado/destruido no CenterContainer
```

---

### 3.2 Módulo de Inspeção

O **ModuloInspecao** é a camada invisível posicionada na frente da tela do computador (site exibido). Ela não é visualmente exibida em condições normais — existe apenas para detectar onde o jogador clica e avaliar se aquela região corresponde a um problema de segurança real.

> ⚠️ **Nota de manutenção:** a descrição abaixo (alvos `Alvo1`/`Alvo2`/`Alvo3` fixos como `ColorRect`) é a arquitetura **original**. O sistema atual usa `AlvoInspecao` (Resource), `TrabalhoInspecao` (Resource) e `AreaAlvo` (`Area2D` dinâmico) organizados numa **grade de 3 colunas × N linhas** com compensação de altura adaptativa, documentado na seção [3.4](#34-sistema-de-trabalho-diagnóstico-e-veredito-diferido). A "Variação por Dificuldade" descrita como design futuro logo abaixo já está parcialmente resolvida pelo grid: a quantidade de quadrantes clicáveis é sempre 3×N (todos inspecionáveis, com ou sem problema atribuído), e "quais são problemáticos" já é definido dinamicamente por trabalho via `AlvoInspecao.quadrante`.

Atualmente a cena trabalha com **3 alvos fixos** (`Alvo1`, `Alvo2`, `Alvo3`), mas a intenção de design é que tanto a **quantidade de alvos** quanto **quais deles são "problemáticos"** variem de acordo com a dificuldade do trabalho sorteado.

#### Estrutura da Cena (detalhada)

```
ModuloInspecao
└── AreaCliqueInspecao         ← Captura cliques do jogador na tela (Control)
	└── GerenciadorInspecao    ← Lógica de verificação dos alvos (Node)
		├── NovaAba            ← Menu contextual "Inspecionar" (TextureRect)
		│   └── VBoxContainer
		│       └── Button     ← Botão que confirma a inspeção
		├── MensagemModal      ← Feedback textual da inspeção (Control)
		│   └── Label          ← Texto: "Verificando...", "Alvo detectado!", etc.
		├── Alvo1               ← ColorRect: alvo suspeito (ou neutro, dependendo do sorteio)
		├── Alvo2               ← ColorRect: alvo neutro
		├── Alvo3               ← ColorRect: alvo neutro
		└── CaixaSelecao        ← ColorRect auxiliar (script vazio; ver seção 3.1)
```

> Esta estrutura corresponde exatamente ao que já foi documentado na seção 3.1 (scripts `area_clique_inspecao.gd`, `gerenciador_inspecao.gd`, `nova_aba_script.gd`, `mensagem_modal_scpt.gd`, `CaixaDeSelecao.gd`). Esta seção foca no **papel de design** dos alvos dentro do módulo.

#### Lógica dos Alvos

| Nó | Papel atual | Comportamento ao ser inspecionado corretamente |
|---|---|---|
| `Alvo1` | Alvo suspeito (problema real) | Aparece visualmente e muda de cor para vermelho semitransparente (`Color(1, 0, 0, 0.35)`) |
| `Alvo2` | Alvo neutro | Nenhuma alteração visual — inspecioná-lo retorna "Nenhum alvo encontrado." |
| `Alvo3` | Alvo neutro | Mesmo comportamento de `Alvo2` |

- Todos os alvos são `ColorRect` **invisíveis por padrão** — só ficam visíveis quando o jogador acerta a inspeção sobre um alvo problemático.
- A verificação é feita por colisão de retângulos (`get_global_rect().has_point(...)`) entre a posição do clique e a área do alvo.

#### Design Futuro: Variação por Dificuldade

A estrutura atual com `Alvo1`, `Alvo2`, `Alvo3` fixos é o caso-base (dificuldade inicial). O plano de design prevê:

| Aspecto | Comportamento planejado |
|---|---|
| **Quantidade de alvos** | Aumenta conforme a dificuldade do trabalho (mais áreas clicáveis = mais lugares para checar) |
| **Quantidade de alvos problemáticos** | Pode haver mais de 1 alvo suspeito em trabalhos mais difíceis |
| **Distribuição/sorteio** | Provavelmente precisará de um sistema que sorteie dinamicamente quais `ColorRect` são "problemáticos" a cada rodada, em vez de fixar isso na cena |

> **Implicação técnica:** o array `alvos_neutros` em `gerenciador_inspecao.gd` (atualmente fixo como `[$Alvo2, $Alvo3]`) provavelmente precisará ser refatorado para algo dinâmico — por exemplo, receber a lista de alvos problemáticos vs. neutros a partir dos dados do trabalho sorteado (`DadosJogo.banco_de_trabalhos`), em vez de hardcoded por nome de nó.

---

### 3.3 Livro de Ajuda (LivroDicas)

O **Livro de Ajuda** é um manual de consulta disponível durante o expediente, na cena **Tela**, acessado por um botão no canto inferior direito (`BtnAbrirLivro`). Diferente do tutorial do Quadro (que ensina controles e mecânicas), este livro contém o **catálogo dos problemas de segurança** que o jogador pode encontrar durante o trabalho — cada capítulo é dividido em três partes: nome do problema, como identificar e como resolver.

O jogador pode abrir e fechar o livro **quantas vezes quiser** durante o expediente, sem penalidade.

> A estrutura técnica do botão (`btn_abrir_livro.gd`) e do componente (`livro_dicas.gd`) já foi documentada na seção 3.1. Esta seção foca no **conteúdo** do livro, detalhado pelo arquivo `conteudo_livro.gd`.

#### Estrutura Interna do Livro

```
LivroDicas (TextureRect)
├── LabelTitulo      ← Nome do problema (ex: "Capítulo 1 — Phishing")
├── LabelProblema     ← Texto explicando como identificar o problema
├── LabelSolucao      ← Texto explicando como agir/resolver
├── BtnProximo        ← Avança para o próximo capítulo
└── BtnAnterior       ← Volta para o capítulo anterior
```

Cada página é populada a partir de um dicionário com três chaves: `titulo`, `descricao` (identificação do problema) e `solucao` (como agir).

#### Fonte de Dados — `conteudo_livro.gd`

**Classe:** `ConteudoLivro` (`extends RefCounted`)

Contém o array `PAGINAS: Array[Dictionary]` com **10 capítulos** atualmente implementados, cobrindo temas de segurança digital:

| # | Capítulo | Tema |
|---|---|---|
| 1 | Phishing | E-mails falsos pedindo dados/ação urgente |
| 2 | Perfil Falso | Identificação de contas falsas em redes sociais |
| 3 | Site Malicioso | Verificação de URLs e cadeado de segurança |
| 4 | Ransomware | Sequestro de arquivos por malware |
| 5 | Engenharia Social | Manipulação via telefone/mensagem se passando por suporte |
| 6 | Senha Fraca | Boas práticas de criação de senha |
| 7 | Wi-Fi Público | Riscos de redes abertas e uso de VPN |
| 8 | Atualização Ignorada | Importância de manter sistemas atualizados |
| 9 | Permissões Excessivas | Revisão de permissões de apps |
| 10 | Vazamento de Dados | Resposta a vazamentos (ex: haveibeenpwned) |

Cada capítulo segue o padrão narrativo: contextualização do problema em tom de conversa ("Sabe aquele e-mail que parece ser do seu banco...") seguido de um bloco prático "Como agir:" com passos objetivos.

> **Observação:** apesar do comentário no código mencionar "12 capítulos estruturados", o array contém atualmente **10 capítulos** (índices 0–9).

> **Atualização:** `PAGINAS` foi alterado de `var` (membro de instância) para `const`, permitindo acesso estático (`ConteudoLivro.PAGINAS`) sem precisar instanciar a classe. Isso passou a ser necessário porque o novo sistema de diagnóstico (seção 3.4) lê `PAGINAS` diretamente a partir de `DadosJogo.gd`.

#### Relação com o Sistema de Inspeção

> ⚠️ **Nota de manutenção:** a tabela abaixo descreve o estado **anterior** à seção 3.4 — os dois bancos de dados já passaram a se referenciar via `AlvoInspecao.capitulo_relacionado`, que aponta para um índice em `ConteudoLivro.PAGINAS`. A vinculação direta que era apenas uma ideia de design já está implementada.

Atualmente, os capítulos do livro (problemas de segurança como phishing, perfil falso, site malicioso etc.) são conceitualmente diferentes dos "trabalhos" do `DadosJogo.banco_de_trabalhos`, que tratam de manutenção técnica genérica (remover vírus, limpar disco, atualizar drivers). Os dois bancos de dados ainda não compartilham uma referência cruzada direta:

| Sistema | Fonte | Conteúdo |
|---|---|---|
| Lembretes/Trabalhos | `DadosJogo.banco_de_trabalhos` | Tarefas de manutenção (título, descrição, recompensa) |
| Livro de Ajuda | `ConteudoLivro.PAGINAS` | Catálogo educativo de ameaças de segurança (título, problema, solução) |

> **Nota de design:** pode ser interessante, no futuro, vincular cada `Alvo` problemático do Módulo de Inspeção a um capítulo específico do livro — assim o jogador consulta exatamente o capítulo relevante para o problema que está enfrentando, em vez de navegar por todos os 10 capítulos.

---

### 3.4 Sistema de Trabalho, Diagnóstico e Veredito Diferido

Esta seção documenta a arquitetura **atual** (v3) do loop de trabalho, que substitui o sistema de post-its (`Lembrete`/`PainelTrabalho`, seção 3.1) e o sistema de alvos fixos (`Alvo1`/`Alvo2`/`Alvo3`, seção 3.2). Passou por três iterações de design ao longo do desenvolvimento — a seção "Histórico de versões" no final resume o que mudou entre elas.

#### Visão geral do fluxo (versão atual)

Todo o ciclo de um trabalho — inspecionar, diagnosticar, ignorar áreas conhecidas, e encerrar — acontece dentro de um **único popup contextual** (`NovaAba`) que abre no ponto onde o jogador clica. Não existe mais navegação de volta à lista de trabalhos pra nenhuma dessas ações; a lista de trabalhos ativos serve só pra **selecionar** qual trabalho inspecionar no momento.

```
GerenciadorExpediente libera um trabalho (horário do dia bateu)
		│
		▼
Item aparece em VBoxDisponiveis (GerenciadorTrabalho)
		│  jogador clica → aceita direto
		▼
DadosJogo.iniciar_resultado_pendente(agendado)   ← abre um ResultadoTrabalho "em branco"
Item some de Disponíveis, aparece em VBoxAtivos com 1 controle: [Título/Selecionar]
		│
		│  jogador clica no título → trabalho_selecionado(agendado)
		▼
CoordenadorTrabalho monta a grade de inspeção (imagem do site + 15 AreaAlvo do grid)
		│
		│  jogador clica em QUALQUER ponto da imagem do site
		▼
NovaAba abre com 5 botões sempre presentes:
   [Inspecionar]     ← desabilitado só se este ponto for um alvo NEUTRO já checado antes
   [Investigar]      ← desabilitado depois do 1º uso que revela dica real no trabalho
   [Diagnosticar]    ← desabilitado até ALGUM alvo suspeito ter sido encontrado no trabalho
   [Ignorar]/[Designorar]  ← alterna por ponto clicado, disponível mesmo sem inspecionar
   [Encerrar]        ← sempre disponível
		│
		├─ Inspecionar → GerenciadorInspecao.verificar_clique()
		│      ├─ acertou (achou o alvo suspeito) → revela visualmente,
		│      │    marca achou_alvo_correto = true no resultado pendente,
		│      │    libera o botão Diagnosticar em QUALQUER ponto do trabalho
		│      └─ neutro → marca esse quadrante como "já checado, sem nada"
		│           (Inspecionar fica desabilitado se clicar de novo ali)
		│
		├─ Investigar → resposta instantânea no MensagemModal, 3 casos:
		│      ├─ quadrante ainda não inspecionado → "Preciso investigar."
		│      ├─ neutro já checado sem nada → "Nada de interessante nesta parte."
		│      └─ suspeito já encontrado → texto de AlvoInspecao.dica
		│           (consome o único uso permitido por trabalho, gravado
		│           em TrabalhoAgendado.investigar_usado — só os dois
		│           primeiros casos NÃO consomem, por não revelarem nada)
		│
		├─ Diagnosticar → abre submenu AO LADO com múltipla escolha
		│      (opções geradas por DadosJogo.gerar_opcoes_diagnostico:
		│      categoria certa do capítulo do LivroDicas + distratores)
		│      │  jogador escolhe uma opção
		│      ▼
		│      diagnostico_escolhido(opcao) → CoordenadorTrabalho grava
		│      diagnostico_correto no resultado pendente
		│
		├─ Ignorar/Designorar → alterna AreaAlvo.ignorado (não afeta o veredito,
		│      é só uma marcação visual/mental pro jogador — "já chequei aqui")
		│
		└─ Encerrar → ConfirmationDialog mostra o diagnóstico atual escolhido
			   (ou avisa que nenhum diagnóstico foi feito ainda)
					│  jogador confirma
					▼
			   DadosJogo.finalizar_trabalho(agendado)
				  → resultado.finalizar(): acertou_no_geral = achou_alvo_correto AND diagnostico_correto
				  → resultado move de resultados_pendentes para resultados_do_dia
			   GerenciadorTrabalho.marcar_trabalho_concluido(agendado)
				  → remove o item de VBoxAtivos
			   GerenciadorInspecao.limpar_alvos() + site_textura.texture = null
				  → limpa a tela pro próximo trabalho
			   Toast "Trabalho encerrado." aparece por 2s
				  (SEM revelar se acertou ou errou)
		│
		▼
[Fim do expediente — GerenciadorExpediente]
   → tela de resumo do dia itera DadosJogo.resultados_do_dia
   → SÓ AQUI o certo/errado e a recompensa de cada trabalho são revelados
```

**Regra de "acerto" combinado:** um trabalho só conta como bem-sucedido se **os dois** critérios forem verdadeiros — achar o alvo suspeito correto **e** escolher a categoria certa no diagnóstico. Se o jogador clicar em "Encerrar" sem nunca ter diagnosticado, `diagnostico_correto` fica no valor padrão (`false`), então o trabalho conta como errado — não trava o jogo, só garante que pular o diagnóstico tem consequência.

#### Sistema de grid (substitui posição/tamanho livre em pixels)

A tela do site deixou de usar `AlvoInspecao.posicao`/`tamanho` livres em pixels. Agora a área da imagem (`ImagemBase`, um `TextureRect`) é dividida numa grade fixa de **3 colunas × N linhas** (5 por padrão, configurável por trabalho via `TrabalhoInspecao.linhas_grid`).

```
Índice do quadrante = linha * 3 + coluna   (0-based)

Linha 0:  [ 0][ 1][ 2]
Linha 1:  [ 3][ 4][ 5]
Linha 2:  [ 6][ 7][ 8]
Linha 3:  [ 9][10][11]
Linha 4:  [12][13][14]
```

- **Largura:** sempre fixa em 1/3 da largura da área de referência — nunca varia.
- **Altura:** cada *linha inteira* (as 3 colunas juntas) compartilha a mesma altura. Um `AlvoInspecao` pode forçar uma altura específica pra sua linha via `altura_real`; as linhas sem alvo forçado dividem igualmente o espaço vertical restante, garantindo que a soma de todas as linhas sempre preencha 100% da área de referência (compensação adaptativa).
- **Quadrantes sem `AlvoInspecao` explícito no `TrabalhoInspecao.alvos`** viram automaticamente alvos `NEUTRO` — ou seja, os 15 quadrantes da grade são **todos** clicáveis/inspecionáveis, não só os que têm problema definido.
- **`area_referencia`** (`@export var area_referencia: Control` em `GerenciadorInspecao`) define o retângulo que a grade cobre — aponta pro `ImagemBase` (`TextureRect`), não pro viewport inteiro, senão a grade fica maior que a imagem do site.

#### Resources (arquitetura de grid)

##### `AlvoInspecao` — `Resource`
```gdscript
class_name AlvoInspecao
extends Resource

enum Tipo { SUSPEITO, NEUTRO }

@export var tipo: Tipo = Tipo.NEUTRO
@export var quadrante: int = 0        # índice: linha * 3 + coluna (0-based)
@export var altura_real: float = 0.0  # altura em px que a LINHA INTEIRA deve assumir; 0 = automática
@export var capitulo_relacionado: int = -1
@export var dica: String = ""         # texto curto mostrado pelo botão Investigar (só pra SUSPEITO)
```

##### `TrabalhoInspecao` — `Resource`
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

##### `AreaAlvo` — `Area2D`
```gdscript
class_name AreaAlvo
extends Area2D

var dados: AlvoInspecao
var tamanho_quadrante: Vector2 = Vector2.ZERO   # calculado pelo grid, não vem do Resource
var foi_encontrado: bool = false
var ignorado: bool = false
var ja_inspecionado_negativo: bool = false
```

##### `TrabalhoAgendado` — `RefCounted`
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

`investigar_usado` fica aqui — na ocorrência do trabalho, não em `AreaAlvo`/`GerenciadorInspecao` — de propósito: como o jogador pode trocar de trabalho ativo e voltar depois, guardar esse limite num objeto efêmero (recriado toda vez que `montar_alvos()` roda) resetaria o limite indevidamente. `TrabalhoAgendado` persiste durante toda a vida do trabalho no expediente.

##### `ResultadoTrabalho` — `Resource`
Sem alterações desde a v1 — continua guardando o veredito combinado de uma ocorrência de trabalho, com `agendado` sem `@export` (`TrabalhoAgendado` é `RefCounted`, não `Resource`).

#### Módulo de dados separado — `banco_de_trabalhos.gd`

A definição dos `TrabalhoInspecao` (textos, imagem, alvos) foi extraída de `DadosJogo.gd` pra um módulo próprio, `BancoDeTrabalhos` (`class_name`, `static func`, sem precisar ser Autoload). `DadosJogo.gd` ficou responsável só por **estado em runtime** (dinheiro, agenda do dia, resultados pendentes) — não por dados estáticos de conteúdo. `DadosJogo._ready()` chama `BancoDeTrabalhos.criar_todos()`.

Como consequência dessa reorganização, **4 dos 5 trabalhos foram removidos temporariamente** do banco — só "Remover Cavalo de Tróia" está migrado pro sistema de grid (com `quadrante`/`altura_real`/`dica` calibrados). Os outros 4 ainda usavam o `posicao`/`tamanho` antigo, que não existe mais em `AlvoInspecao`, e dependem de arte de site que ainda não foi produzida. Serão adicionados de volta em `banco_de_trabalhos.gd` conforme a arte de cada um ficar pronta e os índices de quadrante forem calibrados manualmente (mesmo processo de calibração visual já documentado nos aprendizados do projeto).

#### `NovaAba` — popup unificado (substitui o `PainelDiagnostico` separado)

O `PainelDiagnostico` (`Control` solto, com `@export` em dois scripts diferentes) foi **descontinuado** — toda a interação de diagnóstico passou a viver dentro do próprio `NovaAba`, o popup que já existia pra "Inspecionar". A estrutura interna de `NovaAba` hoje é:

```
NovaAba
├── VBoxPadrao
│   ├── BtnInspecionar
│   ├── BtnInvestigar
│   ├── BtnDiagnosticar
│   ├── BtnIgnorar
│   └── BtnEncerrar
└── VBoxDiagnostico   ← populado em runtime, posicionado ao lado de VBoxPadrao
```

`painel_diagnostico.gd` continua no projeto como arquivo órfão (sem uso) — candidato a remoção junto com a próxima limpeza técnica.

#### Botão Investigar — dica limitada por trabalho

Além dos 4 botões da v3, a `NovaAba` ganhou um 5º: **Investigar**. Ele funciona de forma independente de Diagnosticar — pode ser clicado a qualquer momento, em qualquer quadrante, e responde de 3 formas diferentes dependendo do estado daquele quadrante específico:

| Estado do quadrante clicado | Resposta do Investigar |
|---|---|
| Ainda não inspecionado | "Preciso investigar." |
| Neutro, já inspecionado sem sucesso | "Nada de interessante nesta parte." |
| Suspeito, já encontrado | Texto de `AlvoInspecao.dica` |

Só o terceiro caso **consome** o limite de uso (1 dica por trabalho, gravado em `TrabalhoAgendado.investigar_usado`) — os dois primeiros não entregam informação nenhuma, então não contam contra o limite. A resposta aparece no `MensagemModal` (método novo `mostrar_texto()`, sem a etapa "Verificando..." — é instantânea).

O campo `dica` foi colocado em `AlvoInspecao` (não em `TrabalhoInspecao`), porque a dica é específica do problema, não do trabalho como um todo — importante caso o suporte a múltiplos alvos suspeitos por trabalho seja implementado no futuro, já que cada um poderá ter sua própria dica.

#### Correções de bug feitas durante esta iteração

- **Clique bloqueado no alvo revelado:** o `ColorRect` verde criado por `_revelar_alvo()` nascia com `mouse_filter` padrão (`MOUSE_FILTER_STOP`), bloqueando cliques futuros sobre aquele ponto. Corrigido forçando `mouse_filter = Control.MOUSE_FILTER_IGNORE` nesse `ColorRect`.
- **Quadrado revelado (e imagem do site antiga) ficavam na tela após "Encerrar":** `_on_confirmar_encerramento()` não chamava `limpar_alvos()` nem resetava `site_textura.texture`, então o feedback visual do trabalho anterior persistia até o jogador selecionar outro trabalho. Corrigido chamando `gerenciador_inspecao.limpar_alvos()` e `site_textura.texture = null` no fechamento.
- **`INTEGER_DIVISION` warning em `montar_alvos()`:** divisão `indice / COLUNAS_GRID` sem tipo explícito, porque `mapa_alvos` é um `Dictionary` sem tipo declarado (as chaves vêm como `Variant`). Corrigido com `var linha: int = int(indice) / COLUNAS_GRID` + `@warning_ignore("integer_division")`, deixando explícito que o truncamento é intencional.
- **Grid não seguia a posição real da imagem:** `montar_alvos()` calculava todos os quadrantes a partir de `(0, 0)`, ignorando a `Position` real de `ImagemBase` (`TextureRect`) na cena — se a imagem não nascesse exatamente na origem do mundo, o grid ficava do tamanho certo mas deslocado da imagem visível. Corrigido somando `area_referencia.global_position` como origem de todo o cálculo de posição dos quadrantes.

#### Ponto em aberto: estado por quadrante não persiste ao trocar de trabalho

`foi_encontrado`, `ignorado` e `ja_inspecionado_negativo` vivem no `AreaAlvo`, que é recriado do zero toda vez que `montar_alvos()` roda — inclusive quando o jogador troca de trabalho ativo na lista e depois volta pro mesmo trabalho. Isso reseta silenciosamente o progresso visual por quadrante, incluindo `_algum_alvo_suspeito_encontrado` (que libera o Diagnosticar globalmente). Só `investigar_usado` está protegido disso, por morar no `TrabalhoAgendado` (que persiste enquanto o trabalho está ativo). Ainda não resolvido — a solução, se vier a incomodar na prática, é migrar esses três campos de `AreaAlvo` pra um dicionário indexado por quadrante dentro do próprio `TrabalhoAgendado`.

---

### 3.5 Ciclo do Dia: Iniciar Dia e Relatório de Fim de Expediente

Esta seção documenta a camada mais externa do loop de gameplay (v3.2) — o que acontece **antes** do primeiro trabalho aparecer e **depois** do último ser encerrado, fechando o ciclo `Escritório → expediente → relatório → Escritório`.

#### Fluxo completo

```
[Escritório]
	 │  Jogador clica em Iniciar.gd (reaproveitado, sem mudança de código)
	 ▼
get_tree().change_scene_to_file("res://Scenes/Tela.tscn")
	 │
	 ▼
[Tela.tscn carrega]
	 │
	 ▼
Main_select_script._ready()
	 ├── gerenciador_expediente.iniciar_expediente()
	 │        └── DadosJogo.sortear_agenda_do_dia(...)
	 │             └── reseta trabalhos_do_dia / trabalhos_concluidos_hoje
	 │                 / resultados_pendentes / resultados_do_dia
	 └── conecta gerenciador_expediente.expediente_encerrado → _on_expediente_encerrado()

[Expediente rodando — 8h a 17h simuladas]
	 │
	 │  (jogador aceita/inspeciona/diagnostica/encerra trabalhos,
	 │   ver fluxo completo na seção 3.4 — cada ciclo agora também
	 │   grava hora_inicio/hora_fim e tentativas_certas/erradas)
	 │
	 ▼
GerenciadorExpediente._process(): hora_atual >= HORA_FIM_EXPEDIENTE
	 │
	 ▼
_encerrar_expediente() → expediente_encerrado.emit()
	 │
	 ▼
Main_select_script._on_expediente_encerrado()
	 │
	 ▼
get_tree().change_scene_to_file("res://Scenes/RelatorioDia.tscn")
	 │
	 ▼
[RelatorioDia.tscn carrega]
	 │
	 ▼
RelatorioDia._ready() → montar_relatorio()
	 ├── itera DadosJogo.resultados_do_dia
	 ├── monta 1 linha por trabalho: veredito (✅/❌), alvo encontrado,
	 │   diagnóstico escolhido (+ se correto), tentativas certas/erradas,
	 │   tempo gasto (hora_fim - hora_inicio), recompensa
	 └── DadosJogo.dinheiro_jogador += total_dinheiro   ← só aqui é creditado
	 │
	 │  Jogador clica em BtnVoltar
	 ▼
get_tree().change_scene_to_file("res://Scenes/Escritorio.tscn")
	 │
	 ▼
[Escritório — pronto pra Iniciar Dia de novo]
```

**Correção que fechou o ciclo (clique duplo):** antes desta versão, aceitar um trabalho em `VBoxDisponiveis` só o movia pra `VBoxAtivos` — a inspeção só abria com um segundo clique no item ativo (`_on_ativo_pressionado()`, emitindo `trabalho_selecionado`). Agora `_on_disponivel_pressionado()` já emite `trabalho_selecionado` direto ao aceitar, e `DadosJogo.iniciar_resultado_pendente()` migrou de `gerenciador_trabalho.gd` pra `coordenador_trabalho.gd` (que é onde o `hora_inicio` real do relógio simulado é conhecido).

**Por que o dinheiro só é creditado no relatório, não durante o expediente:** decisão de design mantida desde a v1 (ver "Histórico de versões" abaixo) — o objetivo é nunca vazar se o jogador acertou ou errou um trabalho antes do fim do dia. `RelatorioDia.montar_relatorio()` é o único lugar que soma `resultado.recompensa` em `DadosJogo.dinheiro_jogador`.

#### Integração com o relógio simulado (`GerenciadorExpediente`)

`CoordenadorTrabalho` ganhou `@export var gerenciador_expediente: Node` e um helper `_hora_atual()` que lê `gerenciador_expediente.hora_atual` com segurança. Isso alimenta:
- `ResultadoTrabalho.hora_inicio` — gravado quando `trabalho_selecionado` chega (início da inspeção).
- `ResultadoTrabalho.hora_fim` — gravado quando o jogador confirma "Encerrar".
- `ResultadoTrabalho.tempo_gasto_minutos()` — `(hora_fim - hora_inicio) * 60`, exibido no relatório.

**Duração real de um dia inteiro:** com `GerenciadorExpediente.minutos_por_segundo_real = 4.0` (padrão) e expediente de 8h–17h (9 horas simuladas), um dia completo dura **~2 minutos e 15 segundos em tempo real** — ajustável no Inspetor sem mexer em código (ver tabela de referência no `netetive_changelog.md`).

#### `RelatorioDia` — cena e estrutura de nós

```
RelatorioDia (Control)              ← res://Scenes/RelatorioDia.tscn
├── LabelResumo (Label)             ← v3.4: texto fixo "Dia concluído"
├── LabelDinheiro (Label)           ← v3.4, novo: só o dinheiro ganho no dia ("R$ %d")
├── LabelFama (Label)               ← v3.4, novo: só a fama ganha no dia ("+%d fama")
├── ScrollContainer (ScrollContainer)
│   └── VBoxResultados (VBoxContainer)
└── BtnVoltar (Button)
```

- `ScrollContainer` existe porque `VBoxResultados` cresce em altura conforme o número de trabalhos do dia — sem ele, uma lista longa simplesmente cortaria fora da tela; com ele, aparece rolagem.
- `VBoxResultados` empilha uma linha por trabalho automaticamente, sem cálculo manual de posição.
- Todos os nós são lidos via `get_node_or_null()` em `relatorio_dia.gd`, não `$caminho` direto — um nome/caminho errado gera `push_warning()` específico (dizendo qual nó falta) em vez de um erro fatal `Node not found` que derruba a cena inteira. Essa escolha veio de um bug real: o script foi inicialmente testado anexado a um nó dentro de `Tela.tscn` (raiz `Node2D`), fora da hierarquia esperada.
- **v3.4:** antes disso, `LabelResumo` sozinho concentrava todos os números (trabalhos corretos, dinheiro, upkeep, saldo, fama) numa única string longa. Foi dividido em 3 labels pra ficar mais legível — `LabelResumo` virou só um texto fixo de status ("Dia concluído"), e os números de dinheiro/fama ganharam label próprio cada um. O cálculo interno (soma de `resultado.recompensa`/`resultado.fama_ganha`, desconto de upkeep, crédito em `DadosJogo`) não mudou — só a forma como é exibido.

⚠️ **Ponto em aberto:** `Main_select_script._on_expediente_encerrado()` carrega `RelatorioDia.tscn` por string de caminho — já causou `Cannot open file`/`Failed loading resource` quando a cena foi salva num caminho/nome diferente do esperado. Ainda não migrado pra `@export var cena_relatorio: PackedScene`, que eliminaria esse risco.

---

### 3.6 Sistema de Upgrades: PC, Assistente e IA

Sistema de progressão acessível **só no Escritório**, fora do loop de expediente (`BtnUpgrades` → `PainelUpgrades`). Design fechado em várias rodadas de conversa com o usuário — a versão final tem **5 linhas**, organizadas em **3 categorias automatizadas** (PC, Assistente, IA), cada linha com **4 tiers sequenciais** (só pode comprar o tier N+1 depois de já ter o tier N).

#### Tabela de valores (v3.3)

| Categoria | Linha | Efeito por tier | Pré-requisito | Upkeep/dia |
|---|---|---|---|---|
| PC | única | Popup de verificação: 4s → 3s → 2s → 1s → **instantâneo** | nenhum | não |
| Assistente | Quantidade | Nº de assistentes simultâneos: 2 → 3 → 4 → 5 | nenhum (linha de entrada) | não (upkeep já embutido no Treinamento) |
| Assistente | Treinamento | Tempo/trabalho: 120→105→90→75 min. Taxa de sucesso: 70%→80%→90%→100% | 🔒 Quantidade tier 1 | sim — upkeep_base(tier) × nº de assistentes |
| IA | Capacidade | Trabalhos processados por noite: 1→2→3→4 | nenhum (linha de entrada) | sim — fixo por tier |
| IA | Eficiência | % da recompensa entregue: 35%→50%→65%→80%→95% | 🔒 IA Capacidade tier 1 | sim — fixo por tier |

Taxa de sucesso da IA é **fixa em 75%** (não sobe por tier — só Eficiência muda quanto ela entrega de recompensa por trabalho resolvido).

> ⚠️ **Nota histórica:** o pré-requisito entre as duas linhas do Assistente foi **invertido em runtime**, depois de já implementado e testado em jogo. A primeira versão do design tinha Treinamento como linha de entrada e Quantidade bloqueada até Treinamento tier 1 — o usuário testou e pediu a inversão (Quantidade como entrada, Treinamento bloqueado até Quantidade tier 1). Como a validação de pré-requisito é genérica (só olha `LinhaUpgrade.chave_pre_requisito`), a mudança foi só trocar essa atribuição de lugar em `banco_de_upgrades.gd`, sem tocar em nenhum outro arquivo.

#### Estrutura de dados

##### `TierUpgrade` — `Resource`
```gdscript
class_name TierUpgrade
extends Resource

@export var preco: int = 0
@export var valor_efeito: float = 0.0
@export var valor_efeito_secundario: float = 0.0   # só usado pelo Treinamento (taxa de sucesso)
@export var upkeep: float = 0.0                      # custo diário; no Treinamento é "por assistente"
@export var descricao: String = ""
```
Um degrau individual — dumb data, sem lógica própria. O *significado* de `valor_efeito`/`valor_efeito_secundario` muda por linha (documentado no cabeçalho do arquivo e na tabela acima).

##### `LinhaUpgrade` — `Resource`
```gdscript
class_name LinhaUpgrade
extends Resource

@export var chave: String = ""
@export var nome: String = ""
@export var tiers: Array[TierUpgrade] = []
@export var chave_pre_requisito: String = ""   # vazio = sem pré-requisito

var tier_atual: int = 0   # progresso do jogador — 0 = nenhum tier comprado ainda
```
Diferente de `BancoDeTrabalhos`/`TrabalhoInspecao`, aqui **não** existe separação entre definição estática e estado runtime — cada jogador só tem uma instância de cada linha (não é sorteada nem repetida), então `tier_atual` vive dentro do próprio Resource. Helpers: `esta_no_maximo()`, `proximo_tier()`, `tier_comprado(indice)`, `valor_efeito_atual(valor_base)`, `valor_efeito_secundario_atual(valor_base)`, `upkeep_atual()` — todos leem `tier_atual` na hora, sem cache externo.

##### `BancoDeUpgrades` — módulo estático (`static func`, sem Autoload)
Mesmo padrão de `BancoDeTrabalhos`: monta as 5 `LinhaUpgrade` com os valores fechados da tabela acima. Constantes `CHAVE_PC`, `CHAVE_ASSISTENTE_TREINAMENTO`, `CHAVE_ASSISTENTE_QUANTIDADE`, `CHAVE_IA_CAPACIDADE`, `CHAVE_IA_EFICIENCIA` identificam cada linha globalmente, usadas por todo o resto do sistema pra evitar strings soltas espalhadas pelo código.

##### `DadosJogo.gd` — integração
```gdscript
var upgrades: Dictionary = {}   # String -> LinhaUpgrade

func _ready() -> void:
	banco_de_trabalhos = BancoDeTrabalhos.criar_todos()
	upgrades = BancoDeUpgrades.criar_todas()

func comprar_upgrade(chave: String) -> bool:
	# valida: linha existe -> não está no máximo -> pré-requisito atendido -> saldo suficiente
	# só então: debita dinheiro_jogador, incrementa linha.tier_atual
	...

func obter_linha_upgrade(chave: String) -> LinhaUpgrade:
	return upgrades.get(chave, null)
```
`comprar_upgrade()` é a **única porta de entrada** pra avançar uma linha — nenhum outro script incrementa `tier_atual` ou debita `dinheiro_jogador` diretamente. Isso mantém a validação centralizada, evitando que `painel_upgrades.gd` (UI) precise reimplementar as regras de negócio.

#### Efeito do PC — sincronização entre dois timers

O upgrade do PC reduz o tempo do popup de verificação (`MensagemModal`), mas **dois** timers independentes dependem desse valor: o texto do popup (`mensagem_modal_scpt.gd`) e a revelação da cor do quadrante (`gerenciador_inspecao.gd`). Pra evitar dessincronia, `MensagemModal` expõe `tempo_total_atual()` publicamente, e `GerenciadorInspecao` lê o mesmo valor em vez de manter sua própria cópia:

```gdscript
# mensagem_modal_scpt.gd
func tempo_total_atual() -> float:
	var linha := DadosJogo.obter_linha_upgrade(BancoDeUpgrades.CHAVE_PC)
	return linha.valor_efeito_atual(4.0) if linha != null else 4.0

# gerenciador_inspecao.gd
func _tempo_verificacao_atual() -> float:
	if mensagem_modal != null and mensagem_modal.has_method("tempo_total_atual"):
		return mensagem_modal.tempo_total_atual()
	# fallback: lê a linha PC direto, se mensagem_modal não estiver atribuído
	...
```
No tier 4 (`valor_efeito = 0.0`), ambos os `await get_tree().create_timer(...)` são pulados inteiramente (`if tempo > 0.0`) — verificação e revelação acontecem no mesmo frame do clique em "Inspecionar".

#### Assistente — fila com tempo simulado

`gerenciador_assistente.gd` (`Node`, filho de `ModuloTrabalho`, irmão de `GerenciadorExpediente`/`GerenciadorTrabalho`/`CoordenadorTrabalho`) mantém uma fila de trabalhos delegados pelo jogador:

```
Jogador clica "Delegar" num item de VBoxAtivos (gerenciador_trabalho.gd)
		│  emite delegar_solicitado(agendado) — não conhece GerenciadorAssistente
		▼
CoordenadorTrabalho._on_delegar_solicitado()
		│  chama gerenciador_assistente.delegar(agendado)
		▼
GerenciadorAssistente.delegar()
		├─ garante ResultadoTrabalho pendente (caso o jogador nunca tenha
		│   aberto a inspeção desse trabalho)
		├─ se há slot livre (capacidade = linha Quantidade): processa direto
		└─ senão: entra na fila FIFO (_fila_espera)
		│
		▼  [a cada frame, _process() compara hora_atual com hora_conclusao_prevista]
		│
   Ao vencer o horário:
		├─ sorteia acerto pela taxa de sucesso do Treinamento
		├─ fecha o ResultadoTrabalho direto (sem passar pela NovaAba)
		├─ puxa o próximo da fila de espera, se houver
		└─ emite trabalho_assistente_concluido(agendado, acertou)
				│
				▼
		CoordenadorTrabalho._on_assistente_concluido()
				├─ gerenciador_trabalho.marcar_trabalho_concluido(agendado)
				│   (remove de VBoxAtivos — mesmo destino final do "Encerrar" manual)
				└─ toast: "Assistente: '<título>' concluído com sucesso/erro."
```
Todos os valores (tempo por trabalho, taxa de sucesso, capacidade simultânea) são lidos **sob demanda** de `DadosJogo.obter_linha_upgrade()` a cada chamada — nunca cacheados em variável própria. Isso significa que comprar um tier novo no meio do expediente já afeta o próximo trabalho delegado, sem precisar reiniciar nada.

#### IA — resolução overnight

`gerenciador_ia_noturna.gd` (`class_name GerenciadorIANoturna`, `extends RefCounted`, **sem nó na árvore** — `static func`, mesmo espírito de `BancoDeUpgrades`) roda **uma única vez**, chamada por `Main_select_script._on_expediente_encerrado()` antes da troca de cena pra `RelatorioDia.tscn`:

```
GerenciadorExpediente.expediente_encerrado dispara
		▼
Main_select_script._on_expediente_encerrado()
		├─ GerenciadorIANoturna.processar_noite(hora_fim_expediente)
		│      ├─ se IA Capacidade tier < 1: não faz nada
		│      ├─ coleta "trabalhos sobrados": agendado.apareceu == true E
		│      │   (nunca aceito OU aceito mas nunca concluído), EXCLUINDO
		│      │   qualquer um que já tenha resultado pendente em outro
		│      │   lugar (ex: ainda na fila do Assistente — a IA não "rouba"
		│      │   um trabalho que já está sendo tratado)
		│      ├─ embaralha e processa até a capacidade da linha (1-4/noite)
		│      └─ por trabalho: sorteia acerto a 75% fixo, aplica % de
		│          Eficiência sobre a recompensa, grava direto em
		│          DadosJogo.resultados_do_dia (sem passar por
		│          resultados_pendentes — não há hora_inicio real de
		│          expediente, é tudo simulado de uma vez, à noite)
		▼
get_tree().change_scene_to_file("res://Scenes/RelatorioDia.tscn")
```
Os resultados da IA aparecem no `RelatorioDia` misturados com os do jogador/Assistente, diferenciados só pelo texto `"Resolvido pela IA (noturno)"` no campo Diagnóstico.

#### Upkeep — desconto diário no relatório

`calculadora_upkeep.gd` (`class_name CalculadoraUpkeep`, `static func`, sem nó) isola a fórmula de custo diário, pra `RelatorioDia` não precisar conhecê-la:

```gdscript
static func calcular_total() -> int:
	return _upkeep_assistente() + _upkeep_ia_capacidade() + _upkeep_ia_eficiencia()

static func _upkeep_assistente() -> int:
	# upkeep_atual(Treinamento) × quantidade de assistentes (linha Quantidade)
	# Treinamento tier 0 (não comprado) = upkeep 0, mesmo com Quantidade comprada
	...
```
`relatorio_dia.gd.montar_relatorio()` desconta esse total **antes** de creditar: `DadosJogo.dinheiro_jogador += total_dinheiro - upkeep_total` — pode deixar o saldo **negativo de propósito** (dívida realista, decisão de design confirmada com o usuário). O resumo no `LabelResumo` mostra os três números separados: ganhos do dia, manutenção descontada, saldo final.

#### `PainelUpgrades` — UI de compra

```
PainelUpgrades (Panel)
├── LabelDinheiro (Label)
├── ScrollContainer (ScrollContainer)
│   └── VBoxLinhas (VBoxContainer)
└── BtnFechar (Button)
```

`painel_upgrades.gd` é **UI pura** — só desenha o estado atual (lido via `DadosJogo.obter_linha_upgrade()`) e delega o clique de compra pra `DadosJogo.comprar_upgrade()`, remontando a lista inteira depois (atualiza saldo, preços e desbloqueios de uma vez, sem lógica condicional espalhada). Pra cada linha, mostra:
- `🔒 Bloqueada até comprar "<linha pré-requisito>" tier 1` — se `chave_pre_requisito` não atendido;
- `✅ Tier máximo atingido` — se `esta_no_maximo()`;
- descrição do próximo tier + botão "Comprar (R$ X)" (desabilitado se `dinheiro_jogador < preco`) — caso contrário.

`btn_upgrades.gd` (`TextureButton` no Escritório) só chama `painel_upgrades.abrir()`, conectado ao sinal `pressed` pelo editor — mesmo padrão de `Quadro_avisos`/`Iniciar.gd`.

---

### 3.7 Sistema de Fama

Recurso permanente novo, paralelo ao `dinheiro_jogador` — não é gasto em nada, só cresce, e controla a **quantidade de trabalhos que aparecem por dia**. Fecha o sistema de trabalho ligando a progressão do jogador ao ritmo de novos casos.

#### Como se ganha fama

Todo trabalho que o jogador acerta (achar o alvo suspeito **e** diagnosticar certo) tem uma recompensa de fama fixa, já existente desde a v1 mas nunca usada até agora: `TrabalhoInspecao.recompensa_fama` (padrão `10`). Essa fama é creditada junto com o dinheiro, no `RelatorioDia`, no fim do expediente:

| Origem do resultado | Fama ganha |
|---|---|
| Jogador (manual, via `NovaAba`) | Cheia, se acertar (`ResultadoTrabalho.finalizar()`) |
| Assistente (`gerenciador_assistente.gd`) | Cheia, se acertar — mesma lógica de `finalizar()`, sem upgrade próprio que reduza fama |
| IA (`gerenciador_ia_noturna.gd`, overnight) | Reduzida pela mesma % de Eficiência que já reduz o dinheiro — trabalho malfeito rende menos reputação, não só menos grana |

#### `ResultadoTrabalho` — campo novo

```gdscript
@export var fama_ganha: int = 0

func finalizar() -> void:
	acertou_no_geral = achou_alvo_correto and diagnostico_correto
	recompensa = agendado.recompensa_dinheiro if acertou_no_geral else 0
	fama_ganha = agendado.trabalho.recompensa_fama if acertou_no_geral else 0
```
Como `finalizar()` já é chamado por todo caminho que passa por `DadosJogo.finalizar_trabalho()` (jogador manual, Assistente), esses dois ganham fama **automaticamente**, sem nenhuma mudança adicional nos respectivos arquivos. Só `gerenciador_ia_noturna.gd` define `fama_ganha` manualmente (porque aplica a % de Eficiência, que `finalizar()` não conhece).

#### `CalculadoraFama` — a curva não-linear

```gdscript
class_name CalculadoraFama
extends RefCounted

const TRABALHOS_BASE_PADRAO := 6
const FATOR_CRESCIMENTO := 1.0

static func calcular_quantidade_trabalhos_dia(fama: int, base: int = TRABALHOS_BASE_PADRAO) -> int:
	var fama_efetiva: int = max(0, fama)
	var bonus := int(floor(sqrt(float(fama_efetiva)) * FATOR_CRESCIMENTO))
	return base + bonus
```
`static func`, sem nó na árvore — mesmo espírito de `BancoDeUpgrades`/`CalculadoraUpkeep`/`GerenciadorIANoturna`. **Design pedido:** quanto menos fama, mais rápido a quantidade de trabalhos cresce; quanto mais fama, mais devagar. A raiz quadrada entrega isso sozinha, sem nenhum `if`/condicional extra — a derivada de `sqrt(x)` cai naturalmente conforme `x` cresce, então cada ponto de fama adicional rende cada vez menos trabalhos novos.

**Curva de referência** (fator `1.0`, base `6`):

| Fama | Trabalhos/dia |
|---|---|
| 0 | 6 |
| 25 | 11 |
| 100 | 16 |
| 400 | 26 |
| 900 | 36 |

Cada `+5` trabalhos exige progressivamente mais fama (25 → depois +75 → depois +125...) — retornos decrescentes por design.

#### Integração em `GerenciadorExpediente`

```gdscript
@export var trabalhos_base_dia: int = 6   # mínimo garantido/dia — cresce com fama

func iniciar_expediente() -> void:
	var quantidade_hoje := CalculadoraFama.calcular_quantidade_trabalhos_dia(DadosJogo.fama_jogador, trabalhos_base_dia)
	DadosJogo.sortear_agenda_do_dia(quantidade_hoje, quantidade_trabalhos_iniciais)
	...
```
O antigo `@export var quantidade_trabalhos_dia: int` (fixo) virou `trabalhos_base_dia` (o mínimo/base) — a quantidade real usada em `sortear_agenda_do_dia()` é recalculada a cada `iniciar_expediente()`, lendo `DadosJogo.fama_jogador` na hora. `quantidade_trabalhos_iniciais` (quantos já aparecem prontos às 8h) **não** escala com fama — continua fixo, só o total do dia cresce.

#### `RelatorioDia` — exibição em 3 labels

A partir da v3.4, o resumo do dia deixou de ser uma única string longa e virou 3 labels separados:

```
RelatorioDia (Control)
├── LabelResumo (Label)      ← texto fixo "Dia concluído"
├── LabelDinheiro (Label)    ← "R$ %d" — só o dinheiro ganho no dia
├── LabelFama (Label)        ← "+%d fama" — só a fama ganha no dia
├── ScrollContainer (ScrollContainer)
│   └── VBoxResultados (VBoxContainer)
└── BtnVoltar (Button)
```
O cálculo interno não mudou — soma de `resultado.recompensa`/`resultado.fama_ganha` por trabalho, desconto de upkeep (só no dinheiro; fama não tem upkeep, só cresce), crédito em `DadosJogo.dinheiro_jogador`/`DadosJogo.fama_jogador`. Cada linha individual em `VBoxResultados` (`_criar_linha()`) também passou a mostrar a fama ganha naquele trabalho específico, ao lado da recompensa em dinheiro.

---

## Histórico de versões do Sistema de Trabalho

**v1 — Diagnóstico na lista de trabalhos:** cada item em `VBoxAtivos` tinha 3 botões (Título/Selecionar, Diagnosticar, Terminar trabalho). `Diagnosticar` abria um `PainelDiagnostico` flutuante e separado da inspeção. `Terminar trabalho` só habilitava depois de diagnosticar.

**v2 — Diagnóstico dentro do popup de clique:** o diagnóstico saiu da lista de trabalhos e passou a abrir dentro da própria `NovaAba`, mas só **depois de achar o alvo certo** (a `NovaAba` reabria em outro "modo", sem o botão Inspecionar). Foi identificado nessa etapa que essa regra travaria o trabalho indefinidamente se o jogador nunca achasse o alvo certo.

**v3 — Popup único e sistema de grid:** todos os 4 botões (Inspecionar, Diagnosticar, Ignorar, Encerrar) ficam sempre visíveis juntos no mesmo popup, com Diagnosticar apenas desabilitado até algum alvo suspeito ser achado em qualquer ponto do trabalho — nunca trava de vez. "Terminar trabalho" saiu da lista de trabalhos definitivamente, virando "Encerrar" dentro do popup, com confirmação via `ConfirmationDialog` mostrando o diagnóstico atual. Paralelamente, o sistema de posicionamento de alvos foi inteiramente trocado de pixels livres pra um grid de 3×N quadrantes com compensação de altura adaptativa.

**v3.1 — Botão Investigar:** 5º botão adicionado ao popup, dando uma dica textual limitada (1 uso por trabalho) sobre o problema do quadrante clicado, com 3 respostas possíveis dependendo do estado daquele quadrante. Campo `dica: String` novo em `AlvoInspecao`. Também corrigido nesta etapa: o grid não estava respeitando a posição real de `ImagemBase` na cena, calculando tudo a partir de `(0,0)` em vez de `area_referencia.global_position`.

**v3.2 — Ciclo do Dia (atual):** fecha o loop de ponta a ponta. Corrigido o clique duplo pra entrar num trabalho (aceitar já emite `trabalho_selecionado` direto). `ResultadoTrabalho` ganhou `tentativas_certas`/`tentativas_erradas`/`hora_inicio`/`hora_fim`, alimentados por `CoordenadorTrabalho` a cada inspeção, usando o relógio simulado de `GerenciadorExpediente`. Nova tela `RelatorioDia.tscn`/`relatorio_dia.gd`, disparada por `Main_select_script` quando o expediente encerra — é aqui que `dinheiro_jogador` finalmente é creditado. Botão "Iniciar Dia" no Escritório reaproveitou o `Iniciar.gd` já existente, sem mudanças de código. Ver seção [3.5](#35-ciclo-do-dia-iniciar-dia-e-relatório-de-fim-de-expediente) para o fluxo completo.


---

### 3.8 HUD de Dinheiro/Fama e Trabalhos de Scareware/Ransomware

Esta seção documenta o trabalho de trazer duas features de branches paralelas (`score_system` e `trabalho_malware`) pra dentro da `Sistema-upgrade`. As duas branches partiram de um ponto do projeto anterior ao grid/Investigar/upgrades, então o conteúdo foi **recriado adaptado**, não mesclado diretamente — histórico completo da decisão em `netetive_changelog.md` v3.5.

#### HUD permanente de Dinheiro/Fama (`Scores.tscn`)

Diferente do `RelatorioDia` (que só mostra os números uma vez, no fim do dia), o HUD fica **sempre visível no Escritório**, mostrando o total acumulado de `dinheiro_jogador`/`fama_jogador`.

```
Score (instância de Scores.tscn)
└── HUD (Node, hud_manager.gd)
	└── control (Control)
		├── container_dinheiro (HBoxContainer)
		│   └── icone_dinheiro (TextureRect, icone_dinheiro.gd)
		│       └── contador_dinheiro (Label)
		└── container_fama (HBoxContainer)
			└── icone_fama (TextureRect)
				└── contador_fama (Label)
```

##### `hud_manager.gd` — `Node`

```gdscript
extends Node

@onready var contador_dinheiro: Label = $control/container_dinheiro/icone_dinheiro/contador_dinheiro
@onready var contador_fama: Label = $control/container_fama/icone_fama/contador_fama

var _ultimo_dinheiro: int = -1
var _ultima_fama: int = -1


func _ready() -> void:
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

**Por que polling em `_process()` em vez de sinal:** `DadosJogo` (autoload já existente) não emite nenhum sinal quando `dinheiro_jogador`/`fama_jogador` mudam — não foi criado um sinal novo pra não alterar um arquivo que é prioridade/base (`DadosJogo.gd` já está estabilizado pelo Sistema de Upgrades e Fama). O HUD compara o valor atual com o último valor visto a cada frame e só atualiza o texto quando muda de verdade, evitando redesenhar à toa.

**Efeito colateral esperado, não é bug:** como o crédito de dinheiro/fama só acontece dentro de `RelatorioDia.montar_relatorio()`, uma vez por dia, o HUD fica parado o expediente inteiro e só salta pro valor final quando o relatório é fechado — não é "ao vivo" trabalho a trabalho. Isso é intencional, preserva o veredito escondido até o fim do dia (mesma decisão de design da v1).

##### `icone_dinheiro.gd` — `TextureRect`

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

Troca o sprite da carteira (vazia/cheia) dependendo se o jogador tem saldo positivo — mesma lógica visual da branch original, só trocando a fonte do dado.

**`Global` (autoload da branch `score_system`) foi descartado por completo** — não foi adicionado ao `project.godot`. Ele tinha `money: float`/`fame: int` com sinais próprios (`altered_money`/`fame_received`), duplicando o que `DadosJogo.dinheiro_jogador`/`fama_jogador` já fazem. Ter os dois autoloads coexistindo criaria duas fontes de verdade pro mesmo dado.

##### Bug corrigido na integração

`Node not found` nos dois `@onready` de `hud_manager.gd` — o caminho relativo original (copiado da branch `score_system`, `$control/container/container_dinheiro/...`) não batia com a estrutura real da cena, que não tinha o nível `container` (`MarginContainer`) intermediário entre `control` e `container_dinheiro`. Corrigido ajustando o caminho pra bater com a hierarquia real.

> ⚠️ **Recomendação ainda não aplicada:** trocar os `@onready var ... = $caminho/...` por Unique Names (`%contador_dinheiro`/`%contador_fama`) evitaria esse tipo de erro se a hierarquia interna do HUD mudar de novo no futuro — mesmo padrão de fragilidade de caminho relativo já catalogado várias vezes neste projeto (ver "Observações Gerais" no final do documento).

#### Trabalhos novos: Scareware e Ransomware

A branch `trabalho_malware` trouxe a ideia de um trabalho novo ("Remover ransomware"), mas com uma imagem que na verdade retratava **scareware** (falso alerta de vírus com botão de download disfarçado), não ransomware em ação. Em vez de forçar isso num único trabalho ambíguo, virou **dois trabalhos separados**, representando dois estágios do mesmo golpe — a isca e a consequência.

##### Capítulo novo no Livro de Ajuda — "Scareware"

O capítulo 6, antes "Senha Fraca", foi **substituído** por "Scareware" em `ConteudoLivro.PAGINAS` (índice `5`):

> Conteúdo antigo de "Senha Fraca" não foi descartado do histórico — só removido do array ativo. Candidato a virar um 11º capítulo futuro, se quiser recuperar esse conteúdo em vez de deixá-lo de fora.

##### `_criar_trabalho_scareware()` — novo em `banco_de_trabalhos.gd`

Site com alerta falso de vírus, contador regressivo e botão de download disfarçado de "Safe Browser". `capitulo_relacionado` aponta pro capítulo novo (índice `5`, Scareware).

##### `_criar_trabalho_ransomware()` — novo em `banco_de_trabalhos.gd`

Site redesenhado durante esta rodada pra retratar ransomware de verdade — lista de arquivos criptografados (`.locked`/`.encrypted`/`.crypt`), valor de resgate em Bitcoin, endereço de carteira, instruções de pagamento passo a passo. `capitulo_relacionado` aponta pro capítulo "Ransomware" já existente (índice `3`), que agora bate literalmente com o conteúdo da imagem (diferente do trabalho antigo da `trabalho_malware`, que usava esse mesmo capítulo pra uma imagem de scareware).

Ver `netetive_scripts.md` seção correspondente pro código completo das duas funções e os valores de `quadrante`/`altura_real`/`dica` usados.

> ⚠️ **Pendente:** `quadrante`/`altura_real` dos dois trabalhos novos são **estimativas iniciais**, calculadas por proporção da imagem original (fração de largura/altura, não pixels absolutos) — ainda não calibradas em jogo com o processo padrão do projeto (`print()` temporário em `montar_alvos()`, clicando no ponto certo da imagem em execução).
>
> ⚠️ **Nenhum dos dois trabalhos reaproveitou a cena solta `Tela_baixar_ransomware.tscn`** da branch `trabalho_malware` — ela tinha os três `@export` do `CoordenadorTrabalho` vazios e usava a arquitetura antiga (sem grid). Só o asset de imagem original foi aproveitado (pro trabalho de Scareware); a imagem de Ransomware foi redesenhada do zero nesta rodada.
>
> ⚠️ **Bug evitado, não herdado:** a função de trabalho original da `trabalho_malware` existia no código mas nunca tinha sido incluída no array retornado por `criar_todos()`/`_ready()` — o trabalho nunca era sorteado de fato no jogo. Confirmado que as duas funções novas estão incluídas desta vez.

---

## 4. Estado Geral do Projeto

### 1. Escritório

| Funcionalidade | Status |
|---|---|
| Fundo visual do escritório | ✅ Implementado |
| Quadro de avisos interativo | ✅ Implementado |
| Transição para loop de gameplay | ✅ Implementado |
| Cafeteira com texto de boas-vindas | ✅ Implementado |
| Outras interações no escritório | 🔲 A implementar |

### 2. Quadro de Avisos

| Funcionalidade | Status |
|---|---|
| Fundo visual do quadro | ✅ Implementado |
| Botão para abrir tutorial | ✅ Implementado |
| Tutorial como CanvasLayer | ✅ Implementado |
| Fechar tutorial com clique direito | ✅ Implementado |
| Atalho de teclado (Espaço) | ✅ Implementado |
| Voltar ao escritório com clique direito | ✅ Implementado |
| Conteúdo do tutorial (textos de controles/guias) | 🔲 A expandir |
| Mais papéis/botões no quadro | 🔲 A implementar |

### 3.1–3.4 Tela de Gameplay

| Funcionalidade | Status |
|---|---|
| Site suspeito exibido na tela | ✅ Implementado |
| Sistema de expedição (GerenciadorExpediente) com agenda do dia | ✅ Implementado |
| Menu de trabalhos Disponíveis/Ativos (GerenciadorTrabalho) | ✅ Implementado |
| Alvos dinâmicos via `AlvoInspecao`/`TrabalhoInspecao`/`AreaAlvo` | ✅ Implementado |
| Sinal `inspecao_concluida` emitido corretamente | ✅ Implementado (corrigido nesta rodada) |
| Diagnóstico por múltipla escolha (categoria do problema) | ✅ Implementado |
| Diagnóstico disponível a qualquer momento (sem travar o trabalho) | ✅ Implementado |
| Botão "Terminar trabalho" com veredito combinado (alvo + diagnóstico) | ✅ Implementado |
| Resultado revelado apenas no fim do dia | ✅ Implementado (v3.2 — `RelatorioDia.tscn`) |
| Livro de Dicas paginado | ✅ Implementado |
| Múltiplos alvos suspeitos por cena | 🔲 A implementar |
| Pontuação / recompensa visível ao jogador | ✅ Implementado (v3.2 — na tela `RelatorioDia`) |
| Condição de fim de dia / loop completo | ✅ Implementado (v3.2 — ciclo Escritório → expediente → relatório → Escritório) |

### 3.2 Módulo de Inspeção

| Funcionalidade | Status |
|---|---|
| Alvos dinâmicos (`AreaAlvo`/`Area2D`) por trabalho | ✅ Implementado |
| Detecção de clique por `Area2D`/`CollisionShape2D` | ✅ Implementado |
| Feedback visual ao acertar o alvo suspeito | ✅ Implementado |
| Variação de quantidade de alvos por dificuldade | 🔲 A implementar |
| Variação de quais alvos são problemáticos por dificuldade | 🔲 A implementar |
| Sorteio dinâmico de alvos suspeitos/neutros | 🔲 A implementar |

### 3.3 Livro de Ajuda

| Funcionalidade | Status |
|---|---|
| Estrutura paginada do livro (título, problema, solução) | ✅ Implementado |
| 10 capítulos de conteúdo educativo | ✅ Implementado |
| Navegação entre páginas (anterior/próximo) | ✅ Implementado |
| Abrir/fechar livremente durante o expediente | ✅ Implementado |
| `PAGINAS` acessível estaticamente (`const`) | ✅ Implementado |
| Vínculo entre capítulos do livro e alvos da inspeção (`capitulo_relacionado`) | ✅ Implementado |
| Expansão para 12+ capítulos (mencionado em comentário) | 🔲 A implementar |

### 3.4 Sistema de Trabalho / Diagnóstico / Veredito Diferido

| Funcionalidade | Status |
|---|---|
| `ResultadoTrabalho` (Resource) | ✅ Implementado |
| `PainelDiagnostico` (Control) | 🗑️ Descontinuado — diagnóstico migrou pra dentro da `NovaAba` (v2/v3) |
| `DadosJogo.resultados_pendentes` / `resultados_do_dia` | ✅ Implementado |
| `DadosJogo.titulo_capitulo_correto()` / `gerar_opcoes_diagnostico()` | ✅ Implementado |
| Popup único (`NovaAba`) com Inspecionar/Investigar/Diagnosticar/Ignorar/Encerrar | ✅ Implementado (v3.1) |
| Diagnosticar desbloqueado ao achar qualquer alvo suspeito (sem travar) | ✅ Implementado |
| Investigar — dica limitada (1×/trabalho) via `AlvoInspecao.dica` | ✅ Implementado (v3.1) |
| Ignorar/Designorar por quadrante clicado | ✅ Implementado |
| Encerrar com `ConfirmationDialog` mostrando o diagnóstico atual | ✅ Implementado |
| Botão "Terminar trabalho" na lista de Ativos | 🗑️ Removido — substituído por "Encerrar" no popup |
| Bug de clique bloqueado no alvo revelado (`mouse_filter`) | ✅ Corrigido |
| Limpeza de alvos/imagem ao encerrar trabalho | ✅ Corrigido |
| Grid não seguia a posição real de `ImagemBase` (origem fixa em 0,0) | ✅ Corrigido (v3.1) |
| Sistema de grid (3 colunas × N linhas, compensação de altura) | ✅ Implementado |
| `banco_de_trabalhos.gd` — módulo de dados separado de `DadosJogo` | ✅ Implementado |
| Trabalhos migrados pro sistema de grid | 🔲 3 de 5 ("Remover Cavalo de Tróia", "Identificar Scareware" v3.5, "Remover Ransomware" v3.5; ainda faltam 2 dos originais removidos — sem arte calibrada) |
| Estado por quadrante persistindo ao trocar de trabalho ativo | 🔲 Não resolvido (ver "Ponto em aberto" na seção 3.4) |
| Tela de resumo de fim de expediente | ✅ Implementado (v3.2 — `RelatorioDia.tscn`/`relatorio_dia.gd`) |
| Crédito de `dinheiro_jogador` a partir de `resultados_do_dia` | ✅ Implementado (v3.2 — creditado em `RelatorioDia.montar_relatorio()`) |

### 3.5 Ciclo do Dia (v3.2)

| Funcionalidade | Status |
|---|---|
| Botão "Iniciar Dia" no Escritório | ✅ Implementado (reaproveitando `Iniciar.gd`, sem mudança de código) |
| Reset automático do estado do dia ao carregar `Tela.tscn` | ✅ Implementado (via `sortear_agenda_do_dia()`, já existente) |
| Correção do clique duplo pra entrar no trabalho | ✅ Corrigido (`_on_disponivel_pressionado()` emite `trabalho_selecionado` direto) |
| `ResultadoTrabalho.tentativas_certas`/`tentativas_erradas` | ✅ Implementado |
| `ResultadoTrabalho.hora_inicio`/`hora_fim`/`tempo_gasto_minutos()` | ✅ Implementado |
| `CoordenadorTrabalho` integrado ao relógio simulado (`gerenciador_expediente`) | ✅ Implementado |
| `RelatorioDia.tscn` — tela de resumo detalhado | ✅ Implementado |
| Disparo automático do relatório ao fim do expediente | ✅ Implementado (`Main_select_script._on_expediente_encerrado()`) |
| Carregamento de `RelatorioDia.tscn` por `PackedScene` (`@export`) em vez de string de caminho | 🔲 Pendente — hoje usa string, já causou erro de carregamento |

### 3.6 Sistema de Upgrades (v3.3)

| Funcionalidade | Status |
|---|---|
| `TierUpgrade`/`LinhaUpgrade` (Resources) | ✅ Implementado |
| `BancoDeUpgrades` — módulo de dados estático | ✅ Implementado |
| `DadosJogo.upgrades` + `comprar_upgrade()` + `obter_linha_upgrade()` | ✅ Implementado |
| PC — reduz tempo do popup de verificação (4s → instantâneo) | ✅ Implementado |
| Sincronização entre `MensagemModal` e `GerenciadorInspecao` (mesmo tempo) | ✅ Implementado (corrigido — timers estavam dessincronizados) |
| Assistente — Quantidade (linha de entrada) | ✅ Implementado |
| Assistente — Treinamento (bloqueada até Quantidade tier 1) | ✅ Implementado |
| `GerenciadorAssistente` — fila com tempo simulado + resolução automática | ✅ Implementado |
| Botão "Delegar" em `VBoxDisponiveis` (condicional, só se Assistente disponível) | ✅ Implementado (corrigido — Delegar saiu de Ativos, decisão passou a ser tomada antes de Iniciar) |
| Botão "Encerrar" em `VBoxAtivos` (equivalente ao Encerrar do popup `NovaAba`) | ✅ Implementado |
| IA — Capacidade (linha de entrada) | ✅ Implementado |
| IA — Eficiência (bloqueada até Capacidade tier 1) | ✅ Implementado |
| `GerenciadorIANoturna` — resolução overnight dos trabalhos sobrados | ✅ Implementado |
| `CalculadoraUpkeep` — upkeep diário (Assistente + IA) | ✅ Implementado |
| Desconto de upkeep no `RelatorioDia`, saldo pode ficar negativo | ✅ Implementado |
| `PainelUpgrades`/`BtnUpgrades` no Escritório | ✅ Implementado |
| Upgrade de "Precisão" pra IA (taxa de sucesso por tier) | 🔲 Não implementado — taxa da IA é fixa em 75% |
| Indicador visual de assistentes ocupados na UI | 🔲 Não implementado |
| Persistência da fila do Assistente entre sessões | 🔲 Não implementado |
| Valores de preço/upkeep balanceados por playtesting | 🔲 Pendente — valores atuais são placeholder fechados por design, não testados em jogo real |

### 3.8 HUD de Dinheiro/Fama e Trabalhos de Scareware/Ransomware (v3.5)

| Funcionalidade | Status |
|---|---|
| HUD permanente (`Scores.tscn`/`hud_manager.gd`) no Escritório | ✅ Implementado |
| `icone_dinheiro.gd` — troca de sprite da carteira por saldo | ✅ Implementado |
| HUD lendo `DadosJogo` em vez do autoload `Global` (descartado) | ✅ Implementado |
| HUD atualizando em tempo real, trabalho a trabalho | ❌ Não é o comportamento — só atualiza no fim do dia, por design (veredito diferido) |
| Capítulo "Scareware" no `ConteudoLivro.PAGINAS` (substitui "Senha Fraca") | ✅ Implementado |
| Trabalho "Identificar Scareware" em `banco_de_trabalhos.gd` | ✅ Implementado |
| Trabalho "Remover Ransomware" em `banco_de_trabalhos.gd` | ✅ Implementado |
| `quadrante`/`altura_real` calibrados em jogo (Scareware/Ransomware) | 🔲 Pendente — só estimativa por proporção da imagem |
| Conteúdo antigo de "Senha Fraca" realocado (11º capítulo) | 🔲 Não decidido — removido do array ativo, não descartado |
| Unique Names no HUD (evitar caminho relativo frágil) | 🔲 Pendente — ainda usa `$caminho` |

### 3.7 Sistema de Fama (v3.4)

| Funcionalidade | Status |
|---|---|
| `CalculadoraFama` — curva não-linear (raiz quadrada) | ✅ Implementado |
| `DadosJogo.fama_jogador` | ✅ Implementado |
| `ResultadoTrabalho.fama_ganha` + cálculo em `finalizar()` | ✅ Implementado |
| Fama do jogador manual e do Assistente (cheia, se acertar) | ✅ Implementado |
| Fama da IA reduzida pela % de Eficiência | ✅ Implementado |
| `GerenciadorExpediente.trabalhos_base_dia` + cálculo dinâmico via `CalculadoraFama` | ✅ Implementado |
| `RelatorioDia` — labels separados (`LabelResumo`/`LabelDinheiro`/`LabelFama`) | ✅ Implementado |
| `quantidade_trabalhos_iniciais` escalando com fama | 🔲 Não implementado — só o total do dia escala, quantidade inicial às 8h continua fixa |
| Indicador de fama fora do `RelatorioDia` (ex: Escritório) | 🔲 Não implementado |
| Curva balanceada por playtesting real | 🔲 Pendente — `FATOR_CRESCIMENTO` é placeholder |

---

## 5. Observações Gerais para Desenvolvimento Futuro

### Escritório
- Pode receber mais elementos interativos conforme o jogo evolui (ex: computador, telefone, documentos na mesa).
- O `Label` "Comece o dia!" na Cafeteira pode futuramente ser substituído por um sistema de diálogo ou tutorial introdutório.
- Avaliar se `Iniciar.gd` e `texture_button-Quadro.gd` devem ser unificados ou mantidos separados conforme a cena `Tela.tscn` for desenvolvida.

### Quadro de Avisos
- O conteúdo do `Layer_Tutorial_1 > TextureRect` pode ser expandido para incluir múltiplas páginas (ex: paginação com setas, como o `LivroDicas`).
- O atalho de teclado `ui_accept` (Espaço/Enter) pode ser removido ou rebatizado quando o jogo tiver um sistema de input customizado consolidado.
- Avaliar se a dupla conexão do botão (via `@export` no script geral + `@onready` no script do botão) deve ser simplificada para uma única abordagem.

### Tela de Gameplay
- `button-inspecionar.gd` é uma versão anterior do sistema de inspeção (acessa `caixa_selecao` diretamente e usa `$NovaAba` por caminho). Pode ser removido quando o `GerenciadorInspecao` estiver consolidado.
- `CaixaDeSelecao.gd` está intencionalmente vazio — toda lógica de posição/dimensão fica no `GerenciadorInspecao`. Isso é correto e deve ser mantido. **Confirmado nesta sessão:** o nó `CaixaSelecao` usa de fato esse arquivo (`res://Scripts/Tela/CaixaDeSelecao.gd`). Existe também um `caixa_selecao.gd` (minúsculo) com conteúdo diferente — captura de clique via `_unhandled_input`, redundante com `area_clique_inspecao.gd` — mas confirmado **não anexado** a nenhum nó ativo, candidato a remoção.
- `DadosJogo` (Autoload) já concentra tanto o banco de trabalhos quanto o sistema de resultados diferidos — vale manter essa centralização conforme o jogo cresce, em vez de espalhar estado em outros singletons.

### Módulo de Inspeção
- Ao implementar a variação por dificuldade, considerar gerar múltiplos `AreaAlvo` problemáticos por trabalho (o suporte a múltiplos alvos suspeitos simultâneos ainda não existe — hoje `titulo_capitulo_correto()` assume um único alvo `SUSPEITO` por trabalho e usaria o primeiro que encontrar).
- O `gerenciador_inspecao.gd` precisará receber a informação de dificuldade do trabalho atual para decidir quantos alvos problemáticos gerar.

### Livro de Ajuda
- O comentário "12 capítulos" no código sugere que mais 2 capítulos estavam planejados; vale confirmar se serão adicionados.
- Como o livro pode ser aberto quantas vezes o jogador quiser, ele funciona como uma mecânica de "consulta sem penalidade" — isso deve ser levado em conta no balanceamento de dificuldade (ex: se haverá um custo de tempo ou recompensa reduzida por consultar o livro).
- Há um pequeno erro de digitação no Capítulo 5 ("... pelo golpista **and** reporta.") — um "and" em inglês no meio do texto em português. Corrigir quando for mexer no arquivo novamente.

### Sistema de Trabalho / Diagnóstico (v3 — grid + popup unificado)
- ~~**Tela de resumo de fim de expediente ainda não existe.**~~ ✅ Resolvido na v3.2 — ver seção 3.5. `RelatorioDia.tscn` itera `DadosJogo.resultados_do_dia` e credita `dinheiro_jogador`.
- ~~**Decisão de design pendente:** hoje `marcar_trabalho_concluido()` não credita mais dinheiro nenhum durante o expediente...~~ ✅ Resolvido: o crédito acontece em `RelatorioDia.montar_relatorio()`, mantendo o resultado escondido até o fim do dia — confirmado como comportamento desejado.
- **Suporte a múltiplos alvos suspeitos por trabalho** vai exigir repensar `titulo_capitulo_correto()`/`gerar_opcoes_diagnostico()`, que hoje assumem um único alvo `SUSPEITO`.
- Vale revisar se `mensagem_modal_scpt.gd` (feedback textual "Verificando.../Alvo detectado!") deveria mudar de texto agora que achar o alvo não fecha mais o trabalho — hoje ele ainda comunica "Alvo detectado!" como se fosse um resultado final, o que pode confundir o jogador dado que o veredito de verdade só vem depois do diagnóstico e do fim do dia.
- **`painel_diagnostico.gd` está órfão** desde a migração pro popup unificado (v2/v3) — candidato a remoção junto com a próxima limpeza técnica, como os outros scripts legados já catalogados.
- **4 dos 5 trabalhos foram removidos temporariamente** de `banco_de_trabalhos.gd` por não terem arte de site calibrada pro sistema de grid. Precisam ser recriados (não só reabilitados) com `quadrante`/`altura_real` calibrados manualmente conforme a arte de cada site for produzida.
- **`area_referencia` precisa apontar pro `ImagemBase`** (`TextureRect`), não pro viewport inteiro — se ficar sem preencher no Inspetor, o grid é calculado do tamanho da janela inteira em vez do tamanho real da imagem do site, e nenhum clique bate certo com os quadrantes visuais.
- **Cuidado com `Stretch Mode` em `ImagemBase`:** se estiver configurado como `Keep Aspect` (em vez de `Scale`) e a proporção da imagem não bater exatamente com o `Control`, pode sobrar espaço vazio nas bordas (letterboxing) — o grid ficaria alinhado ao `Control`, mas visualmente desalinhado da imagem renderizada. Ainda não confirmado se isso afeta o projeto atual.

### Ciclo do Dia (v3.2 — Iniciar Dia + Relatório)
- **Trocar o caminho de string por `PackedScene`:** `Main_select_script._on_expediente_encerrado()` hoje carrega `"res://Scenes/RelatorioDia.tscn"` como string literal — já causou `Cannot open file`/`Failed loading resource` em runtime por divergência de nome/pasta. Recomendação: `@export var cena_relatorio: PackedScene`, arrastando a cena no Inspetor, elimina esse risco porque o Godot atualiza a referência sozinho se o arquivo for movido/renomeado. O mesmo vale considerar pro `Iniciar.gd` (`"res://Scenes/Tela.tscn"`) e pro `BtnVoltar` de `RelatorioDia` (`"res://Scenes/Escritorio.tscn"`), embora esses dois ainda não tenham dado erro na prática.
- **`relatorio_dia.gd` usa `get_node_or_null()` em vez de `$caminho`** de propósito — qualquer nó da estrutura (`LabelResumo`, `ScrollContainer/VBoxResultados`, `BtnVoltar`) que estiver com nome errado gera um `push_warning()` específico dizendo qual falta, em vez de um erro fatal que impede a cena inteira de carregar. Vale manter esse padrão em outras cenas que ainda usam `$caminho` direto, especialmente as que dependem de estrutura montada manualmente no editor (mais propensas a divergir do que o script espera).
- **Nenhuma tela de "Dia X" ou histórico entre dias existe ainda** — `RelatorioDia` mostra só o dia que acabou de terminar; não há registro persistente de dias anteriores. Se o design quiser progressão entre dias (ex: múltiplos dias de expediente, não só um loop único), isso ainda precisa ser desenhado.
- **`TrabalhoAgendado.investigar_usado` não é resetado entre dias** — como `trabalhos_do_dia` é recriado do zero a cada `sortear_agenda_do_dia()` (novos objetos `TrabalhoAgendado.new()`), isso não chega a ser um bug hoje, mas vale ter em mente se algum dia `TrabalhoAgendado` passar a persistir entre dias (ex: trabalhos recorrentes).
- **Testar o fluxo completo com duração real reduzida** — pra validar o relatório sem esperar ~2min15s por rodada de teste, considerar aumentar temporariamente `minutos_por_segundo_real` no Inspetor do `GerenciadorExpediente` (ex: `20.0` → dia inteiro em ~27s), sem precisar mexer em código.

### Sistema de Upgrades (v3.3 — PC, Assistente, IA)
- **Valores de preço/upkeep/efeito são placeholder** — fechados por rodadas de design conversado, nunca testados em jogo real com uma economia funcionando de ponta a ponta (poucos trabalhos calibrados no `banco_de_trabalhos.gd` hoje). Provável que precisem de ajuste depois que houver mais trabalhos e alguns dias de playtesting real.
- **Taxa de sucesso da IA é fixa (75%)** — cogitada uma linha de "Precisão" pra IA no design, mas descartada por ora. Se quiser adicionar depois, o padrão já está pronto: seria só uma 3ª linha em `banco_de_upgrades.gd` com `chave_pre_requisito = CHAVE_IA_CAPACIDADE`, e `gerenciador_ia_noturna.gd` passaria a ler a taxa de `DadosJogo.obter_linha_upgrade()` em vez da constante `TAXA_SUCESSO_IA`.
- **Sem indicador de "assistentes ocupados agora" na UI** — o jogador só descobre que delegar funcionou pelo botão virar "Delegado..." e pelo toast quando termina; não há um contador visual tipo "2/3 ocupados" em lugar nenhum.
- **Resultados da IA não têm destaque visual no `RelatorioDia`** — aparecem misturados com os do jogador/Assistente, diferenciados só pelo texto no campo Diagnóstico ("Resolvido pela IA (noturno)"). Pode confundir se o jogador não ler com atenção; um ícone ou cor diferenciando a origem do resultado (jogador/Assistente/IA) ajudaria.
- **Fila do Assistente não persiste entre sessões** — se o jogo fechar com trabalhos ainda na fila (`_fila_espera`/`_em_andamento` de `gerenciador_assistente.gd`), esse estado se perde. Mesma categoria de limitação que já existe hoje pra `resultados_pendentes` em geral (nada no projeto persiste em disco ainda).
- **`chave_pre_requisito` foi invertida uma vez em runtime** (Assistente — ver seção 3.6) — episódio serviu de validação de que a arquitetura genérica de pré-requisito (`DadosJogo.comprar_upgrade()`/`painel_upgrades.gd` lendo só a string, sem hardcode de qual linha é qual) realmente permite esse tipo de ajuste tardio sem quebrar nada. Vale lembrar desse padrão se mais inversões de design surgirem depois de implementado.

### Sistema de Fama (v3.4)
- **`FATOR_CRESCIMENTO` (`calculadora_fama.gd`) é placeholder** — a curva de raiz quadrada foi escolhida pela forma (retornos decrescentes naturais), mas o fator `1.0` nunca foi testado em jogo real ao longo de vários dias seguidos. Se a progressão de trabalhos/dia parecer rápida ou lenta demais na prática, é o único número que precisa mudar — nenhum outro arquivo depende do valor exato.
- **`quantidade_trabalhos_iniciais` não escala com fama** — só `trabalhos_base_dia` (o total do dia) passa pela curva de `CalculadoraFama`. Quantos trabalhos já aparecem prontos às 8h continua fixo. Se, na prática, os trabalhos extras de fama alta demorarem demais pra aparecer ao longo do dia (poucos no início, muitos "sobrando" pro fim), pode valer revisitar essa proporção.
- **Sem indicador de fama fora do `RelatorioDia`** — mesmo padrão de observação já feito pro dinheiro/upgrades: não há nenhum lugar (Escritório, HUD) mostrando `fama_jogador` fora do momento em que o relatório do dia é exibido.
- **Assistente sempre entrega fama cheia, IA sempre reduzida** — decisão implícita do design (Assistente não tem upgrade de "qualidade" que afete fama, só a IA tem Eficiência). Vale confirmar se isso é intencional a longo prazo ou se o Assistente também deveria ter alguma penalidade de fama em caso de erro (hoje: erro do Assistente = 0 fama e 0 dinheiro, igual já era antes da fama existir).
