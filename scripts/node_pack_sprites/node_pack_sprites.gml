function Node_Pack_Sprites(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Pack Sprites";
	
	////- =Sprties
	newInput(0, nodeValue_Surface( "Sprites" ));
	
	////- =Packing
	newInput(1, nodeValue_EScroll( "Algorithm",  0, { data: [ "Skyline", "Shelf", "Top left", "Best fit" ], update_hover: false }));
	newInput(4, nodeValue_Int(     "Spacing",    0   ));
	newInput(2, nodeValue_Int(     "Max width",  128 ));
	newInput(3, nodeValue_Int(     "Max height", 128 ));
	// 5
	
	newOutput(0, nodeValue_Output("Packed image", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Atlas data", VALUE_TYPE.atlas, []));
	
	input_display_list = [ 
		[ "Sprties", false ], 0, 
		[ "Packing", false ], 1, 4, 2, 3 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var rect = outputs[1].getValue();
		var spac = getInputData(4);
		
		draw_set_color(COLORS._main_accent);
		
		for( var i = 0, n = array_length(rect); i < n; i++ ) {
			var r = rect[i];
			
			var _surf = r.getSurface();
			var _sx   = r.x;
			var _sy   = r.y;
			
			if(!is_surface(_surf)) continue;
			
			var _sw = surface_get_width_safe(_surf);
			var _sh = surface_get_height_safe(_surf);
			
			draw_rectangle(
				_x + _s * (_sx), 
				_y + _s * (_sy), 
				_x + _s * (_sx + _sw), 
				_y + _s * (_sy + _sh), true);
		}
	}
	
	static update = function() {
		var _inpt = getInputData(0);
		var _algo = getInputData(1);
		var _spac = getInputData(4);
		
		inputs[2].setVisible(_algo <= 2);
		inputs[3].setVisible(_algo == 0);
		
		if(!is_array(_inpt) || array_length(_inpt) == 0) return;
		
		var _rects = [];
		var _ind   = 0;
		
		for( var i = 0, n = array_length(_inpt); i < n; i++ ) {
			var s = _inpt[i];
			if(!is_surface(s)) continue;
			
			_rects[_ind] = new SurfaceAtlas(s);
			_rects[_ind].w = surface_get_width_safe(s)  + _spac * 2;
			_rects[_ind].h = surface_get_height_safe(s) + _spac * 2;
			
			_ind++;
		}
		
		array_resize(_rects, _ind);
		
		var pack;
		
		switch(_algo) {
			case 0 : 
				var _wid = getInputData(2);
				var _hei = getInputData(3);
				pack = sprite_pack_skyline(_rects, _wid, _hei); 
				break;
				
			case 1 : 
				var _wid = getInputData(2);
				pack = sprite_pack_shelf(_rects, _wid); 
				break;
				
			case 2 : 
				var _wid = getInputData(2);
				pack = sprite_pack_bottom_left(_rects, _wid); 
				break;
				
			case 3 : 
				pack = sprite_pack_best_fit(_rects); 
				break;
		}
		
		var area  = pack[0];
		var rect  = pack[1];
		var atlas = [];
		
		if(array_length(rect) < array_length(_rects))
			noti_warning($"Not enought space, packed {array_length(rect)} out of {array_length(_rects)} images.", noone, self);
		
		var _surf = outputs[0].getValue();
		_surf = surface_verify(_surf, area.w, area.h, surface_get_format(_inpt[0]));
		outputs[0].setValue(_surf);
		
		surface_set_target(_surf);
			DRAW_CLEAR
			// BLEND_OVERRIDE
			
			for( var i = 0, n = array_length(rect); i < n; i++ ) {
				var r = rect[i];
				
				draw_set_color(c_red);
				draw_set_alpha(.5);
				draw_rectangle(r.x, r.y, r.x+r.w-1, r.y+r.h-1, false);
				draw_set_alpha(1);
				
				array_push(atlas, new SurfaceAtlas(r.surface.surface, r.x + _spac, r.y + _spac));
				draw_surface_safe(r.surface.surface, r.x + _spac, r.y + _spac);
				
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		outputs[1].setValue(atlas);
	}
}