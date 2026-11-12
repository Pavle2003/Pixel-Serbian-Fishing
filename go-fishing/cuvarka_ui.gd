extends Control

@onready var grid_container: GridContainer = $Panel/ScrollContainer/GridContainer
@onready var brojac_label: Label = $Panel/Label
@onready var close_button: TextureButton = $Panel/TextureButton

var item_scene = preload("res://cuvarka_item.tscn")

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	if close_button and not close_button.pressed.is_connected(_on_close_pressed):
		close_button.pressed.connect(_on_close_pressed)

func otvori_cuvarku() -> void:
	osvezi_prikaz()
	visible = true
	get_tree().paused = true

func _on_close_pressed() -> void:
	visible = false
	get_tree().paused = false

func osvezi_prikaz() -> void:
	for child in grid_container.get_children():
		child.queue_free()
		
	if brojac_label:
		brojac_label.text = str(GameManager.cuvarka.size()) + " / " + str(GameManager.maksimalni_kapacitet)
		
	for i in range(GameManager.cuvarka.size()):
		var riba = GameManager.cuvarka[i]
		var item = item_scene.instantiate()
		grid_container.add_child(item)
		
		var img_rect = item.find_child("TextureRect", true, false)
		var lbl = item.find_child("Podaci_Kilaza", true, false)
		var gold_lbl = item.find_child("Gold", true, false)
		var meat_lbl = item.find_child("Meet", true, false)
		var obrisi_btn = item.find_child("Button", true, false)
		
		if img_rect and riba["tekstura"]:
			img_rect.texture = riba["tekstura"]
			img_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			img_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			
		if lbl:
			lbl.text = riba["naziv"] + "\n" + str(riba["tezina"]) + " kg"
			
		if gold_lbl:
			gold_lbl.text = str(riba["zlato"])
			
		if meat_lbl:
			meat_lbl.text = str(riba["meso"])
			
		if obrisi_btn:
			obrisi_btn.pressed.connect(func():
				GameManager.izbaci_ribu_iz_cuvarke(i)
				osvezi_prikaz()
			)
