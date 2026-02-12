extends CanvasLayer

@export var task_fade_speed: float = 1.0

func _ready() -> void:
	$TopRightPanel/EnergyBar.value = Gamestate.current_energy


func _on_npc_assign(task: CheckBox) -> void:
	Gamestate.active_tasks.append(task)
	task.reparent($TopRightPanel/TaskList, false)
	task.show()
	var tween = get_tree().create_tween().chain()
	tween.tween_property(task, "modulate:a", 0, 0.0)
	tween.tween_property(task, "modulate:a", 1, task_fade_speed)


func _on_npc_turn_in(task: CheckBox) -> void:
	# Can the task be turned in?
	if Gamestate.current_energy > task.energy_cost:
		# Spend energy
		Gamestate.current_energy -= task.energy_cost
		$TopRightPanel/EnergyBar.value = Gamestate.current_energy
		# Clear task
		Gamestate.active_tasks.erase(task)
		task.button_pressed = true
		task.disabled = true
		var tween = get_tree().create_tween().chain()
		tween.tween_interval(0.5)
		tween.tween_property(task, "modulate:a", 0, task_fade_speed)
		tween.tween_callback(queue_free)
