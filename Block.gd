extends Node

var top
var side
var bottom

var topPos
var sidePos
var bottomPos

func BlockSingle(tileEnum):
	self.top = tileEnum
	self.side = tileEnum
	self.bottom = tileEnum
	getPositions()

func BlockMulti(tileTopEnum, tileSideEnum, tileBottomEnum):
	self.top = tileTopEnum
	self.side = tileSideEnum
	self.bottom = tileBottomEnum
	getPositions()

func getPositions():
	self.topPos = WorldGenerationGlobals.tiles[top]
	self.sidePos = WorldGenerationGlobals.tiles[side]
	self.bottomPos = WorldGenerationGlobals.tiles[bottom]