// Everett
// Build
// Alex Hartford
// May 2023

build :: () {
    w := compiler_create_workspace("Everett Workspace");
    if !w {
        print("Workspace creation failed.\n");
        return;
    }

    options := get_build_options(w);
    options.output_executable_name = "everett";

    // Add ext/ to the import path.
    import_path: [..] string;
    array_add(*import_path, ..options.import_path);
    array_add(*import_path, "../ext");
    options.import_path = import_path;

    // NOTE(alex): this refers to a relative path from this (build.jai) file.
    options.output_path = "../bin";
    options.output_type = .EXECUTABLE;
    options.text_output_flags = 2;

    set_build_options(options, w);
    set_build_options_dc(.{do_output=false});

	compiler_begin_intercept(w);

    add_build_file(tprint("%/main.jai", #filepath), w);

    add_build_file(tprint("%/utils.jai", #filepath), w);
    add_build_file(tprint("%/init.jai", #filepath), w);
    add_build_file(tprint("%/imgui_init.jai", #filepath), w);
    add_build_file(tprint("%/input.jai", #filepath), w);
    add_build_file(tprint("%/camera.jai", #filepath), w);
    add_build_file(tprint("%/collision.jai", #filepath), w);

    add_build_file(tprint("%/program_mode.jai", #filepath), w);

    add_build_file(tprint("%/editor.jai", #filepath), w);
    add_build_file(tprint("%/undo.jai", #filepath), w);
    add_build_file(tprint("%/gizmos.jai", #filepath), w);

    add_build_file(tprint("%/debug.jai", #filepath), w);

    // Levels
    add_build_file(tprint("%/entity.jai", #filepath), w);
    add_build_file(tprint("%/serialization.jai", #filepath), w);

    // Gameplay
    add_build_file(tprint("%/simulate.jai", #filepath), w);
    add_build_file(tprint("%/body.jai", #filepath), w);

    // Rendering
    add_build_file(tprint("%/render.jai", #filepath), w);
    add_build_file(tprint("%/primitives.jai", #filepath), w);
    add_build_file(tprint("%/parse_utils.jai", #filepath), w);
    add_build_file(tprint("%/mesh.jai", #filepath), w);
    add_build_file(tprint("%/animation.jai", #filepath), w);

    add_build_file(tprint("%/color.jai", #filepath), w);
    add_build_file(tprint("%/light.jai", #filepath), w);
    add_build_file(tprint("%/frustum.jai", #filepath), w);

    add_build_file(tprint("%/shader.jai", #filepath), w);
    add_build_file(tprint("%/texture.jai", #filepath), w);
    add_build_file(tprint("%/framebuffer.jai", #filepath), w);
    add_build_file(tprint("%/depthbuffer.jai", #filepath), w);

    add_build_file(tprint("%/skybox.jai", #filepath), w);
    add_build_file(tprint("%/shadow.jai", #filepath), w);
    add_build_file(tprint("%/water.jai", #filepath), w);

    add_build_file(tprint("%/font.jai", #filepath), w);

	// Set up ctags options
	ctags: CTags;
	ctags.base_path = get_working_directory();
	defer reset(*ctags);

	while true {
		message := compiler_wait_for_message();
		if !message continue;

		if message.workspace == w {
			process_message(*ctags, message);
		}

		if message.kind == .COMPLETE break;
	}

    // Create a manifest and an icon file.
	#if OS == .WINDOWS {
		exe_name := sprint("%/%.exe", options.output_path, options.output_executable_name);
		defer free(exe_name);

		ico_data := create_ico_file_from_bitmap_filename("../assets/icon.png");
		defer free(ico_data);
		set_icon_by_data(exe_name, ico_data);
        write_entire_file("../assets/icon.ico", ico_data);

		print("Icon     added: %\n", set_icon_by_filename(exe_name, "../assets/icon.ico"));

		manifest_options: Manifest_Options;
		print("Manifest added: %\n", add_manifest_to_executable(exe_name, manifest_options));

		#import "Ico_File";
		#import "Windows_Resources";
	}
}

#run build();


#import "Basic";
#import "Compiler";
#import "File";
#import "ctags";
