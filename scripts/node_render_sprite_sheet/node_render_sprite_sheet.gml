enum SPRITE_STACK {
	horizontal,
	vertical,
	grid
}

enum SPRITE_ANIM_GROUP {
	animation,
	all_sprites
}

function Node_Render_Sprite_Sheet(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Render Spritesheet";
	anim_drawn	= array_create(TOTAL_FRAMES + 1, false);
	
	inputs[| 0] = nodeValue("Sprites", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Sprite set", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Animation", "Sprite array" ])
		.rejectArray();
	
	inputs[| 2] = nodeValue("Frame step", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1, "Number of frames until next sprite. Can be seen as (Step - 1) frame skip.")
		.rejectArray();
	
	inputs[| 3] = nodeValue("Packing type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Horizontal", "Vertical", "Grid" ])
		.rejectArray();
	
	inputs[| 4] = nodeValue("Grid column", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 4)
		.rejectArray();
	
	inputs[| 5] = nodeValue("Alignment", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "First", "Middle", "Last" ])
		.rejectArray();
	
	inputs[| 6] = nodeValue("Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 7] = nodeValue("Padding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.padding)
	
	inputs[| 8] = nodeValue("Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ], "Starting/ending frames, set end to 0 to default to last frame.")
		.setDisplay(VALUE_DISPLAY.vector)
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
		
	outputs[| 1] = nodeValue("Atlas Data", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, [])
		.setArrayDepth(1);
	
	refreshSurface = false;
	
	input_display_list = [
		["Surfaces", false], 0, 1, 2,
		["Sprite",	 false], 3, 8, 
		["Packing",	 false], 4, 5, 6, 7, 
	]
	
	attribute_surface_depth();

	static step = function() { #region
		var grup = getInputData(1);
		var pack = getInputData(3);
		
		if(pack == 0)	inputs[| 5].editWidget.data = [ "Top", "Center", "Bottom" ];
		else			inputs[| 5].editWidget.data = [ "Left", "Center", "Right" ];
		
		inputs[| 2].setVisible(grup == SPRITE_ANIM_GROUP.animation);
		inputs[| 4].setVisible(pack == SPRITE_STACK.grid);
		inputs[| 5].setVisible(pack != SPRITE_STACK.grid);
		
		update_on_frame = grup == 0;
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var inpt = getInputData(0);
		var grup = getInputData(1);
		var skip = getInputData(2);
		var pack = getInputData(3);
		var grid = getInputData(4);
		var alig = getInputData(5);
		var spac = getInputData(6);
		var padd = getInputData(7);
		var rang = getInputData(8);
		
		var _atl = outputs[| 1].getValue();
		var cDep = attrDepth();
		
		if(grup != SPRITE_ANIM_GROUP.animation) {
			initRender();
			return;
		} 
		
		if(IS_RENDERING && PROJECT.animator.frame_progress && CURRENT_FRAME == 0 && !refreshSurface) {
			var skip = getInputData(2);
			
			var arr = is_array(inpt);
			if(arr && array_length(inpt) == 0) return;
			if(!arr) inpt  = [ inpt ];
			var _surf = [];
			
			var amo   = floor(TOTAL_FRAMES / skip);
			var _st   = clamp(rang[0], 0, amo);
			var _ed   = rang[1];
			if(rang[1] == 0)     _ed = amo;
			else if(rang[1] < 0) _ed = amo + rang[1];
			_ed = clamp(_ed, 0, amo);
			if(_ed <= _st) return;
			amo = _ed - _st;
			
			for(var i = 0; i < array_length(inpt); i++) { 
				_atl[i] = [];
				
				if(!is_surface(inpt[i])) continue;
				var sw = surface_get_width_safe(inpt[i]);
				var sh = surface_get_height_safe(inpt[i]);
				var ww = sw, hh = sh;
				
				switch(pack) {
					case SPRITE_STACK.horizontal :						
						ww = sw * amo + spac * (amo - 1);
						break;
					case SPRITE_STACK.vertical :
						hh = sh * amo + spac * (amo - 1);
						break;
					case SPRITE_STACK.grid :
						var amo = floor(TOTAL_FRAMES / skip);
						var col = getInputData(4);
						var row = ceil(amo / col);
						
						ww = sw * col + spac * (col - 1);
						hh = sh * row + spac * (row - 1);
						break;
				}
				
				ww += padd[0] + padd[2];
				hh += padd[1] + padd[3];
				_surf[i] = surface_create_valid(ww, hh, cDep);
				surface_set_target(_surf[i]);
				DRAW_CLEAR
				surface_reset_target();
				
				refreshSurface = true;
			}
			
			if(!arr) _surf = array_safe_get(_surf, 0);
			outputs[| 0].setValue(_surf);
			outputs[| 1].setValue(_atl);
		}
		
		if(safe_mod(CURRENT_FRAME, skip) != 0) return;
		
		if(array_length(anim_drawn) != TOTAL_FRAMES)
			array_resize(anim_drawn, TOTAL_FRAMES);
			
		if(CURRENT_FRAME >= 0 && CURRENT_FRAME < TOTAL_FRAMES) {
			if(anim_drawn[CURRENT_FRAME]) return;
			
			if(PROJECT.animator.is_playing && PROJECT.animator.frame_progress) {
				if(is_array(inpt) && array_length(inpt) == 0) return;
				if(!is_array(inpt)) inpt = [ inpt ];
			}
		}
		
		var oupt = outputs[| 0].getValue();
		if(is_array(oupt) && (array_length(inpt) != array_length(oupt))) return;
		if(CURRENT_FRAME % skip != 0) return;
		
		var amo    = floor(TOTAL_FRAMES / skip);
		var _st    = clamp(rang[0], 0, amo);
		var _ed = rang[1];
		if(rang[1] == 0)     _ed = amo;
		else if(rang[1] < 0) _ed = amo + rang[1];
		_ed = clamp(_ed, 0, amo);
		if(_ed <= _st) return;
		
		var _frame = floor(CURRENT_FRAME / skip);
		
		if(_frame < _st || _frame > _ed) return;
		_frame -= _st;
		
		var drawn = false;
		var px = padd[2];
		var py = padd[1];
						
		for(var i = 0; i < array_length(inpt); i++) {
			if(!is_surface(inpt[i])) {
				_atl[i] = noone;
				break;
			}
			
			var oo = noone;
			if(!is_array(oupt))		oo = oupt;
			else					oo = oupt[i];
			if(!is_surface(oo)) break;
			
			var ww = surface_get_width_safe(oo);
			var hh = surface_get_height_safe(oo);
			
			var _w = surface_get_width_safe(inpt[i]);
			var _h = surface_get_height_safe(inpt[i]);
			
			surface_set_target(oo);
			BLEND_OVERRIDE
			
			switch(pack) {
				case SPRITE_STACK.horizontal :
					var px  = padd[2] + _frame * _w + max(0, _frame) * spac;
					var _sx = px;
					var _sy = py;
					
					switch(alig) {
						case 1 : _sy = py + (hh - _h) / 2;	break;
						case 2 : _sy = py + (hh - _h);		break;
					}
					
					_atl[i] = array_push_create(_atl[i], new SurfaceAtlas(inpt[i], _sx, _sy));
					draw_surface_safe(inpt[i], _sx, _sy);
					break;
				case SPRITE_STACK.vertical :
					var py = padd[1] + _frame * _h + max(0, _frame) * spac;
					var _sx = px;
					var _sy = py;
					
					switch(alig) {
						case 1 : _sx = px + (ww - _w) / 2;	break;
						case 2 : _sx = px + (ww - _w);		break;
					}
					
					_atl[i] = array_push_create(_atl[i], new SurfaceAtlas(inpt[i], _sx, _sy));
					draw_surface_safe(inpt[i], _sx, _sy);
					
					break;
				case SPRITE_STACK.grid :
					var col  = getInputData(4);
					var _row = floor(_frame / col);
					var _col = safe_mod(_frame, col);
					
					px = padd[2] + _col * _w + max(0, _col) * spac;
					py = padd[1] + _row * _h + max(0, _row) * spac;
					
					_atl[i] = array_push_create(_atl[i], new SurfaceAtlas(inpt[i], px, py));
					draw_surface_safe(inpt[i], px, py);
					break;
			}
			drawn = true;
			
			BLEND_NORMAL;
			surface_reset_target();
		}
		
		if(drawn) array_safe_set(anim_drawn, CURRENT_FRAME, true);
		outputs[| 1].setValue(_atl);
	} #endregion
	
	static onInspector1Update = function(updateAll = true) { #region
		var key = ds_map_find_first(PROJECT.nodeMap);
		
		repeat(ds_map_size(PROJECT.nodeMap)) {
			var node = PROJECT.nodeMap[? key];
			key = ds_map_find_next(PROJECT.nodeMap, key);
			
			if(!node.active) continue;
			if(instanceof(node) != "Node_Render_Sprite_Sheet") continue;
			
			node.initRender();
		}
		
		array_push(RENDERING, node_id);
	} #endregion
	
	static initRender = function() { #region
		for(var i = 0; i < array_length(anim_drawn); i++) anim_drawn[i] = false;
		
		var inpt = getInputData(0);
		var grup = getInputData(1);
		var pack = getInputData(3);
		var alig = getInputData(5);
		var spac = getInputData(6);
		var padd = getInputData(7);
		var rang = getInputData(8);
		
		var cDep = attrDepth();
		
		if(grup == SPRITE_ANIM_GROUP.animation) {
			refreshSurface = false;
			if(!LOADING && !APPENDING)
				PROJECT.animator.render();
			
			outputs[| 1].setValue([]);
			return;
		} 
		
		if(!is_array(inpt)) {
			outputs[| 0].setValue(inpt);
			outputs[| 1].setValue([]);
			return;	
		}
		
		var amo = array_length(inpt);
		var _st = clamp(rang[0], 0, amo);
		var _ed = rang[1];
		if(rang[1] == 0)     _ed = amo;
		else if(rang[1] < 0) _ed = amo + rang[1];
		_ed = clamp(_ed, 0, amo);
		
		amo = _ed - _st;
		
		if(_ed <= _st) return;
		var ww   = 0;
		var hh   = 0;
		var _atl = [];
		
		switch(pack) {
			case SPRITE_STACK.horizontal :
				for(var i = _st; i < _ed; i++) {
					ww += surface_get_width_safe(inpt[i]);
					if(i > _st) ww += spac;
					hh  = max(hh, surface_get_height_safe(inpt[i]));
				}
				break;
			case SPRITE_STACK.vertical :
				for(var i = _st; i < _ed; i++) {
					ww  = max(ww, surface_get_width_safe(inpt[i]));
					hh += surface_get_height_safe(inpt[i]);
					if(i > _st) hh += spac;
				}
				break;
			case SPRITE_STACK.grid :
				var col = getInputData(4);
				var row = ceil(amo / col);
						
				var row_w = 0;
				var row_h = 0;
						
				for(var i = 0; i < row; i++) {
					var row_w = 0;
					var row_h = 0;
							
					for(var j = 0; j < col; j++) {
						var index = _st + i * col + j;
						if(index >= amo) break;
						row_w += surface_get_width_safe(inpt[index]);
						if(j) row_w += spac;
						row_h  = max(row_h, surface_get_height_safe(inpt[index]));
					}
							
					ww  = max(ww, row_w);
					hh += row_h							
					if(i) hh += spac;
				}
				break;
		}
				
		ww += padd[0] + padd[2];
		hh += padd[1] + padd[3];
		var _surf = surface_create_valid(ww, hh, cDep);
				
		surface_set_target(_surf);
		DRAW_CLEAR
				
		BLEND_OVERRIDE;
		switch(pack) {
			case SPRITE_STACK.horizontal :
				var px = padd[2];
				var py = padd[1];
				for(var i = _st; i < _ed; i++) {
					var _w  = surface_get_width_safe(inpt[i]);
					var _h  = surface_get_height_safe(inpt[i]);
					var _sx = px;
					var _sy = py;
					
					switch(alig) {
						case 1 : _sy = py + (hh - _h) / 2;	break;
						case 2 : _sy = py + (hh - _h);		break;
					}
					
					array_push(_atl, new SurfaceAtlas(inpt[i], _sx, _sy));
					draw_surface_safe(inpt[i], _sx, _sy);
					
					px += _w + spac;
				}
				break;
			case SPRITE_STACK.vertical :
				var px = padd[2];
				var py = padd[1];
				for(var i = _st; i < _ed; i++) {
					var _w = surface_get_width_safe(inpt[i]);
					var _h = surface_get_height_safe(inpt[i]);
					var _sx = px;
					var _sy = py;
							
					switch(alig) {
						case 1 : _sx = px + (ww - _w) / 2;	break;
						case 2 : _sx = px + (ww - _w);		break;
					}
					
					array_push(_atl, new SurfaceAtlas(inpt[i], _sx, _sy));
					draw_surface_safe(inpt[i], _sx, _sy);
					
					py += _h + spac;
				}
				break;
			case SPRITE_STACK.grid :
				var amo = array_length(inpt);
				var col = getInputData(4);
				var row = ceil(amo / col);
						
				var row_w = 0;
				var row_h = 0;
				var px = padd[2];
				var py = padd[1];
						
				for(var i = 0; i < row; i++) {
					var row_w = 0;
					var row_h = 0;
					px = padd[2];
								
					for(var j = 0; j < col; j++) {
						var index = _st + i * col + j;
						if(index >= amo) break;
								
						var _w = surface_get_width_safe(inpt[index]);
						var _h = surface_get_height_safe(inpt[index]);
						
						array_push(_atl, new SurfaceAtlas(inpt[index], px, py));
						draw_surface_safe(inpt[index], px, py);
								
						px += _w + spac;
						row_h = max(row_h, _h);
					}
					py += row_h + spac;
				}
				break;
			}
			BLEND_NORMAL;
		surface_reset_target();
		
		outputs[| 0].setValue(_surf);
		outputs[| 1].setValue(_atl);
	} #endregion
}