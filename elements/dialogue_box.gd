extends Node2D

signal confirm()

var tween: Tween

func _ready() -> void:
	hide()


func say_as_character(character: Area2D, dialogue: String, timed: bool = true) -> void:
	if tween:
		tween.kill()
	reparent(character, false)
	$Panel/Label.text = dialogue
	if character.get("tint"):
		$Panel.self_modulate = character.tint
	else:
		$Panel.self_modulate = Color.WHITE
	modulate.a = 0.0
	position.y = 0
	show()
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	tween.parallel().tween_property(self, "position:y", position.y - 4, 0.1)
	if timed:
		# A timed window disappears after 2 seconds
		$Panel/Continue.hide()
		tween.tween_interval(2.0)
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
	else:
		# An untimed window flashes the Continue icon
		$Panel/Continue.show()
		$Panel/Continue.modulate.a = 0.0
		tween.set_loops()
		tween.tween_property($Panel/Continue, "modulate:a", 1.0, 0.5)
		tween.tween_property($Panel/Continue, "modulate:a", 0.0, 0.5)


func _on_npc_say(character: Area2D, dialogue: String) -> void:
	say_as_character(character, dialogue)


func _on_npc_start_conversation(character: Area2D, c_dialogue: Array[Resource]) -> void:
	Gamestate.conversation_active = true
	# Dialogue line scheme: "speaker" is NodePath from NPC, "text" and "animation" are self-explanatory
	for i in c_dialogue.size():
		var line = c_dialogue[i]
		var speaker = character.get_node(line["speaker"])
		print("Speaker is " + speaker.name)
		say_as_character(speaker, line["text"], false)
		await confirm
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	Gamestate.conversation_active = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm"):
		confirm.emit()
	pass
