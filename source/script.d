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