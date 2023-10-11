extends Node2D

@onready var infoLabel : Label = $Info
@onready var imageTexture : Sprite2D = $Image

func set_cursor_state(info : String, image: Texture2D):
	infoLabel.text = info
	imageTexture.texture = image
