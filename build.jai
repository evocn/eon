// Eon
// Build
// Alex Hartford

// This file contains a metaprogram whose objective is to build the target program contained in source/.


// Shared between the build program and the target program.
shared_data :: #string DONE

build_settings : struct {
    configuration : enum {
        DEBUG;
        RELEASE;
    }
}

program_title :: "Eon";

DONE
#run add_build_string(shared_data, w = -1);

////////////////////////////////////////////////////////////////////////////////

build :: () {
    // Create target program workspace
    w := compiler_create_workspace("Final Program");
    if !w {
        print("Workspace creation failed.\n");
        return;
    }
    options := get_build_options(w);


    // Handle command-line arguments / plugins
    {
        for argument: options.compile_time_command_line {
            if argument == {
                case "release"; {
                    build_settings.configuration = .RELEASE;
                }
            }
        }
    }


    // Build options for the Target Workspace
    {
        options.output_executable_name = program_title;

        options.output_path = "bin";
        options.intermediate_path = "bin/.build";
        options.output_type = .EXECUTABLE;

        // Configure Compiler output printing
        options.text_output_flags = 0;
        //options.text_output_flags |= .OUTPUT_LINK_LINE;
        options.text_output_flags |= .OUTPUT_TIMING_INFO;

        if build_settings.configuration == {
            case .DEBUG;    set_optimization(*options, .DEBUG);
            case .RELEASE;  set_optimization(*options, .VERY_OPTIMIZED);
        }

        set_build_options(options, w);
    }


    // Init plugins
    {
        plugin_names : [..] string;
        defer array_reset(*plugin_names);

        if build_settings.configuration == .DEBUG {
            array_add(*plugin_names, "Iprof");
        }

        init_plugins(plugin_names, *plugins, w);

        for plugins {
            //if it.log_help then it.log_help(it);
        }
    }

    {
        // Interception begins
        intercept_flags: Intercept_Flags;
        for plugins if it.before_intercept it.before_intercept(it, *intercept_flags);

        compiler_begin_intercept(w, intercept_flags);

        // Add files to the Target Workspace
        {
            for plugins if it.add_source it.add_source(it);

            // Files to compile
            {
                add_build_file(tprint("%/source/main.jai", #filepath), w);
            }

            // User Build Options
            {
                add_build_string(shared_data, w);

                build_configuration_string : string;
                build_configuration_string = tprint("BUILD_TYPE :: build_settings.configuration.%;", build_settings.configuration);
                add_build_string(build_configuration_string, w);
            }
        }

        message_loop(w);

        compiler_end_intercept(w);

        for plugins if it.finish it.finish(it);
        for plugins if it.shutdown it.shutdown(it);
    }

    // Publishing work
    {
        log("\nCompilation ended on the target workspace. On to publishing work!");

        executable_path := sprint("%/%.exe", options.output_path, options.output_executable_name);
        defer free(executable_path);

        icon_path :: "assets/publishing/icon.png";

        create_and_apply_manifest_and_icon_files(executable_path, icon_path);
    }

    // Build Program (this one) settings.
    {
        // No executable!
        set_build_options_dc(.{
            do_output = false,
            write_added_strings = false
        });
    }
}

#run,stallable build(); // If plugins have assertions, they may stall.

////////////////////////////////////////////////////////////////////////////////

message_loop :: (w: Workspace) {

    // Ctags module setup
    ctags: CTags;
    defer reset(*ctags);
    ctags.output_filename = "tags";
    ctags.base_path = sprint("%", #filepath);
    defer free(ctags.base_path);

    while true {
        message := compiler_wait_for_message();
        if !message continue;

        if message.workspace == w {
            process_message(*ctags, message);

            for plugin : plugins if plugin.message plugin.message(plugin, message);
        }

        if message.kind == .COMPLETE return;
    }
}

////////////////////////////////////////////////////////////////////////////////

create_and_apply_manifest_and_icon_files :: (executable_path : string, icon_path : string) {
    #if OS == .WINDOWS {
        #import "Ico_File";
        #import "Windows_Resources";

        ico_data := create_ico_file_from_bitmap_filename(icon_path);
        defer free(ico_data);

        ico_path := sprint("%.ico", path_strip_extension(icon_path));
        defer free(ico_path);
        // Save .ico back out for inspection
        {
            write_entire_file(ico_path, ico_data);
        }

        success := set_icon_by_data(executable_path, ico_data);
        print("Icon     added: %\n", success);

        manifest_options: Manifest_Options;
        success = add_manifest_to_executable(executable_path, manifest_options);

        print("Manifest added: %\n", success);
    }
}

////////////////////////////////////////////////////////////////////////////////

// Standard Library
#import "Basic";
#import "Compiler";
#import "String";
#import "File";

// Plugins
#import "Metaprogram_Plugins";
#import "Iprof";

plugins: [..] *Metaprogram_Plugin;

// Local Project Modules
#import "ctags";
