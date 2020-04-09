# GodotProceduralCubeTerrain
The beginnings of procedural cube (Minecraft-like) terrain in Godot.

# How to setup to make me look dumb
1. Import the project into Godot
2. Run the project
3. Move around with the arrow keys

# How to setup to make me look smart
1. Import the project into Godot
2. Remove the script from the Spatial node
3. Click and drag the ProceduralCubes script onto the Spatial node
4. Run the project
5. Move around with the arrow keys

# Learn
There are now 2 version of terrain generation. The easier one is all inside of the ProceduralCubes script.

The more complicated and non-functional one is spread out across multiple files.
These files are:
- TilePos
- Block
- Chunk
- WorldGenerator
- WorldGenerationGlobals

# Known problems/additions
- Is only 1 layer
- Snaps to half blocks, therefore blocks overlap.
- Doesn't chunk
