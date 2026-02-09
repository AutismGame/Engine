require render_module


[export]
def main {
    let verts <- [ 0.5, 0.5, 0.0, -0.5, 0.5, 0.0, -0.5, -0.5, 0.0, 0.5, -0.5, 0.0, -0.5, -0.5, 0.0, 0.5, 0.5, 0.0 ];

    let vert_shader = "#version 460 core
    layout(location = 0) in vec3 vp;
    uniform mat4 view_matrix;
    uniform mat4 proj_matrix;
    uniform mat4 model_matrix;

    void main() \{
        gl_Position = proj_matrix * view_matrix * model_matrix * vec4( vp, 1.0 );
    \}";

    let frag_shader = "#version 460 core
    layout(location = 0) out vec4 frag_color;
    void main() \{
        frag_color = vec4( 0.5, 0.5, 0.0, 1.0 );
    \}";
        
    var mdl_id = model_CreateModel(vert_shader, frag_shader, verts);
    print("model id is {mdl_id}\n");
}