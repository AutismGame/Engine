import std.traits;
import daslang_bridge;
import std.stdio;
import render;
import std.string : toStringz, fromStringz;;
import std.utf : toUTFz;

void ScriptInit() {
	writeln("Initializing daScript...");

	das_initialize();
	das_module_group* libgroup = das_modulegroup_make();

	das_initRenderModule(libgroup);

	das_text_writer* tout = das_text_make_printer();
	das_file_access* f_access = das_fileaccess_make_default();
	das_program* program = das_program_compile("source/scripts/example.das".toUTFz!(char*), f_access, tout, libgroup);

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
			das_function* main_fn = das_context_find_function(ctx, "main".toUTFz!(char*));

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