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
	anim_drawn	= array_create(ANIMATOR.frames_total + 1, false);
	
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
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
		
	outputs[| 1] = nodeValue("Atlas Data", self, JUNCTION_CONNECT.output, VALUE_TYPE.struct, [])
		.setArrayDepth(1);
	
	refreshSurface = false;
	
	input_display_list = [
		["Surface",	 false], 0, 1, 2,
		["Packing",	 false], 3, 4, 5, 6, 7, 
	]
	
	attribute_surface_depth();

	static step = function() {
		var grup = inputs[| 1].getValue();
		var pack = inputs[| 3].getValue();
		
		if(pack == 0)	inputs[| 5].editWidget.data = [ "Top", "Center", "Bottom" ];
		else			inputs[| 5].editWidget.data = [ "Left", "Center", "Right" ];
		
		inputs[| 2].setVisible(grup == SPRITE_ANIM_GROUP.animation);
		inputs[| 4].setVisible(pack == SPRITE_STACK.grid);
		inputs[| 5].setVisible(pack != SPRITE_STACK.grid);
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		var inpt = inputs[| 0].getValue();
		var grup = inputs[| 1].getValue();
		var skip = inputs[| 2].getValue();
		var pack = inputs[| 3].getValue();
		var grid = inputs[| 4].getValue();
		var alig = inputs[| 5].getValue();
		var spac = inputs[| 6].getValue();
		var padd = inputs[| 7].getValue();
		
		var _atl = outputs[| 1].getValue();
		var cDep = attrDepth();
		
		if(grup != SPRITE_ANIM_GROUP.animation) {
			initRender();
			return;
		} else if(ANIMATOR.rendering & ANIMATOR.frame_progress && ANIMATOR.current_frame == 0 && !refreshSurface) {
			var skip = inputs[| 2].getValue();
			
			if(is_array(inpt) && array_length(inpt) == 0) return;
			var arr   = is_array(inpt);
			if(!arr) 
				inpt  = [ inpt ];
			var _surf = [];
			var amo   = floor(ANIMATOR.frames_total / skip);
			
			for(var i = 0; i < array_length(inpt); i++) { 
				if(!is_surface(inpt[i])) continue;
				var sw = surface_get_width(inpt[i]);
				var sh = surface_get_height(inpt[i]);
				var ww = sw, hh = sh;
				
				switch(pack) {
					case SPRITE_STACK.horizontal :						
						ww = sw * amo + spac * (amo - 1);
						break;
					case SPRITE_STACK.vertical :
						hh = sh * amo + spac * (amo - 1);
						break;
					case SPRITE_STACK.grid :
						var amo = floor(ANIMATOR.frames_total / skip);
						var col = inputs[| 4].getValue();
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
				
				_atl[i] = [];
			}
			
			if(!arr) _surf = array_safe_get(_surf, 0);
			outputs[| 0].setValue(_surf);
		}
		
		if(safe_mod(ANIMATOR.current_frame, skip) != 0) return;
		
		if(array_length(anim_drawn) != ANIMATOR.frames_total)
			array_resize(anim_drawn, ANIMATOR.frames_total);
			
		if(ANIMATOR.current_frame >= 0 && ANIMATOR.current_frame < ANIMATOR.frames_total) {
			if(anim_drawn[ANIMATOR.current_frame]) return;
			
			if(ANIMATOR.is_playing && ANIMATOR.frame_progress) {
				if(is_array(inpt) && array_length(inpt) == 0) return;
				if(!is_array(inpt)) inpt = [ inpt ];
			}
		}
		
		var oupt = outputs[| 0].getValue();
		if(is_array(oupt) && (array_length(inpt) != array_length(oupt))) return;
		
		var drawn = false;
		var px = padd[2];
		var py = padd[1];
						
		for(var i = 0; i < array_length(inpt); i++) {
			if(!is_surface(inpt[i])) break;
			var oo = noone;
			if(!is_array(oupt))		oo = oupt;
			else					oo = oupt[i];
			if(!is_surface(oo)) break;
			
			var ww = surface_get_width(oo);
			var hh = surface_get_height(oo);
			
			var _w = surface_get_width(inpt[i]);
			var _h = surface_get_height(inpt[i]);
			
			var _frame = floor(ANIMATOR.current_frame / skip);
			surface_set_target(oo);
			BLEND_OVERRIDE;
			
			switch(pack) {
				case SPRITE_STACK.horizontal :
					var px  = padd[2] + _frame * _w + max(0, _frame - 1) * spac;
					var _sx = px;
					var _sy = py;
					
					switch(alig) {
						case 1 : _sy = py + (hh - _h) / 2;	break;
						case 2 : _sy = py + (hh - _h);		break;
					}
					
					array_push(_atl[i], new spriteAtlasData(_sx, _sy, _w, _h, inpt[i], _frame));
					draw_surface_safe(inpt[i], _sx, _sy);
					
					break;
				case SPRITE_STACK.vertical :
					var py = padd[1] + _frame * _h + max(0, _frame - 1) * spac;
					var _sx = px;
					var _sy = py;
					
					switch(alig) {
						case 1 : _sx = px + (ww - _w) / 2;	break;
						case 2 : _sx = px + (ww - _w);		break;
					}
					
					array_push(_atl[i], new spriteAtlasData(_sx, _sy, _w, _h, inpt[i], _frame));
					draw_surface_safe(inpt[i], _sx, _sy);
					
					break;
				case SPRITE_STACK.grid :
					var col  = inputs[| 4].getValue();
					var _row = floor(_frame / col);
					var _col = safe_mod(_frame, col);
					
					px = padd[2] + _col * _w + max(0, _col - 1) * spac;
					py = padd[1] + _row * _h + max(0, _row - 1) * spac;
					
					array_push(_atl[i], new spriteAtlasData(px, py, _w, _h, inpt[i], _frame));
					draw_surface_safe(inpt[i], px, py);
					break;
			}
			drawn = true;
			
			BLEND_NORMAL;
			surface_reset_target();
		}
		
		if(drawn) array_safe_set(anim_drawn, ANIMATOR.current_frame, true);
		outputs[| 1].setValue(_atl);
	}
	
	static onInspectorUpdate = function(updateAll = true) {
		var key = ds_map_find_first(NODE_MAP);
		repeat(ds_map_size(NODE_MAP)) {
			var node = NODE_MAP[? key];
			key = ds_map_find_next(NODE_MAP, key);
			
			if(!node.active) continue;
			if(instanceof(node) != "Node_Render_Sprite_Sheet") continue;
			
			node.initRender();
		}
	}
	
	static initRender = function() { 
		for(var i = 0; i < array_length(anim_drawn); i++) anim_drawn[i] = false;
		
		var inpt = inputs[| 0].getValue();
		var grup = inputs[| 1].getValue();
		var pack = inputs[| 3].getValue();
		var alig = inputs[| 5].getValue();
		var spac = inputs[| 6].getValue();
		var padd = inputs[| 7].getValue();
		
		var cDep = attrDepth();
		
		if(grup == SPRITE_ANIM_GROUP.animation) {
			refreshSurface = false;
			if(!LOADING && !APPENDING) {
				ANIMATOR.setFrame(-1);
				ANIMATOR.is_playing = true;
				ANIMATOR.rendering = true;
				ANIMATOR.frame_progress = true;
			}
			
			outputs[| 1].setValue([]);
			return;
		} 
		
		if(!is_array(inpt)) {
			outputs[| 0].setValue(inpt);
			outputs[| 1].setValue([]);
			return;	
		}
		
		if(array_length(inpt) == 0) return;
		var ww   = 0;
		var hh   = 0;
		var _atl = [];
		
		switch(pack) {
			case SPRITE_STACK.horizontal :
				for(var i = 0; i < array_length(inpt); i++) {
					ww += surface_get_width(inpt[i]);
					if(i) ww += spac;
					hh  = max(hh, surface_get_height(inpt[i]));
				}
				break;
			case SPRITE_STACK.vertical :
				for(var i = 0; i < array_length(inpt); i++) {
					ww  = max(ww, surface_get_width(inpt[i]));
					hh += surface_get_height(inpt[i]);
					if(i) hh += spac;
				}
				break;
			case SPRITE_STACK.grid :
				var amo = array_length(inpt);
				var col = inputs[| 4].getValue();
				var row = ceil(amo / col);
						
				var row_w = 0;
				var row_h = 0;
						
				for(var i = 0; i < row; i++) {
					var row_w = 0;
					var row_h = 0;
							
					for(var j = 0; j < col; j++) {
						var index = i * col + j;
						if(index >= amo) break;
						row_w += surface_get_width(inpt[index]);
						if(j) row_w += spac;
						row_h  = max(row_h, surface_get_height(inpt[index]));
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
				for(var i = 0; i < array_length(inpt); i++) {
					var _w  = surface_get_width(inpt[i]);
					var _h  = surface_get_height(inpt[i]);
					var _sx = px;
					var _sy = py;
					
					switch(alig) {
						case 1 : _sy = py + (hh - _h) / 2;	break;
						case 2 : _sy = py + (hh - _h);		break;
					}
					
					array_push(_atl, new spriteAtlasData(_sx, _sy, _w, _h, inpt[i], i));
					draw_surface_safe(inpt[i], _sx, _sy);
					
					px += _w + spac;
				}
				break;
			case SPRITE_STACK.vertical :
				var px = padd[2];
				var py = padd[1];
				for(var i = 0; i < array_length(inpt); i++) {
					var _w = surface_get_width(inpt[i]);
					var _h = surface_get_height(inpt[i]);
					var _sx = px;
					var _sy = py;
							
					switch(alig) {
						case 1 : _sx = px + (ww - _w) / 2;	break;
						case 2 : _sx = px + (ww - _w);		break;
					}
					
					array_push(_atl, new spriteAtlasData(_sx, _sy, _w, _h, inpt[i], i));
					draw_surface_safe(inpt[i], _sx, _sy);
					
					py += _h + spac;
				}
				break;
			case SPRITE_STACK.grid :
				var amo = array_length(inpt);
				var col = inputs[| 4].getValue();
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
						var index = i * col + j;
						if(index >= amo) break;
								
						var _w = surface_get_width(inpt[index]);
						var _h = surface_get_height(inpt[index]);
						
						array_push(_atl, new spriteAtlasData(px, py, _w, _h, inpt[i], index));
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
	}
}