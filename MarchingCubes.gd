extends Spatial

var arrayQuadVerticies = []
var arrayQuadIndicies = []

var dictionaryCheckQuadVerticies = {}

const CUBE_SIZE = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	# Just some fun code for now that creates a grid of blocks at different dimensions.
	for x in range(6):
		if x == 0:
			makeCube(1, 1, 1)
		else:
			makeCube(x, 1, 1)
		for y in range(3):
			if y == 0:
				makeCube(1, 1, 1)
			else:
				makeCube(x, y, 1)
			for z in range(3):
				if z == 0:
					makeCube(1, 1, 1)
				else:
					makeCube(x, y, z)

# Make a cube and specify offsets to move the cubes around.
func makeCube(offsetX, offsetY, offsetZ):
	arrayQuadVerticies = []
	arrayQuadIndicies = []
	dictionaryCheckQuadVerticies = {}
	
	var resultMesh = Mesh.new()
	var surface_tool = SurfaceTool.new()
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var vertNorthTopLeft     = Vector3( CUBE_SIZE * offsetX,  CUBE_SIZE * offsetY,  CUBE_SIZE * offsetZ)
	var vertNorthBottomLeft  = Vector3( CUBE_SIZE * offsetX,  CUBE_SIZE * offsetY, -CUBE_SIZE * offsetZ)
	var vertNorthTopRight    = Vector3(-CUBE_SIZE * offsetX,  CUBE_SIZE * offsetY,  CUBE_SIZE * offsetZ)
	var vertNorthBottomRight = Vector3(-CUBE_SIZE * offsetX,  CUBE_SIZE * offsetY, -CUBE_SIZE * offsetZ)
	
	var vertSouthTopRight    = Vector3(-CUBE_SIZE * offsetX, -CUBE_SIZE * offsetY,  CUBE_SIZE * offsetZ)
	var vertSouthTopLeft     = Vector3( CUBE_SIZE * offsetX, -CUBE_SIZE * offsetY,  CUBE_SIZE * offsetZ)
	var vertSouthBottomLeft  = Vector3( CUBE_SIZE * offsetX, -CUBE_SIZE * offsetY, -CUBE_SIZE * offsetZ)
	var vertSouthBottomRight = Vector3(-CUBE_SIZE * offsetX, -CUBE_SIZE * offsetY, -CUBE_SIZE * offsetZ)
	
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
	var cube = MeshInstance.new()
	cube.mesh = resultMesh
	self.add_child(cube)

# The points must be added in clockwise or counter-clockwise or else this function will not work!
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

func _addOrGetVertexFromArray(vertex):
	if dictionaryCheckQuadVerticies.has(vertex) == true:
		return dictionaryCheckQuadVerticies[vertex]
	else:
		arrayQuadVerticies.append(vertex)
		dictionaryCheckQuadVerticies[vertex] = arrayQuadVerticies.size() - 1
		return arrayQuadVerticies.size() - 1
