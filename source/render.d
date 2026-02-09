import bindbc.glfw;
import bindbc.opengl.util;
import bindbc.opengl;
import asset;
import std.concurrency;
import std.stdio;
import math;
import app;
import config;
import script;

struct Camera
{
	Transform3D transform;
	
	const float near = 0.2;
	const float far = 9000;
	const float top = 1*0.25f;
	const float right = 1.77777*0.25f;
	const float left = -1.77777*0.25f;
	const float bottom = -1*0.25f;
	
	const float4x4 projmat = cast(float4x4)[
		2*near/(right-left),0,0,0,
		0,2*near/(top-bottom),0,0,
		(right+left)/(right-left),(top+bottom)/(top-bottom),-(far+near)/(far-near),-1,
		0,0,-2*(far*near)/(far-near),0
	];
	
	alias this = transform;

	void SetPosition(float3 position)
	{
		transform.position = float3([0,0,0]) - position;
	}
}

void checkShader(GLuint shader) {
    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char[512] infoLog;
        glGetShaderInfoLog(shader, 512, null, infoLog.ptr);
        import std.stdio;
        writeln("Shader Error: ", cast(string)infoLog);
    }
}

struct Model
{	
	bool initialized = false;
	char* vertex_shader;
	char* fragment_shader;	
	float[] vertices;
	Transform3D transform;

	GLuint vbo = 0;
	GLuint vao = 0;
		
	GLuint shader = 0;

	Script script;
	
	void Init()
	{	
		writeln("Init model");
		writeln("vertex shader: ", fromStringz(vertex_shader));
		writeln("fragment shader: ", fromStringz(fragment_shader));
		writeln("vertices: ", vertices);

		glGenBuffers(1, &vbo);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW);
		glGenVertexArrays(1, &vao);
		glBindVertexArray(vao);
		glEnableVertexAttribArray(0);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);

		GLuint v_shader = glCreateShader(GL_VERTEX_SHADER);
		glShaderSource(v_shader, 1, &vertex_shader, null);
		glCompileShader(v_shader);
		checkShader(v_shader);
		
		
		GLuint f_shader = glCreateShader(GL_FRAGMENT_SHADER);
		glShaderSource(f_shader, 1, &fragment_shader, null);
		glCompileShader(f_shader);
		checkShader(f_shader);

		shader = glCreateProgram();
		glAttachShader(shader, v_shader);
		glAttachShader(shader, f_shader);
		glLinkProgram(shader);

		glBindBuffer(GL_ARRAY_BUFFER, 0);
		initialized = true;
	}

	void Render(Camera camera)
	{	
		if (!initialized) return;
		float4x4 viewmat = cast(float4x4)camera;
		float4x4 modelmat = cast(float4x4)transform;
		glUseProgram(shader);

		GLint view = glGetUniformLocation(shader, "view_matrix");
		glUniformMatrix4fv(view, 1, GL_FALSE, viewmat.ptr);
		GLint proj = glGetUniformLocation(shader, "proj_matrix");
		glUniformMatrix4fv(proj, 1, GL_FALSE, camera.projmat.ptr);
		GLint model = glGetUniformLocation(shader, "model_matrix");
		glUniformMatrix4fv(model, 1, GL_FALSE, modelmat.ptr);
		
		glBindVertexArray(vao);

		glDrawArrays(GL_TRIANGLES, 0, 6);
	}
}

// Someone please clean this up
import core.stdc.string : strdup;
import daslang_bridge;

import core.sync.mutex;
import core.atomic;

Model*[] models;
__gshared Model*[] initQueue;
__gshared Mutex queueMutex;

import core.simd;
import std.string : fromStringz;

import core.stdc.stdlib : malloc, free;
import core.stdc.string : memcpy;
import core.exception : onOutOfMemoryError;

shared static this() {
    queueMutex = new Mutex();
}

extern (C) {
	struct das_model {
		char* vertex_shader;
		char* fragment_shader;	
		float* vertices;
	};

	vec4f CreateModel(das_context* ctx, das_node* node, vec4f* args) {
		cast(void)ctx; cast(void)node;
		char* vert_shader = das_argument_string(args[0]);
		if (!vert_shader) {
			writeln("Invalid or null vertex shader!");
		}
		// writeln(fromStringz(vert_shader));
		char* frag_shader = das_argument_string(args[1]);
		if (!vert_shader) {
			writeln("Invalid or null fragment shader!");
		}
		// writeln(fromStringz(frag_shader));
		das_array * arr = cast(das_array *)das_argument_ptr(args[2]);

		if (!arr) {
			writeln("Invalid or null vertices!");
		}

		uint32_t size = arr.size;
		float * data = cast(float *)arr.data;

		float[] verts = data[0..size];

		// Model model = Model(strdup(vert_shader), strdup(frag_shader), verts.dup);
		Model* mdl = new Model();

		mdl.vertex_shader = strdup(vert_shader);
		mdl.fragment_shader = strdup(frag_shader);
		mdl.vertices = verts.dup;
		models ~= mdl;
		synchronized(queueMutex) {
			initQueue ~= mdl;
		}

		das_model * dmdl = cast(das_model *) malloc(das_model.sizeof);
		// dmdl.vertices = cast(float *) malloc(float.sizeof * size);
		// memcpy(dmdl.vertices, data, float.sizeof * size);
		return das_result_ptr(&dmdl);
	}
}

extern (C) @nogc nothrow void errorCallback(int error, const(char)* description)
{
	import core.stdc.stdio;

	fprintf(stderr, "Error: %s\n", description);
}

bool mouse_pending = false;
int mouse_button = 0;
int mouse_action = 0;
int mouse_x = 0;
int mouse_y = 0;

extern (C) @nogc nothrow void mouse_button_callback(GLFWwindow* window, int button, int action, int mods)
{
	double dxpos, dypos;
	glfwGetCursorPos(window, &dxpos, &dypos);
	mouse_x = cast(int) dxpos;
	mouse_y = cast(int) dypos;
	mouse_button = button;
	mouse_action = action;
	mouse_pending = true;
}

bool key_pending = false;
uint key_chr = 0;

extern (C) @nogc nothrow void text_callback(GLFWwindow* window, uint chr)
{
	key_pending = true;
	key_chr = chr;
}

extern (C) @nogc nothrow void key_callback(GLFWwindow* window, int key, int scancode, int action, int mods)
{
	if (key >= 256 && action == GLFW_PRESS)
	{
		key_pending = true;
		key_chr = -key;
	}
}

shared(bool) Render_run;

void Render_Loop()
{
	glfwSetErrorCallback(&errorCallback);
	glfwInit();

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);

	glfwWindowHint(GLFW_TRANSPARENT_FRAMEBUFFER, 1);
	glfwWindowHint(GLFW_DECORATED, 1);
	GLFWwindow* window = glfwCreateWindow(1280, 720, "App", null, null);
	glfwSetMouseButtonCallback(window, &mouse_button_callback);
	glfwSetCharCallback(window, &text_callback);
	glfwSetKeyCallback(window, &key_callback);

	glfwMakeContextCurrent(window);

	glfwSwapInterval(1);
	
	if (g_config.render_api == "opengl") {
		loadOpenGL();
	} else {
		writeln("Unsupported graphics api: ", g_config.render_api);
	}

	Camera camera = Camera(Transform3D());

	camera.SetPosition(float3([-0.5, 0.0, 0.5]));

	int testtime = 0;
	import std.math;
	while (!glfwWindowShouldClose(window) && Render_run)
	{
		glfwPollEvents();

		if (g_config.render_api == "opengl") {
			int width, height;

			glEnable(GL_BLEND);
			glfwGetFramebufferSize(window, &width, &height);
			glViewport(0, 0, width, height);
			glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE);
		}
		camera.SetPosition(float3([sin(testtime*0.02f), 0.0, cos(testtime*0.026f)+1.5f]));
		testtime++;
		
		//Init models (must be done here so its on the same thread as GLFW)
		
		Model*[] toInit;
		synchronized(queueMutex) {
			if (initQueue.length > 0) {
				toInit = initQueue.dup;
				initQueue.length = 0;
			}
		}

		foreach (mdl; toInit)
		{
			mdl.Init();
			models ~= mdl;
			writeln("Model initialized and added to render list.");
		}

		foreach (model; models)
		{
			model.Render(camera);
		}
		
		

		glfwSwapBuffers(window);

	}

	Kill_Everything_And_Quit();
	Render_run = false;
}

// called in main
public void Render_Init()
{
	Render_run = true;
	spawn(&Render_Loop);
}

public void Render_End()
{
	Render_run = false;
}
