extends Node

# Need a chunk
var ChunkClass = load("res://Chunk.gd")
var terrainChunk # mayhaps this should really be the MeshInstance object. We'll see.
var thread
var sem = Semaphore.new()
signal finished

# Get the player; In this case a camera node
var player = Camera
var world

# Make a dictionary to hold chunks
var chunks = {}

# Noise
var noise = OpenSimplexNoise.new()
const genSeed = 10

# Distance chunks load from player
export var chunkDistance = 5

# List of pooled chunks (For what? Deletion? Loading?)
var pooledChunks = []

# List of chunk positions for chunks to generate
var chunksToGen = []

func _ready():
	world = get_node(".")
	player = get_node("Camera")
	noise.seed = genSeed
	loadChunks(true)

func _process(delta):
	loadChunks()

var currentChunk = Vector2(-1 ,-1)
func loadChunks(immediate = false):
	# Get the chunk the player is currently in
	var currentChunkPosX = floor(player.global_transform.origin.x / WorldGenerationGlobals.CHUNK_WIDTH) * WorldGenerationGlobals.CHUNK_WIDTH
	var currentChunkPosZ = floor(player.global_transform.origin.z / WorldGenerationGlobals.CHUNK_WIDTH) * WorldGenerationGlobals.CHUNK_WIDTH
	
	# Player entered a new chunk
	# I'm using y here instead of z since I'm using a Vector2 instead of making my own class for chunk position
	if currentChunk.x != currentChunkPosX || currentChunk.y != currentChunkPosZ:
		currentChunk.x = currentChunkPosX
		currentChunk.y = currentChunkPosZ
		
		var i = currentChunkPosX - (WorldGenerationGlobals.CHUNK_WIDTH * chunkDistance)
		var iComp = currentChunkPosX + (WorldGenerationGlobals.CHUNK_WIDTH * chunkDistance)
		
		while i <= iComp:
			var j = currentChunkPosZ - (WorldGenerationGlobals.CHUNK_WIDTH * chunkDistance)
			var jComp = currentChunkPosZ + (WorldGenerationGlobals.CHUNK_WIDTH * chunkDistance)
			while j <= jComp:
				var cp = Vector2(i, j)
				
				if !(chunks.has(cp)) && !(chunksToGen.has(cp)):
					print(str(i) + ", " + str(j))
					if immediate:
						buildChunk(i, j)
					else:
						chunksToGen.append(cp)
				
				j += WorldGenerationGlobals.CHUNK_WIDTH
			i += WorldGenerationGlobals.CHUNK_WIDTH
		
		var chunksToDestroy = []
		
		# Remove chunks that are too far away.
		for chunkPos in chunks:
			if (abs(currentChunkPosX - chunkPos.x) > WorldGenerationGlobals.CHUNK_WIDTH * (chunkDistance + 3)) || (abs(currentChunkPosZ - chunkPos.y) > WorldGenerationGlobals.CHUNK_WIDTH * (chunkDistance + 3)):
				chunksToDestroy.append(chunkPos)
		
		# Remove any up for regeneration
		for chunkPos in chunksToGen:
			if (abs(currentChunkPosX - chunkPos.x) > WorldGenerationGlobals.CHUNK_WIDTH * (chunkDistance + 1)) || (abs(currentChunkPosZ - chunkPos.y) > WorldGenerationGlobals.CHUNK_WIDTH * (chunkDistance + 1)):
				chunksToGen.erase(chunkPos)
		
		for chunkPos in chunksToDestroy:
			world.remove_child(chunks[chunkPos])
			pooledChunks.append(chunks[chunkPos])
			chunks.erase(chunkPos)
		
		call_deferred("delayBuildChunks")
#		yield(self, "finished")

func buildChunk(posX, posZ):
	var chunk = ChunkClass.new()
	
	# I believe this is looping through the chunk
	for x in range(WorldGenerationGlobals.CHUNK_WIDTH + 2):
		for z in range(WorldGenerationGlobals.CHUNK_WIDTH + 2):
			for y in range(WorldGenerationGlobals.CHUNK_HEIGHT):
				chunk.blocks[chunk._blocksKey(x, y, z)] = getBlockType(posX + x - 1, y, posZ + z - 1)
	
	world.add_child(chunk)
	chunk.global_transform.origin = Vector3(posX, 0, posZ)
	
#	if pooledChunks.size() > 0:
#		chunk = pooledChunks[0]
#		world.add_child(chunk)
#		pooledChunks.erase(chunk)
#		chunk.global_transform.origin = Vector3(posX, 0, posZ)
#	else:
#		world.add_child(chunk)
#		chunk.global_transform.origin = Vector3(posX, 0, posZ)
	
	# TODO: Generate trees eventually
	
	chunk.buildMesh()
	chunks[Vector2(posX, posZ)] = chunk

func getBlockType(x, y, z):
	var surfacePass1 = noise.get_noise_2d(x, z) * 10
	var surfacePass2 = noise.get_noise_2d(x, z) * 10 * (noise.get_noise_2d(x, z) + .5)
	
	var surfaceMap = surfacePass1 + surfacePass2
	var surfaceHeight = (WorldGenerationGlobals.CHUNK_HEIGHT * .5) + surfaceMap
	
	# Add more noise down here eventually for caves, cave masks, stone level, etc.
	
	var block = WorldGenerationGlobals.BlockType.AIR
	if y <= surfaceHeight:
		block = WorldGenerationGlobals.BlockType.DIRT
	
	# Would also use this loop for the cave gen but using certain noises as a mask
	
	return block

func delayBuildChunks():
	while chunksToGen.size() > 0:
		buildChunk(chunksToGen[0].x, chunksToGen[0].y)
		chunksToGen.remove(0)
		
		yield(get_tree().create_timer(.1), "timeout")
#		emit_signal("finished")