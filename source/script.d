
import std.traits;
import daslang_bridge;
import std.stdio;

void ScriptInit() {
	writeln("Initializing daScript...");

	das_initialize();

	auto ctx = das_context_make(64 * 1024);

	if (ctx) {
		writeln("Success! daScript VM is live");

		das_shutdown();
	} else {
		writeln("Failed to create context");
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