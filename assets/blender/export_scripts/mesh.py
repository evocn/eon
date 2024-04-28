
import bpy

from bpy_extras.io_utils import (
	ExportHelper,
	orientation_helper,
	axis_conversion
)

version = 1

class Exporter (bpy.types.Operator, ExportHelper):
	"""Export mesh data"""
	bl_idname = "export.eon_mesh"
	bl_label = "Eon (.mesh)"
	bl_options = { 'REGISTER', 'UNDO' }
	filename_ext = ".mesh"

	def execute (self, context : bpy.types.Context):
		context.window.cursor_set ('WAIT')

		export_mesh(self.filepath)

		context.window.cursor_set ('DEFAULT')

		return { 'FINISHED' }

def export_menu_func (self, context : bpy.types.Context):
	self.layout.operator (Exporter.bl_idname)

def format_float(value):
    if abs(value) < 0.00001:
        return "0.00000"
    else:
        return "{:.6f}".format(value)

def export_mesh(filepath):
    # Get the currently active scene
    scene = bpy.context.scene

    # Filter objects to find the top-level object
    top_level_objects = [obj for obj in scene.objects if obj.parent is None]

    if len(top_level_objects) == 0:
        print("No objects in the scene. Nothing to export.")
        return

    armature = top_level_objects[0]
    if armature.type != 'ARMATURE':
        print("Top-level object is not an armature. Please select an armature as the active object.")
        return


    # Get vertex count and triangle count
    vertex_count = 0
    triangle_count = 0
    for obj in bpy.context.scene.objects:
        if obj.type == 'MESH':
            mesh = obj.data
            vertex_count += len(mesh.vertices)
            triangle_count += len(mesh.polygons)


    with open(filepath, 'w') as file:
        file.write(f"[{version}]\n\n")
        
        file.write(f"joint_count\t\t{len(armature.data.bones)}\n")
        file.write(f"vertex_count\t{vertex_count}\n")
        file.write(f"triangle_count\t{triangle_count}\n")

        # Write armature joint names, bind pose matrices, and their parent indices.
        file.write("\njoints:\n")
        for bone in armature.data.bones:
            if bone.parent:
                parent_index = armature.data.bones.find(bone.parent.name)
            else:
                parent_index = -1

            if bone.parent:
                local_bind_transform = bone.parent.matrix_local.inverted() @ bone.matrix_local
            else:
                local_bind_transform = bone.matrix_local

            file.write(f"{bone.name}\n")
            for row in local_bind_transform:
                formatted_row = " ".join(format_float(cell) for cell in row)
                file.write(formatted_row + "\n")
            file.write(f"{parent_index}\n")
            file.write("\n")

        # Write vertex data for each mesh object in scene
        for obj in bpy.context.scene.objects:
            if obj.type != 'MESH':
                continue
            
            mesh = obj.data
            file.write("\nvertices:\n")
            for vert in mesh.vertices:
                # Vertex Position
                formatted_co = " ".join(format_float(co) for co in vert.co)
                file.write(formatted_co + "\n")
                
                # Vertex Normal
                formatted_no = " ".join(format_float(no) for no in vert.normal)
                file.write(formatted_no + "\n")
                
                # Vertex UV
                if mesh.uv_layers.active:
                    uv_layer = mesh.uv_layers.active.data
                    uv_coords = uv_layer[vert.index].uv
                    formatted_uv = " ".join(format_float(uv) for uv in uv_coords)
                    file.write(formatted_uv + "\n")

                # Vertex Weights and Joints
                weights = []
                joint_indices = []  # Changed from joint names to indices
                for group in vert.groups:
                    if len(weights) < 4:
                        joint_name = obj.vertex_groups[group.group].name
                        weight = group.weight
                        joint_index = armature.data.bones.find(joint_name)  # Get the index of the joint
                        if joint_index >= 0:
                            joint_indices.append(str(joint_index))
                            weights.append(weight)
                while len(weights) < 4:
                    joint_indices.append("-1")  # Placeholder for non-influenced vertices
                    weights.append(0)

                # Normalize these suckas
                length = weights[0] + weights[1] + weights[2] + weights[3];
                weights[0] = weights[0] / length;
                weights[1] = weights[1] / length;
                weights[2] = weights[2] / length;
                weights[3] = weights[3] / length;

                formatted_weights = " ".join(format_float(w) for w in weights)
                formatted_joint_indices = " ".join(joint_indices)
                file.write(formatted_weights + "\n")
                file.write(formatted_joint_indices + "\n")

                # Add whitespace between each vertex
                file.write("\n")

        # Write triangle indices for each mesh object in scene
        for obj in bpy.context.scene.objects:
            if obj.type != 'MESH':
                continue
            
            mesh = obj.data
            file.write("\ntriangles:\n")
            for poly in mesh.polygons:
                if len(poly.vertices) != 3: # Ensure it's a triangle
                    print("This thing has a polygon that isn't a triangle. Fix that first!")
                    return

                indices = [str(v) for v in poly.vertices]
                file.write(" ".join(indices) + "\n")
