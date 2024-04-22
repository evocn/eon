// Everett
// Animation
// Alex Hartford
// March 2024

Joint_Sample :: struct
{
    local_position      : Vector3;
    local_orientation   : Quaternion;
    local_scale         : Vector3;
}

Joint_Animation :: struct
{
    name : string;
    samples : [] Joint_Sample;
}

Sampled_Animation :: struct
{
    name : string;
    sample_count : s64;
    joints : [] Joint_Animation;
}

Skeleton_Pose :: struct
{
    skeleton : *Skeleton;
    joints   : [] Joint;
    skinning_matrices : [] Matrix4;

    Joint :: struct
    {
        parent : *Joint;
        using #as sample : Joint_Sample;
        model_space_transform := Matrix4_Identity; // This is the transform matrix of the Joint in model space. It is used for skinning matrices generation.
    }
}

// Allocate a pose for a given skeleton and set it to the bind pose
make_pose_for_skeleton :: (skeleton : *Skeleton) -> Skeleton_Pose #must
{
    result : Skeleton_Pose;
    result.skeleton = skeleton;
    result.joints = NewArray (skeleton.joints.count, Skeleton_Pose.Joint);

    for * result.joints
    {
        joint_in_skeleton := *skeleton.joints[it_index];
        if joint_in_skeleton.parent
        {
            parent_id := joint_in_skeleton.parent - skeleton.joints.data;
            it.parent = *result.joints[parent_id];
        }
        else
            it.parent = null;
    }

    reset_to_bind_pose (*result);

    return result;
}

reset_to_bind_pose :: (using pose : *Skeleton_Pose)
{
    for * joints
    {
        it.local_position,
        it.local_orientation,
        it.local_scale = decompose_transform (skeleton.joints[it_index].local_bind_transform);
    }
}

Interpolation_Mode :: enum s32
{
    NEAREST :: 0;
    LINEAR  :: 1;
    LINEAR_SLERP :: 2;
}

interpolate_joint_samples :: inline (
    a : Joint_Sample,
    b : Joint_Sample,
    t : float,
    interpolation_mode : Interpolation_Mode
) -> Joint_Sample #must
{
    nlerp_shortest :: (a : Quaternion, b : Quaternion, t : float) -> Quaternion #must
    {
        first  := a;
        second := b;
        if dot (first, second) < 0
            second = -second;

        return nlerp (first, second, t);
    }

    slerp_shortest :: (a : Quaternion, b : Quaternion, t : float) -> Quaternion #must
    {
        first  := a;
        second := b;
        if dot (first, second) < 0
            second = -second;

        return slerp (first, second, t);
    }

    result : Joint_Sample = ---;
    if #complete interpolation_mode ==
    {
    case .NEAREST;
        if t < 0.5 then result = a;
        else            result = b;
    case .LINEAR;
        t = clamp (t, 0, 1);
        result.local_position    = lerp (a.local_position, b.local_position, t);
        result.local_orientation = nlerp_shortest (a.local_orientation, b.local_orientation, t);
        result.local_scale       = lerp (a.local_scale, b.local_scale, t);
    case .LINEAR_SLERP;
        t = clamp (t, 0, 1);
        result.local_position    = lerp (a.local_position, b.local_position, t);
        result.local_orientation = slerp_shortest (a.local_orientation, b.local_orientation, t);
        result.local_scale       = lerp (a.local_scale, b.local_scale, t);
    }
    return result;
}


sample_animation :: (
    using anim : Sampled_Animation,
    time_in_samples : float,
    pose : *Skeleton_Pose,
    interpolation_mode := Interpolation_Mode.LINEAR
)
{
    time_in_samples = fmod_cycling(time_in_samples, cast (float) sample_count);
    for joint : joints
    {
        joint_index, ok := table_find(*pose.skeleton.name_to_joint_id, joint.name);
        if !ok
            continue;
        first_index  := cast (s64)time_in_samples;
        second_index := (first_index + 1) % sample_count;
        first  := joint.samples[first_index];
        second := joint.samples[second_index];
        pose.joints[joint_index].sample = interpolate_joint_samples (
            first,
            second,
            time_in_samples - first_index, // [0, 1]
            interpolation_mode
        );
    }
}

// A skinning matrix is the difference between the bind pose and the actual pose we want.
generate_skinning_matrices :: (using pose : *Skeleton_Pose)
{
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *animation_pool;

    // The skinning matrices array isn't allocated as long as you don't call this function.
    if !skinning_matrices.data
        skinning_matrices = NewArray(joints.count, Matrix4, initialized = false,, a);

    calculate_pose_transforms(pose);
    for i : 0..skinning_matrices.count - 1
    {
        skinning_matrices[i] = joints[i].model_space_transform * skeleton.joints[i].inverse_bind_transform;
    }
}

// These are used to generate skinning matrices, but also are useful on their own.
calculate_pose_transforms :: (using pose : *Skeleton_Pose)
{
    for * joints
    {
        local_transform := make_translation_matrix4 (it.local_position)
            * make_scale_matrix4 (it.local_scale)
            * rotation_matrix(Matrix4, it.local_orientation);

        parent := it.parent;
        if parent
            it.model_space_transform = parent.model_space_transform * local_transform;
        else
            it.model_space_transform = local_transform;
    }
}

////////////////////////////////////////////////////////////////////////////////
// Management


create_animation_from_file :: (filename : string) -> Sampled_Animation {
    a: Allocator;
    a.proc = flat_pool_allocator_proc;
    a.data = *animation_pool;

    animation : Sampled_Animation;

    success := load_animation_from_file(*animation, tprint("%/%", animations_path, filename));
    if !success {
        log_error("Unable to load .anim file.\n");
        return animation;
    }

    return animation;
}


load_animation_from_file :: (anim : *Sampled_Animation, filename : string) -> bool
{
    parse_joint :: (handler : *Text_File_Handler, anim : *Sampled_Animation, joint : *Joint_Animation, data : *void) -> bool
    {
        line, ok := consume_next_line (handler);
        if !ok then return error_out (handler, "Could not parse joint name.");

        // @TODO: Make sure the name doesn't already exist!
        joint.name = copy_string (line);
        joint.samples.data = data;
        joint.samples.count = anim.sample_count;
        for i : 0..anim.sample_count - 1
        {
            sample := *joint.samples[i];
            sample.local_position, ok = parse_vector3(handler);
            if !ok then return error_out (handler, "Could not parse joint local position.");
            sample.local_orientation, ok = parse_quaternion(handler);
            if !ok then return error_out (handler, "Could not parse joint local orientation.");
            sample.local_scale, ok = parse_vector3(handler);
            if !ok then return error_out (handler, "Could not parse joint local scale.");
        }

        return true;
    }

    _, name, _, _ := path_decomp(filename);
    anim.name = copy_string(name);

    handler : Text_File_Handler;
    defer deinit(*handler);

    found_slash, dir, basename := split_from_right(filename, #char "/");
    if !found_slash
        basename = filename;
    start_file(*handler, basename, filename, optional = false);
    if handler.failed then return false;
    if handler.version != VERSION then return error_out(handler, "Invalid version number.");

    ok : bool;
    anim.joints.count, ok = parse_ident_and_int_line(*handler, "joint_count");
    if !ok then return false;

    anim.sample_count, ok = parse_ident_and_int_line(*handler, "sample_count");
    if !ok then return false;

    all_data := alloc (size_of(Joint_Animation) * anim.joints.count
        + size_of(Joint_Sample) * anim.sample_count * anim.joints.count);
    anim.joints.data = all_data;
    for * anim.joints
    {
        joint_data := all_data + size_of(Joint_Animation) * anim.joints.count
            + size_of(Joint_Sample) * anim.sample_count * it_index;
        if !parse_joint(*handler, anim, it, joint_data) then return false;
    }

    return true;
}


free_pose :: (pose : *Skeleton_Pose)
{
    free(pose.joints.data);
    free(pose.skinning_matrices.data);
    pose.skeleton = null;
    pose.joints = .[];
    pose.skinning_matrices = .[];
}
