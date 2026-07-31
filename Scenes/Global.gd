extends Node


var fame: int = 0
var money: double = 0

# Avisos sobre a alter~
signal altered_money(new_money: int)
signal fame_received(more_fame: int)

func add_money
