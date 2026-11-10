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


func _on_ranac_button_pressed() -> void:
	$CanvasLayer/CuvarkaUI.otvori_cuvarku()

@onready var ranac_button: TextureButton = $CanvasLayer/RanacButton # Proveri da li ti je putanja do ranca tačna

var pulsing_time: float = 0.0

func _process(delta: float) -> void:
	# Proveravamo da li je čuvarka puna
	if GameManager.cuvarka.size() >= GameManager.maksimalni_kapacitet:
		pulsing_time += delta * 6.0
		# Blago povećavanje i smanjivanje skale (efekt pulsiranja)
		var scale_factor = 1.0 + sin(pulsing_time) * 0.15
		if ranac_button:
			ranac_button.scale = Vector2(scale_factor, scale_factor)
			ranac_button.pivot_offset = ranac_button.size / 2 # Da pulsuje iz centra
	else:
		if ranac_button:
			ranac_button.scale = Vector2(1, 1) # Vrati na normalu kad ima mesta
