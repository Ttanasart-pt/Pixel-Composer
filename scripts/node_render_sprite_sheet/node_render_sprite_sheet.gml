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
	static log = false;
	
	name		= "Render Spritesheet";
	anim_drawn	= array_create(TOTAL_FRAMES + 1, false);
	
	inputs[| 0] = nodeValue("Sprites", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 1] = nodeValue("Sprite set", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Animation", "Sprite array" ])
		.rejectArray();
	
	inputs[| 2] = nodeValue("Frame step", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1, "Number of frames until next sprite. Can be seen as (Step - 1) frame skip.")
		.rejectArray();
	
	inputs[| 3] = nodeValue("Packing type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ new scrollItem("Horizontal", s_node_alignment, 0), 
												 new scrollItem("Vertical",   s_node_alignment, 1), 
												 new scrollItem("Grid",       s_node_alignment, 2), ])
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
		.setDisplay(VALUE_DISPLAY.slider_range)
		
	inputs[| 9] = nodeValue("Spacing", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 10] = nodeValue("Overlappable", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 11] = nodeValue("Custom Range", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
		
	outputs[| 1] = nodeValue("Atlas Data", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, []);
	
	input_display_list = [
		["Surfaces",  false], 0, 1, 2,
		["Sprite",	  false], 3, 
		["Packing",	  false], 4, 5, 6, 9, 7, 
		//["Rendering", false], 10, 
		["Custom Range", true, 11], 8, 
	]
	
	atlases = [];
	
	attribute_surface_depth();

	static onInspector1Update = function(updateAll = true) { initSurface(true); PROJECT.animator.render(); }
	
	static step = function() { #region
		var inpt = getInputData(0);
		var grup = getInputData(1);
		var pack = getInputData(3);
		var user = getInputData(11);
		
		if(pack == 0)	inputs[| 5].editWidget.data = [ "Top", "Center", "Bottom" ];
		else			inputs[| 5].editWidget.data = [ "Left", "Center", "Right" ];
		
		inputs[| 2].setVisible(grup == SPRITE_ANIM_GROUP.animation);
		inputs[| 4].setVisible(pack == SPRITE_STACK.grid);
		inputs[| 5].setVisible(pack != SPRITE_STACK.grid);
		inputs[| 6].setVisible(pack != SPRITE_STACK.grid);
		inputs[| 9].setVisible(pack == SPRITE_STACK.grid);
		
		if(grup == SPRITE_ANIM_GROUP.animation) {
			inputs[| 8].editWidget.minn = FIRST_FRAME + 1;
			inputs[| 8].editWidget.maxx = LAST_FRAME + 1;
			if(!user) inputs[| 8].setValueDirect([ FIRST_FRAME + 1, LAST_FRAME + 1], noone, false, 0, false);
		} else {
			inputs[| 8].editWidget.minn = 0;
			inputs[| 8].editWidget.maxx = array_length(inpt) - 1;
			if(!user) inputs[| 8].setValueDirect([ 0, array_length(inpt) - 1], noone, false, 0, false);
		}
		
		update_on_frame = grup == 0;
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		if(IS_FIRST_FRAME) initSurface();
		
		var grup = getInputData(1);
		
		if(grup == SPRITE_ANIM_GROUP.animation) animationRender();
		else									arrayRender();
	} #endregion
	
	static initSurface = function(clear = false) { #region
		for(var i = 0; i < TOTAL_FRAMES; i++) anim_drawn[i] = false;
		
		var grup = getInputData(1);
		
		if(grup == SPRITE_ANIM_GROUP.animation) animationInit(clear);
		else									arrayRender();
	} #endregion
	
	static arrayRender = function() { #region
		var inpt = getInputData(0);
		var grup = getInputData(1);
		var pack = getInputData(3);
		var alig = getInputData(5);
		var spac = getInputData(6);
		var padd = getInputData(7);
		var rang = getInputData(8);
		var spc2 = getInputData(9);
		//var ovlp = getInputData(10);
		
		var cDep = attrDepth();
		
		if(!is_array(inpt)) {
			outputs[| 0].setValue(surface_clone(inpt));
			outputs[| 1].setValue([]);
			return;	
		}
		
		#region frame
			var _st, _ed;
			var _ln = array_length(inpt);
			
			if(rang[0] < 0)  _st = _ln + rang[0];
			else             _st = rang[0];
			
			     if(rang[1] == 0) _ed = _ln;
			else if(rang[1] < 0)  _ed = _ln + rang[1];
			else                  _ed = rang[1];
			
			_st = clamp(_st, 0, _ln);
			_ed = clamp(_ed, 0, _ln);
			
			if(_ed < _st) return;
			var amo = _ed - _st + 1;
		#endregion
		
		var ww   = 0;
		var hh   = 0;
		atlases  = [];
		
		#region surface generate
			
			switch(pack) { 
				case SPRITE_STACK.horizontal :
					for(var i = _st; i <= _ed; i++) {
						var _surf = array_safe_get(inpt, i);
						if(!is_surface(_surf)) continue;
						
						ww += surface_get_width_safe(_surf);
						if(i > _st) ww += spac;
						hh  = max(hh, surface_get_height_safe(_surf));
					}
					break;
				case SPRITE_STACK.vertical :
					for(var i = _st; i <= _ed; i++) {
						var _surf = array_safe_get(inpt, i);
						if(!is_surface(_surf)) continue;
						
						ww  = max(ww, surface_get_width_safe(_surf));
						hh += surface_get_height_safe(_surf);
						if(i > _st) hh += spac;
					}
					break;
				case SPRITE_STACK.grid :
					var col = getInputData(4);
					var row = ceil(amo / col);
				
					for(var i = 0; i < row; i++) {
						var row_w = 0;
						var row_h = 0;
							
						for(var j = 0; j < col; j++) {
							var index = _st + i * col + j;
							if(index > _ed) break;
							
							var _surf = array_safe_get(inpt, index);
							if(!is_surface(_surf)) continue;
							
							row_w += surface_get_width_safe(_surf);
							if(j) row_w += spc2[0];
							row_h  = max(row_h, surface_get_height_safe(_surf));
						}
							
						ww  = max(ww, row_w);
						hh += row_h							
						if(i) hh += spc2[1];
					}
					break;
			} 
				
			ww += padd[0] + padd[2];
			hh += padd[1] + padd[3];
			var _surf = surface_create_valid(ww, hh, cDep);
		#endregion
		
		#region draw
			surface_set_shader(_surf, noone);
			
			var curr_w = -1;
			var curr_h = -1;
	
			switch(pack) {
				case SPRITE_STACK.horizontal :
					var px = padd[2];
					var py = padd[1];
					for(var i = _st; i <= _ed; i++) {
						var _w  = surface_get_width_safe(inpt[i]);
						var _h  = surface_get_height_safe(inpt[i]);
						var _sx = px;
						var _sy = py;
						
						curr_w = curr_w == -1? _w : curr_w; curr_h = curr_h == -1? _h : curr_h;
						if(curr_w != _w || curr_h != _h) noti_warning("Spritesheet node does not support different surfaces size. Use Stack, Image grid, or pack sprite.");
						
						switch(alig) {
							case 1 : _sy = py + (hh - _h) / 2;	break;
							case 2 : _sy = py + (hh - _h);		break;
						}
					
						array_push(atlases, new SurfaceAtlas(inpt[i], _sx, _sy));
						draw_surface_safe(inpt[i], _sx, _sy);
					
						px += _w + spac;
					}
					break;
				case SPRITE_STACK.vertical :
					var px = padd[2];
					var py = padd[1];
					for(var i = _st; i <= _ed; i++) {
						var _w = surface_get_width_safe(inpt[i]);
						var _h = surface_get_height_safe(inpt[i]);
						var _sx = px;
						var _sy = py;
							
						curr_w = curr_w == -1? _w : curr_w; curr_h = curr_h == -1? _h : curr_h;
						if(curr_w != _w || curr_h != _h) noti_warning("Spritesheet node does not support different surfaces size. Use Stack, Image grid, or pack sprite.");
						
						switch(alig) {
							case 1 : _sx = px + (ww - _w) / 2;	break;
							case 2 : _sx = px + (ww - _w);		break;
						}
					
						array_push(atlases, new SurfaceAtlas(inpt[i], _sx, _sy));
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
						row_w = 0;
						row_h = 0;
						px    = padd[2];
								
						for(var j = 0; j < col; j++) {
							var index = _st + i * col + j;
							if(index > _ed) break;
								
							var _w = surface_get_width_safe(inpt[index]);
							var _h = surface_get_height_safe(inpt[index]);
							
							curr_w = curr_w == -1? _w : curr_w; curr_h = curr_h == -1? _h : curr_h;
							if(curr_w != _w || curr_h != _h) noti_warning("Spritesheet node does not support different surfaces size. Use Stack, Image grid, or pack sprite.");
						
							array_push(atlases, new SurfaceAtlas(inpt[index], px, py));
							draw_surface_safe(inpt[index], px, py);
								
							px += _w + spc2[0];
							row_h = max(row_h, _h);
						}
						py += row_h + spc2[1];
					}
					break;
				}
				
			surface_reset_shader();
		#endregion
		
		outputs[| 0].setValue(_surf);
		outputs[| 1].setValue(array_spread(atlases));
	} #endregion
	
	anim_curr_w = -1;
	anim_curr_h = -1;
	
	static animationInit = function(clear = false) { #region
		var inpt = getInputData(0);
		var skip = getInputData(2);
		var pack = getInputData(3);
		var grid = getInputData(4);
		var alig = getInputData(5);
		var spac = getInputData(6);
		var padd = getInputData(7);
		var rang = getInputData(8);
		var spc2 = getInputData(9);
		//var ovlp = getInputData(10);
		var user = getInputData(11);
		
		var _out = outputs[| 0].getValue();
		var cDep = attrDepth();
		
		printIf(log, $"Init animation");
		
		var arr = is_array(inpt);
		if(arr && array_length(inpt) == 0) return;
		if(!arr) inpt = [ inpt ];
		
		if(!is_array(_out)) _out = [ _out ];
		
		#region frame
			var _st = FIRST_FRAME;
			var _ed = LAST_FRAME  + 1;
			
			if(user) {
				if(rang[0] < 0)  _st = LAST_FRAME + rang[0] - 1;
				else             _st = rang[0] - 1;
			
				if(rang[1] < 0)  _ed = LAST_FRAME + rang[1];
				else             _ed = rang[1];
			}
			
			if(_ed <= _st) return;
			var amo = floor((_ed - _st) / skip);
		#endregion
		
		var skip  = getInputData(2);
		
		var ww = 1, hh = 1;
				
		for(var i = 0; i < array_length(inpt); i++) { 
			var _surfi = inpt[i];
			if(!is_surface(_surfi)) continue;
					
			atlases[i]    = [];
					
			var sw = surface_get_width_safe(_surfi);
			var sh = surface_get_height_safe(_surfi);
			ww = sw;
			hh = sh;
			
			anim_curr_w = sw; 
			anim_curr_h = sh;
				
			switch(pack) {
				case SPRITE_STACK.horizontal :						
					ww = sw * amo + spac * (amo - 1);
					break;
				case SPRITE_STACK.vertical :
					hh = sh * amo + spac * (amo - 1);
					break;
				case SPRITE_STACK.grid :
					var row = ceil(amo / grid);
						
					ww = sw * grid + spc2[0] * (grid - 1);
					hh = sh * row  + spc2[1] * (row - 1);
					break;
			}
				
			ww += padd[0] + padd[2];
			hh += padd[1] + padd[3];
				
			_out[i] = surface_verify(array_safe_get_fast(_out, i), surface_valid_size(ww), surface_valid_size(hh), cDep);
			
			if(clear) surface_clear(_out[i]);
		}
			
		if(!arr) _out = array_safe_get_fast(_out, 0);
		outputs[| 0].setValue(_out);
		outputs[| 1].setValue(array_spread(atlases));
				
		printIf(log, $"Surface generated [{ww}, {hh}]");
	} #endregion
	
	static animationRender = function() { #region
		var inpt = getInputData(0);
		var skip = getInputData(2);
		var pack = getInputData(3);
		var grid = getInputData(4);
		var alig = getInputData(5);
		var spac = getInputData(6);
		var padd = getInputData(7);
		var rang = getInputData(8);
		var spc2 = getInputData(9);
		//var ovlp = getInputData(10);
		var user = getInputData(11);
		
		var cDep = attrDepth();
		
		printIf(log, $"Rendering animation {name}/{CURRENT_FRAME}");
		
		var arr = is_array(inpt);
		if(arr && array_length(inpt) == 0) return;
		if(!arr) inpt = [ inpt ];
		
		#region frame
			var _st = FIRST_FRAME;
			var _ed = LAST_FRAME  + 1;
			
			if(user) {
				if(rang[0] < 0)  _st = LAST_FRAME + rang[0] - 1;
				else             _st = rang[0] - 1;
			
				if(rang[1] < 0)  _ed = LAST_FRAME + rang[1] + 1;
				else             _ed = rang[1] + 1;
			}
			
			if(_ed <= _st) return;
			var amo = floor((_ed - _st) / skip);
		#endregion
		
		if(safe_mod(CURRENT_FRAME - _st, skip) != 0) {
			printIf(log, $"   > Skip frame");
			return;
		}
		
		#region check overlap
			if(array_length(anim_drawn) != TOTAL_FRAMES)
				array_resize(anim_drawn, TOTAL_FRAMES);
				
			if(CURRENT_FRAME >= 0 && CURRENT_FRAME < TOTAL_FRAMES && anim_drawn[CURRENT_FRAME]) {
				printIf(log, $"   > Skip drawn");
				return;
			}
		#endregion
		
		var oupt   = outputs[| 0].getValue();
		var _frame = floor((CURRENT_FRAME - _st) / skip);
		var drawn  = false;
		var px = padd[2];
		var py = padd[1];
		
		for(var i = 0; i < array_length(inpt); i++) { #region
			var _surfi = inpt[i];
			
			if(!is_surface(_surfi)) {
				printIf(log, $"   > Skip input not surface");
				atlases[i] = noone;
				break;
			} 
			
			if(!is_array(array_safe_get_fast(atlases, i)))
				atlases[i] = [];
			var _atli = atlases[i];
			
			var oo = noone;
			if(!is_array(oupt))	oo = oupt;
			else				oo = oupt[i];
			
			if(!is_surface(oo)) {
				printIf(log, $"   > Skip output not surface");
				break;
			}
			
			var ww = surface_get_width_safe(oo);
			var hh = surface_get_height_safe(oo);
			
			var _w = surface_get_width_safe(_surfi);
			var _h = surface_get_height_safe(_surfi);
			
			if(anim_curr_w != _w || anim_curr_h != _h) noti_warning("Spritesheet node does not support different surfaces size. Use Stack, Image grid, or pack sprite.");
			
			var px;
			var _sx = 0;
			var _sy = 0;
			
			switch(pack) {
				case SPRITE_STACK.horizontal :
					px  = padd[2] + _frame * _w + max(0, _frame) * spac;
					_sx = px;
					_sy = py;
					
					switch(alig) {
						case 1 : _sy = py + (hh - _h) / 2;	break;
						case 2 : _sy = py + (hh - _h);		break;
					}
					
					break;
				case SPRITE_STACK.vertical :
					py = padd[1] + _frame * _h + max(0, _frame) * spac;
					_sx = px;
					_sy = py;
					
					switch(alig) {
						case 1 : _sx = px + (ww - _w) / 2;	break;
						case 2 : _sx = px + (ww - _w);		break;
					}
					
					break;
				case SPRITE_STACK.grid :
					var col  = getInputData(4);
					var _row = floor(_frame / col);
					var _col = safe_mod(_frame, col);
					
					_sx = px + _col * _w + max(0, _col) * spc2[0];
					_sy = py + _row * _h + max(0, _row) * spc2[1];
					break;
			}
				
			surface_set_shader(oo, noone, false, BLEND.over);
				
				printIf(log, $"   > Drawing frame ({CURRENT_FRAME}) {_surfi} at {_sx}, {_sy}");
				
				_atli[i] = new SurfaceAtlas(_surfi, _sx, _sy);
				draw_surface(_surfi, _sx, _sy);
				
			surface_reset_shader();
			
			drawn = true;
		} #endregion
		
		if(drawn) array_safe_set(anim_drawn, CURRENT_FRAME, true);
		outputs[| 1].setValue(array_spread(atlases));
	} #endregion
}