// Everett
// Gizmos
// Alex Hartford
// June 2023

maybe_select_entity :: (entities: [..] *Entity) {
    if input.left_click {
        find_which_entity_pointed_at(entities);
        input.left_click = false;
    }
    if input.right_click {
        editor.selected_entity = -1;
        input.right_click = false;
    }
}

// @TODO:
// Track the distance of each t value to get the closest collision.
// Make bounding boxes change with scale.
find_which_entity_pointed_at :: (entities: [..] *Entity) {
    x, y : s32;
    buttons := SDL_GetMouseState(*x, *y);

    ray := generate_mouse_ray(xx x, xx y);

    for entities {
        new_box : Box;
        if it.kind == {
            case;
                new_box = Box.{it.position - Vector3.{1, 1, 0}, it.position + Vector3.{1, 1, 1}};
        }

        intersected := intersection(ray, new_box);
        if intersected {
            editor.selected_entity = it_index;
        }
    }
}
