// Everett
// Simulate
// Alex Hartford
// August 2023

simulate :: (entities : *[..] *Entity, delta_time : float) {
    if program_state.paused then return;

    for entities.* {
        update(it, delta_time);
    }
}
