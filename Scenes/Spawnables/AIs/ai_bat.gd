extends AITemplate

func getDirection(_position, _enemyPosition) -> Vector2:
	return Vector2(_enemyPosition - _position).normalized()
