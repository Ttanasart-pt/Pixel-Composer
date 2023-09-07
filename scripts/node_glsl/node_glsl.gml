globalvar CUSTOM_SHADER_SLOT, CUSTOM_SHADER_UNIFORM;
CUSTOM_SHADER_SLOT = ds_map_create();
CUSTOM_SHADER_SLOT[? sh_dummy_0] = noone;

CUSTOM_SHADER_UNIFORM = @"
uniform float u_float_0, u_float_1, u_float_2, u_float_3, u_float_4, u_float_5, u_float_6, u_float_7;
uniform float u_float_8, u_float_9, u_float_10, u_float_11, u_float_12, u_float_13, u_float_14, u_float_15;

uniform int u_int_0, u_int_1, u_int_2, u_int_3, u_int_4, u_int_5, u_int_6, u_int_7;
uniform int u_int_8, u_int_9, u_int_10, u_int_11, u_int_12, u_int_13, u_int_14, u_int_15;

uniform vec2 u_vec2_0, u_vec2_1, u_vec2_2, u_vec2_3, u_vec2_4, u_vec2_5, u_vec2_6, u_vec2_7;
uniform vec2 u_vec2_8, u_vec2_9, u_vec2_10, u_vec2_11, u_vec2_12, u_vec2_13, u_vec2_14, u_vec2_15;

uniform vec3 u_vec3_0, u_vec3_1, u_vec3_2, u_vec3_3, u_vec3_4, u_vec3_5, u_vec3_6, u_vec3_7;
uniform vec3 u_vec3_8, u_vec3_9, u_vec3_10, u_vec3_11, u_vec3_12, u_vec3_13, u_vec3_14, u_vec3_15;

uniform vec4 u_vec4_0, u_vec4_1, u_vec4_2, u_vec4_3, u_vec4_4, u_vec4_5, u_vec4_6, u_vec4_7;
uniform vec4 u_vec4_8, u_vec4_9, u_vec4_10, u_vec4_11, u_vec4_12, u_vec4_13, u_vec4_14, u_vec4_15;

uniform mat3 u_mat3_0, u_mat3_1, u_mat3_2, u_mat3_3, u_mat3_4, u_mat3_5, u_mat3_6, u_mat3_7;
uniform mat3 u_mat3_8, u_mat3_9, u_mat3_10, u_mat3_11, u_mat3_12, u_mat3_13, u_mat3_14, u_mat3_15;

uniform mat4 u_mat4_0, u_mat4_1, u_mat4_2, u_mat4_3, u_mat4_4, u_mat4_5, u_mat4_6, u_mat4_7;
uniform mat4 u_mat4_8, u_mat4_9, u_mat4_10, u_mat4_11, u_mat4_12, u_mat4_13, u_mat4_14, u_mat4_15;

uniform sampler2D  u_sampler2D_0,  u_sampler2D_1,  u_sampler2D_2,  u_sampler2D_3,  u_sampler2D_4,  u_sampler2D_5,  u_sampler2D_6; ";

function custom_shader_reserve(node) {
	var keys = ds_map_keys_to_array(CUSTOM_SHADER_SLOT);
	for( var i = 0, n = array_length(keys); i < n; i++ ) {
		if(CUSTOM_SHADER_SLOT[? keys[i]] == noone) {
			CUSTOM_SHADER_SLOT[? keys[i]] = node;
			return keys[i];
		}
	}
	
	return noone;
}

function custom_shader_free(node) {
	var keys = ds_map_keys_to_array(CUSTOM_SHADER_SLOT);
	for( var i = 0, n = array_length(keys); i < n; i++ ) {
		if(CUSTOM_SHADER_SLOT[? keys[i]] == node)
			CUSTOM_SHADER_SLOT[? keys[i]] = noone;
	}
}

function glsl_wrap_vertex(content) {
	return @"
attribute vec3 in_Position;
attribute vec4 in_Colour;
attribute vec2 in_TextureCoord;
" + CUSTOM_SHADER_UNIFORM + @"
varying vec2 v_vTexcoord;

void main() {
" + string(content) + "\n}";
}

function glsl_wrap_fragment(content) {
	return @"
varying vec2 v_vTexcoord;
" + CUSTOM_SHADER_UNIFORM + @"
void main() {
" + string(content) + "\n}";
}

function Node_GLSL(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name   = "GLSL";
	shader = custom_shader_reserve(self);
	
	hlslCompiler = working_directory + "HLSL/HLSLCompiler.exe";
	
	inputs[| 0] = nodeValue("Vertex", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, 
@"vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
v_vTexcoord = in_TextureCoord;")
		.setDisplay(VALUE_DISPLAY.codeGLSL)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Fragment", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, 
@"gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );")
		.setDisplay(VALUE_DISPLAY.codeGLSL)
		.rejectArray();
	
	inputs[| 2] = nodeValue("Base Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	outputs[| 0] = nodeValue("Surface", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone );
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index + 0] = nodeValue("Argument name", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "" );
		
		inputs[| index + 1] = nodeValue("Argument type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
			.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Float", "Int", "Vec2", "Vec3", "Vec4", "Mat3", "Mat4", "Sampler2D" ], { update_hover: false });
		inputs[| index + 1].editWidget.interactable = false;
		
		inputs[| index + 2] = nodeValue("Argument value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
			.setVisible(true, true);
		inputs[| index + 2].editWidget.interactable = false;
	}
	
	argumentRenderer();
	
	input_display_list = [ 2, 
		["Shader",		false], 1,
		["Arguments",	false], argument_renderer,
	];

	setIsDynamicInput(3);
	
	uniform_name = [
		"u_float_",
		"u_int_",
		"u_vec2_",
		"u_vec3_",
		"u_vec4_",
		"u_mat3_",
		"u_mat4_",
		"u_sampler2D_",
	];
	
	insp1UpdateTooltip  = __txt("Compile");
	insp1UpdateIcon     = [ THEME.refresh, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { //compile
		refreshShader();
	}
	
	static refreshShader = function() {
		var vs = inputs[| 0].getValue();
		var fs = inputs[| 1].getValue();
		
		var uTypes = array_create(8, 0);
		for( var i = input_fix_len, n = ds_list_size(inputs); i < n; i += data_length ) {
			var _arg_name = inputs[| i + 0].getValue();
			var _arg_type = inputs[| i + 1].getValue();
			
			var _index = uTypes[_arg_type];
			uTypes[_arg_type]++;
			var _uni_name = uniform_name + string(_index);
			
			vs = string_replace_all(vs, _arg_name, _uni_name);
			fs = string_replace_all(fs, _arg_name, _uni_name);
		}
		
		vs = glsl_wrap_vertex(vs);
		fs = glsl_wrap_fragment(fs);
		
		var _dir = DIRECTORY + "shadertemp/";
		directory_create(_dir);
		
		file_text_write_all(_dir + "temp.shader",
			vs
			+ "\n//######################_==_YOYO_SHADER_MARKER_==_######################@~\n"
			+ fs
		);
		
		//print(file_text_read_all(_dir + "temp.shader"));
		//print(hlslCompiler);
		
		var cmd = (scr_cmd_arg(hlslCompiler)
			+ " -hlsl11"
			+ " -shader " + scr_cmd_arg(_dir + "temp.shader")
			+ " -name temp"
			+ " -out " + scr_cmd_arg(_dir)
			+ " -typedefine " + scr_cmd_arg("#define _YY_HLSL11_ 1")
			+ " -preamble " + scr_cmd_arg(filename_dir(hlslCompiler))
		);
		//
		var ex = execute_program_pipe(cmd, 0
			| program_pipe_flags_hide_window
			| program_pipe_flags_capture_stdout
			| program_pipe_flags_capture_stderr
		);
		
		//print(ex)
		
		if (ex[0] != 0) { // didn't even run
			noti_warning($"Error executing HLSLCompiler: {ex[2]}");
		} else if (ex[1] != 0) { // errored out
			noti_warning($"Error compiling the shader: {ex[2]}");
		} else { // OK! Let's pick up those shaders
			var vsh = file_text_read_all(_dir + "vout.shader");
			var fsh = file_text_read_all(_dir + "fout.shader");
			var e   = shader_replace_simple(shader, vsh, fsh);
			if (e != "") noti_warning($"Error applying the shader: {e}");
		}
	}
	
	static onValueUpdate = function(index) {
		refreshShader();
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
		var _surf = _data[2];
		_output = surface_verify(_output, surface_get_width(_surf), surface_get_height(_surf));
		
		surface_set_shader(_output, shader);
		
		var uTypes = array_create(8, 0);
		for( var i = input_fix_len, n = array_length(_data); i < n; i += data_length ) {
			var _arg_name = _data[i + 0];
			var _arg_type = _data[i + 1];
			var _arg_valu = _data[i + 2];
			
			var _index = uTypes[_arg_type];
			uTypes[_arg_type]++;
			var _uni_name = uniform_name + string(_index);
			
			switch(_arg_type) {
				case 0 : shader_set_f(_uni_name, _arg_valu); break;			//u_float
				case 1 : shader_set_i(_uni_name, _arg_valu); break;			//u_int
				case 2 : shader_set_f(_uni_name, _arg_valu); break;			//u_vec2
				case 3 : shader_set_f(_uni_name, _arg_valu); break;			//u_vec3
				case 4 : shader_set_f(_uni_name, _arg_valu); break;			//u_vec4
				case 5 : shader_set_f(_uni_name, _arg_valu); break;			//u_mat3
				case 6 : shader_set_f(_uni_name, _arg_valu); break;			//u_mat4
				case 7 : shader_set_surface(_uni_name, _arg_valu); break;	//u_sampler2D
			}
		}
		
		draw_surface_safe(_surf);
		surface_reset_shader();
		
		return _output;
	}
	
	static postConnect = function() {
		refreshShader();
	}
	
	static onCleanUp = function() {
		custom_shader_free(self);
	}
}