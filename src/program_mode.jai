// Everett
// Main
// Alex Hartford
// August 2023

Program_Mode :: enum {
    GAME;
    EDITOR;
    VIEW;
}

switch_mode :: (new_mode: Program_Mode) {
    program_state.prior_mode = program_state.mode;
    program_state.mode = new_mode;

    if program_state.mode == {
        case .GAME;
        drive_game_camera();

        case .VIEW;
        drive_free_camera();

        case .EDITOR;
        drive_editor_camera();
    }
}

return_to_prior_mode :: () {
    the_current_mode := program_state.mode;
    switch_mode(program_state.prior_mode);
    program_state.prior_mode = the_current_mode;
}

