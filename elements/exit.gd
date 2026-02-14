extends Area2D

#signal assign(task: CheckBox)
signal turn_in(task: CheckBox)
signal turn_in_warn(task: CheckBox)
signal turn_in_unwarn(task: CheckBox)

@export var target_player: Area2D
@export var dullness: float = 0.8
@export var next_scene: PackedScene
@export var next_scene_hint: String = "Leave"
@export var lock_messsage: String
#var assignment: CheckBox


func _ready() -> void:
	$Label.modulate.a = 0.0


func _on_player_interact(area: Area2D) -> void:
	if self == area:
		# Check if I am a turn-in point for any tasks
		for i in range(Gamestate.active_tasks.size()):
			var task = Gamestate.active_tasks.get(i)
			if task.turn_in == self:
				turn_in.emit(task)
		# If not locked, let player change scene
		if !lock_messsage:
			get_tree().change_scene_to_packed(next_scene)


func _on_player_highlight(area: Area2D) -> void:
	if self == area:
		if lock_messsage:
			$Label.text = lock_messsage
		else:
			$Label.text = next_scene_hint
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.2)
		tween.parallel().tween_property($Label, "modulate:a", 1.0, 0.2)
		# Check if I am a turn-in point for any tasks
		for i in range(Gamestate.active_tasks.size()):
			var task = Gamestate.active_tasks.get(i)
			if task.turn_in == self:
				turn_in_warn.emit(task)


func _on_player_unhighlight(area: Area2D) -> void:
	if self == area:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", dullness, 0.2)
		tween.parallel().tween_property($Label, "modulate:a", 0.0, 0.2)
		# Check if I am a turn-in point for any tasks
		for i in range(Gamestate.active_tasks.size()):
			var task = Gamestate.active_tasks.get(i)
			if task.turn_in == self:
				turn_in_unwarn.emit(task)
