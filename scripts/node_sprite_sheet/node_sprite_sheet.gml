enum SPRITE_STACK {
	horizontal,
	vertical,
	grid
}

enum SPRITE_ANIM_GROUP {
	animation,
	all_sprites
}

function Node_Render_Sprite_Sheet(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
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
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static step = function() {
		var grup = inputs[| 1].getValue();
		var pack = inputs[| 3].getValue();
		
		inputs[| 2].setVisible(grup == SPRITE_ANIM_GROUP.animation);
		inputs[| 4].setVisible(pack == SPRITE_STACK.grid);
	}
	
	static update = function(frame = ANIMATOR.current_frame) {
		var inpt = inputs[| 0].getValue();
		var grup = inputs[| 1].getValue();
		var skip = inputs[| 2].getValue();
		var pack = inputs[| 3].getValue();
		var grid = inputs[| 4].getValue();
		var alig = inputs[| 5].getValue();
		
		var oupt = outputs[| 0].getValue();
		
		if(grup != SPRITE_ANIM_GROUP.animation) {
			onInspectorUpdate();
			return;
		}
		if(safe_mod(ANIMATOR.current_frame, skip) != 0) return;
		
		if(array_length(anim_drawn) != ANIMATOR.frames_total)
			array_resize(anim_drawn, ANIMATOR.frames_total);
			
		if(ANIMATOR.current_frame < ANIMATOR.frames_total) {
			if(anim_drawn[ANIMATOR.current_frame]) return;
			
			if(ANIMATOR.is_playing && ANIMATOR.frame_progress) {
				if(is_array(inpt) && array_length(inpt) == 0) return;
				if(!is_array(inpt)) inpt = [ inpt ];
			}
		}
		
		if(is_array(oupt) && (array_length(inpt) != array_length(oupt))) return;
		
		var px = 0, py = 0;
		var drawn = false;
		
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
					var px = _frame * _w;
					switch(alig) {
						case 0 :
							draw_surface_safe(inpt[i], px, py);
							break;
						case 1 :
							draw_surface_safe(inpt[i], px, py + (hh - _h) / 2);
							break;
						case 2 :
							draw_surface_safe(inpt[i], px, py + (hh - _h));
							break;
					}
					break;
				case SPRITE_STACK.vertical :
					var py = _frame * _h;
					switch(alig) {
						case 0 :
							draw_surface_safe(inpt[i], px, py);
							break;
						case 1 :
							draw_surface_safe(inpt[i], px + (ww - _w) / 2, py);
							break;
						case 2 :
							draw_surface_safe(inpt[i], px + (ww - _w), py);
							break;
					}
					break;
				case SPRITE_STACK.grid :
					var col  = inputs[| 4].getValue();
					var _row = floor(_frame / col);
					var _col = safe_mod(_frame, col);
					
					px = _col * _w;
					py = _row * _h;
					
					draw_surface_safe(inpt[i], px, py);
					break;
			}
			drawn = true;
			
			BLEND_NORMAL;
			surface_reset_target();
		}
		
		if(drawn)
			anim_drawn[ANIMATOR.current_frame] = true;
	}
	
	static onInspectorUpdate = function() {
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
		
		if(grup == SPRITE_ANIM_GROUP.animation) {
			if(!LOADING && !APPENDING) {
				ANIMATOR.setFrame(-1);
				ANIMATOR.is_playing = true;
				ANIMATOR.rendering = true;
				ANIMATOR.frame_progress = true;
			}
			
			var skip = inputs[| 2].getValue();
			
			if(is_array(inpt) && array_length(inpt) == 0) return;
			var arr = is_array(inpt);
			if(!arr) inpt = [ inpt ];
			var _surf = [];
			
			for(var i = 0; i < array_length(inpt); i++) {
				if(!is_surface(inpt[i])) continue;
				var ww = surface_get_width(inpt[i]);
				var hh = surface_get_height(inpt[i]);
				
				switch(pack) {
					case SPRITE_STACK.horizontal :
						ww *= floor(ANIMATOR.frames_total / skip);
						break;
					case SPRITE_STACK.vertical :
						hh *= floor(ANIMATOR.frames_total / skip);
						break;
					case SPRITE_STACK.grid :
						var amo = floor(ANIMATOR.frames_total / skip);
						var col = inputs[| 4].getValue();
						var row = ceil(amo / col);
						
						ww *= col;
						hh *= row;
						break;
				}
				
				_surf[i] = surface_create_valid(ww, hh);
				surface_set_target(_surf[i]);
				draw_clear_alpha(0, 0);
				surface_reset_target();
			}
			
			if(!arr) _surf = _surf[0];
			outputs[| 0].setValue(_surf);
		} else {
			if(is_array(inpt)) {
				if(array_length(inpt) == 0) return;
				var ww = 0;
				var hh = 0;
				
				switch(pack) {
					case SPRITE_STACK.horizontal :
						for(var i = 0; i < array_length(inpt); i++) {
							ww += surface_get_width(inpt[i]);
							hh  = max(hh, surface_get_height(inpt[i]));
						}
						break;
					case SPRITE_STACK.vertical :
						for(var i = 0; i < array_length(inpt); i++) {
							ww  = max(ww, surface_get_width(inpt[i]));
							hh += surface_get_height(inpt[i]);
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
								row_h  = max(row_h, surface_get_height(inpt[index]));
							}
							
							ww  = max(ww, row_w);
							hh += row_h;
						}
						break;
				}
				
				var _surf = surface_create_valid(ww, hh);
				
				surface_set_target(_surf);
				draw_clear_alpha(0, 0);
				
				BLEND_OVERRIDE;
				switch(pack) {
					case SPRITE_STACK.horizontal :
						var px = 0;
						var py = 0;
						for(var i = 0; i < array_length(inpt); i++) {
							var _w = surface_get_width(inpt[i]);
							var _h = surface_get_height(inpt[i]);
							
							switch(alig) {
								case 0 :
									draw_surface_safe(inpt[i], px, py);
									break;
								case 1 :
									draw_surface_safe(inpt[i], px, py + (hh - _h) / 2);
									break;
								case 2 :
									draw_surface_safe(inpt[i], px, py + (hh - _h));
									break;
							}
							
							px += _w;
						}
						break;
					case SPRITE_STACK.vertical :
						var px = 0;
						var py = 0;
						for(var i = 0; i < array_length(inpt); i++) {
							var _w = surface_get_width(inpt[i]);
							var _h = surface_get_height(inpt[i]);
							
							switch(alig) {
								case 0 :
									draw_surface_safe(inpt[i], px, py);
									break;
								case 1 :
									draw_surface_safe(inpt[i], px + (ww - _w) / 2, py);
									break;
								case 2 :
									draw_surface_safe(inpt[i], px + (ww - _w), py);
									break;
							}
							
							py += _h;
						}
						break;
					case SPRITE_STACK.grid :
						var amo = array_length(inpt);
						var col = inputs[| 4].getValue();
						var row = ceil(amo / col);
						
						var row_w = 0;
						var row_h = 0;
						var px = 0;
						var py = 0;
						
						for(var i = 0; i < row; i++) {
							var row_w = 0;
							var row_h = 0;
							px = 0;
								
							for(var j = 0; j < col; j++) {
								var index = i * col + j;
								if(index >= amo) break;
								
								var _w = surface_get_width(inpt[index]);
								var _h = surface_get_height(inpt[index]);
								draw_surface_safe(inpt[index], px, py);
								
								px += _w;
								row_h = max(row_h, _h);
							}
							py += row_h;
						}
						break;
					}
					BLEND_NORMAL;
				surface_reset_target();
				outputs[| 0].setValue(_surf);
			} else
				outputs[| 0].setValue(inpt);
		}
	}
}