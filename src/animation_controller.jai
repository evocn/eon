// Everett
// Animation Controller
// Alex Hartford
// April 2024

Animation_Controller :: struct {
    time : float;
    paused : bool;

    animation   : *Sampled_Animation;
    pose        : Skeleton_Pose;
    speed_in_fps: float = 60;
}

update :: (using animation_controller : *Animation_Controller, delta_time : float) {
    reset_to_bind_pose(*pose);

    if !paused {
        time += delta_time * speed_in_fps;
    }

    sample_animation(
        animation,
        time,
        *pose,
        .LINEAR
    );

    generate_skinning_matrices(*pose);

    assert(pose.skinning_matrices.count <= MAX_JOINTS, "Skinning matrices array cannot have more than % elements for now.");
}
