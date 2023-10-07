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
			.setDisplay(VALUE_DISPLAY.enum_scroll, { data: [ "Float", "Int", "Vec2", "Vec3", "Vec4", "Mat3", "Mat4", "Sampler2D", "Color" ], update_hover: false });
		inputs[| index + 1].editWidget.interactable = false;
		
		inputs[| index + 2] = nodeValue("Argument value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0 )
			.setVisible(true, true);
		inputs[| index + 2].editWidget.interactable = false;
	}
	
	argumentRenderer();
	
	input_display_list = [ 2, 
		["Shader",		false], 1,
		["Arguments",	false], argument_renderer,
		["Values",		false], 
	];

	setIsDynamicInput(3, false);
	
	static refreshDynamicInput = function() { #region
		var _in = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			if(getInputData(i) == "") {
				delete inputs[| i + 0];
				delete inputs[| i + 1];
				delete inputs[| i + 2];
				continue;
			}
			
			var inp_name = getInputData(i + 0);
			var inp_type = inputs[| i + 1];
			var inp_valu = inputs[| i + 2];
			var cur_valu = getInputData(i + 2);
			
			ds_list_add(_in, inputs[| i + 0]);
			ds_list_add(_in, inp_type);
			ds_list_add(_in, inp_valu);
				
			inp_type.editWidget.interactable = true;
			if(inp_valu.editWidget != noone)
				inp_valu.editWidget.interactable = true;
			inp_valu.name = inp_name;
				
			var type = inp_type.getValue();
			switch(type) {
				case 1 : 
					if(is_array(cur_valu)) inp_valu.overrideValue(0);
					inp_valu.setType(VALUE_TYPE.integer);	
					inp_valu.setDisplay(VALUE_DISPLAY._default);
					break;
				case 0 : 
					if(is_array(cur_valu)) inp_valu.overrideValue(0);
					inp_valu.setType(VALUE_TYPE.float);
					inp_valu.setDisplay(VALUE_DISPLAY._default);
					break;
				case 2 : 
					if(!is_array(cur_valu) || array_length(cur_valu) != 2)
						inp_valu.overrideValue([ 0, 0 ]);
					inp_valu.setType(VALUE_TYPE.float);	
					inp_valu.setDisplay(VALUE_DISPLAY.vector);
					break;
				case 3 : 
					if(!is_array(cur_valu) || array_length(cur_valu) != 3)
						inp_valu.overrideValue([ 0, 0, 0 ]);
					inp_valu.setType(VALUE_TYPE.float);	
					inp_valu.setDisplay(VALUE_DISPLAY.vector);
					break;
				case 4 : 
					if(!is_array(cur_valu) || array_length(cur_valu) != 4)
						inp_valu.overrideValue([ 0, 0, 0, 0 ]);
					inp_valu.setType(VALUE_TYPE.float);	
					inp_valu.setDisplay(VALUE_DISPLAY.vector);
					break;
				case 5 : 
					if(!is_array(cur_valu) || array_length(cur_valu) != 9)
						inp_valu.overrideValue(array_create(9));
					inp_valu.setType(VALUE_TYPE.float);	
					inp_valu.setDisplay(VALUE_DISPLAY.matrix, { size: 3 });
					break;
				case 6 : 
					if(!is_array(cur_valu) || array_length(cur_valu) != 16)
						inp_valu.overrideValue(array_create(16));
					inp_valu.setType(VALUE_TYPE.float);	
					inp_valu.setDisplay(VALUE_DISPLAY.matrix, { size: 4 });
					break;
				case 7 : 
					inp_valu.setType(VALUE_TYPE.surface);	
					inp_valu.setDisplay(VALUE_DISPLAY._default);
					break;
				case 8 : 
					inp_valu.setType(VALUE_TYPE.color);	
					inp_valu.setDisplay(VALUE_DISPLAY._default);
					break;
			}
				
			array_push(input_display_list, i + 2);
		}
		
		for( var i = 0; i < ds_list_size(_in); i++ )
			_in[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _in;
		
		createNewInput();
		
		//print("==========================");
		//for( var i = 0, n = array_length(input_display_list); i < n; i++ )
		//	print(input_display_list[i]);
		//print("==========================");
	#endregion
	} if(!LOADING && !APPENDING) refreshDynamicInput();
	
	insp1UpdateTooltip  = __txt("Compile");
	insp1UpdateIcon     = [ THEME.refresh, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { refreshShader(); }
	
	static refreshShader = function() { #region
		var vs = getInputData(0);
		var fs = getInputData(1);
		
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
	float4 color : SV_TARGET0;
};
"
		var fs_param = "cbuffer Data : register(b10) {";
		var fs_sample = "";
		var sampler_slot = 1;
		
		for( var i = input_fix_len, n = ds_list_size(inputs); i < n; i += data_length ) {
			var _arg_name = getInputData(i + 0);
			if(_arg_name == "") continue;
			
			var _arg_type = getInputData(i + 1);
			
			switch(_arg_type) {
				case 0 : fs_param += $"float  {_arg_name};\n";   break;	//u_float
				case 1 : fs_param += $"int    {_arg_name};\n";   break;	//u_int
				case 2 : fs_param += $"float2 {_arg_name};\n";   break;	//u_vec2
				case 3 : fs_param += $"float3 {_arg_name};\n";   break;	//u_vec3
				case 4 : fs_param += $"float4 {_arg_name};\n";   break;	//u_vec4
				case 5 : fs_param += $"float3x3 {_arg_name};\n"; break;	//u_mat3
				case 6 : fs_param += $"float4x4 {_arg_name};\n"; break;	//u_mat4
				case 7 : //u_sampler2D
					fs_sample += $"Texture2D {_arg_name}Object : register(t{sampler_slot});\n";
					fs_sample += $"SamplerState {_arg_name} : register(s{sampler_slot});\n";
					sampler_slot++;
					break;
				case 8 : fs_param += $"float4 {_arg_name};\n";   break;	//u_vec4
			}
		}
		
		fs_param += "};\n";
		fs_param += fs_sample;
		
		var fs_pos = "\nvoid main(in VertexShaderOutput input, out PixelShaderOutput output) {\n" + fs + "\n}";
		
		fs = fs_pre + fs_param + fs_pos;
		file_text_write_all(_dir + "fout.shader", fs);
		
		//print("==================== Compiling ====================");
		//print(fs)
		//print("===================================================\n");
		
		shader.vs = d3d11_shader_compile_vs(_dir + "vout.shader", "main", "vs_4_0");
		if (!d3d11_shader_exists(shader.vs)) 
			noti_warning(d3d11_get_error_string());
			
		shader.fs = d3d11_shader_compile_ps(_dir + "fout.shader", "main", "ps_4_0");
		if (!d3d11_shader_exists(shader.fs))
			noti_warning(d3d11_get_error_string());
	} #endregion
	if(!LOADING && !APPENDING) refreshShader();
	
	static onValueUpdate = function(index) { #region
		var _refresh = index == 0 || index == 1 ||
				(index >= input_fix_len && (index - input_fix_len) % data_length != 2);
		
		if(_refresh) {
			refreshShader();
			refreshDynamicInput();
		}
	} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _surf = _data[2];
		if(!is_surface(_surf)) return noone;
		if(!d3d11_shader_exists(shader.vs)) return noone;
		if(!d3d11_shader_exists(shader.fs)) return noone;
		
		_output = surface_verify(_output, surface_get_width_safe(_surf), surface_get_height_safe(_surf));
		
		surface_set_target(_output);
		DRAW_CLEAR
		
		d3d11_shader_override_vs(shader.vs);
		d3d11_shader_override_ps(shader.fs);
		
		var uTypes = array_create(8, 0);
		var sampler_slot = 1;
		
		d3d11_cbuffer_begin();
		var _buffer = buffer_create(1, buffer_grow, 1);
		var _cbSize = 0;
		
		for( var i = input_fix_len, n = array_length(_data); i < n; i += data_length ) {
			var _arg_name = _data[i + 0];
			var _arg_type = _data[i + 1];
			var _arg_valu = _data[i + 2];
			
			if(_arg_name == "") continue;
			
			var _uni = shader_get_uniform(shader.fs, _arg_name);
			
			switch(_arg_type) {
				case 1 : 
					d3d11_cbuffer_add_int(1); 
					_cbSize++;
					
					buffer_write(_buffer, buffer_s32, _arg_valu);
					break;
				case 0 : 
					d3d11_cbuffer_add_float(1); 
					_cbSize++;
					
					buffer_write(_buffer, buffer_f32, _arg_valu);
					break;
				case 2 : 
				case 3 : 
				case 4 : 
				case 5 : 
				case 6 : 
					if(is_array(_arg_valu)) {
						d3d11_cbuffer_add_float(array_length(_arg_valu)); 
						_cbSize += array_length(_arg_valu);
						
						for( var j = 0, m = array_length(_arg_valu); j < m; j++ ) 
							buffer_write(_buffer, buffer_f32, _arg_valu[j]);
					}
					break;
				case 8 : 
					var _clr = colToVec4(_arg_valu);
					d3d11_cbuffer_add_float(4);
					_cbSize += 4;
					
					for( var j = 0, m = 4; j < m; j++ ) 
						buffer_write(_buffer, buffer_f32, _clr[i]);
					break;
				case 7 : 
					if(is_surface(_arg_valu))
						d3d11_texture_set_stage_ps(sampler_slot, surface_get_texture(_arg_valu));
					sampler_slot++;
					break;
			}
		}
		
		d3d11_cbuffer_add_float(4 - _cbSize % 4);
		var cbuff = d3d11_cbuffer_end();
		d3d11_cbuffer_update(cbuff, _buffer);
		buffer_delete(_buffer);
		
		d3d11_shader_set_cbuffer_ps(10, cbuff);

		matrix_set(matrix_world, matrix_build(0, 0, 0, 0, 0, 0, 
			surface_get_width_safe(_surf), surface_get_height_safe(_surf), 1));
		vertex_submit(global.HLSL_VB, pr_trianglestrip, surface_get_texture(_surf));
		matrix_set(matrix_world, matrix_build_identity());
		
		d3d11_shader_override_vs(-1);
		d3d11_shader_override_ps(-1);
		surface_reset_target();
		
		return _output;
	} #endregion
	
	static postLoad = function() { 
		refreshShader(); 
		refreshDynamicInput();
	}
}