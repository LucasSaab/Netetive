extends Node


var fame: int = 0
var money: float = 0

# Avisos sobre a alteracao dos valores de fama e dinheiro
signal altered_money(new_money: float)
signal fame_received(more_fame: int)

# Funcao para incrementar o dinheiro
 
# Funcao para incrementar o dinheiro
func add_money(qtd: float) -> void:
	money += qtd
	print("Seu saldo atual e de: %.2f" % money)
	altered_money.emit(money) # Notifica a UI que o valor mudou

# Funcao para incrementar a fama
func add_fame(qtd: int) -> void:
	fame += qtd
	print("Sua fama atual e de: %d" % fame)
	fame_received.emit(fame) # Notifica a UI que o valor mudou
	
# Funcao para decrementar o dinheiro recebido
func decrease_money(qtd: float) -> void:
	money -= qtd
	print("Seu saldo atual e de: %.2f" % money)
	altered_money.emit(money) # Notifica a UI que o valor mudou
	
