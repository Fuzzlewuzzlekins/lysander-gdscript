extends CanvasLayer

@export var task_fade_speed: float = 1.0
var task_current_warning: CheckBox
var task_warn_tween: Tween

func _ready() -> void:
	$TopRightPanel/EnergyBarBase.value = Gamestate.current_energy
	$TopRightPanel/EnergyBarBase/EnergyBarOverlay.value = Gamestate.current_energy


func _on_entity_assign(task: CheckBox) -> void:
	Gamestate.active_tasks.append(task)
	task.reparent($TopRightPanel/TaskList, false)
	task.show()
	var tween = get_tree().create_tween()
	tween.tween_property(task, "modulate:a", 0, 0.0)
	tween.tween_property(task, "modulate:a", 1, task_fade_speed)


func _on_entity_turn_in(task: CheckBox) -> void:
	# Can the task be turned in?
	if Gamestate.current_energy > task.energy_cost:
		# Spend energy
		Gamestate.current_energy -= task.energy_cost
		$TopRightPanel/EnergyBarBase.value = Gamestate.current_energy
		$TopRightPanel/EnergyBarBase.self_modulate = Color.WHITE
		$TopRightPanel/EnergyBarBase/EnergyBarOverlay.value = Gamestate.current_energy
		task_current_warning = null
		if task_warn_tween:
			task_warn_tween.kill()
			task_warn_tween = null
		# Clear task
		Gamestate.active_tasks.erase(task)
		task.button_pressed = true
		task.disabled = true
		var tween = get_tree().create_tween()
		tween.tween_interval(0.5)
		tween.tween_property(task, "modulate:a", 0, task_fade_speed)
		tween.tween_callback(task.queue_free)


func _on_entity_turn_in_warn(task: CheckBox) -> void:
	task_current_warning = task
	if task.energy_cost > 0:
		# If the task cost is > 0, flash the base and shorten the overlay.
		$TopRightPanel/EnergyBarBase/EnergyBarOverlay.value -= task.energy_cost
		task_warn_tween = get_tree().create_tween().set_loops()
		task_warn_tween.tween_property($TopRightPanel/EnergyBarBase, "self_modulate:a", 0.0, 0.5)
		task_warn_tween.tween_property($TopRightPanel/EnergyBarBase, "self_modulate:a", 1.0, 0.5)
		if task.energy_cost > Gamestate.current_energy:
			$TopRightPanel/EnergyBarBase.self_modulate = Color.RED
	elif task.energy_cost < 0:
		# If the task cost is < 0 (a recovery), extend the base and flash it GREEN.
		$TopRightPanel/EnergyBarBase.value -= task.energy_cost
		task_warn_tween = get_tree().create_tween().set_loops()
		task_warn_tween.tween_property($TopRightPanel/EnergyBarBase, "self_modulate:a", 0.0, 0.5)
		task_warn_tween.tween_property($TopRightPanel/EnergyBarBase, "self_modulate:a", 1.0, 0.5)
		$TopRightPanel/EnergyBarBase.self_modulate = Color.GREEN


func _on_entity_turn_in_unwarn(task: CheckBox) -> void:
	if task_current_warning == task:
		task_current_warning = null
		$TopRightPanel/EnergyBarBase.value = Gamestate.current_energy
		$TopRightPanel/EnergyBarBase.self_modulate = Color.WHITE
		$TopRightPanel/EnergyBarBase/EnergyBarOverlay.value = Gamestate.current_energy
		if task_warn_tween:
			task_warn_tween.kill()
			task_warn_tween = null
