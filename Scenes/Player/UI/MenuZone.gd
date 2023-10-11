extends Control

func _on_mouse_exited():
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
