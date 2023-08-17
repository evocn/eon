// Workspace: Everett Workspace
//
// #insert text. Generated from C:/Users/alexa/Code/everett/src//serialization.jai:196.
//
if !unserialize(*s.kind, handler) return false;
if !unserialize(*s.serial, handler) return false;
if !unserialize(*s.name, handler) return false;
if !unserialize(*s.position, handler) return false;
if !unserialize(*s.orientation, handler) return false;
if !unserialize(*s.scale, handler) return false;
if !unserialize(*s.flags, handler) return false;
if !unserialize(*s.mesh_name, handler) return false;

//
// #insert text. Generated from C:/Users/alexa/Code/everett/src//serialization.jai:88.
//
if !serialize(s.kind, "kind", builder) return false;
if !serialize(s.serial, "serial", builder) return false;
if !serialize(s.name, "name", builder) return false;
if !serialize(s.position, "position", builder) return false;
if !serialize(s.orientation, "orientation", builder) return false;
if !serialize(s.scale, "scale", builder) return false;
if !serialize(s.flags, "flags", builder) return false;
if !serialize(s.mesh_name, "mesh_name", builder) return false;
