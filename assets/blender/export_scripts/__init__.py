bl_info = {
    "name": "Everett Addon",
    "author": "Alex Hartford",
    "version": (1, 0),
    "blender": (3, 6, 0),
    "location": "File > Export",
    "category": "Import-Export",
}

import bpy

from . import mesh
from . import anim

def register():
	bpy.utils.register_class (mesh.Exporter)
	bpy.utils.register_class (anim.Exporter)
	bpy.types.TOPBAR_MT_file_export.append (mesh.export_menu_func)
	bpy.types.TOPBAR_MT_file_export.append (anim.export_menu_func)

def unregister():
	bpy.utils.unregister_class (mesh.Exporter)
	bpy.utils.unregister_class (anim.Exporter)
	bpy.types.TOPBAR_MT_file_export.remove (mesh.export_menu_func)
	bpy.types.TOPBAR_MT_file_export.remove (anim.export_menu_func)

if __name__ == "__main__":
	register ()
