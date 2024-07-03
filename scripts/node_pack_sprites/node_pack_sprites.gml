function Node_Pack_Sprites(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Pack Sprites";
	
	inputs[| 0] = nodeValue("Sprites", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Algorithm", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, { data: [ "Skyline", "Shelf", "Top left", "Best fit" ], update_hover: false });
	
	inputs[| 2] = nodeValue("Max width", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 128);
	
	inputs[| 3] = nodeValue("Max height", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 128);
	
	inputs[| 4] = nodeValue("Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	outputs[| 0] = nodeValue("Packed image", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Atlas data", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, []);
	
	input_display_list = [ 0, 4, 1, 2, 3 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var rect = outputs[| 1].getValue();
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
	} #endregion
	
	static step = function() { #region
		var algo = getInputData(1);
		
		inputs[| 2].setVisible(algo == 1 || algo == 0);
		inputs[| 3].setVisible(algo == 2 || algo == 0);
	} #endregion
	
	static update = function() { #region
		var _inpt = getInputData(0);
		var _algo = getInputData(1);
		var _spac = getInputData(4);
		
		if(!is_array(_inpt) || array_length(_inpt) == 0) return;
		
		var _rects = [], _ind = 0;
		
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
				var _hei = getInputData(3);
				pack = sprite_pack_bottom_left(_rects, _hei); 
				break;
				
			case 3 : 
				pack = sprite_pack_best_fit(_rects); 
				break;
		}
		
		var area  = pack[0];
		var rect  = pack[1];
		var atlas = [];
		
		if(array_length(rect) < array_length(_rects)) {
			var _txt = $"Not enought space, packed {array_length(rect)} out of {array_length(_rects)} images.";
			logNode(_txt); noti_warning(_txt);
		}
		
		var _surf = outputs[| 0].getValue();
		_surf = surface_verify(_surf, area.w, area.h, surface_get_format(_inpt[0]));
		outputs[| 0].setValue(_surf);
		
		surface_set_target(_surf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			
			for( var i = 0, n = array_length(rect); i < n; i++ ) {
				var r = rect[i];
				
				array_push(atlas, new SurfaceAtlas(r.surface.surface, r.x + _spac, r.y + _spac));
				draw_surface_safe(r.surface.surface, r.x + _spac, r.y + _spac);
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		outputs[| 1].setValue(atlas);
	} #endregion
}