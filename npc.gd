extends Area2D

signal assign(task: CheckBox)
signal turn_in(task: CheckBox)
signal turn_in_warn(task: CheckBox)
signal turn_in_unwarn(task: CheckBox)

@export var target_player: Area2D
@export var dullness: float = 0.8
@export var behavior: Array[Dictionary] = [{"animation":"idle","speed":0.0,"flip_h":true,"duration":1.0}]
var behavior_elapsed_time: float
var assignment: CheckBox


func _ready() -> void:
	# Dull sprite slightly
	modulate.a = dullness
	# Look for the Player in the scene
	if !target_player:
		target_player = get_tree().get_root().find_child("Player")
	# If I have a Task as a child, manage it
	assignment = get_node_or_null("Task")
	if assignment != null:
		assignment.hide()
	# Initialize behavior timer
	behavior_elapsed_time = 0.0


func _process(delta: float) -> void:
	# Tick the behavior timer
	behavior_elapsed_time += delta
	if behavior_elapsed_time > behavior[0]["duration"]:
		# If it's time for the next behavior, reset timer and move current behavior to the end of the list.
		behavior_elapsed_time -= behavior[0]["duration"]
		var old_behavior = behavior.pop_front()
		behavior.append(old_behavior)
	# Handle behavior. Keys: "animation", "speed", "flip_h", duration"
	$AnimatedSprite2D.play(behavior[0]["animation"])
	$AnimatedSprite2D.flip_h = behavior[0]["flip_h"]
	position.x += behavior[0]["speed"] * delta


func _on_player_interact(area: Area2D) -> void:
	if self == area:
		if global_position.x > target_player.global_position.x:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		# Check if I am a turn-in point for any tasks
		for i in range(Gamestate.active_tasks.size()):
			var task = Gamestate.active_tasks.get(i)
			if task.turn_in == self:
				turn_in.emit(task)
		# If I have an assignment, assign it
		if assignment != null:
			assign.emit(assignment)
			assignment = null


func _on_player_highlight(area: Area2D) -> void:
	if self == area:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", 1.0, 0.2)
		# Check if I am a turn-in point for any tasks
		for i in range(Gamestate.active_tasks.size()):
			var task = Gamestate.active_tasks.get(i)
			if task.turn_in == self:
				turn_in_warn.emit(task)


func _on_player_unhighlight(area: Area2D) -> void:
	if self == area:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate:a", dullness, 0.2)
		# Check if I am a turn-in point for any tasks
		for i in range(Gamestate.active_tasks.size()):
			var task = Gamestate.active_tasks.get(i)
			if task.turn_in == self:
				turn_in_unwarn.emit(task)
