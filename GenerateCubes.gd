extends Spatial

var pointColor = SpatialMaterial.new()
var blockColor = SpatialMaterial.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pointColor.albedo_color = Color(.25, .82, .17)
	blockColor.albedo_color = Color(.08, .46, 1)
	makeBlocks(5, 5, 5)

func makeBlocks(numOfCubesX, numOfCubesY, numOfCubesZ, highlightPoints = true):
	var block = null
	var offset = 2
	
	for i in range(numOfCubesX):
		var xOffset = offset * i
		block = MeshInstance.new()
		block.mesh = CubeMesh.new()
		block.set_surface_material(0, blockColor)
		highlightPoints(block) 
		block.translate(Vector3(xOffset, 0, 0))
		self.add_child(block)
		for j in range(numOfCubesY):
			var yOffset = offset * j
			block = MeshInstance.new()
			block.mesh = CubeMesh.new()
			block.set_surface_material(0, blockColor)
			highlightPoints(block)
			block.translate(Vector3(xOffset, yOffset, 0))
			self.add_child(block)
			for k in range(numOfCubesZ):
				var zOffset = offset * k
				block = MeshInstance.new()
				block.mesh = CubeMesh.new()
				block.set_surface_material(0, blockColor)
				highlightPoints(block)
				block.translate(Vector3(xOffset, yOffset, zOffset))
				self.add_child(block)

func highlightPoints(block):
	for i in range(8):
		var point = MeshInstance.new()
		point.mesh = SphereMesh.new();
		point.set_surface_material(0, pointColor)
		point.set_scale(Vector3(.1, .1, .1))
		point.translate(block.get_aabb().get_endpoint(i) / .1)
		block.add_child(point)
		
func createPointCube(size):
	var point = MeshInstance.new()
	point.mesh = SphereMesh.new();
	point.set_surface_material(0, pointColor)
	point.set_scale(Vector3(.1, .1, .1))
	for i in range(8):
		point.translate(size / .1)
	