function Node_Align_Content(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Align Content";
	
	newActiveInput(1);
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface(  "Surface In"  )).setRequired();
	newInput( 2, nodeValue_Color(    "Background", cola(c_black, 0) )).setPieMenu();
	
	////- =Alignment
	newInput( 3, nodeValue_Anchor(   "Align Anchor"           )).setPieMenu();
	newInput( 4, nodeValue_IPadding( "Pad Content", [0,0,0,0] )).setUnitSimple(false);
	// 5
	
	newOutput( 0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 1,
		[ "Surfaces",   false ], 0, 2, 
		[ "Alignment",  false ], 3, 4, 
	];
	
	////- Node
	
	attribute_surface_depth();
	
	temp_surface = [ noone, noone ];
	surface_bbox = [];
	surface_pos  = [];
	
	draw_transforms = [];
	static drawOverlayTransform = function(_node) { return array_safe_get(draw_transforms, preview_index, noone); }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var bbox = array_safe_get(surface_bbox, preview_index, noone);
		var ppos = array_safe_get(surface_pos,  preview_index, noone);
		if(!is_array(bbox)) return;
		
		var _padd = getInputSingle( 4);
		
		var minx = bbox[0];
		var miny = bbox[1];
		var conw = bbox[2];
		var conh = bbox[3];
		
		var x0 = _x + minx * _s + ppos[0] * _s;
		var y0 = _y + miny * _s + ppos[1] * _s;
		var x1 = x0 + conw * _s;
		var y1 = y0 + conh * _s;
		
		var px0 = x0 - _padd[2] * _s;
		var py0 = y0 - _padd[1] * _s;
		var px1 = x1 + _padd[0] * _s;
		var py1 = y1 + _padd[3] * _s;
		
		draw_set_color(COLORS._main_icon);
		draw_rectangle_dashed(px0-1, py0-1, px1, py1);
		
		draw_set_color(COLORS._main_accent);
		draw_rectangle(x0, y0, x1, y1, true);
		
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf = _data[ 0];
			var _bg   = _data[ 2];
			
			var _anc  = _data[ 3];
			var _pad  = _data[ 4];
		#endregion
		
		var sw = surface_get_width_safe(_surf);
		var sh = surface_get_height_safe(_surf);
		
		_outSurf        = surface_verify(_outSurf,        sw, sh, attrDepth());
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
		
		surface_bbox[_array_index] = bbox;
		surface_pos[_array_index]  = [sx, sy];
		
		surface_set_shader(_outSurf);
			draw_clear_alpha(_bg, _color_get_alpha(_bg));
			draw_surface(temp_surface[0], sx, sy);
		surface_reset_shader();
		
		return _outSurf;
	}
}