function Node_3D_Light_Directional(_x, _y, _group = noone) : Node_3D_Light(_x, _y, _group) constructor {
	name = "Directional Light";
	
	object_class = __3dLightDirectional;
	
	inputs[in_light + 0] = nodeValue_Bool("Cast Shadow", self, false);
	
	inputs[in_light + 1] = nodeValue_Int("Shadow Map Size", self, 1024);
	
	inputs[in_light + 2] = nodeValue_Int("Shadow Map Scale", self, 4);
	
	inputs[in_light + 3] = nodeValue_Float("Shadow Bias", self, .001);
	
	input_display_list = [
		["Transform", false], 0,
		__d3d_input_list_light,
		["Shadow", false], in_light + 0, in_light + 1, in_light + 2, in_light + 3, 
	]
	
	tools = [ tool_pos ];
	tool_settings = [];
	tool_attribute.context = 1;
	
	//static drawOverlay3D = function(active, params, _mx, _my, _snx, _sny, _panel) { #region
	//	var object   = getObject(0);
	//	var _outSurf = object.shadow_map;
		
	//	if(!is_surface(_outSurf)) return;
		
	//	var _w = _panel.w;
	//	var _h = _panel.h - _panel.toolbar_height;
	//	var _pw = surface_get_width_safe(_outSurf);
	//	var _ph = surface_get_height_safe(_outSurf);
	//	var _ps = min(128 / _ph, 160 / _pw);
		
	//	var _pws = _pw * _ps;
	//	var _phs = _ph * _ps;
		
	//	var _px = _w - 16 - _pws;
	//	var _py = _h - 16 - _phs;
		
	//	draw_surface_ext_safe(_outSurf, _px, _py, _ps, _ps);
	//	draw_set_color(COLORS._main_icon);
	//	draw_rectangle(_px, _py, _px + _pws, _py + _phs, true);
	//} #endregion
	
	static processData = function(_output, _data, _output_index, _array_index = 0) { #region
		var _active = _data[in_d3d + 0];
		if(!_active) return noone;
		
		var _shadow_active   = _data[in_light + 0];
		var _shadow_map_size = _data[in_light + 1];
		var _shadow_map_scal = _data[in_light + 2];
		var _shadow_bias     = _data[in_light + 3];
		
		var object = getObject(_array_index);
		
		setTransform(object, _data);
		setLight(object, _data);
		object.setShadow(_shadow_active, _shadow_map_size, _shadow_map_scal);
		object.shadow_bias = _shadow_bias;
		
		var _rot = new __rot3().lookAt(object.transform.position, new __vec3());
		object.transform.rotation.FromEuler(_rot.x, _rot.y, _rot.z);
		
		return object;
	} #endregion
}