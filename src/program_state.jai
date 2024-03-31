// Everett
// Program State
// Alex Hartford
// March 2024

////////////////////////////////////////////////////////////////////////////////

Program_Mode :: enum {
    GAME;
    EDITOR;
    VIEW;
}

switch_mode :: (new_mode: Program_Mode) {
    program_state.prior_mode = program_state.mode;
    program_state.mode = new_mode;

    // Change program state according to the new mode.
    if program_state.mode == {
        case .GAME;
        program_drive_game_camera();

        case .VIEW;
        program_drive_free_camera();

        case .EDITOR;
        program_drive_editor_camera();
    }
}

return_to_prior_mode :: () {
    the_current_mode := program_state.mode;
    switch_mode(program_state.prior_mode);
    program_state.prior_mode = the_current_mode;
}

