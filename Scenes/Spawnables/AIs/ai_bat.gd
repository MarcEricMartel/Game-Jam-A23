extends AITemplate

func getDirection(position, enemyPosition) -> Vector2:
	return Vector2(enemyPosition - position).normalized()
