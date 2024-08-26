extends OptionButton

func _ready() -> void:
	get_popup().add_theme_font_size_override("font_size", self.get_theme_font_size("font_size"))