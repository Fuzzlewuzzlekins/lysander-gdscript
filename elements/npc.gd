extends Area2D

signal assign(task: CheckBox)
signal turn_in(task: CheckBox)
signal turn_in_warn(task: CheckBox)
signal turn_in_unwarn(task: CheckBox)
signal say(character: Area2D, dialogue: String)
signal start_conversation(character: Area2D, c_dialogue: Array[Resource])

@export var target_player: Area2D
@export var tint: Color = Color.WHITE
@export var dullness: float = 0.8
@export var behaviors: Array[Resource]
@export var in_conversation: bool = false
@export_group("Dialogue")
@export var idle_dialogue: Array[String]
@export var assign_dialogue: String
@export var turn_in_dialogue: String
@export var complex_dialogue: Array[Resource]
enum DialogueType {IDLE, ASSIGN, TURN_IN}
@export var complex_dialogue_type: DialogueType = DialogueType.TURN_IN
var behavior_elapsed_time: float
var assignment: CheckBox


func _ready() -> void:
	# Tint sprite
	$AnimatedSprite2D.modulate = tint
	# Dull sprite slightly by default
	$AnimatedSprite2D.modulate.a = dullness
	# If I have a Task as a child, manage it
	assignment = get_node_or_null("Task")
	if assignment != null:
		assignment.hide()
	# Initialize behavior timer
	behavior_elapsed_time = 0.0


func _process(delta: float) -> void:
	# Run background behaviors if not busy in a conversation.
	if !in_conversation:
		# Tick the behavior timer
		behavior_elapsed_time += delta
		if behavior_elapsed_time > behaviors[0]["duration"]:
			# If it's time for the next behavior, reset timer and move current behavior to the end of the list.
			behavior_elapsed_time -= behaviors[0]["duration"]
			var old_behavior = behaviors.pop_front()
			behaviors.append(old_behavior)
		# Handle behavior. Keys: "animation", "speed", "flip_h", duration"
		$AnimatedSprite2D.play(behaviors[0]["animation"])
		$AnimatedSprite2D.flip_h = behaviors[0]["flip_h"]
		position.x += behaviors[0]["speed"] * delta


func _on_player_interact(area: Area2D) -> void:
	if self == area and target_player:
		## Turn to face the player. Only useful if dialogue pauses behavior.
		#if global_position.x > target_player.global_position.x:
			#$AnimatedSprite2D.flip_h = true
		#else:
			#$AnimatedSprite2D.flip_h = false
		# Check if I am a turn-in point for any tasks
		for i in range(Gamestate.active_tasks.size()):
			var task = Gamestate.active_tasks.get(i)
			if task.turn_in == self and Gamestate.current_energy > task.energy_cost:
				turn_in.emit(task)
				if complex_dialogue and complex_dialogue_type == DialogueType.TURN_IN:
					start_conversation.emit(self, complex_dialogue)
					complex_dialogue = []
				elif turn_in_dialogue:
					say.emit(self, turn_in_dialogue)
				return
		# If I have an assignment, assign it
		if assignment != null:
			assign.emit(assignment)
			assignment = null
			if complex_dialogue and complex_dialogue_type == DialogueType.ASSIGN:
				start_conversation.emit(self, complex_dialogue)
				complex_dialogue = []
			elif assign_dialogue:
				say.emit(self, assign_dialogue)
			return
		# If I have an idle conversation, start it
		if complex_dialogue and complex_dialogue_type == DialogueType.IDLE:
			start_conversation.emit(self, complex_dialogue)
			complex_dialogue = []
		# If I have idle dialogue, loop through it
		elif idle_dialogue:
			var current_dialogue = idle_dialogue.pop_front()
			say.emit(self, current_dialogue)
			idle_dialogue.append(current_dialogue)
			return


func _on_player_highlight(area: Area2D) -> void:
	if self == area and target_player:
		var tween = get_tree().create_tween()
		tween.tween_property($AnimatedSprite2D, "modulate:a", 1.0, 0.2)
		# Check if I am a turn-in point for any tasks
		for i in range(Gamestate.active_tasks.size()):
			var task = Gamestate.active_tasks.get(i)
			if task.turn_in == self:
				turn_in_warn.emit(task)


func _on_player_unhighlight(area: Area2D) -> void:
	if self == area and target_player:
		var tween = get_tree().create_tween()
		tween.tween_property($AnimatedSprite2D, "modulate:a", dullness, 0.2)
		# Check if I am a turn-in point for any tasks
		for i in range(Gamestate.active_tasks.size()):
			var task = Gamestate.active_tasks.get(i)
			if task.turn_in == self:
				turn_in_unwarn.emit(task)
