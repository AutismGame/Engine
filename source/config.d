module config;

import std.conv : to;
import std.stdio;
import std.file;
import sdlang;

struct Config {
    ushort server_port = 21370;
    ushort client_port = 21370;
    string server_ip = "127.0.0.1";
    string render_api = "opengl";
};

__gshared Config g_config;

void ParseConfig(string path = "config/config.sdl") {
    // Check if config exists
    if (!exists(path)) {
        writeln("Warning: Config file not found. Using defaults.");
        return;
    }

    try {
        Tag root = parseFile(path);

        g_config.server_port = root.getTagValue!int("server_port", g_config.server_port).to!ushort;
        g_config.client_port = root.getTagValue!int("client_port", g_config.client_port).to!ushort;
        g_config.server_ip = root.getTagValue!string("server_ip", g_config.server_ip);
        g_config.render_api = root.getTagValue!string("render_api", g_config.render_api);

        writeln("Configuration loaded successfully.");
    } catch (ParseException e) {
        stderr.writefln("Error parsing config: %s (Line %d)", e.msg, e.line);
    } catch (Exception e) {
        stderr.writeln("General error: ", e.msg);
    }
}