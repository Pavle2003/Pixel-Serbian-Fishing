extends Control

@onready var texture_rect: TextureRect = $Panel/TextureRect
@onready var weight_label: Label = $Panel/WeightLabel        
@onready var gold_label: Label = $Panel/GoldLabel          
@onready var xp_label: Label = $Panel/XpLabel              
@onready var meat_label: Label = $Panel/MeatLabel          
@onready var ok_button: TextureButton = $Panel/OkButton     

var trenutna_riba_podatci: Dictionary = {}

func _ready() -> void:
	visible = false # Prozor je sakriven dok se riba ne upeca
	process_mode = Node.PROCESS_MODE_ALWAYS # Omogućava da dugme i prozor rade i kada je igra pauzirana

func _on_ok_button_pressed() -> void:
	visible = false
	get_tree().paused = false
	
	# Vraćamo štap i čistimo ribu preko igrača
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("pull_rod"):
		player.pull_rod()

func prikazi_ulov(fish_node: Node) -> void:
	if not is_instance_valid(fish_node):
		print("Greška: Riba ne postoji!")
		return
		
	trenutna_riba_podatci = GameManager.dodaj_ribu_u_cuvarku(fish_node)
	
	if trenutna_riba_podatci.is_empty():
		print("Greška: Podaci o ribi su prazni!")
		return

	if weight_label: 
		weight_label.text = str(trenutna_riba_podatci["tezina"]) + " kg"
	if gold_label: 
		gold_label.text = str(trenutna_riba_podatci["zlato"])
	if xp_label: 
		xp_label.text = str(trenutna_riba_podatci["xp"])
	if meat_label: 
		meat_label.text = str(trenutna_riba_podatci["meso"])
	
	var fish_anim_sprite = fish_node.find_child("AnimatedSprite2D", true, false)
	if not fish_anim_sprite:
		fish_anim_sprite = fish_node.find_child("Swim", true, false)
		
	if fish_anim_sprite and fish_anim_sprite.sprite_frames and texture_rect:
		var current_anim = fish_anim_sprite.animation
		if current_anim:
			texture_rect.texture = fish_anim_sprite.sprite_frames.get_frame_texture(current_anim, 0)
			texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	visible = true
	get_tree().paused = true
