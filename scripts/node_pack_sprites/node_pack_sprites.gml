function Node_Pack_Sprites(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Pack Sprties";
	
	inputs[| 0] = nodeValue("Sprites", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Algorithm", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Skyline", "Shelf", "Top left", "Best fit" ], { update_hover: false })
	
	inputs[| 2] = nodeValue("Max width", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 32);
	
	inputs[| 3] = nodeValue("Max height", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 32);
	
	outputs[| 0] = nodeValue("Packed image", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Atlas data", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, []);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var rect = outputs[| 1].getValue();
		
		draw_set_color(COLORS._main_accent);
		
		for( var i = 0; i < array_length(rect); i++ ) {
			var r = rect[i];
			draw_rectangle(
				_x + r.x * _s, 
				_y + r.y * _s, 
				_x + r.x * _s + r.w * _s, 
				_y + r.y * _s + r.h * _s, true);
		}
	}
	
	static step = function() {
		var algo = inputs[| 1].getValue();
		
		inputs[| 2].setVisible(algo == 1 || algo == 0);
		inputs[| 3].setVisible(algo == 2 || algo == 0);
	}
	
	static update = function() {
		var _inpt = inputs[| 0].getValue();
		var _algo = inputs[| 1].getValue();
		
		if(!is_array(_inpt) || array_length(_inpt) == 0) return;
		
		var _rects = [];
		
		for( var i = 0; i < array_length(_inpt); i++ ) {
			var s = _inpt[i];
			if(!is_surface(s)) continue;
			
			_rects[i] = new spriteAtlasData(0, 0, surface_get_width(s), surface_get_height(s), s, i);
		}
		
		var pack;
		
		switch(_algo) {
			case 0 : 
				var _wid = inputs[| 2].getValue();
				var _hei = inputs[| 3].getValue();
				pack = sprite_pack_skyline(_rects, _wid, _hei); 
				break;
			case 1 : 
				var _wid = inputs[| 2].getValue();
				pack = sprite_pack_shelf(_rects, _wid); 
				break;
			case 2 : 
				var _hei = inputs[| 3].getValue();
				pack = sprite_pack_bottom_left(_rects, _hei); 
				break;
			case 3 : 
				pack = sprite_pack_best_fit(_rects); 
				break;
		}
		
		var area = pack[0];
		var rect = pack[1];
		
		if(array_length(rect) < array_length(_rects))
			noti_warning("Not enought space, packed " + string(array_length(rect)) + " out of " + string(array_length(_rects)) + " images");
			
		var _surf = outputs[| 0].getValue();
		_surf = surface_verify(_surf, area.w, area.h, surface_get_format(_inpt[0]));
		outputs[| 0].setValue(_surf);
		
		surface_set_target(_surf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			
			for( var i = 0; i < array_length(rect); i++ ) {
				var r = rect[i];
				draw_surface(r.surface, r.x, r.y);
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		outputs[| 1].setValue(rect);
	}
}