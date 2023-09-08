#region vb
	vertex_format_begin();
	vertex_format_add_position();
	vertex_format_add_color();
	vertex_format_add_texcoord();
	global.HLSL_VB_FORMAT = vertex_format_end();

	global.HLSL_VB = vertex_create_buffer();
	vertex_begin(global.HLSL_VB, global.HLSL_VB_FORMAT);
	vertex_position(global.HLSL_VB, 0, 0);
	vertex_color(global.HLSL_VB, c_white, 1);
	vertex_texcoord(global.HLSL_VB, 0, 0);
	
	vertex_position(global.HLSL_VB, 0, 1);
	vertex_color(global.HLSL_VB, c_white, 1);
	vertex_texcoord(global.HLSL_VB, 0, 1);
	
	vertex_position(global.HLSL_VB, 1, 0);
	vertex_color(global.HLSL_VB, c_white, 1);
	vertex_texcoord(global.HLSL_VB, 1, 0);
	
	vertex_position(global.HLSL_VB, 1, 1);
	vertex_color(global.HLSL_VB, c_white, 1);
	vertex_texcoord(global.HLSL_VB, 1, 1);
	vertex_end(global.HLSL_VB);
#endregion

function Node_HLSL(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name   = "HLSL";
	shader = { vs: -1, fs: -1 };
	
	inputs[| 0] = nodeValue("Vertex", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, @"")
		.setDisplay(VALUE_DISPLAY.codeHLSL)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Fragment", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, 
@"float4 surfaceColor = gm_BaseTextureObject.Sample(gm_BaseTexture, input.uv);
output.color = surfaceColor;")
		.setDisplay(VALUE_DISPLAY.codeHLSL)
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
	
	insp1UpdateTooltip  = __txt("Compile");
	insp1UpdateIcon     = [ THEME.refresh, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { //compile
		refreshShader();
	}
	
	static refreshShader = function() {
		var vs = inputs[| 0].getValue();
		var fs = inputs[| 1].getValue();
		
		var _dir = DIRECTORY + "shadertemp/";
		var vs   = @"
#define MATRIX_WORLD                 0
#define MATRIX_WORLD_VIEW            1
#define MATRIX_WORLD_VIEW_PROJECTION 2

cbuffer Matrices : register(b0) {
	float4x4 gm_Matrices[3];
};

struct VertexShaderInput {
	float3 pos		: POSITION;
	float3 color	: COLOR0;
	float2 uv		: TEXCOORD0;
};

struct VertexShaderOutput {
	float4 pos		: SV_POSITION;
	float2 uv		: TEXCOORD0;
};

void main(in VertexShaderInput input, out VertexShaderOutput output) {
	output.pos   = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(input.pos, 1.0f));
    output.uv    = input.uv;   
}";
		file_text_write_all(_dir + "vout.shader", vs);
		
		var fs_pre = @"
Texture2D gm_BaseTextureObject : register(t0);
SamplerState gm_BaseTexture    : register(s0);

struct VertexShaderOutput {
	float4 pos		: SV_POSITION;
	float2 uv		: TEXCOORD0;
};

struct PixelShaderOutput {
	float4 color : SV_Target0;
};
"
		var fs_param = "";
		var sampler_slot = 1;
		
		for( var i = input_fix_len, n = ds_list_size(inputs); i < n; i += data_length ) {
			var _arg_name = inputs[| i + 0].getValue();
			var _arg_type = inputs[| i + 1].getValue();
			
			switch(_arg_type) {
				case 0 : fs_param += $"uniform float  {_arg_name};\n";   break;	//u_float
				case 1 : fs_param += $"uniform int    {_arg_name};\n";   break;	//u_int
				case 2 : fs_param += $"uniform float2 {_arg_name};\n";   break;	//u_vec2
				case 3 : fs_param += $"uniform float3 {_arg_name};\n";   break;	//u_vec3
				case 4 : fs_param += $"uniform float4 {_arg_name};\n";   break;	//u_vec4
				case 5 : fs_param += $"uniform float3x3 {_arg_name};\n"; break;	//u_mat3
				case 6 : fs_param += $"uniform float4x4 {_arg_name};\n"; break;	//u_mat4
				case 7 : //u_sampler2D
					fs_param += $"Texture2D {_arg_name}Object : register(t{sampler_slot});\nSamplerState {_arg_name} : register(s{sampler_slot});\n";
					sampler_slot++;
					break;
			}
		}
		
		var fs_pos = "\nvoid main(in VertexShaderOutput input, out PixelShaderOutput output) {\n" + fs + "\n}";
		
		fs = fs_pre + fs_param + fs_pos;
		file_text_write_all(_dir + "fout.shader", fs);
		
		shader.vs = d3d11_shader_compile_vs(_dir + "vout.shader", "main", "vs_4_0");
		if (!d3d11_shader_exists(shader.vs)) 
			noti_warning(d3d11_get_error_string());
			
		shader.fs = d3d11_shader_compile_ps(_dir + "fout.shader", "main", "ps_4_0");
		if (!d3d11_shader_exists(shader.fs))
			noti_warning(d3d11_get_error_string());
	}
	
	static onValueUpdate = function(index) {
		var _refresh = index == 0 || index == 1 || (index > input_fix_len && (index - input_fix_len) % data_length != 2);
		if(_refresh) refreshShader();
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { 
		var _surf = _data[2];
		if(!is_surface(_surf)) return;
		_output = surface_verify(_output, surface_get_width(_surf), surface_get_height(_surf));
		
		surface_set_target(_output);
		DRAW_CLEAR
		
		d3d11_shader_override_vs(shader.vs);
		d3d11_shader_override_ps(shader.fs);
		
		var uTypes = array_create(8, 0);
		for( var i = input_fix_len, n = array_length(_data); i < n; i += data_length ) {
			var _arg_name = _data[i + 0];
			var _arg_type = _data[i + 1];
			var _arg_valu = _data[i + 2];
			
			switch(_arg_type) {
				case 0 : shader_set_f(_arg_name, _arg_valu); break;			//u_float
				case 1 : shader_set_i(_arg_name, _arg_valu); break;			//u_int
				case 2 : shader_set_f(_arg_name, _arg_valu); break;			//u_vec2
				case 3 : shader_set_f(_arg_name, _arg_valu); break;			//u_vec3
				case 4 : shader_set_f(_arg_name, _arg_valu); break;			//u_vec4
				case 5 : shader_set_f(_arg_name, _arg_valu); break;			//u_mat3
				case 6 : shader_set_f(_arg_name, _arg_valu); break;			//u_mat4
				case 7 : shader_set_surface(_arg_name, _arg_valu); break;	//u_sampler2D
			}
		}
		
		matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, surface_get_width(_surf), surface_get_height(_surf), 1));
		vertex_submit(global.HLSL_VB, pr_trianglestrip, surface_get_texture(_surf));
		matrix_set(matrix_world, matrix_build_identity());
		
		d3d11_shader_override_vs(-1);
		d3d11_shader_override_ps(-1);
		surface_reset_target();
		
		return _output;
	}
	
	static postConnect = function() { refreshShader(); }
}