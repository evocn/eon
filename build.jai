// Everett
// Build
// Alex Hartford
// March 2024

build :: () {
    workspace := compiler_create_workspace("Main Workspace");
    if !workspace {
        print("Workspace creation failed.\n");
        return;
    }

    options := get_build_options(workspace);
    options.output_executable_name = "everett";

    // NOTE(alex): this refers to a relative path from this (build.jai) file.
    options.output_path = "bin";
    options.intermediate_path = "bin/.build";
    options.output_type = .EXECUTABLE;
    options.text_output_flags = 2;

    set_build_options(options, workspace);
    set_build_options_dc(.{do_output=false});

	compiler_begin_intercept(workspace);

    add_build_file("src/main.jai", workspace);

	// Set up ctags options
	ctags: CTags;
	ctags.output_filename = "src/tags";
	ctags.base_path = get_working_directory();
	defer reset(*ctags);

	while true {
		message := compiler_wait_for_message();
		if !message continue;

		if message.workspace == workspace {
			process_message(*ctags, message);
		}

		if message.kind == .COMPLETE break;
	}

    // Create a manifest and an icon file.
	#if OS == .WINDOWS {
        icons_path :: "assets/misc";

		exe_name := sprint("%/%.exe", options.output_path, options.output_executable_name);
		defer free(exe_name);

        ico_data := create_ico_file_from_bitmap_filename(tprint("%/icon.png", icons_path));
		defer free(ico_data);

		set_icon_by_data(exe_name, ico_data);

        generated_icon_file_path := tprint("%/generated.ico", icons_path);
        write_entire_file(generated_icon_file_path, ico_data);
		print("Icon     added: %\n", set_icon_by_filename(exe_name, generated_icon_file_path));

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
