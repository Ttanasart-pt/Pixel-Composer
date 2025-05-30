enum SHADER_UNIFORM {
	integer,
	float,
	color,
	texture,
}

function Node_Shader(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name   = "";
	shader = noone;
	shader_data = [];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	static setShader = function(_data) {
		var _keys = struct_get_names(shaderProp);
		for( var i = 0, n = array_length(_keys); i < n; i++ ) {
			var _key = _keys[i];
			var _inp = shaderProp[$ _key];
			var _ind = _inp.index;
			var _val = _data[_ind];
			
			if(struct_has(_inp.attributes, "mapped") && _inp.attributes.mapped) {
				shader_set_f_map(_key, _val, _data[_inp.attributes.map_index], _inp);
				continue;
			}
			
			switch(instanceof(_inp)) {
				case "__NodeValue_Float": 
				case "__NodeValue_Slider": 
				case "__NodeValue_Rotation":     shader_set_f(_key, _val); break;
				
				case "__NodeValue_Int":
				case "__NodeValue_ISlider":
				case "__NodeValue_Bool":
				case "__NodeValue_Enum_Button":
				case "__NodeValue_Enum_Scroll":  shader_set_i(_key, _val); break;
				
				case "__NodeValue_Vec2":
				case "__NodeValue_IVec2":
				case "__NodeValue_Range":
				case "__NodeValue_Dimension":
				case "__NodeValue_Slider_Range": shader_set_2(_key, _val); break;
				
				case "__NodeValue_Vec3":         shader_set_3(_key, _val); break;
				case "__NodeValue_Vec4":         shader_set_4(_key, _val); break;
				
				case "__NodeValue_Color":        shader_set_c(_key, _val); break;
				case "__NodeValue_Surface":      shader_set_surface(_key, _val); break;
			}
		}
	}
	
	static processData = function(_outSurf, _data, _array_index) { return _outSurf; }
}