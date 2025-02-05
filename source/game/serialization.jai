// Eon
// Serialization
// Alex Hartford
// June 2023

#load "parse_utils.jai";

save_entities :: (entities : [..] *Entity, filename : string) -> success : bool {
    builder : String_Builder;
    defer free_buffers(*builder);

    print_to_builder(*builder, "[%] # Version\n", 1);

    for entities {
        append(*builder, "\n");

        if it.kind == {
            case;
                success := serialize_structure(it.*, *builder);
                if !success return false;
        }
    }
    write_entire_file(tprint("%/%", entities_path, filename), *builder);

    //log(*log_serialization, "Saved entities to \"%\".\n", filename);

    return true;
}

load_entities :: (entities : *[..] *Entity, filename : string) -> success : bool {
    handler : Text_File_Handler;
    defer deinit(*handler);

    start_file(*handler, filename, tprint("%/%", entities_path, filename), optional = false);
    if handler.failed return false;

    if handler.version != VERSION
        return error_out(handler, "Invalid version number.");

    array_reset(entities);

    while handler.file_data {
        new_entity, success := get_next_entity(*handler);
        if !success log_error("File Handler problem with %.\n", filename);
        array_add(entities, new_entity);
    }

    //log(*log_serialization, "Loaded entities from \"%\".\n", filename);

    for entity : entities.* {
        if entity.mesh_name {
            find_entity_mesh(entity);
        }

        if entity.animation_name {
            find_entity_animation(entity);

            entity.pose = make_pose_for_skeleton(*entity.mesh.skeleton);
        }
    }

    return true;
}

// @TODO: Get that logger stuff figured out!
log_serialization : Log_Section;

// %1          = member name
// type_of(%1) = member type
for_each_member :: ($T: Type, format: string) -> string
{
    builder: String_Builder;
    defer free_buffers(*builder);

    struct_info := cast(*Type_Info_Struct) T;
    assert(struct_info.type == Type_Info_Tag.STRUCT);

    for member : struct_info.members 
    {
        if member.flags & .CONSTANT continue;

        for note: member.notes {
            if note == "NoSerialize" then continue member;
        }

        print_to_builder(*builder, format, member.name);
    }

    return builder_to_string(*builder);
}

serialize_structure :: (s: $T, builder: *String_Builder) -> success: bool
{
    #insert #run for_each_member(T, "if !serialize(s.%1, \"%1\", builder) return false;\n" );
    return true;
}

// Definitions for how we want to serialize things.
// Think of these not as code, but as a bunch of settings.
//

serialize  :: (to_serialize: int, name : string, builder: *String_Builder) -> success: bool { 
    print_to_builder(builder, "%", to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true; 
}
serialize  :: (to_serialize: u64, name : string, builder: *String_Builder) -> success: bool { 
    print_to_builder(builder, "%", to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true; 
}
serialize  :: (to_serialize: float, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: bool, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: string, name : string, builder: *String_Builder) -> success: bool { 
    if !to_serialize
        print_to_builder(builder, "!");
    else
        print_to_builder(builder, "%", to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: Vector3, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "% % %", to_serialize.x, to_serialize.y, to_serialize.z);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: Quaternion, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "% % % %", to_serialize.x, to_serialize.y, to_serialize.z, to_serialize.w);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}

//
//

serialize  :: (to_serialize: Entity, name := "", builder: *String_Builder) -> success: bool { 
    success := serialize_structure(to_serialize, builder);
    return success;
}

serialize  :: (to_serialize: Transform, name := "", builder: *String_Builder) -> success: bool { 
    success := serialize_structure(to_serialize, builder);
    return success;
}

serialize  :: (to_serialize: Entity_Kind, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: Direction, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}
serialize  :: (to_serialize: Entity_Flags, name : string, builder: *String_Builder) -> success: bool {
    print_to_builder(builder, "%", cast(int)to_serialize);
    if name print_to_builder(builder, "\t# %", name);
    append(builder, "\n");
    return true;
}

//
//
//

get_next_entity :: (handler : *Text_File_Handler) -> entity: *Entity, success: bool {
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *entity_pool;

    kind_int, is_another_entity_to_get := parse_int(handler);
    if !is_another_entity_to_get return null, false;

    kind := cast(Entity_Kind)kind_int;

    if kind == {
        case;
            entity := New(Entity,, a);
            success := unserialize_structure(entity, handler);
            if !success {
                log_error("Unable to unserialize Unit type in file %.\n");
                return null, false;
            }

            return entity, true;
    }
}

unserialize_structure :: (s: *$T, handler: *Text_File_Handler) -> success: bool {
    success : bool;
    #insert #run for_each_member(T, "if !unserialize(*s.%1, handler) return false;\n" );
    return true;
}

// Definitions for how we want to unserialize things.
// Think of these not as code, but as a bunch of settings.
//

unserialize  :: (to_unserialize: *int, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_int(handler);
    return success;
}
unserialize  :: (to_unserialize: *u64, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_int(handler, u64);
    return success;
}
unserialize  :: (to_unserialize: *float, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_float(handler);
    return success;
}
unserialize  :: (to_unserialize: *bool, handler : *Text_File_Handler) -> success: bool { 
    b, success := parse_int(handler);
    <<to_unserialize = cast(bool)b;
    return success;
}
unserialize  :: (to_unserialize: *string, handler : *Text_File_Handler) -> success: bool { 
    str, success := parse_string(handler);
    if str == "!" then to_unserialize.* = "";
    else {
        a: Allocator;
        a.proc = flat_pool_allocator_proc;
        a.data = *entity_pool;

        to_unserialize.* = copy_string(str,, a);
    }
    return success;
}
unserialize  :: (to_unserialize: *Vector3, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_vector3(handler);
    return success;
}
unserialize  :: (to_unserialize: *Quaternion, handler : *Text_File_Handler) -> success: bool { 
    success : bool;
    <<to_unserialize, success = parse_quaternion(handler);
    return success;
}

unserialize  :: (to_unserialize: *Entity, handler: *Text_File_Handler) -> success: bool {
    success := unserialize_structure(to_unserialize, handler);
    return success;
}

unserialize  :: (to_unserialize: *Transform, handler: *Text_File_Handler) -> success: bool {
    success := unserialize_structure(to_unserialize, handler);
    return success;
}

unserialize  :: (to_unserialize: *Entity_Kind, handler: *Text_File_Handler) -> success: bool {
    // @NOTE: We parse this separately so we know what kind of entity we're lookin at.
    return true;
}

unserialize  :: (to_unserialize: *Direction, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(Direction)i;
    return success;
}

unserialize  :: (to_unserialize: *Entity_Flags, handler: *Text_File_Handler) -> success: bool {
    i, success := parse_int(handler);
    <<to_unserialize = cast(Entity_Flags)i;
    return success;
}
