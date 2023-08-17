// Everett
// Undo System
// Alex Hartford
// June 2023

// @TODO: Manage this memory instead of just leaking it...
// @TODO: make sure there aren't weird bugs in here too...

undo_last_command :: () {
    if current_editor_command_index == -1 return;
    undo_command(editor_commands[current_editor_command_index]);
    current_editor_command_index -= 1;
}

redo_next_command :: () {
    if current_editor_command_index >= editor_commands.count - 1 return;

    execute_command(editor_commands[current_editor_command_index + 1]);
    current_editor_command_index += 1;
}

delete_entity :: (entities: *[..] *Entity, index: int) {
    command := New(Delete_Entity_Command);
    command.name = sprint("Delete Entity % | %", entities.*[index].serial, entities.*[index].name);
    command.entities = entities;
    command.index = index;
    command.entity_copy = copy_entity(entities.*[index]);

    append_command(cast(*Command)command);
    execute_command(cast(*Command)command);
}

duplicate_entity :: (entities: *[..] *Entity, index: int) {
    command := New(Duplicate_Entity_Command);
    command.name = sprint("Duplicate Entity % | %", entities.*[index].serial, entities.*[index].name);
    command.entities = entities;
    command.index = index;
    command.entity_copy = copy_entity(entities.*[index]);

    append_command(cast(*Command)command);
    execute_command(cast(*Command)command);
}

//
//

editor_commands : [..] *Command;
current_editor_command_index := -1;

#scope_file

append_command :: (command: *Command) {
    if current_editor_command_index == -1 {
        array_reset(*editor_commands);
    }
    if current_editor_command_index != editor_commands.count - 1 {
        // We delete the rest of the command pipe and add it at the end.
        for i : current_editor_command_index..editor_commands.count-1 {
            free(editor_commands[i]);
        }
        editor_commands.count = current_editor_command_index;
        current_editor_command_index -= 1;
    }

    array_add(*editor_commands, cast(*Command)command);
    current_editor_command_index += 1;
}

execute_command :: (using command : *Command) {
    if kind == {
        case .NONE; return;

        case .DELETE; {
            using cast(*Delete_Entity_Command)command;
            array_ordered_remove_by_index(entities, index);
        }

        case .DUPLICATE; {
            using cast(*Duplicate_Entity_Command)command;
            array_insert_at(entities, entity_copy, index);
        }
    }
}

undo_command :: (using command : *Command) {
    if kind == {
        case .NONE; return;

        case .DELETE; {
            using cast(*Delete_Entity_Command)command;
            array_insert_at(entities, entity_copy, index);
        }

        case .DUPLICATE; {
            using cast(*Duplicate_Entity_Command)command;
            array_ordered_remove_by_index(entities, index+1);
        }
    }
}

Command_Kind :: enum #complete {
    NONE;
    DELETE;
    DUPLICATE;
}

Command :: struct {
    name : string;
    kind : Command_Kind;
}

//
//

Delete_Entity_Command :: struct {
    using #as c: Command;
    kind = .DELETE;

    //

    entities: *[..] *Entity;
    index: int;
    entity_copy: *Entity;
}

Duplicate_Entity_Command :: struct {
    using #as c: Command;
    name = "Duplicate Entity";
    kind = .DUPLICATE;

    //

    entities: *[..] *Entity;
    index: int;
    entity_copy: *Entity;
}
