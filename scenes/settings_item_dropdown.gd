extends HBoxContainer


@export var label: String = "Setting Label"
@export var config_section: String = "SectionName"
@export var config_key: String = "key_name"
@export var menu_items: Array

@onready var popup = $MenuButton.get_popup()


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = label
	$MenuButton.text = menu_items[GameSettings.general[config_section][config_key]]
	var index: int = 0
	for item in menu_items:
		popup.add_item(item, index, 0)
		index += 1
	popup.id_pressed.connect(_on_menu_button_item_selected)


func _on_menu_button_item_selected(id):
	GameSettings.general[config_section][config_key] = id
	$MenuButton.text = menu_items[id]


func _on_menu_button_about_to_popup():
	$MenuButton.icon
