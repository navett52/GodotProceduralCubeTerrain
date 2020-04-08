extends Node

var posX
var posY
var uvs = []

func TilePos(posX, posY):
	self.posX = posX
	self.posY = posY
	uvs.append(Vector2(posX / 16 + .001, posY / 16 + .001))
	uvs.append(Vector2(posX / 16 + .001, (posY + 1) / 16 - .001))
	uvs.append(Vector2((posX + 1) / 16 - .001, (posY + 1) / 16 - .001))
	uvs.append(Vector2((posX + 1) / 16 - .001, posY / 16 + .001))

func getUvs():
	return uvs

