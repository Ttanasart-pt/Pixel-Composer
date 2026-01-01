function Node_Align_Content(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Align Content";
	
	newActiveInput(1);
	
	////- =Surfaces
	newInput(0, nodeValue_Surface( "Surface In" )).setArrayDepth(1);
	newInput(2, nodeValue_Color(   "Background", cola(c_black, 0) ));
	
	////- =Alignment
	newInput(3, nodeValue_Anchor(  "Align Anchor" ));
	newInput(4, nodeValue_Padding( "Pad Content", [0,0,0,0] ));
	// 5
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone )).setArrayDepth(1);
	
	input_display_list = [ 1,
		[ "Surfaces",   false ], 0, 2, 
		[ "Alignment",  false ], 3, 4, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	temp_surface = [ noone, noone ];
	
	draw_transforms = [];
	static drawOverlayTransform = function(_node) { return array_safe_get(draw_transforms, preview_index, noone); }
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[0];
			var _bg   = _data[2];
			
			var _anc  = _data[3];
			var _pad  = _data[4];
		#endregion
		
		var sw = surface_get_width_safe(_surf);
		var sh = surface_get_height_safe(_surf);
		
		temp_surface[0] = surface_verify(temp_surface[0], sw, sh);
		var _sclr = temp_surface[0];
		surface_set_shader(_sclr, sh_crop_content_replace_color);
			shader_set_c("target", _bg);
			draw_surface_safe(_surf);
		surface_reset_shader();
		
		var bbox = surface_get_bbox(_sclr);
		var minx = bbox[0];
		var miny = bbox[1];
		var conw = bbox[2];
		var conh = bbox[3];
		
		var sx = -minx + _anc[0] * (sw - conw - _pad[0] - _pad[2]) + _pad[2];
		var sy = -miny + _anc[1] * (sh - conh - _pad[3] - _pad[1]) + _pad[1];
		
		surface_set_shader(_outSurf);
			draw_clear_alpha(_bg, _color_get_alpha(_bg));
			
			draw_surface(temp_surface[0], sx, sy);
		surface_reset_shader();
		
		return _outSurf;
	}
}