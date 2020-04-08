extends Node

# Need a chunk
var ChunkClass = load("res://Chunk.gd")
var terrainChunk # mayhaps this should really be the MeshInstance object. We'll see.

# Get the player; In this case a camera node
var player
var world

# Make a dictionary to hold chunks
var chunks = {}

# Noise
var noise = OpenSimplexNoise.new()

# Distance chunks load from player
export var chunkDistance = 5

# List of pooled chunks (For what? Deletion? Loading?)
var pooledChunks = []

# List of chunk positions for chunks to generate
var chunksToGen = []

func _ready():
	world = get_node(".")
	player = get_node("Camera")
	loadChunks(true)

func _process(delta):
	loadChunks()

func buildChunk(posX, posZ):
	var chunk = ChunkClass.new()
	
	if pooledChunks.size() > 0:
		chunk = pooledChunks[0]
		world.add_child(chunk)
		pooledChunks.erase(chunk)
		chunk.global_transform = Vector3(posX, 0, posZ)
	else:
		chunk.global_transform = Vector3(posX, 0, posZ)
	
	# I believe this is looping through the chunk
	for x in range(WorldGenerationGlobals.CHUNK_WIDTH + 2):
		for z in range(WorldGenerationGlobals.CHUNK_WIDTH + 2):
			for y in range(WorldGenerationGlobals.CHUNK_HEIGHT):
				chunk.blocks[chunk._blocksKey(x, y, z)] = getBlockType(posX + x - 1, y, posZ + z - 1)
	
	# TODO: Generate trees eventually
	
	chunk.buildMesh()

func getBlockType(x, y, z):
	
	pass

func loadChunks(immediate = false):
	pass