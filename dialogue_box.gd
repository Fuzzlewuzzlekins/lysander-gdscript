extends Node2D

var tween: Tween

func _ready() -> void:
	hide()


func _on_npc_say(character: Area2D, dialogue: String) -> void:
	if tween:
		tween.kill()
	reparent(character, false)
	$Panel/Label.text = dialogue
	$Panel.self_modulate = character.tint
	#modulate.a = 1.0
	modulate.a = 0.0
	position.y = 0
	show()
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	tween.parallel().tween_property(self, "position:y", position.y - 4, 0.1)
	tween.tween_interval(2.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
