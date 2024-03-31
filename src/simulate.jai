// Everett
// Simulate
// Alex Hartford
// August 2023

simulate :: (game: *Game, delta_time : float) {
    for entity : game.entities {
        update(entity, delta_time);
    }
}
