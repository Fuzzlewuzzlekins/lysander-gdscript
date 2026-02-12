extends Area2D

signal assign(task: CheckBox)
signal turn_in(task: CheckBox)

@export var target_player: Area2D
var assignment: CheckBox


func _ready() -> void:
	# If I have a Task as a child, manage it
	assignment = get_node_or_null("Task")
	if assignment != null:
		assignment.hide()


func _on_player_interact(area: Area2D) -> void:
	if self == area:
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
		# TODO: animate
		pass


func _on_player_unhighlight(area: Area2D) -> void:
	if self == area:
		# TODO: animate
		pass
