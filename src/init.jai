// Everett
// Init
// Alex Hartford
// June 2023

init :: () -> bool {
    print("Initializing...\n");
    start_time := cast(float32)get_time();

    {
        // SDL

        SDL_Init(SDL_INIT_VIDEO);

        // Create an application window with the following settings:
        window = SDL_CreateWindow("Everett",
            600, 250, cast(s32)window_width, cast(s32)window_height,
            SDL_WINDOW_OPENGL|SDL_WINDOW_SHOWN);

        if !window {
            print("Could not create window: %\n", to_string(SDL_GetError()));
            return false;
        }
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);

        gl_context = SDL_GL_CreateContext(window);
        if !gl_context {
            print( "Could not create OpenGL context: %\n", to_string(SDL_GetError()));
            return false;
        }  

        gl_load(*gl, SDL_GL_GetProcAddress);
        //print("GL Vendor = %\n", to_string(glGetString(GL_VENDOR)));
        //print("GL Version = %\n", to_string(glGetString(GL_VERSION)));
    }

    
    {
        // OpenGL

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);  
        // @TODO: This is not a complete solution. In order to properly do alpha blending...
        // 1. Draw all the opaque objects.
        // 2. Sort all the transparent objects by distance to the viewer.
        // 3. Draw all the transparent object in sorted order.

        glEnable(GL_DEPTH_TEST); 
        glDepthMask(GL_TRUE);

        glLineWidth(5);
        glPointSize(5);
    }


    {
        // ImGui

        imgui_context = ImGui.CreateContext();
        ImGui_ImplSdl_Init(window);

        ImGui.StyleColorsClassic();
        //ImGui.StyleColorsLight();
    }


    {
        // My Program's Stuff

        // Set the working directory to the base of the project so we can access our folders nicely.
        executable_path := path_strip_filename(get_path_of_running_executable());
        set_working_directory (tprint("%/../", executable_path));

        // Shaders
        render_context.basic_shader     = make_shader("basic.vs", "basic.fs");
        render_context.main_shader      = make_shader("main.vs", "main.fs");
        render_context.animation_shader = make_shader("anim.vs", "main.fs");
        render_context.skybox_shader    = make_shader("skybox.vs", "skybox.fs");

        render_context.screen_shader    = make_shader("screen.vs", "texture.fs");
        render_context.text_shader      = make_shader("text.vs", "text.fs");

        render_context.depth_shader     = make_shader("depth.vs", "depth.fs");

        // Meshes
        table_add(*meshes, "mesh_bird", new_skinned_mesh("bird.mesh"));
        table_add(*meshes, "mesh_cube", new_skinned_mesh("cube.mesh"));
        table_add(*meshes, "mesh_sphere", new_skinned_mesh("sphere.mesh"));
        table_add(*meshes, "mesh_mannequin", new_skinned_mesh("mannequin.mesh"));

        // Primitives
        init_quad_rendering_objects(*quad);
        init_cube_rendering_objects(*cube);

        // Fonts
        table_add(*fonts, "Header", make_font("JosefinSans-Regular.ttf", 24));

        // Textures
        table_add(*textures, "missing", load_texture("missing.png"));

        // Rendering Structures
        load_cubemap_textures(*render_context.skybox, "512_cartoon_green");

        init_rendering_objects(*shadow_map);
        init_rendering_objects(*framebuffer);

        // @TODO!
        /*
        // Animations
        anim : Sampled_Animation;
        loaded = load_animation_from_file(*anim, "assets/animations/idle.anim");
        if !loaded
            log_error ("Could not load % animation.", basename);

        init_rendering_objects(animation_shader);

        animation_time := 0.0;
        animation_speed_in_fps := 20.0;

        pose : Skeleton_Pose;
        pose = make_pose_for_skeleton(*mesh.skeleton);
        */

        set_camera();
        switch_mode(program_state.mode);
    }

    end_time := cast(float32)get_time();

    print("Done! (took % seconds)\n", end_time - start_time);

    return true;
}
