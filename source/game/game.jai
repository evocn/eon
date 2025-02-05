// Eon
// Game
// Alex Hartford
// March 2024

#load "entity.jai";
#load "serialization.jai";
#load "character_controller.jai";

Game :: struct {
    DEFAULT_CAMERA_ORIGIN :: Vector3.{0, 2, 10};
    DEFAULT_CAMERA_ANGLES :: Vector3.{0, 0, 0};

    entities : [..] *Entity;

    terrain : Terrain;
}

simulate :: (game: *Game, delta_time : float) {
    for entity : game.entities {
        update(entity, delta_time);
    }
}
