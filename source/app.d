import std.file;
import std.path;
import std.stdio;
// import glfw3.api;
// import bindbc.glfw;
// po chuj tu jest import glfw3
// import dgui;
import server;
import client;
import sex;
import render;
import config;
import script;
import test;

void Kill_Everything_And_Quit()
{
	Render_End();
	Client_End();
	Server_End();
}

void main(string[] args)
{
	RunAllTests();
	
	ParseConfig();
	ScriptInit();
	Render_Init();
	Server_Init();
	Client_Init();
}
