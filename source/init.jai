// Eon
// Init
// Alex Hartford
// June 2023

init :: () -> bool {
    log("Initializing...\n");
    start_time := cast(float32)seconds_since_init();

    // Set the working directory to the base of the project so we can access our folders nicely.
    executable_path := path_strip_filename(get_path_of_running_executable());
    set_working_directory (tprint("%/../", executable_path));

    {
        // SDL
        SDL_Init(SDL_INIT_VIDEO);

        // Create an application window with the following settings:
        window = SDL_CreateWindow("Eon",
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

        {
            glEnable(GL_MULTISAMPLE);

            glEnable(GL_CULL_FACE);

            glEnable(GL_DEPTH_TEST); 
            glDepthMask(GL_TRUE);

            glLineWidth(5);
            glPointSize(10);
        }
    }


    {
        // ImGui
        imgui_context = ImGui.CreateContext();
        ImGui_ImplSdl_Init(window);

        {
            io := ImGui.GetIO();
            io.Fonts.AddFontFromFileTTF(io.Fonts, "assets/fonts/verdanab.ttf", window_height / 40.0, null, io.Fonts.GetGlyphRangesDefault(io.Fonts));

            // Default location
            io.IniFilename = "bin/imgui.ini";

            ImGui.StyleColorsClassic();
            //ImGui.StyleColorsLight();
        }
    }

    ////////////////////////////////////////////////////////////////////////////////
    // My Program's Stuff
    {

        // Shaders
        render_context.basic_shader     = make_shader("basic.vs", "basic.fs");
        render_context.main_shader      = make_shader("main.vs", "main.fs");
        render_context.terrain_shader   = make_shader("terrain.vs", "terrain.fs");
        render_context.skybox_shader    = make_shader("skybox.vs", "skybox.fs");
        render_context.highlight_shader = make_shader("main.vs", "highlight.fs");

        render_context.depth_shader     = make_shader("depth.vs", "depth.fs");
        render_context.water_shader     = make_shader("water.vs", "water.fs");

        render_context.text_shader      = make_shader("text.vs", "text.fs");
        render_context.screen_shader    = make_shader("screen.vs", "screen.fs");
        render_context.post_processing_shader = make_shader("screen.vs", "post_processing.fs");

        // Rendering Setup
        {
            max_uniform_components : s32;
            glGetIntegerv(GL_MAX_VERTEX_UNIFORM_COMPONENTS, *max_uniform_components);
            assert(max_uniform_components > 16 * MAX_JOINTS, "System's max uniform components: %. How many you want to send : %.\n", max_uniform_components, 16 * MAX_JOINTS);
        }

        // Meshes
        {
            a: Allocator;
            a.proc = flat_pool_allocator_proc;
            a.data = *mesh_pool;

            mesh_catalogue.allocator = a;

            new_mesh :: (name : string) {
                mesh := create_mesh_from_file(tprint("%.mesh", name));
                locator, pointer := bucket_array_add(*mesh_storage, mesh);
                table_add(*mesh_catalogue, name, pointer);
            }

            new_mesh("guy");
            new_mesh("guy2");
            new_mesh("rob");
            new_mesh("porygon");
        }


        // Animations
        {
            a: Allocator;
            a.proc = flat_pool_allocator_proc;
            a.data = *animation_pool;

            animation_catalogue.allocator = a;

            new_animation :: (name : string) {
                animation := create_animation_from_file(tprint("%.anim", name));
                locator, pointer := bucket_array_add(*animation_storage, animation);
                table_add(*animation_catalogue, name, pointer);
            }

            new_animation("animation");
            new_animation("rob_idle");
            new_animation("sit");
            new_animation("idle");
        }


        // Primitives
        init_quad_rendering_objects(*quad);
        init_cube_rendering_objects(*cube);
        init_sphere_rendering_objects(*sphere);

        // Fonts
        {
            a: Allocator;
            a.proc = flat_pool_allocator_proc;
            a.data = *forever_pool;

            fonts.allocator = a;
            table_add(*fonts, "Header", make_font("verdanab.ttf", xx (window_height / 40)));

            // Textures
            textures.allocator = a;
            table_add(*textures, "missing", load_texture_from_file("missing.png"));
        }

        // Rendering Structures
        {
            {
                render_context.sun.position = Vector3.{0, 400, 400};
                render_context.sun.scale = 100;
            }

            {
                render_context.water.position = Vector3.{0, -0.1, 0};
                set_from_axis_and_angle(*render_context.water.orientation, .{1, 0, 0}, radians(-90.0));
                render_context.water.scale = 125;
                init_rendering_objects(*render_context.water);
            }

            load_cubemap_textures(*render_context.skybox, "yellow");

            init_rendering_objects(*shadow_map);

            init_rendering_objects(*framebuffer);
        }
    }

    end_time := cast(float32)seconds_since_init();

    log("Done! (took % seconds)\n", end_time - start_time);

    return true;
}
