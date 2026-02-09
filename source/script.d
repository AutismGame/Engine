
import std.traits;
import daslang_bridge;
import std.stdio;
import render;
import std.string : toStringz;

// extern(C) {
// 	static void setup_module(das_module_group* lib) {
// 	das_module* mod = das_module_create("render_module");

// 	if (!lib) {
// 		writeln("fuck off");
// 	}

// 	das_structure * mst = das_structure_make(lib, "das_model", cast(char"das_model".ptr, das_model.sizeof, das_model.alignof);
// 	das_structure_add_field(mst, mod, lib, cast(char"vertex_shader", cast(char"vertex_shader".p, das_model.vertex_shader.offsetof, cast(char"s".p);
// 	das_structure_add_field(mst, mod, lib, cast(char"fragment_shader", cast(char"fragment_shader".p, das_model.fragment_shader.offsetof, cast(char"s".p);
// 	das_structure_add_field(mst, mod, lib, cast(char"vertices", cast(char"vertices".ptr, das_model.vertices.offsetof, cast(char"1<f>?".p);
	
// 	das_module_bind_interop_function(
// 		mod,
// 		lib,
// 		&CreateModel,
// 		cast(char*)"model_CreateModel\0".ptr,
// 		cast(char*)"CreateModel\0".ptr,
// 		SIDEEFFECTS_modifyExternal,
// 		cast(char*)"1<H<model>>? ssC1<f>A\0".ptr
// 	);

// 	das_modulegroup_add_module(lib, mod);
// }

// }

import std.utf : toUTFz;

void ScriptInit() {
	writeln("Initializing daScript...");

	das_initialize();

	das_module* mod = das_module_create("render_module".toUTFz!(char*));
	das_module_group* libgroup = das_modulegroup_make();
	das_modulegroup_add_module(libgroup, mod);
	

	das_structure * mst = das_structure_make(libgroup, "das_model".toUTFz!(char*), cast(char*)"das_model\0".ptr, das_model.sizeof, das_model.alignof);
	das_structure_add_field(mst, mod, libgroup, cast(char*)"vertex_shader\0".ptr, cast(char*)"vertex_shader\0".ptr, das_model.vertex_shader.offsetof, "s".toUTFz!(char*));
	das_structure_add_field(mst, mod, libgroup, cast(char*)"fragment_shader\0".ptr, cast(char*)"fragment_shader\0".ptr, das_model.fragment_shader.offsetof, "s".toUTFz!(char*));
	das_structure_add_field(mst, mod, libgroup, cast(char*)"vertices\0".ptr, cast(char*)"vertices\0".ptr, das_model.vertices.offsetof, "1<f>?".toUTFz!(char*));
	
	das_module_bind_interop_function(
		mod,
		libgroup,
		&CreateModel,
		"model_CreateModel".toUTFz!(char*),
		"CreateModel".toUTFz!(char*),
		SIDEEFFECTS_modifyExternal,
		"1<H<das_model>>? ssC1<f>A".toUTFz!(char*)
	);

	das_text_writer* tout = das_text_make_printer();
	das_file_access* f_access = das_fileaccess_make_default();
	das_program* program = das_program_compile(cast(char*)"source/scripts/example.das\0".ptr, f_access, tout, libgroup);

	int err_count = das_program_err_count(program);
	if (err_count > 0) {
		writeln("Compilation Failed with ", err_count, " errors:");

        foreach (i; 0 .. err_count) {
            das_error* err = das_program_get_error(program, i);
            
            char[1024] errorBuf;
            das_error_report(err, errorBuf.ptr, errorBuf.length);
            
            import std.conv : to;
            writeln("Error ", i, ": ", errorBuf.ptr.to!string);
        }
	} else {
		das_context* ctx = das_context_make(64 * 1024);

		if (das_program_simulate(program, ctx, tout)) {
			das_function* main_fn = das_context_find_function(ctx, cast(char*)"main\0".ptr);

			if (main_fn) {
				das_context_eval_with_catch(ctx, main_fn, null);
			}
		}
	}

	
}

class Script
{	
	void Tick(double delta)
	{
		
	}
}

struct ffi2daslang {
	byte level;
}

/// This is an example function to demonstrate the usage of "ffi2daslang"
@ffi2daslang(4) string Hello() {
	return "Hello, world!";
}

mixin template FFI2DASLangImpl() 
{
	template opDispatch(string name)
		if(hasUDA!(__traits(getMember, typeof(this), name ~ "_"), ffi2daslang))
	{
		auto opDispatch(Parameters!(__traits(getMember, typeof(this), name ~ "_")) params) 
		{
			writeln("FFI");
			scope(success) {
				writeln("FFI yaya");
			}
			
			return __traits(getMember, this, name ~ "_")(params);
		}
	}
}