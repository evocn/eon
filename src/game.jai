// Eon
// Game
// Alex Hartford
// March 2024

Game :: struct {
    DEFAULT_CAMERA_ORIGIN :: Vector3.{0, 2, 10};
    DEFAULT_CAMERA_ANGLES :: Vector3.{0, 0, 0};

    entities : [..] *Entity;

    terrain : Terrain;
}
