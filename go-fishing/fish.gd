extends CharacterBody2D

var speed: float = 20.0
var direction: int = 1 
var time_passed: float = 0.0
var vertical_speed: float = 2.0

var change_dir_timer: float = 0.0
var next_dir_change: float = 3.0

@onready var animated_sprite: AnimatedSprite2D = $Swim

func _ready() -> void:
	add_to_group("fish")
	
	var random_scale = randf_range(0.1, 0.3)
	scale = Vector2(random_scale, random_scale)
	
	speed = randf_range(20.0, 45.0)
	vertical_speed = randf_range(1.0, 2.5)
	
	direction = 1 if randf() > 0.5 else -1
	next_dir_change = randf_range(3.0, 6.0)
	
	animated_sprite.play("SaranAnimated")

func _physics_process(delta: float) -> void:
	time_passed += delta * vertical_speed
	change_dir_timer += delta
	
	if change_dir_timer >= next_dir_change:
		change_dir_timer = 0.0
		next_dir_change = randf_range(3.0, 6.0)
		
		if randf() > 0.4:
			direction *= -1
	
	velocity.x = direction * speed
	# Smanjen vertikalni pomak (sa 15 na 6) da se drže blizu dna
	velocity.y = sin(time_passed) * 6.0 
	
	# Obrnuto okretanje glave da prate pravi smjer kretanja
	if velocity.x > 0:
		animated_sprite.flip_h = true   # Kada idu u desno
	elif velocity.x < 0:
		animated_sprite.flip_h = false  # Kada idu u lijevo
	
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
