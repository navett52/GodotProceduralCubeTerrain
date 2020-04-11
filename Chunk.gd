extends MeshInstance

#=== Cube related variables ===#
# Keeping track of our verticies and indicies for, currently, a single cube.
var arrayQuadVerticies = []
var arrayQuadIndicies = []

# A dictionary to check against to make sure we don't create duplicate verticies in a cube.
# Could probably be expanded upon to be used on a larger mesh.
var dictionaryCheckQuadVerticies = {}
#=== Cube related variables ===#

# Chunk sizing
var chunkWidth = WorldGenerationGlobals.CHUNK_WIDTH
var chunkHeight = WorldGenerationGlobals.CHUNK_HEIGHT

# 3 dimensional array to hold block types
# Making it a dictionaty with a 3 part string key to match what the unique pairing would have been in a 3D array
var blocks = {}

func buildMesh():
	var mesh
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var verts = []
	var tris = []
	var uvs = []
	var normals = []
	
	for x in range(1, chunkWidth + 1):
		for z in range(1, chunkWidth + 1):
			for y in range(1, chunkHeight):
				if blocks[_blocksKey(x, y, z)] != WorldGenerationGlobals.BlockType.AIR:
					var blockPos = Vector3(x - 1, y, z - 1)
					var numFaces = 0

					# Create the top face if there is air above the block.
					if y < chunkHeight - 1 && blocks[_blocksKey(x, y + 1, z)] == WorldGenerationGlobals.BlockType.AIR:
						var pos1 = blockPos + Vector3(1, 1, 0) # D
						var pos2 = blockPos + Vector3(1, 1, 1) # C
						var pos3 = blockPos + Vector3(0, 1, 1) # B
						var pos4 = blockPos + Vector3(0, 1, 0) # A
						addQuad(pos1, pos2, pos3, pos4)
						
						for uv in WorldGenerationGlobals.blocks[blocks[_blocksKey(x, y, z)]].topPos.getUvs():
							uvs.append(uv)

					# Bottom of a cube if it's next to an air block
					if y > 0 && blocks[_blocksKey(x, y - 1, z)] == WorldGenerationGlobals.BlockType.AIR:
						var pos1 = blockPos + Vector3(0, 0, 0)
						var pos2 = blockPos + Vector3(0, 0, 1)
						var pos3 = blockPos + Vector3(1, 0, 1)
						var pos4 = blockPos + Vector3(1, 0, 0)
						addQuad(pos1, pos2, pos3, pos4)
						numFaces += 1

						for uv in WorldGenerationGlobals.blocks[blocks[_blocksKey(x, y, z)]].bottomPos.getUvs():
							uvs.append(uv)

					# Front of the cube
					if blocks[_blocksKey(x, y, z - 1)] == WorldGenerationGlobals.BlockType.AIR:
						var pos1 = blockPos + Vector3(1, 0, 0)
						var pos2 = blockPos + Vector3(1, 1, 0)
						var pos3 = blockPos + Vector3(0, 1, 0)
						var pos4 = blockPos + Vector3(0, 0, 0)
						addQuad(pos1, pos2, pos3, pos4)
						numFaces += 1

						for uv in WorldGenerationGlobals.blocks[blocks[_blocksKey(x, y, z)]].sidePos.getUvs():
							uvs.append(uv)

					# Right side of the cube
					if blocks[_blocksKey(x + 1, y, z)] == WorldGenerationGlobals.BlockType.AIR:
						var pos1 = blockPos + Vector3(1, 0, 1)
						var pos2 = blockPos + Vector3(1, 1, 1)
						var pos3 = blockPos + Vector3(1, 1, 0)
						var pos4 = blockPos + Vector3(1, 0, 0)
						addQuad(pos1, pos2, pos3, pos4)
						numFaces += 1

						for uv in WorldGenerationGlobals.blocks[blocks[_blocksKey(x, y, z)]].sidePos.getUvs():
							uvs.append(uv)

					# Back of the cube (working)
					if blocks[_blocksKey(x, y, z + 1)] == WorldGenerationGlobals.BlockType.AIR:
						var pos1 = blockPos + Vector3(0, 0, 1)
						var pos2 = blockPos + Vector3(0, 1, 1)
						var pos3 = blockPos + Vector3(1, 1, 1)
						var pos4 = blockPos + Vector3(1, 0, 1)
						addQuad(pos1, pos2, pos3, pos4)
						numFaces += 1

						for uv in WorldGenerationGlobals.blocks[blocks[_blocksKey(x, y, z)]].sidePos.getUvs():
							uvs.append(uv)

					# Left side of the cube
					if blocks[_blocksKey(x - 1, y, z)] == WorldGenerationGlobals.BlockType.AIR:
						var pos1 = blockPos + Vector3(0, 0, 0)
						var pos2 = blockPos + Vector3(0, 1, 0)
						var pos3 = blockPos + Vector3(0, 1, 1)
						var pos4 = blockPos + Vector3(0, 0, 1)
						addQuad(pos1, pos2, pos3, pos4)
						numFaces += 1

						for uv in WorldGenerationGlobals.blocks[blocks[_blocksKey(x, y, z)]].sidePos.getUvs():
							uvs.append(uv)
	
	# Add all of the verticies, indicies, and uvs to the surface tool
	for vertex in arrayQuadVerticies:
		st.add_vertex(vertex)
	
	for index in arrayQuadIndicies:
		st.add_index(index)
	
	for uv in uvs:
		st.add_uv(uv)
	
	st.generate_normals()
	
	self.mesh = st.commit()

func addQuad(point1, point2, point3, point4):
	var vertexIndexOne = -1
	var vertexIndexTwo = -1
	var vertexIndexThree = -1
	var vertexIndexFour = -1
	
	vertexIndexOne = _addOrGetVertexFromArray(point1)
	vertexIndexTwo = _addOrGetVertexFromArray(point2)
	vertexIndexThree = _addOrGetVertexFromArray(point3)
	vertexIndexFour = _addOrGetVertexFromArray(point4)
	
	arrayQuadIndicies.append(vertexIndexOne)
	arrayQuadIndicies.append(vertexIndexTwo)
	arrayQuadIndicies.append(vertexIndexThree)
	
	arrayQuadIndicies.append(vertexIndexOne)
	arrayQuadIndicies.append(vertexIndexThree)
	arrayQuadIndicies.append(vertexIndexFour)

# Helper function to ensure we aren't adding more verticies than we need to.
func _addOrGetVertexFromArray(vertex):
	if dictionaryCheckQuadVerticies.has(vertex) == true:
		return dictionaryCheckQuadVerticies[vertex]
	else:
		arrayQuadVerticies.append(vertex)
		dictionaryCheckQuadVerticies[vertex] = arrayQuadVerticies.size() - 1
		return arrayQuadVerticies.size() - 1

# A helper function to generate a string key based on x, y, z since Godot doesn't to 3D arrays.
func _blocksKey(x, y, z):
	return (str(x) + "," + str(y) + "," + str(z))
