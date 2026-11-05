extends Node2D

const FISH_SCENE = preload("res://fish.tscn")

@onready var spawn_point: Marker2D = $FishSpawnPoint
@onready var spawn_timer: Timer = $FishSpawnTimer

# Maksimalan broj riba koje mogu istovremeno biti u akvarijumu
const MAX_FISH = 4

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	# Prebrojavamo koliko trenutno riba postoji u igri
	var current_fish_count = get_tree().get_nodes_in_group("fish").size()
	
	# Ako ih ima manje od maksimalnog broja, stvaramo novu
	if current_fish_count < MAX_FISH:
		var new_fish = FISH_SCENE.instantiate()
		new_fish.global_position = spawn_point.global_position
		add_child(new_fish)
		print("Nova riba je stvorena! Trenutno u jezeru: ", current_fish_count + 1)


func _on_ok_button_pressed() -> void:
	pass # Replace with function body.
