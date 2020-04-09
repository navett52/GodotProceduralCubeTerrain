extends Node

var TilePosClass = load("res://TilePos.gd")
var BlockClass = load("res://Block.gd")

const CHUNK_WIDTH = 5
const CHUNK_HEIGHT = 50

enum Tile {DIRT, GRASS, GRASS_SIDE, STONE, TREE_SIDE, TREE_CX, LEAVES}

var tiles = {
	Tile.DIRT: TilePosClass.new(),
	Tile.GRASS: TilePosClass.new(),
	Tile.GRASS_SIDE: TilePosClass.new(),
	Tile.STONE: TilePosClass.new(),
	Tile.TREE_SIDE: TilePosClass.new(),
	Tile.TREE_CX: TilePosClass.new(),
	Tile.LEAVES: TilePosClass.new()
}

enum BlockType {AIR, DIRT, GRASS, STONE, TRUNK, LEAVES}

var blocks = {
	BlockType.GRASS: BlockClass.new(),
	BlockType.DIRT: BlockClass.new(),
	BlockType.STONE: BlockClass.new(),
	BlockType.TRUNK: BlockClass.new(),
	BlockType.LEAVES: BlockClass.new()
}

func _ready():
	tiles[Tile.DIRT].TilePos(0, 0)
	tiles[Tile.GRASS].TilePos(1, 0)
	tiles[Tile.GRASS_SIDE].TilePos(0, 1)
	tiles[Tile.STONE].TilePos(0, 2)
	tiles[Tile.TREE_SIDE].TilePos(0, 4)
	tiles[Tile.TREE_CX].TilePos(0, 3)
	tiles[Tile.LEAVES].TilePos(0, 5)
	
	blocks[BlockType.GRASS].BlockMulti(Tile.GRASS, Tile.GRASS_SIDE, Tile.DIRT)
	blocks[BlockType.DIRT].BlockSingle(Tile.DIRT)
	blocks[BlockType.STONE].BlockSingle(Tile.STONE)
	blocks[BlockType.TRUNK].BlockMulti(Tile.TREE_CX, Tile.TREE_SIDE, Tile.TREE_CX)
	blocks[BlockType.LEAVES].BlockSingle(Tile.LEAVES)