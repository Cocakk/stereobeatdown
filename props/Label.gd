extends Label

@onready var label = $"."
@onready var timer = $"../Timer"

var current_text = ""
var char_index = 0
var typing_speed = 0.05  # Segundos entre cada caractere

func _ready():
	text = ""  # Limpa o texto visível inicialmente
	timer.connect("timeout", _on_Timer_timeout)
	timer.wait_time = typing_speed
	timer.start()

func _on_Timer_timeout():
	if char_index < label.text.length():
		current_text += label.text[char_index]
		text = current_text
		char_index += 1
	else:
		timer.stop()

# Função para reiniciar a animação
func reset_typing():
	current_text = ""
	char_index = 0
	text = ""
	timer.start()

# Função para definir texto personalizado
func set_typing_text(new_text):
	label.text = new_text
	reset_typing()


func _on_timer_timeout():
	if char_index < label.text.length():
		current_text += label.text[char_index]
		text = current_text
		char_index += 1
	else:
		timer.stop()
	pass # Replace with function body.
