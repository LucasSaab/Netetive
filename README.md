# Netetive — Documentação do Projeto

> Jogo educativo de cibersegurança em Godot 4, inspirado em *Papers, Please*. O jogador assume o papel de alguém que precisa identificar ameaças digitais (phishing, sites maliciosos, perfis falsos etc.) durante o expediente de trabalho.
>
> **Última atualização deste documento:** 21/11/2026

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
   - [3.8 Grid M×N e Múltiplos Alvos Suspeitos](#38-grid-mn-e-múltiplos-alvos-suspeitos)
   - [3.9 Sistema de Áudio: Música de Fundo e Efeitos Sonoros](#39-sistema-de-áudio-música-de-fundo-e-efeitos-sonoros)
   - [3.10 Sistema de Modificadores de Dificuldade e Cursor Virtual](#310-sistema-de-modificadores-de-dificuldade-e-cursor-virtual)
   - [3.11 HUD de Dinheiro/Fama](#311-hud-de-dinheirofama)
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

> **Ordem de desenho (v4.3):** `abrir()` chama `move_to_front()` antes do `show()`. Sem isso, o `BtnLivro` (que vem depois do painel na árvore) era desenhado por cima do painel aberto. Qualquer nó novo adicionado ao Escritório depois do painel teria o mesmo problema.

#### `BtnLivro` — `TextureButton` (v4.2, novo)
**Script:** `btn_abrir_livro.gd`

Livro fechado sobre a mesa. Ao clicar, abre o `LivroDicas` pelo grupo `livro_dicas` (sem referência no Inspetor), permitindo consultar o manual **antes do expediente**, sem pressão de tempo. O hover clareia o sprite. Arte do sprite ainda pendente.

#### `LivroDicas` — instância de `LivroDicas.tscn` (v4.2, novo)

Cena reutilizável do livro (`CanvasLayer`, layer 10), a mesma instanciada na `Tela.tscn` — ver seção [3.3](#33-livro-de-ajuda-livrodicas). Começa oculta.

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

```gdscript
extends TextureButton

@onready var layer_tutorial: CanvasLayer = $"../Layer_Tutorial_1"

func _on_pressed() -> void:
	if layer_tutorial != null:
		layer_tutorial.show()
```

#### `Layer_Tutorial_1` — `CanvasLayer`
Camada de sobreposição que exibe o conteúdo do tutorial por cima da cena. Começa **oculto** e é exibido apenas quando o jogador interage.

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

A cena **Tela** (`res://Scenes/Tela.tscn`) é onde o loop principal de gameplay ocorre. O jogador visualiza um site suspeito na tela do computador e interage com ele para identificar problemas de segurança.

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

Post-its clicáveis com tarefas aleatórias, substituídos pelo sistema de expedição.

#### Sistema do Livro de Dicas (acesso)

*(conteúdo detalhado na seção [3.3](#33-livro-de-ajuda-livrodicas))*

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

> ⚠️ A descrição original (`Alvo1`/`Alvo2`/`Alvo3` fixos) foi substituída pelo sistema de grid dinâmico (`AlvoInspecao`/`TrabalhoInspecao`/`AreaAlvo`), documentado na seção [3.4](#34-sistema-de-trabalho-diagnóstico-e-veredito-diferido).

---

### 3.3 Livro de Ajuda (LivroDicas)

Manual de consulta sobre os problemas de segurança, redesenhado na **v4.2** no estilo do livro de regras de *Papers, Please* (paleta própria, azul-acinzentada). É uma **cena reutilizável** (`LivroDicas.tscn`, raiz `CanvasLayer`, layer 10) usada em dois momentos:

- **Escritório** (antes do expediente): pelo livro fechado sobre a mesa (`BtnLivro`).
- **Tela** (durante o expediente): pelo `BtnAbrirLivro`.

Ambos usam `btn_abrir_livro.gd`, que acha o livro pelo grupo `livro_dicas`. O jogador abre e fecha **quantas vezes quiser, sem penalidade** (custo de consulta continua indefinido; os sinais `aberto`/`fechado` são o gancho).

#### Estrutura do conteúdo

3 níveis: **capítulo → subcapítulo → partes** (Reconhecer / Proteger). São **10 capítulos e 34 subcapítulos** (`ConteudoLivro.CAPITULOS`): Golpes por Mensagem, Fraudes Financeiras, Identidade Falsa, Sites e Downloads Maliciosos, Malware, Engenharia Social, Segurança Física, Contas e Acesso, Sistemas e Redes, Privacidade e Dados. Tabela completa no `netetive_changelog.md` (v4.2).

O **diagnóstico acontece no nível do capítulo** (o jogador não erra por confundir Phishing com Smishing — ambos são "Golpes por Mensagem"); o subcapítulo é o detalhe ensinado no livro e na dica. `DadosJogo` lê `ConteudoLivro.CAPITULOS` por auxiliares estáticos (`total_capitulos()`, `titulo_capitulo()`, `titulos_capitulos()`); `PAGINAS` foi removido.

#### Navegação (duas páginas)

| Estado | Esquerda | Direita |
|---|---|---|
| Índice | Capa (escudo com cadeado, pintada no fundo) | Lista dos 10 capítulos |
| Subcapítulos | Lista dos subcapítulos | Resumo do capítulo |
| Texto | Lista dos subcapítulos | Texto do subcapítulo (aba Reconhecer ou Proteger) |

Abas laterais **Índice / Reconhecer / Proteger** (um único sprite; a aba atual fica na cor cheia e as outras escurecidas — **sem deslocamento**, removido na v4.3). **Clique direito** volta um nível e fecha o livro quando já está no índice. A API `abrir_em(capitulo, sub, aba)` deixa a dica do Investigar abrir o livro direto no tópico certo (ainda não ligada).

#### Integração técnica

- Registra-se nos grupos `popups` (o cursor virtual devolve o cursor nativo enquanto o livro está aberto — `CanvasLayer.visible` é o que `esta_com_popup_aberto()` lê) e `livro_dicas`.
- Camada 10: acima do `CanvasLayer` da Tela, abaixo do cursor virtual (4096).
- A `Raiz` (`Control`, Full Rect, `mouse_filter = Stop`) impede cliques atravessando o livro; por isso o clique direito é tratado em `_input`.
- O nó `Livro` é escalado 2× sobre uma arte de 480×320; fonte em `TAMANHO_FONTE = 11` (valor que ficou legível em jogo) e `texture_filter = Nearest`.

#### Ajustes visuais da v4.3

- **Botões de capítulo/subcapítulo:** `SIZE_EXPAND_FILL` + `autowrap_mode = WORD_SMART` + `clip_text`, com margens verticais de 1 px e `separation = 2` nas listas. Antes (`SHRINK_BEGIN`) cada botão crescia até caber o texto inteiro e vazava da página. `VBoxIndice`/`VBoxSubcapitulos` precisam de uma **largura definida** no Inspetor para o `EXPAND_FILL` ter limite.
- **Abas — texto:** o rótulo (`Label`) de cada aba é girado 90° em torno do próprio centro, com a caixa do tamanho da aba (comprimento = altura, espessura = largura). A fonte desce até o maior tamanho (máx. `TAMANHO_FONTE`) em que o texto cabe, então as três abas ficam iguais.
- **Abas — corte:** `_trazer_aba_para_frente()` chama `move_to_front()`, `z_index = 10` e desliga `clip_contents` em todos os `Control` pais. A causa do corte era um irmão desenhado depois da aba e/ou um pai com *Clip Contents* ligado.

> **Status:** abas e botões corrigidos na v4.3 (confirmado por print); abertura nas duas cenas, clique direito e convivência com o cursor virtual seguem sem validação completa (ver `netetive_status.md`).

---

### 3.4 Sistema de Trabalho, Diagnóstico e Veredito Diferido

Arquitetura atual (v3.1) do loop de trabalho. Todo o ciclo — inspecionar, diagnosticar, ignorar, encerrar — acontece dentro de um único popup contextual (`NovaAba`).

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

**Regra de acerto combinado:** achar o alvo suspeito **e** escolher a categoria certa no diagnóstico.

#### Sistema de grid

Grade de M colunas × N linhas (mínimo 3×3), configurável por trabalho (`TrabalhoInspecao.linhas_grid`/`colunas_grid`). Quadrantes de tamanho uniforme (sem compensação adaptativa desde a v3.5). Ver seção [3.8](#38-grid-mn-e-múltiplos-alvos-suspeitos).

#### Botão Investigar

5º botão da `NovaAba`, dá uma dica textual limitada (1 uso por trabalho) via `AlvoInspecao.dica`.

#### Módulo de dados separado — `banco_de_trabalhos.gd`

Definição estática dos trabalhos, extraída de `DadosJogo.gd` — que cuida só de estado em runtime.

##### Trabalhos (v4.3: 11, um por capítulo)

Os capítulos 0, 1, 2, 5, 6, 7, 8 e 9 do livro não tinham nenhum trabalho; a v4.3 adiciona um para cada. Todos usam o grid **3 colunas × 5 linhas** (exceto Ransomware, 3×3), com 1 alvo suspeito, e o índice do quadrante é `linha * 3 + coluna`.

| Trabalho | Cap. | Subcapítulo | Quadrante(s) | Elemento suspeito | Recompensa base |
|---|---|---|---|---|---|
| Site duvidoso | 3 | Site Malicioso | `[0]` | Endereço do site | 150 |
| Alerta estranho | 3 | Scareware | `[7, 10]` | Botão verde de download | 150 |
| Remover Ransomware | 4 | Ransomware | `[4]` (grid 3×3) | Botão "COMO PAGAR" | 200 |
| Encomenda retida | 0 | Smishing | `[7]` | Link na mensagem de celular | 150 |
| Boleto estranho | 1 | Pix/boleto falso | `[3]` | Nome do beneficiário | 200 |
| Login clonado | 2 | Typosquatting | `[1]` | Endereço com letra trocada | 150 |
| Pendrive esquecido | 5 | Baiting | `[11]` | Pendrive com etiqueta de dinheiro | 150 |
| Mesa sem dono | 6 | Tela desbloqueada | `[5]` | Post-it ao lado do monitor | 150 |
| Cadastro frágil | 7 | Senha fraca | `[10]` | Campo de senha aceito com barra de força vazia | 150 |
| Café com Wi-Fi | 8 | Wi-Fi público | `[6]` | Rede aberta com sinal máximo | 200 |
| Foto de primeiro dia | 9 | Oversharing | `[5, 10]` | Monitor ao fundo e crachá | 150 |

- **Arte:** as 8 imagens novas são geradas no Gemini com prompts que pedem o mínimo de texto (barras cinzas no lugar de palavras; só o boleto e o endereço do login mantêm uma linha curta, porque o erro é o próprio texto). Formato final: **480×320 (3:2), PNG**, em `res://Sprites/Trabalhos/` com nomes em minúsculas e `_` (`encomenda_retida.png`, `boleto_estranho.png`, ...). Na geração saíram em tamanhos variados (1264×848, 1024×687 e 1376×768) e em JPG, então precisam ser recortados/reduzidos e convertidos.
- **Carregamento:** os 8 sprites novos usam `_carregar_imagem()` (`ResourceLoader.exists()` + `load()`), que avisa no Output com o caminho exato em vez de quebrar o script, como o `preload()` fazia. Os 3 trabalhos antigos continuam com `preload`.
- **Helper `_montar()`:** monta um trabalho de 1 alvo a partir de título, descrição, recompensa, imagem, quadrantes, capítulo e dica.
- **Quadrantes:** foram calculados a partir dos prompts, não conferidos nas imagens finais. Conferir traçando 3×5 em cada imagem e ajustar o número em `_montar(...)` se o elemento caiu em outra célula.
- **Diagnóstico por capítulo:** o título e a descrição de cada trabalho evitam termos como "phishing" ou "golpe" para não vazar a resposta, e cada um aponta para um único capítulo.

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

5 linhas em 3 categorias (PC, Assistente-Quantidade/Treinamento, IA-Capacidade/Eficiência), cada uma com 4 tiers sequenciais. `DadosJogo.comprar_upgrade()` é a única porta de entrada pra avançar um tier.

---

### 3.7 Sistema de Fama

Recurso permanente, paralelo ao dinheiro, que controla a quantidade de trabalhos que aparecem por dia (`CalculadoraFama`, curva de raiz quadrada) **e**, desde a v4.0, também gate a de quais tiers de modificadores de dificuldade podem aparecer nos trabalhos (ver seção [3.10](#310-sistema-de-modificadores-de-dificuldade-e-cursor-virtual)).

---

### 3.8 Grid M×N e Múltiplos Alvos Suspeitos

Colunas configuráveis por trabalho (`colunas_grid`), quadrantes uniformes (sem compensação adaptativa), `AlvoInspecao.quadrantes: Array[int]` permitindo um alvo cobrir vários quadrantes, e múltiplos alvos `SUSPEITO` por trabalho desde que compartilhem o mesmo capítulo.

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

---

### 3.10 Sistema de Modificadores de Dificuldade e Cursor Virtual

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

> **Nota v4.1:** a implementação do Labirinto descrita abaixo (geração, colisão, revelação por proximidade) foi documentada já na v4.0, mas só foi de fato persistida nos arquivos reais do projeto nesta rodada — até então o modificador não tinha nenhum efeito de jogo (não entrava nem no sorteio). Ver `netetive_changelog.md` v4.1 e `netetive_scripts.md` pras notas completas sobre o que foi corrigido.

#### Estrutura em tiers

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

Cada trabalho sorteado no dia (`DadosJogo.sortear_agenda_do_dia()`) rola aleatoriamente a quantidade (0 até o teto permitido), escolhe tipos sem repetir, e sorteia um nível pra cada um. O teto de nível também cresce com o tier desbloqueado:

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

**T3 tem uma regra especial:** só 1 dos 3 modificadores de T3 pode aparecer por trabalho (Caos, Travamento, Labirinto competem pelo mesmo slot).

#### `ModificadorAtivo` (Resource-like, `RefCounted`)

```gdscript
static func calcular_total() -> int:
	return _upkeep_assistente() + _upkeep_ia_capacidade() + _upkeep_ia_eficiencia()

static func _upkeep_assistente() -> int:
	# upkeep_atual(Treinamento) × quantidade de assistentes (linha Quantidade)
	# Treinamento tier 0 (não comprado) = upkeep 0, mesmo com Quantidade comprada
	...
```
`relatorio_dia.gd.montar_relatorio()` desconta esse total **antes** de creditar: `DadosJogo.dinheiro_jogador += total_dinheiro - upkeep_total` — pode deixar o saldo **negativo de propósito** (dívida realista, decisão de design confirmada com o usuário). O resumo no `LabelResumo` mostra os três números separados: ganhos do dia, manutenção descontada, saldo final.

enum Tipo {
	DESCONHECIDO, CONEXAO_LENTA, MAIS_OPCOES, ARMADILHA, MOUSE_GRANDE,
	AO_CONTRARIO, MISDIRECAO, TEMPO_LIMITADO, COPIAS, CAOS, LABIRINTO,
	MOUSE_RAPIDO, TRAVAMENTO,
}

var tipo: Tipo
var nivel: int = 1
var sub_modificadores: Array[ModificadorAtivo] = []   # só usado por CAOS
```

#### Os 13 modificadores

| Modificador | Tier | Efeito |
|---|---|---|
| **Desconhecido** | T1 | O cartão em Disponíveis mostra só "???" no título e "R$ ???" na recompensa, sem descrição — uma vez aceito, o cartão em Ativos mostra tudo normalmente |
| **Conexão Lenta** | T1 | `+0.5s × nível` no tempo de verificação, somado ao efeito do upgrade PC (nunca substitui) |
| **Mais Opções** | T1 | `+1 opção × nível` no popup de diagnóstico (base 3, teto 6) |
| **Armadilha** | T1 | `nível` quadrantes-armadilha sorteados entre os neutros (nunca o suspeito); inspecionar um deles trava o cursor por 1s |
| **Mouse Grande** | T1 | Cursor cresce `+100% × nível`; ponto de clique sempre na ponta superior-esquerda do sprite, nunca no centro |
| **Ao Contrário** | T1 (nível único) | `site_textura.flip_h = true` + índices de quadrante espelhados na mesma direção, pra o alvo suspeito continuar batendo com o ponto certo na imagem invertida |
| **Misdireção** | T2 | `nível` quadrantes-chamariz — neutros que fingem acerto visual no `MensagemModal`, mas nunca contam como erro extra pro jogador |
| **Tempo Limitado** | T2 | Prazo de `6h / nível` a partir do aceite; se expirar sem diagnóstico feito, fecha automaticamente como erro; **nunca** volta pra Disponíveis se o jogador trocar de trabalho no meio — fecha direto como interrompido |
| **Cópias** | T2 | `nível` cursores falsos opacos, puramente visuais (sem colisão de clique), com passeio aleatório próprio |
| **Mouse Rápido** | T2 | Surtos periódicos (6–10s, duram 2s) de velocidade `×(1 + 0.35×nível)` |
| **Caos** | T3 | Injeta 3 modificadores aleatórios de T1/T2 (exceto Desconhecido) em nível 1 — conta como 1 slot só pro teto de quantidade |
| **Travamento** | T3 | Mesmo sistema de surto do Mouse Rápido, mas com multiplicador `0.0` (congelamento total) |
| **Labirinto** | T3 | Ver subseção própria abaixo |

*(Confusão foi cogitado e chegou a ser implementado nesta mesma janela de desenvolvimento, mas foi removido do jogo antes de ser lançado — substituído por Travamento no slot de T3.)*

**Bônus de recompensa:** taxa fixa por tier × nível (T1 = 3%, T2 = 5%, T3 = 20%) + bônus de combo (`+5%` por modificador além do primeiro), aplicado tanto no dinheiro quanto na fama ganha, sem teto máximo.

#### `CalculadoraModificadores` (novo, `static func`, sem nó)

Centraliza sorteio, tetos de nível/quantidade e cálculo de bônus — mesmo padrão de `CalculadoraFama`/`CalculadoraUpkeep`. Todas as constantes (taxas, limiares de fama, magnitudes por nível) isoladas no topo do arquivo pra calibrar sem tocar em mais nada.

#### Labirinto — o modificador mais complexo do sistema

O único modificador que restringe **fisicamente** o movimento do cursor, não só velocidade/visual.

**Geração (`gerador_labirinto.gd`, novo):** recursive backtracker (busca em profundidade randomizada) — garante uma árvore geradora sobre o grid de quadrantes, ou seja, conectividade total: sempre existe exatamente 1 caminho entre dois quadrantes quaisquer. A regra "todo quadrante mantém pelo menos 1 lado bloqueado dos disponíveis" é aplicada como **preferência**, nunca como veto — se a única forma de conectar um quadrante de canto (que só tem 2 lados possíveis) exigir abrir os dois, isso é permitido; conectividade total nunca é sacrificada pela estética.

**Colisão de movimento (`GerenciadorInspecao.restringir_movimento_labirinto()`):** processa eixo X e depois eixo Y separadamente — se o destino desejado ainda está dentro da célula atual naquele eixo, libera direto; se cruzaria pra célula vizinha, checa se o lado correspondente está bloqueado antes de permitir, senão trava exatamente na fronteira (com uma pequena margem de segurança contra ambiguidade de arredondamento). Isso permite "deslizar" ao longo de uma parede quando só um dos dois eixos está bloqueado, em vez de travar o movimento inteiro.

**Revelação por proximidade (`desenho_labirinto.gd`, novo):** as paredes bloqueadas só ficam visíveis (com fade suave) dentro de um raio de distância do cursor — o jogador nunca vê o labirinto inteiro de antemão, só descobre as paredes conforme se aproxima delas.

#### `GerenciadorCursorVirtual` (novo Autoload)

Necessário porque vários modificadores (Mouse Grande, Cópias, Mouse Rápido, Travamento, Labirinto) exigem controle sobre o cursor que o sistema operacional não entrega nativamente. Funciona em dois modos:

```
COSMÉTICO (padrão, sempre ativo em qualquer cena — Escritório, Quadro,
           Tela, RelatorioDia)
  → Input.mouse_mode = HIDDEN
  → sprite segue get_viewport().get_mouse_position() 1:1
  → nunca prende o cursor na janela

CAPTURA (só quando o trabalho aberto tem Mouse Rápido, Travamento ou
         Labirinto)
  → Input.mouse_mode = CONFINED_HIDDEN
  → sprite segue posicao_logica, acumulada por delta de movimento
  → Input.warp_mouse() realinha o cursor real do SO sempre que a
    posição lógica precisa ser corrigida (velocidade alterada, ou
    parede do labirinto bloqueando)
```

> ⚠️ **Nota técnica:** o modo certo é `CONFINED_HIDDEN`, não `CAPTURED`. `CAPTURED` existe pra câmeras estilo FPS e trava a posição *reportada* no centro da tela, entregando só deltas relativos — usar ele aqui causava um bug real onde a posição lógica era corrompida de volta pro centro toda vez que um popup fechava (porque a resincronização lia essa posição travada, não a real). `CONFINED_HIDDEN` esconde e confina o cursor sem esse problema.

**Pausa automática durante popups:** checagem tree-wide via `GerenciadorInspecao.esta_com_popup_aberto()` (olha `NovaAba`, `MensagemModal`, e qualquer nó no grupo `"popups"` — o `ConfirmationDialog` de encerramento precisa ser adicionado manualmente a esse grupo em `coordenador_trabalho.gd._ready()`, senão o cursor continua capturado por baixo do diálogo e o jogador não consegue clicar OK/Cancel).

**Ponto de clique sempre na ponta:** `sprite_cursor.centered = false` faz o canto superior-esquerdo da textura corresponder à posição de clique real — importante pro Mouse Grande crescer sem desalinhar onde o clique realmente acontece.

#### `BadgeModificador.tscn` (novo, cena própria)

Ícone do modificador (`TextureRect`, `Expand Mode = Ignore Size` — crítico, sem isso a resolução nativa do PNG vira o tamanho mínimo do badge inteiro) + número do nível sobreposto no canto inferior-direito (`Label`, sem moldura), com tooltip mostrando o nome completo. Precisou virar cena própria depois de repetidas tentativas de montar tudo dinamicamente em código — o `size_flags` padrão de um `Control` novo faz ele esticar pra preencher o `HBoxContainer` inteiro se não for travado explicitamente pra `SIZE_SHRINK_CENTER`.

```gdscript
# badge_modificador.gd — chamado ANTES do nó entrar na árvore
# (logo após instantiate(), sem add_child() ainda), então usa
# get_node() em vez de @onready (que só resolve em _ready(),
# disparado só quando o nó entra na SceneTree de verdade).
func configurar(mod: ModificadorAtivo) -> void:
	var icone := get_node_or_null("Icone") as TextureRect
	icone.texture = load(mod.caminho_icone())
	...
```

Um **HUD de Prazo** (v4.1, novo) complementa o Tempo Limitado: uma caixinha fixa no canto superior direito da tela (`VBoxPrazosHud`, fora do menu de Disponíveis/Ativos), com contagem regressiva ao vivo por trabalho ativo, usando o `StyleBox` do tema do jogo. Fica visível mesmo com o menu fechado, e muda de laranja pra vermelho quando falta 1h ou menos.

Ver `netetive_scripts.md` (apêndice v4.1) pro código completo de todos os arquivos citados nesta seção.

---

### 3.11 HUD de Dinheiro/Fama

HUD permanente no Escritório (`Scores.tscn`, nó `Score`), mostrando o total acumulado de `dinheiro_jogador` e `fama_jogador`. Diferente do `RelatorioDia`, que mostra só o que foi ganho no dia.

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

- **Polling:** `hud_manager.gd` lê `DadosJogo.dinheiro_jogador`/`fama_jogador` em `_process()` e só atualiza o texto quando o valor muda. `DadosJogo` não emite sinal para esses campos, e criar um alteraria um arquivo já estabilizado.
- **Atualização só no fim do dia:** o crédito de dinheiro e fama só acontece em `RelatorioDia.montar_relatorio()`, então o HUD fica parado durante o expediente e salta ao fechar o relatório. É intencional (preserva o veredito escondido até o fim do dia).
- **`icone_dinheiro.gd`:** troca o sprite da carteira (vazia/cheia) conforme o saldo seja positivo.
- **Sem autoload `Global`:** o autoload da branch `score_system` (`money`/`fame` próprios) foi descartado, para não duplicar a fonte de verdade de `DadosJogo`.
- **Pendente:** trocar os `@onready` por caminho relativo (`$control/...`) por Unique Names (`%contador_dinheiro`/`%contador_fama`), evitando o erro `Node not found` se a hierarquia mudar.

---

## 4. Estado Geral do Projeto

### 1. Escritório

| Funcionalidade | Status |
|---|---|
| Fundo visual do escritório | ✅ Implementado |
| Quadro de avisos interativo | ✅ Implementado |
| Transição para loop de gameplay | ✅ Implementado |
| Cafeteira com texto de boas-vindas | ✅ Implementado |
| Sistema de Upgrades (`BtnUpgrades`/`PainelUpgrades`) | ✅ Implementado |
| Livro fechado clicável (`BtnLivro`) + instância do `LivroDicas` | 🟡 Instância abre o livro (print); arte do livro fechado pendente |
| `PainelUpgrades` desenhado acima do `BtnLivro` (`move_to_front()`) | 🟡 Corrigido na v4.3; confirmar em jogo |
| HUD de dinheiro/fama (`Score`) | ✅ Implementado |
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

### 3.1–3.9 Tela de Gameplay

| Funcionalidade | Status |
|---|---|
| Sistema de expedição, menu de trabalhos, grid dinâmico, diagnóstico, veredito diferido | ✅ Implementado (ver detalhes em `netetive_status.md`) |
| Ciclo do dia completo (Escritório → expediente → relatório → Escritório) | ✅ Implementado |
| Sistema de Upgrades (PC/Assistente/IA) | ✅ Implementado |
| Sistema de Fama | ✅ Implementado |
| Grid M×N + múltiplos alvos suspeitos | ✅ Implementado |
| Sistema de Áudio | ✅ Implementado |
| Livro de Dicas redesenhado (`LivroDicas.tscn`, 10 capítulos / 34 subcapítulos, `CAPITULOS`) | 🟡 Código entregue (v4.2); validação em jogo incompleta |
| Diagnóstico lendo `CAPITULOS` (`PAGINAS` removido) | 🟡 Não validado em jogo |
| Livro: botões dentro da página, abas com texto igual e sem corte, sem deslocamento da aba ativa | ✅ Corrigido (v4.3, confirmado por print) |
| 8 trabalhos novos em `banco_de_trabalhos.gd` (caps 0, 1, 2, 5, 6, 7, 8, 9) | 🟡 Código entregue; imagens finais e quadrantes ainda não conferidos em jogo |
| Imagens dos 8 trabalhos novos (480×320 PNG em `Sprites/Trabalhos/`) | 🔲 Geradas no Gemini; falta recortar, converter, renomear e conferir o grid |
| Segundo trabalho nos capítulos 0, 3 e 4 (Vishing, QR Code, Cavalo de Tróia) | 🔲 Opcional, não iniciado |

### 3.10 Sistema de Modificadores de Dificuldade e Cursor Virtual (v4.1)

| Funcionalidade | Status |
|---|---|
| Estrutura de tiers (T1/T2/T3) desbloqueada por fama | ✅ Implementado |
| Sorteio de modificadores por trabalho (`CalculadoraModificadores`) | ✅ Implementado |
| Bônus de recompensa (dinheiro e fama) por tier/nível + combo | ✅ Implementado |
| Desconhecido, Conexão Lenta, Mais Opções, Armadilha, Ao Contrário, Misdireção | ✅ Implementado |
| Tempo Limitado (prazo + fechamento automático/por interrupção) | ✅ Implementado |
| Mouse Grande, Cópias, Mouse Rápido, Travamento (cursor virtual) | ✅ Implementado |
| Caos (injeção de sub-modificadores) | ✅ Implementado |
| Labirinto (geração + colisão + revelação por proximidade) | ✅ Implementado de fato na v4.1 — documentado desde a v4.0, mas sem efeito de jogo até esta rodada |
| Confusão | 🗑️ Implementado e depois removido — substituído por Travamento |
| Badges visuais (ícone + nível) nos cartões | ✅ Implementado (`BadgeModificador.tscn`) |
| `GerenciadorCursorVirtual` (Autoload, cosmético + captura) | ✅ Implementado, incluindo pausa correta (`VISIBLE`) durante popups (v4.1) |
| HUD de Prazo (contagem regressiva do Tempo Limitado, canto superior direito) | ✅ Implementado (v4.1) |
| Ícone dedicado pro Travamento | ✅ Implementado (v4.1, `travamento.png`) |
| Combinações entre modificadores testadas em playtesting real | 🔲 Pendente — agora que o Labirinto funciona de verdade, é a prioridade da próxima rodada |
| Calibração de taxas/limiares/magnitudes por playtesting | 🔲 Pendente — valores atuais são placeholders de design |

---

## 5. Observações Gerais para Desenvolvimento Futuro

### Escritório
- Pode receber mais elementos interativos conforme o jogo evolui.
- Avaliar se `Iniciar.gd` e `texture_button-Quadro.gd` devem ser unificados.

### Quadro de Avisos
- Conteúdo do tutorial pode ser expandido pra múltiplas páginas.
- **Tutorial planejado (ainda não implementado):** páginas só de imagem, com texto desenhado na própria arte (etiquetas sobre o print do Escritório, como "Comece o dia!" e "Leia o guia"), mais várias telas de gameplay (loop básico, Investigar, Ignorar e Livro de Dicas). Sempre revisável no Quadro e também acessível por uma tela inicial, que ainda será construída.

### Tela de Gameplay
- `DadosJogo` (Autoload) já concentra banco de trabalhos e resultados diferidos — manter essa centralização conforme o jogo cresce.

### Trabalhos (v4.3)
- **`preload()` quebra o projeto inteiro se o arquivo não existir ou não foi importado.** Por isso os 8 trabalhos novos usam `_carregar_imagem()`. Se o Output mostrar "imagem não encontrada", confira pasta, nome (minúsculas, sem espaço nem acento, o Godot diferencia maiúsculas), extensão real do arquivo (renomear `.jpg` para `.png` não converte) e se o import terminou.
- **Todas as imagens do mesmo tamanho:** a imagem é esticada na área de inspeção e o grid assume 3:2. A foto de primeiro dia saiu em 16:9 (1376×768) e precisa de recorte para 3:2 mantendo crachá e monitor dentro do quadro.
- **Elementos pequenos:** em 480×320 cada célula tem 160×64 px; pendrive e post-it precisam ficar inteiros dentro de uma única célula.
- **Ransomware é o único em 3×3.** Padronizar em 3×5 exigiria recalibrar o quadrante e a arte.
- **Recompensas:** 150 para a maioria; 200 para Ransomware, Boleto estranho e Café com Wi-Fi (mais difíceis). Placeholder, como o resto da calibração.

### Livro de Ajuda (v4.2)
- **Cena reutilizável:** `LivroDicas.tscn` é instanciada em `Escritorio.tscn` e `Tela.tscn`; o script `livro_dicas.gd` só pode ficar anexado ao nó raiz (`CanvasLayer`) — anexá-lo a um botão gera o erro "Script inherits from native type 'CanvasLayer'". Botões usam `btn_abrir_livro.gd`.
- **Diagnóstico no nível do capítulo:** "Site duvidoso" e "Alerta estranho" (Scareware) agora compartilham a mesma resposta correta (Sites e Downloads Maliciosos). Se a distinção importar no diagnóstico, avaliar o diagnóstico em dois passos (capítulo + subcapítulo) como evolução futura; o campo `subcapitulo_relacionado` em `AlvoInspecao` deixaria o caminho preparado.
- **Mais Opções:** com 10 capítulos o teto de 6 opções continua válido; se os capítulos forem reduzidos de novo, limitar o teto ao número de capítulos.
- **Textos:** 24 dos 34 subcapítulos têm texto novo e curto — revisar tom e conteúdo.
- **Custo de consulta ao livro** ainda não definido — decisão consciente de deixar pra depois (ganchos: sinais `aberto`/`fechado`).
- **Abas (v4.3):** a ordem de desenho e o `clip_contents` dos pais foram a causa do corte; se uma aba nova for adicionada ao livro, passe por `_trazer_aba_para_frente()` e `_ajustar_rotulo_aba()`. O sprite da aba ainda está na lista de arte pendente (Piskel, 20×68).
- **Se o livro virar Autoload no futuro:** hoje cada cena tem sua instância, então o estado (capítulo aberto) não persiste entre Escritório e Tela; Autoload existiria em todas as cenas (Quadro, Relatório).

### Sistema de Modificadores (v4.1)
- **Combinações não testadas** — Cópias + Labirinto, Mouse Rápido + Labirinto, e outras combinações de T2+T3 no mesmo trabalho ainda não passaram por uma rodada dedicada de playtesting. Decisão consciente de não travar regras de exclusão adicionais até ter mais dados de jogo real — agora que o Labirinto tem efeito de jogo de verdade (v4.1), essa é a prioridade natural da próxima rodada.
- **Labirinto é o modificador com mais superfície de bug** — qualquer mudança futura no sistema de cursor virtual (novo modificador de mouse, por exemplo) deve ser testada especificamente em conjunto com Labirinto, já que ele depende da colisão de movimento estar sincronizada corretamente com o resto do pipeline de input.
- **Ícones dos modificadores** — confirmar que os 13 arquivos em `res://Sprites/Modificadores/` continuam com os nomes exatos esperados por `ModificadorAtivo.caminho_icone()` caso a pasta seja reorganizada no futuro.
- **`GerenciadorCursorVirtual` usa `CONFINED_HIDDEN`, não `CAPTURED`** — qualquer refatoração futura desse sistema deve preservar essa escolha; usar `CAPTURED` reintroduz o bug de posição corrompida ao fechar popups.
- **Documentação à frente do código é um risco real** — a v4.0 descrevia o Labirinto e a correção do warp counter como "✅ Implementado", mas nenhum dos dois tinha sido salvo de fato no projeto, o que só foi descoberto ao testar o modificador em jogo. Pra evitar repetir isso: sempre que uma sessão de chat gerar código extenso pra colar manualmente, confirmar com um teste em jogo (não só revisão visual) antes de marcar como ✅ na documentação.
- **Limpeza de legado (v4.1)** — removidos do projeto `lembrete.gd`, `painel_trabalho.gd`, `button-inspecionar.gd`, `mensagem_modal.gd`, `painel_diagnostico.gd`, `CaixaDeSelecao.gd`, `caixa_selecao.gd`, e os nós `Alvo1`/`CaixaSelecao`/`TimerLembrete`/instância duplicada de `GerenciadorCursorVirtual`. Todos confirmados órfãos antes da remoção (sem referências no sistema atual).
