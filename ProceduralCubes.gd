extends Spatial

# Gotta keep track of those verticies and indicies.
var arrayQuadVerticies = []
var arrayQuadIndicies = []

# A dictionary to check against to make sure we don't create duplicate verticies in a cube.
# Could probably be expanded upon to be used on a larger mesh.
var dictionaryCheckQuadVerticies = {}

# How big we want our cubes.
const CUBE_SIZE = 1

# OpenSimplex noise instance.
var noise = OpenSimplexNoise.new()

# A dictionary to store pregenerated Y values from noise.
# Apart of the nested loop code that isn't currently being used.
var terrain = {}

# The value to multiple the noise value by.
# Currently not being used but could easily be swapped in.
var GRID_SCALE = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	# This is the noise seed. I have it hardcoded for debugging.
	noise.seed = 10
	
	# These are the noise variable sto tweak to get different terrain effects.
	noise.octaves = 4
	noise.period = 50
	noise.persistence = 0.8
	# noise.lacunarity = .5
	
	# Pre-creating a list of height values from the noise. I'm not actually using this right now.
#	for x in range(10):
#		for y in range(10):
#			if terrain.has((str(x) + ',' + str(y))) == false:
#				terrain[(str(x) + ',' + str(y))] = noise.get_noise_2d(x, y) * GRID_SCALE
	
	# Create a 100x100 grid of cubes and set the Y offset to the noise value multiplied by 10 since it returns between -1 and 1.
	var offset = 2
	var xOffset
	var yOffset
	var zOffset
	
	for x in range(100):
		xOffset = offset * x
		for y in range(1):
			yOffset = offset * y
			for z in range(100):
				zOffset = offset * z
				print(noise.get_noise_2d(x, z))
				makeCube(xOffset, floor(noise.get_noise_2d(x, z) * GRID_SCALE), zOffset)

# Make a cube and specify offsets to move the cubes around.
func makeCube(offsetX, offsetY, offsetZ):
	arrayQuadVerticies = []
	arrayQuadIndicies = []
	dictionaryCheckQuadVerticies = {}
	
	var resultMesh = Mesh.new()
	var surface_tool = SurfaceTool.new()
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var vertNorthTopLeft     = Vector3( CUBE_SIZE + offsetX,  CUBE_SIZE + offsetY,  CUBE_SIZE + offsetZ)
	var vertNorthBottomLeft  = Vector3( CUBE_SIZE + offsetX,  CUBE_SIZE + offsetY, -CUBE_SIZE + offsetZ)
	var vertNorthTopRight    = Vector3(-CUBE_SIZE + offsetX,  CUBE_SIZE + offsetY,  CUBE_SIZE + offsetZ)
	var vertNorthBottomRight = Vector3(-CUBE_SIZE + offsetX,  CUBE_SIZE + offsetY, -CUBE_SIZE + offsetZ)
	
	var vertSouthTopRight    = Vector3(-CUBE_SIZE + offsetX, -CUBE_SIZE + offsetY,  CUBE_SIZE + offsetZ)
	var vertSouthTopLeft     = Vector3( CUBE_SIZE + offsetX, -CUBE_SIZE + offsetY,  CUBE_SIZE + offsetZ)
	var vertSouthBottomLeft  = Vector3( CUBE_SIZE + offsetX, -CUBE_SIZE + offsetY, -CUBE_SIZE + offsetZ)
	var vertSouthBottomRight = Vector3(-CUBE_SIZE + offsetX, -CUBE_SIZE + offsetY, -CUBE_SIZE + offsetZ)
	
	# Make the six quads for needed to make a box!
	# ============================================
	# IMPORTANT: You have to input the points in the going either clockwise, or counter clockwise
	# or the add_quad function will not work!
	addQuad(vertSouthTopRight, vertSouthTopLeft, vertSouthBottomLeft, vertSouthBottomRight)
	addQuad(vertNorthTopRight, vertNorthBottomRight, vertNorthBottomLeft, vertNorthTopLeft)
	
	addQuad(vertNorthBottomLeft, vertNorthBottomRight, vertSouthBottomRight, vertSouthBottomLeft)
	addQuad(vertNorthTopLeft, vertSouthTopLeft, vertSouthTopRight, vertNorthTopRight)
	
	addQuad(vertNorthTopRight, vertSouthTopRight, vertSouthBottomRight, vertNorthBottomRight)
	addQuad(vertNorthTopLeft, vertNorthBottomLeft, vertSouthBottomLeft, vertSouthTopLeft)
	# ============================================
	
	for vertex in arrayQuadVerticies:
		surface_tool.add_vertex(vertex)
	
	for index in arrayQuadIndicies:
		surface_tool.add_index(index)
	
	surface_tool.generate_normals()
	
	resultMesh = surface_tool.commit()
	# resultMesh.surface_get_arrays() <- Could be good to delete duplicate faces in a larger mesh.
	
	# Below is some Godot specific stuff of adding a new node to display the newly made mesh.
	var cube = MeshInstance.new()
	cube.mesh = resultMesh
	cube.create_trimesh_collision() # This line makes it collidable.
	self.add_child(cube) # Adding the cube to the scene hierarchy so it displays.

# The points must be added in clockwise or counter-clockwise or else this function will not work!
# Just a helper function to create squares for the cubes.
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
