extends Area2D

signal interact(area: Area2D)
signal highlight(area: Area2D)
signal unhighlight(area: Area2D)

@export var speed: float = 200
@export var in_conversation: bool = false
#@export var anim_frame_rate: float = 10
enum SpriteFrameSet {BASE, BACKPACK, PJS}
@export var sprite_frame_sets: Array[SpriteFrames]
@export var current_sprite_frame_set: SpriteFrameSet = SpriteFrameSet.BASE
var closest_entity: Area2D = null
var scene_bound_right: float = 10000
const SCENE_MARGIN: float = 100.0


func _ready() -> void:
	#var background = get_parent().find_child("Background")
	var background = get_tree().current_scene.find_child("Background")
	if background:
		scene_bound_right = (background as ColorRect).size.x
		print("Found Background of width: %f", scene_bound_right)
	else:
		print("Background not found")
	$AnimatedSprite2D.sprite_frames = sprite_frame_sets[current_sprite_frame_set]


func _process(delta: float) -> void:
	# Only process input if able.
	if !Gamestate.conversation_active:
		var current_anim = $AnimatedSprite2D.animation
		# If Player is not sitting, determine how they walk or idle.
		if current_anim == "idle" or current_anim == "walk":
			if Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
				$AnimatedSprite2D.play("walk")
				$AnimatedSprite2D.flip_h = true
				position.x -= speed * delta
			elif Input.is_action_pressed("move_right") and !Input.is_action_pressed("move_left"):
				$AnimatedSprite2D.play("walk")
				$AnimatedSprite2D.flip_h = false
				position.x += speed * delta
			else:
				$AnimatedSprite2D.play("idle")
		position.x = clampf(position.x, 0 + SCENE_MARGIN, scene_bound_right - SCENE_MARGIN)
		
		# If Player is idle (not walking), handle sit/stand
		if (Input.is_action_just_pressed("sit_down") or Input.is_action_just_pressed("toggle_sit")) and current_anim == "idle":
			$AnimatedSprite2D.play("sit")
		if (Input.is_action_just_pressed("stand_up") or Input.is_action_just_pressed("toggle_sit")) and current_anim == "sit_idle":
			$AnimatedSprite2D.play("stand")
		
		# Handle interactions with other Area2Ds
		var touching_areas = get_overlapping_areas()
		if !touching_areas.is_empty():
			# Find the touching area that is closest (by global position)
			var closest_dist = 10000
			var closest_area: Area2D = null
			for i in range(touching_areas.size()):
				var area_checking: Area2D = touching_areas[i]
				var temp_dist = global_position.distance_squared_to(area_checking.global_position)
				if temp_dist < closest_dist:
					closest_dist = temp_dist
					closest_area = area_checking
			# If our closest area has changed, update closest_entity pointer and send signals
			if closest_area != closest_entity:
				unhighlight.emit(closest_entity)
				highlight.emit(closest_area)
				closest_entity = closest_area
			# If the Player has pressed Interact, send signal
			if Input.is_action_just_pressed("interact"):
				interact.emit(closest_entity)
		else:
			# If the Player is touching nothing but is still tracking closest_entity, release pointer and send signal
			if closest_entity:
				unhighlight.emit(closest_entity)
				closest_entity = null
	else:
		in_conversation = true


func _on_animated_sprite_2d_animation_finished() -> void:
	var current_anim = $AnimatedSprite2D.animation
	# When Player is done sitting, flow into sit_idle. Same with stand->idle.
	if current_anim == "sit":
		$AnimatedSprite2D.play("sit_idle")
	elif current_anim == "stand":
		$AnimatedSprite2D.play("idle")


# Alternate way to move the character only when the anim frame changes. Stuttery.
func _on_animated_sprite_2d_frame_changed() -> void:
	#var current_anim = $AnimatedSprite2D.animation
	#if current_anim == "walk":
		#var sprite_frames: SpriteFrames = $AnimatedSprite2D.sprite_frames
		#var fps: float = sprite_frames.get_animation_speed(current_anim)
		#if $AnimatedSprite2D.flip_h:
			#position.x -= speed / fps
		#else:
			#position.x += speed / fps
		#position.x = clampf(position.x, 0 + SCENE_MARGIN, scene_bound_right - SCENE_MARGIN)
	pass
