//
// This file was auto-generated using the following command:
//
// jai first.jai
//



FAST_OBJ_VERSION_MAJOR :: 1;
FAST_OBJ_VERSION_MINOR :: 2;
FAST_OBJ_VERSION :: (FAST_OBJ_VERSION_MAJOR << 8) | FAST_OBJ_VERSION_MINOR;

fastObjTexture :: struct {
    /* Texture name from .mtl file */
    name: *u8;

    /* Resolved path to texture */
    path: *u8;
}

fastObjMaterial :: struct {
    /* Material name */
    name:     *u8;

    Ka:       [3] float; /* Ambient */
    Kd:       [3] float; /* Diffuse */
    Ks:       [3] float; /* Specular */
    Ke:       [3] float; /* Emission */
    Kt:       [3] float; /* Transmittance */
    Ns:       float; /* Shininess */
    Ni:       float; /* Index of refraction */
    Tf:       [3] float; /* Transmission filter */
    d:        float; /* Disolve (alpha) */
    illum:    s32; /* Illumination model */

    /* Texture maps */
    map_Ka:   fastObjTexture;
    map_Kd:   fastObjTexture;
    map_Ks:   fastObjTexture;
    map_Ke:   fastObjTexture;
    map_Kt:   fastObjTexture;
    map_Ns:   fastObjTexture;
    map_Ni:   fastObjTexture;
    map_d:    fastObjTexture;
    map_bump: fastObjTexture;
}

fastObjUInt :: u32;

fastObjIndex :: struct {
    p: fastObjUInt;
    t: fastObjUInt;
    n: fastObjUInt;
}

fastObjGroup :: struct {
    /* Group name */
    name:         *u8;

    /* Number of faces */
    face_count:   u32;

    /* First face in fastObjMesh face_* arrays */
    face_offset:  u32;

    /* First index in fastObjMesh indices array */
    index_offset: u32;
}

fastObjMesh :: struct {
    /* Vertex data */
    position_count: u32;
    positions:      *float;

    texcoord_count: u32;
    texcoords:      *float;

    normal_count:   u32;
    normals:        *float;

    color_count:    u32;
    colors:         *float;

    /* Face data: one element for each face */
    face_count:     u32;
    face_vertices:  *u32;
    face_materials: *u32;

    /* Index data: one element for each face vertex */
    index_count:    u32;
    indices:        *fastObjIndex;

    /* Materials */
    material_count: u32;
    materials:      *fastObjMaterial;

    /* Mesh objects ('o' tag in .obj file) */
    object_count:   u32;
    objects:        *fastObjGroup;

    /* Mesh groups ('g' tag in .obj file) */
    group_count:    u32;
    groups:         *fastObjGroup;
}

fastObjCallbacks :: struct {
    file_open:  #type (path: *u8, user_data: *void) -> *void #c_call;
    file_close: #type (file: *void, user_data: *void) -> void #c_call;
    file_read:  #type (file: *void, dst: *void, bytes: size_t, user_data: *void) -> size_t #c_call;
    file_size:  #type (file: *void, user_data: *void) -> u32 #c_call;
}

fast_obj_read :: (path: *u8) -> *fastObjMesh #foreign fast_obj;
fast_obj_read_with_callbacks :: (path: *u8, callbacks: *fastObjCallbacks, user_data: *void) -> *fastObjMesh #foreign fast_obj;
fast_obj_destroy :: (mesh: *fastObjMesh) -> void #foreign fast_obj;

#scope_file

#import "Basic"; // For assert

fast_obj :: #library "./fast_obj";

#run {
    {
        instance: fastObjTexture;
        assert(((cast(*void)(*instance.name)) - cast(*void)(*instance)) == 0, "fastObjTexture.name has unexpected offset % instead of 0", ((cast(*void)(*instance.name)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjTexture.name)) == 8, "fastObjTexture.name has unexpected size % instead of 8", size_of(type_of(fastObjTexture.name)));
        assert(((cast(*void)(*instance.path)) - cast(*void)(*instance)) == 8, "fastObjTexture.path has unexpected offset % instead of 8", ((cast(*void)(*instance.path)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjTexture.path)) == 8, "fastObjTexture.path has unexpected size % instead of 8", size_of(type_of(fastObjTexture.path)));
        assert(size_of(fastObjTexture) == 16, "fastObjTexture has size % instead of 16", size_of(fastObjTexture));
    }

    {
        instance: fastObjMaterial;
        assert(((cast(*void)(*instance.name)) - cast(*void)(*instance)) == 0, "fastObjMaterial.name has unexpected offset % instead of 0", ((cast(*void)(*instance.name)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.name)) == 8, "fastObjMaterial.name has unexpected size % instead of 8", size_of(type_of(fastObjMaterial.name)));
        assert(((cast(*void)(*instance.Ka)) - cast(*void)(*instance)) == 8, "fastObjMaterial.Ka has unexpected offset % instead of 8", ((cast(*void)(*instance.Ka)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.Ka)) == 12, "fastObjMaterial.Ka has unexpected size % instead of 12", size_of(type_of(fastObjMaterial.Ka)));
        assert(((cast(*void)(*instance.Kd)) - cast(*void)(*instance)) == 20, "fastObjMaterial.Kd has unexpected offset % instead of 20", ((cast(*void)(*instance.Kd)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.Kd)) == 12, "fastObjMaterial.Kd has unexpected size % instead of 12", size_of(type_of(fastObjMaterial.Kd)));
        assert(((cast(*void)(*instance.Ks)) - cast(*void)(*instance)) == 32, "fastObjMaterial.Ks has unexpected offset % instead of 32", ((cast(*void)(*instance.Ks)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.Ks)) == 12, "fastObjMaterial.Ks has unexpected size % instead of 12", size_of(type_of(fastObjMaterial.Ks)));
        assert(((cast(*void)(*instance.Ke)) - cast(*void)(*instance)) == 44, "fastObjMaterial.Ke has unexpected offset % instead of 44", ((cast(*void)(*instance.Ke)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.Ke)) == 12, "fastObjMaterial.Ke has unexpected size % instead of 12", size_of(type_of(fastObjMaterial.Ke)));
        assert(((cast(*void)(*instance.Kt)) - cast(*void)(*instance)) == 56, "fastObjMaterial.Kt has unexpected offset % instead of 56", ((cast(*void)(*instance.Kt)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.Kt)) == 12, "fastObjMaterial.Kt has unexpected size % instead of 12", size_of(type_of(fastObjMaterial.Kt)));
        assert(((cast(*void)(*instance.Ns)) - cast(*void)(*instance)) == 68, "fastObjMaterial.Ns has unexpected offset % instead of 68", ((cast(*void)(*instance.Ns)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.Ns)) == 4, "fastObjMaterial.Ns has unexpected size % instead of 4", size_of(type_of(fastObjMaterial.Ns)));
        assert(((cast(*void)(*instance.Ni)) - cast(*void)(*instance)) == 72, "fastObjMaterial.Ni has unexpected offset % instead of 72", ((cast(*void)(*instance.Ni)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.Ni)) == 4, "fastObjMaterial.Ni has unexpected size % instead of 4", size_of(type_of(fastObjMaterial.Ni)));
        assert(((cast(*void)(*instance.Tf)) - cast(*void)(*instance)) == 76, "fastObjMaterial.Tf has unexpected offset % instead of 76", ((cast(*void)(*instance.Tf)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.Tf)) == 12, "fastObjMaterial.Tf has unexpected size % instead of 12", size_of(type_of(fastObjMaterial.Tf)));
        assert(((cast(*void)(*instance.d)) - cast(*void)(*instance)) == 88, "fastObjMaterial.d has unexpected offset % instead of 88", ((cast(*void)(*instance.d)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.d)) == 4, "fastObjMaterial.d has unexpected size % instead of 4", size_of(type_of(fastObjMaterial.d)));
        assert(((cast(*void)(*instance.illum)) - cast(*void)(*instance)) == 92, "fastObjMaterial.illum has unexpected offset % instead of 92", ((cast(*void)(*instance.illum)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.illum)) == 4, "fastObjMaterial.illum has unexpected size % instead of 4", size_of(type_of(fastObjMaterial.illum)));
        assert(((cast(*void)(*instance.map_Ka)) - cast(*void)(*instance)) == 96, "fastObjMaterial.map_Ka has unexpected offset % instead of 96", ((cast(*void)(*instance.map_Ka)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.map_Ka)) == 16, "fastObjMaterial.map_Ka has unexpected size % instead of 16", size_of(type_of(fastObjMaterial.map_Ka)));
        assert(((cast(*void)(*instance.map_Kd)) - cast(*void)(*instance)) == 112, "fastObjMaterial.map_Kd has unexpected offset % instead of 112", ((cast(*void)(*instance.map_Kd)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.map_Kd)) == 16, "fastObjMaterial.map_Kd has unexpected size % instead of 16", size_of(type_of(fastObjMaterial.map_Kd)));
        assert(((cast(*void)(*instance.map_Ks)) - cast(*void)(*instance)) == 128, "fastObjMaterial.map_Ks has unexpected offset % instead of 128", ((cast(*void)(*instance.map_Ks)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.map_Ks)) == 16, "fastObjMaterial.map_Ks has unexpected size % instead of 16", size_of(type_of(fastObjMaterial.map_Ks)));
        assert(((cast(*void)(*instance.map_Ke)) - cast(*void)(*instance)) == 144, "fastObjMaterial.map_Ke has unexpected offset % instead of 144", ((cast(*void)(*instance.map_Ke)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.map_Ke)) == 16, "fastObjMaterial.map_Ke has unexpected size % instead of 16", size_of(type_of(fastObjMaterial.map_Ke)));
        assert(((cast(*void)(*instance.map_Kt)) - cast(*void)(*instance)) == 160, "fastObjMaterial.map_Kt has unexpected offset % instead of 160", ((cast(*void)(*instance.map_Kt)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.map_Kt)) == 16, "fastObjMaterial.map_Kt has unexpected size % instead of 16", size_of(type_of(fastObjMaterial.map_Kt)));
        assert(((cast(*void)(*instance.map_Ns)) - cast(*void)(*instance)) == 176, "fastObjMaterial.map_Ns has unexpected offset % instead of 176", ((cast(*void)(*instance.map_Ns)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.map_Ns)) == 16, "fastObjMaterial.map_Ns has unexpected size % instead of 16", size_of(type_of(fastObjMaterial.map_Ns)));
        assert(((cast(*void)(*instance.map_Ni)) - cast(*void)(*instance)) == 192, "fastObjMaterial.map_Ni has unexpected offset % instead of 192", ((cast(*void)(*instance.map_Ni)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.map_Ni)) == 16, "fastObjMaterial.map_Ni has unexpected size % instead of 16", size_of(type_of(fastObjMaterial.map_Ni)));
        assert(((cast(*void)(*instance.map_d)) - cast(*void)(*instance)) == 208, "fastObjMaterial.map_d has unexpected offset % instead of 208", ((cast(*void)(*instance.map_d)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.map_d)) == 16, "fastObjMaterial.map_d has unexpected size % instead of 16", size_of(type_of(fastObjMaterial.map_d)));
        assert(((cast(*void)(*instance.map_bump)) - cast(*void)(*instance)) == 224, "fastObjMaterial.map_bump has unexpected offset % instead of 224", ((cast(*void)(*instance.map_bump)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMaterial.map_bump)) == 16, "fastObjMaterial.map_bump has unexpected size % instead of 16", size_of(type_of(fastObjMaterial.map_bump)));
        assert(size_of(fastObjMaterial) == 240, "fastObjMaterial has size % instead of 240", size_of(fastObjMaterial));
    }

    {
        instance: fastObjIndex;
        assert(((cast(*void)(*instance.p)) - cast(*void)(*instance)) == 0, "fastObjIndex.p has unexpected offset % instead of 0", ((cast(*void)(*instance.p)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjIndex.p)) == 4, "fastObjIndex.p has unexpected size % instead of 4", size_of(type_of(fastObjIndex.p)));
        assert(((cast(*void)(*instance.t)) - cast(*void)(*instance)) == 4, "fastObjIndex.t has unexpected offset % instead of 4", ((cast(*void)(*instance.t)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjIndex.t)) == 4, "fastObjIndex.t has unexpected size % instead of 4", size_of(type_of(fastObjIndex.t)));
        assert(((cast(*void)(*instance.n)) - cast(*void)(*instance)) == 8, "fastObjIndex.n has unexpected offset % instead of 8", ((cast(*void)(*instance.n)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjIndex.n)) == 4, "fastObjIndex.n has unexpected size % instead of 4", size_of(type_of(fastObjIndex.n)));
        assert(size_of(fastObjIndex) == 12, "fastObjIndex has size % instead of 12", size_of(fastObjIndex));
    }

    {
        instance: fastObjGroup;
        assert(((cast(*void)(*instance.name)) - cast(*void)(*instance)) == 0, "fastObjGroup.name has unexpected offset % instead of 0", ((cast(*void)(*instance.name)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjGroup.name)) == 8, "fastObjGroup.name has unexpected size % instead of 8", size_of(type_of(fastObjGroup.name)));
        assert(((cast(*void)(*instance.face_count)) - cast(*void)(*instance)) == 8, "fastObjGroup.face_count has unexpected offset % instead of 8", ((cast(*void)(*instance.face_count)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjGroup.face_count)) == 4, "fastObjGroup.face_count has unexpected size % instead of 4", size_of(type_of(fastObjGroup.face_count)));
        assert(((cast(*void)(*instance.face_offset)) - cast(*void)(*instance)) == 12, "fastObjGroup.face_offset has unexpected offset % instead of 12", ((cast(*void)(*instance.face_offset)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjGroup.face_offset)) == 4, "fastObjGroup.face_offset has unexpected size % instead of 4", size_of(type_of(fastObjGroup.face_offset)));
        assert(((cast(*void)(*instance.index_offset)) - cast(*void)(*instance)) == 16, "fastObjGroup.index_offset has unexpected offset % instead of 16", ((cast(*void)(*instance.index_offset)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjGroup.index_offset)) == 4, "fastObjGroup.index_offset has unexpected size % instead of 4", size_of(type_of(fastObjGroup.index_offset)));
        assert(size_of(fastObjGroup) == 24, "fastObjGroup has size % instead of 24", size_of(fastObjGroup));
    }

    {
        instance: fastObjMesh;
        assert(((cast(*void)(*instance.position_count)) - cast(*void)(*instance)) == 0, "fastObjMesh.position_count has unexpected offset % instead of 0", ((cast(*void)(*instance.position_count)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.position_count)) == 4, "fastObjMesh.position_count has unexpected size % instead of 4", size_of(type_of(fastObjMesh.position_count)));
        assert(((cast(*void)(*instance.positions)) - cast(*void)(*instance)) == 8, "fastObjMesh.positions has unexpected offset % instead of 8", ((cast(*void)(*instance.positions)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.positions)) == 8, "fastObjMesh.positions has unexpected size % instead of 8", size_of(type_of(fastObjMesh.positions)));
        assert(((cast(*void)(*instance.texcoord_count)) - cast(*void)(*instance)) == 16, "fastObjMesh.texcoord_count has unexpected offset % instead of 16", ((cast(*void)(*instance.texcoord_count)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.texcoord_count)) == 4, "fastObjMesh.texcoord_count has unexpected size % instead of 4", size_of(type_of(fastObjMesh.texcoord_count)));
        assert(((cast(*void)(*instance.texcoords)) - cast(*void)(*instance)) == 24, "fastObjMesh.texcoords has unexpected offset % instead of 24", ((cast(*void)(*instance.texcoords)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.texcoords)) == 8, "fastObjMesh.texcoords has unexpected size % instead of 8", size_of(type_of(fastObjMesh.texcoords)));
        assert(((cast(*void)(*instance.normal_count)) - cast(*void)(*instance)) == 32, "fastObjMesh.normal_count has unexpected offset % instead of 32", ((cast(*void)(*instance.normal_count)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.normal_count)) == 4, "fastObjMesh.normal_count has unexpected size % instead of 4", size_of(type_of(fastObjMesh.normal_count)));
        assert(((cast(*void)(*instance.normals)) - cast(*void)(*instance)) == 40, "fastObjMesh.normals has unexpected offset % instead of 40", ((cast(*void)(*instance.normals)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.normals)) == 8, "fastObjMesh.normals has unexpected size % instead of 8", size_of(type_of(fastObjMesh.normals)));
        assert(((cast(*void)(*instance.color_count)) - cast(*void)(*instance)) == 48, "fastObjMesh.color_count has unexpected offset % instead of 48", ((cast(*void)(*instance.color_count)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.color_count)) == 4, "fastObjMesh.color_count has unexpected size % instead of 4", size_of(type_of(fastObjMesh.color_count)));
        assert(((cast(*void)(*instance.colors)) - cast(*void)(*instance)) == 56, "fastObjMesh.colors has unexpected offset % instead of 56", ((cast(*void)(*instance.colors)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.colors)) == 8, "fastObjMesh.colors has unexpected size % instead of 8", size_of(type_of(fastObjMesh.colors)));
        assert(((cast(*void)(*instance.face_count)) - cast(*void)(*instance)) == 64, "fastObjMesh.face_count has unexpected offset % instead of 64", ((cast(*void)(*instance.face_count)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.face_count)) == 4, "fastObjMesh.face_count has unexpected size % instead of 4", size_of(type_of(fastObjMesh.face_count)));
        assert(((cast(*void)(*instance.face_vertices)) - cast(*void)(*instance)) == 72, "fastObjMesh.face_vertices has unexpected offset % instead of 72", ((cast(*void)(*instance.face_vertices)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.face_vertices)) == 8, "fastObjMesh.face_vertices has unexpected size % instead of 8", size_of(type_of(fastObjMesh.face_vertices)));
        assert(((cast(*void)(*instance.face_materials)) - cast(*void)(*instance)) == 80, "fastObjMesh.face_materials has unexpected offset % instead of 80", ((cast(*void)(*instance.face_materials)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.face_materials)) == 8, "fastObjMesh.face_materials has unexpected size % instead of 8", size_of(type_of(fastObjMesh.face_materials)));
        assert(((cast(*void)(*instance.index_count)) - cast(*void)(*instance)) == 88, "fastObjMesh.index_count has unexpected offset % instead of 88", ((cast(*void)(*instance.index_count)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.index_count)) == 4, "fastObjMesh.index_count has unexpected size % instead of 4", size_of(type_of(fastObjMesh.index_count)));
        assert(((cast(*void)(*instance.indices)) - cast(*void)(*instance)) == 96, "fastObjMesh.indices has unexpected offset % instead of 96", ((cast(*void)(*instance.indices)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.indices)) == 8, "fastObjMesh.indices has unexpected size % instead of 8", size_of(type_of(fastObjMesh.indices)));
        assert(((cast(*void)(*instance.material_count)) - cast(*void)(*instance)) == 104, "fastObjMesh.material_count has unexpected offset % instead of 104", ((cast(*void)(*instance.material_count)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.material_count)) == 4, "fastObjMesh.material_count has unexpected size % instead of 4", size_of(type_of(fastObjMesh.material_count)));
        assert(((cast(*void)(*instance.materials)) - cast(*void)(*instance)) == 112, "fastObjMesh.materials has unexpected offset % instead of 112", ((cast(*void)(*instance.materials)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.materials)) == 8, "fastObjMesh.materials has unexpected size % instead of 8", size_of(type_of(fastObjMesh.materials)));
        assert(((cast(*void)(*instance.object_count)) - cast(*void)(*instance)) == 120, "fastObjMesh.object_count has unexpected offset % instead of 120", ((cast(*void)(*instance.object_count)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.object_count)) == 4, "fastObjMesh.object_count has unexpected size % instead of 4", size_of(type_of(fastObjMesh.object_count)));
        assert(((cast(*void)(*instance.objects)) - cast(*void)(*instance)) == 128, "fastObjMesh.objects has unexpected offset % instead of 128", ((cast(*void)(*instance.objects)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.objects)) == 8, "fastObjMesh.objects has unexpected size % instead of 8", size_of(type_of(fastObjMesh.objects)));
        assert(((cast(*void)(*instance.group_count)) - cast(*void)(*instance)) == 136, "fastObjMesh.group_count has unexpected offset % instead of 136", ((cast(*void)(*instance.group_count)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.group_count)) == 4, "fastObjMesh.group_count has unexpected size % instead of 4", size_of(type_of(fastObjMesh.group_count)));
        assert(((cast(*void)(*instance.groups)) - cast(*void)(*instance)) == 144, "fastObjMesh.groups has unexpected offset % instead of 144", ((cast(*void)(*instance.groups)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjMesh.groups)) == 8, "fastObjMesh.groups has unexpected size % instead of 8", size_of(type_of(fastObjMesh.groups)));
        assert(size_of(fastObjMesh) == 152, "fastObjMesh has size % instead of 152", size_of(fastObjMesh));
    }

    {
        instance: fastObjCallbacks;
        assert(((cast(*void)(*instance.file_open)) - cast(*void)(*instance)) == 0, "fastObjCallbacks.file_open has unexpected offset % instead of 0", ((cast(*void)(*instance.file_open)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjCallbacks.file_open)) == 8, "fastObjCallbacks.file_open has unexpected size % instead of 8", size_of(type_of(fastObjCallbacks.file_open)));
        assert(((cast(*void)(*instance.file_close)) - cast(*void)(*instance)) == 8, "fastObjCallbacks.file_close has unexpected offset % instead of 8", ((cast(*void)(*instance.file_close)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjCallbacks.file_close)) == 8, "fastObjCallbacks.file_close has unexpected size % instead of 8", size_of(type_of(fastObjCallbacks.file_close)));
        assert(((cast(*void)(*instance.file_read)) - cast(*void)(*instance)) == 16, "fastObjCallbacks.file_read has unexpected offset % instead of 16", ((cast(*void)(*instance.file_read)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjCallbacks.file_read)) == 8, "fastObjCallbacks.file_read has unexpected size % instead of 8", size_of(type_of(fastObjCallbacks.file_read)));
        assert(((cast(*void)(*instance.file_size)) - cast(*void)(*instance)) == 24, "fastObjCallbacks.file_size has unexpected offset % instead of 24", ((cast(*void)(*instance.file_size)) - cast(*void)(*instance)));
        assert(size_of(type_of(fastObjCallbacks.file_size)) == 8, "fastObjCallbacks.file_size has unexpected size % instead of 8", size_of(type_of(fastObjCallbacks.file_size)));
        assert(size_of(fastObjCallbacks) == 32, "fastObjCallbacks has size % instead of 32", size_of(fastObjCallbacks));
    }
}

