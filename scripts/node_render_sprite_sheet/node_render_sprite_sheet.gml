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
	static log  = false;
	name		= "Render Spritesheet";
	anim_drawn	= array_create(TOTAL_FRAMES + 1, false);
	
	////- =Surfaces
	
	newInput( 0, nodeValue_Surface(     "Sprites"));
	newInput( 1, nodeValue_Enum_Scroll( "Sprite set", 0, [ "Animation", "Sprite array" ])).rejectArray();
	newInput( 2, nodeValue_Int(         "Frame step", 1, "Number of frames until next sprite. Can be seen as (Step - 1) frame skip.")).rejectArray();
	newInput(12, nodeValue_Bool(        "Skip Empty", false ));
	
	////- =Packing
	
	newInput(3, nodeValue_Enum_Scroll( "Packing type", 0, __enum_array_gen(["Horizontal", "Vertical", "Grid"], s_node_alignment))).rejectArray();
	newInput(4, nodeValue_Int(         "Grid column",  4        )).rejectArray();
	newInput(5, nodeValue_Enum_Button( "Alignment",    0, [ "First", "Middle", "Last" ])).rejectArray();
	newInput(6, nodeValue_Int(         "Spacing",      0        ));
	newInput(9, nodeValue_Vec2(        "Spacing",     [0,0]     ));
	newInput(7, nodeValue_Padding(     "Padding",     [0,0,0,0] ));
	
	////- =Rendering
	
	/*UNUSED*/ newInput(10, nodeValue_Bool( "Overlappable", false ));
	
	////- =Range
	
	newInput(11, nodeValue_Bool(         "Custom Range", false ));
	newInput( 8, nodeValue_Slider_Range( "Range",        [0,0] )).setTooltip("Starting/ending frames, set end to 0 to default to last frame.");
	
	// inputs 12
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output("Atlas Data",  VALUE_TYPE.atlas,   []    ));
	
	input_display_list = [
		["Surfaces",  false], 0, 1, 2, 12, 
		["Packing",	  false], 3, 4, 5, 6, 9, 7, 
		//["Rendering", false], 10, 
		["Custom Range", true, 11], 8, 
	]
	
	atlases = [];
	noti_dimension_txt = "Spritesheet node does not support different surfaces size. Use Stack, Image grid, or Pack sprite node.";
	
	attribute_surface_depth();

	setTrigger(1,,, function() /*=>*/ { initSurface(true); PROJECT.animator.render(); anim_rendering = false; });
	setTrigger(2, "Clear Result", [ THEME.cache, 0, COLORS._main_icon ]);
	
	////- Nodes
	
	static step = function() {
		var inpt = getInputData( 0);
		var grup = getInputData( 1);
		var pack = getInputData( 3);
		
		if(pack == 0)	inputs[5].editWidget.data = [ "Top", "Center", "Bottom" ];
		else			inputs[5].editWidget.data = [ "Left", "Center", "Right" ];
		
		inputs[2].setVisible(grup == SPRITE_ANIM_GROUP.animation);
		inputs[4].setVisible(pack == SPRITE_STACK.grid);
		inputs[5].setVisible(pack != SPRITE_STACK.grid);
		inputs[6].setVisible(pack != SPRITE_STACK.grid);
		inputs[9].setVisible(pack == SPRITE_STACK.grid);
		
		if(grup == SPRITE_ANIM_GROUP.animation) {
			inputs[8].editWidget.slide_range[0] = FIRST_FRAME + 1;
			inputs[8].editWidget.slide_range[1] = LAST_FRAME + 1;
			
		} else {
			inputs[8].editWidget.slide_range[0] = 0;
			inputs[8].editWidget.slide_range[1] = array_length(inpt);
		}
		
		update_on_frame = grup == 0;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		if(IS_FIRST_FRAME) initSurface(false);
		
		var inpt   = getInputData( 0);
		var sprSet = getInputData( 1);
		var user   = getInputData(11);
		var anim   = sprSet == SPRITE_ANIM_GROUP.animation;
		
		if(!user) {
			if(sprSet == SPRITE_ANIM_GROUP.animation) 
				 inputs[8].setValueDirect([ FIRST_FRAME + 1, LAST_FRAME + 1], noone, false, 0, false);
			else inputs[8].setValueDirect([ 0, array_length(inpt)], noone, false, 0, false);
		}
		
		if(anim) animationRender();
		else     arrayRender();
		
		anim_rendering = PROJECT.animator.is_rendering;
	}
	
	static initSurface = function(clear = false) {
		for(var i = 0; i < TOTAL_FRAMES; i++) anim_drawn[i] = false;
		
		var grup = getInputData(1);
		var anim = grup == SPRITE_ANIM_GROUP.animation;
		
		if(anim) animationInit(clear);
		else     arrayRender();
	}
	
	static arrayRender = function() {
		var inpt = getInputData(0);
		var grup = getInputData(1);
		var pack = getInputData(3);
		var alig = getInputData(5);
		var spac = getInputData(6);
		var padd = getInputData(7);
		var rang = getInputData(8);
		var spc2 = getInputData(9);
		var exemp = getInputData(12);
		
		var cDep = attrDepth();
		
		var _outSurf = outputs[0].getValue();
		
		if(is_array(_outSurf)) {
			surface_array_free(_outSurf);
			_outSurf = noone;
		}
		
		if(!is_array(inpt)) {
			if(is_surface(inpt)) {
				_outSurf = surface_verify(_outSurf, surface_get_width_safe(inpt), surface_get_height_safe(inpt));
				surface_set_shader(_outSurf, noone);
					draw_surface(inpt, 0, 0);
				surface_reset_shader();
				
			} else {
				surface_array_free(_outSurf);
				_outSurf = noone;
			}
			
			outputs[0].setValue(_outSurf);
			outputs[1].setValue([]);
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
		
		if(exemp) {
			var _is_empty = array_create(_ed);
			for(var i = _st; i < _ed; i++) 
				_is_empty[i] = surface_is_empty(array_safe_get(inpt, i));
		}
		
		#region surface generate
			switch(pack) { 
				case SPRITE_STACK.horizontal :
					for(var i = _st; i < _ed; i++) {
						var _surf = array_safe_get(inpt, i);
						if(!is_surface(_surf))    continue;
						if(exemp && _is_empty[i]) continue; 
						
						ww += surface_get_width_safe(_surf);
						if(i > _st) ww += spac;
						hh  = max(hh, surface_get_height_safe(_surf));
					}
					break;
					
				case SPRITE_STACK.vertical :
					for(var i = _st; i < _ed; i++) {
						var _surf = array_safe_get(inpt, i);
						if(!is_surface(_surf))    continue;
						if(exemp && _is_empty[i]) continue;
						
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
							if(index >= _ed) break;
							
							var _surf = array_safe_get(inpt, index);
							if(!is_surface(_surf))        continue;
							if(exemp && _is_empty[index]) continue;
							
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
			var _surf = surface_verify(_outSurf, ww, hh, cDep);
		#endregion
		
		#region draw
			surface_set_shader(_surf, noone);
			
			var curr_w = -1;
			var curr_h = -1;
	
			switch(pack) {
				case SPRITE_STACK.horizontal :
					var px = padd[2];
					var py = padd[1];
					for(var i = _st; i < _ed; i++) {
						if(exemp && _is_empty[i]) continue;
						
						var _w  = surface_get_width_safe(inpt[i]);
						var _h  = surface_get_height_safe(inpt[i]);
						var _sx = px;
						var _sy = py;
						
						curr_w = curr_w == -1? _w : curr_w; curr_h = curr_h == -1? _h : curr_h;
						if(curr_w != _w || curr_h != _h) noti_warning(noti_dimension_txt, noone, self);
						
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
					for(var i = _st; i < _ed; i++) {
						if(exemp && _is_empty[i]) continue;
						
						var _w = surface_get_width_safe(inpt[i]);
						var _h = surface_get_height_safe(inpt[i]);
						var _sx = px;
						var _sy = py;
							
						curr_w = curr_w == -1? _w : curr_w; curr_h = curr_h == -1? _h : curr_h;
						if(curr_w != _w || curr_h != _h) noti_warning(noti_dimension_txt, noone, self);
						
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
							if(index >= _ed) break;
							if(exemp && _is_empty[index]) continue;
								
							var _w = surface_get_width_safe(inpt[index]);
							var _h = surface_get_height_safe(inpt[index]);
							
							curr_w = curr_w == -1? _w : curr_w; curr_h = curr_h == -1? _h : curr_h;
							if(curr_w != _w || curr_h != _h) noti_warning(noti_dimension_txt, noone, self);
							
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
		
		outputs[0].setValue(_surf);
		outputs[1].setValue(array_spread(atlases));
	}
	
	anim_curr_w        = -1;
	anim_curr_h        = -1;
	anim_frames        = [];
	anim_array_length  = 0;
	anim_surface_cache = noone;
	anim_rendering     = false;
	
	static animationInit = function(clear = false) {
		if(anim_rendering) return;
		
		var inpt  = getInputData( 0);
		var skip  = getInputData( 2);
		var exemp = getInputData(12);
		
		var pack  = getInputData( 3);
		var grid  = getInputData( 4);
		var alig  = getInputData( 5);
		var spac  = getInputData( 6);
		var spc2  = getInputData( 9);
		var padd  = getInputData( 7);
		
		var user  = getInputData(11);
		var rang  = getInputData( 8);
		
		var _out = outputs[0].getValue();
		var cDep = attrDepth();
		
		printIf(log, $"Init animation");
		
		var arr = is_array(inpt);
		if(arr && array_length(inpt) == 0) return;
		
		anim_array_length = array_safe_length(inpt);
		if(!arr) inpt = [ inpt ];
		
		if(!is_array(_out)) _out = [ _out ];
		anim_frames = array_create(array_safe_length(inpt,1), 0);
		
		#region frame
			var _st = FIRST_FRAME;
			var _ed = LAST_FRAME  + 1;
			
			if(user) {
				     if(rang[0] <  0) _st = LAST_FRAME + rang[0] - 1;
				else if(rang[0] == 0) _st = FIRST_FRAME;
				else                  _st = rang[0] - 1;
			
				     if(rang[1] <  0) _ed = LAST_FRAME + rang[1];
				else if(rang[1] == 0) _ed = LAST_FRAME + 1;
				else                  _ed = rang[1];
			}
			
			if(_ed <= _st) return;
			var amo = floor((_ed - _st) / skip);
		#endregion
		
		var ww = 1, hh = 1;
		
		for(var i = 0; i < array_length(inpt); i++) { 
			var _surfi = inpt[i];
			if(!is_surface(_surfi)) continue;
					
			atlases[i] = [];
					
			var sw = surface_get_width_safe(_surfi);
			var sh = surface_get_height_safe(_surfi);
			ww = sw;
			hh = sh;
			
			anim_curr_w = sw; 
			anim_curr_h = sh;
				
			switch(pack) {
				case SPRITE_STACK.horizontal : ww = sw * amo + spac * (amo - 1); break;
				case SPRITE_STACK.vertical :   hh = sh * amo + spac * (amo - 1); break;
					
				case SPRITE_STACK.grid :
					var row = ceil(amo / grid);
					
					ww = sw * grid + spc2[0] * (grid - 1);
					hh = sh * row  + spc2[1] * (row - 1);
					break;
			}
				
			ww += padd[0] + padd[2];
			hh += padd[1] + padd[3];
				
			var _o  = array_safe_get_fast(_out, i);
			_out[i] = surface_verify(_o, ww, hh, cDep);
			if(clear) surface_clear(_out[i]);
		}
			
		if(!arr) _out = array_safe_get_fast(_out, 0);
		outputs[0].setValue(_out);
		outputs[1].setValue(array_spread(atlases));
		
		printIf(log, $"Surface generated [{ww}, {hh}]");
	}
	
	static animationRender = function() {
		if(IS_FIRST_FRAME && anim_rendering) return;
		if(!IS_PLAYING) return;
		
		var inpt  = getInputData( 0);
		var skip  = getInputData( 2);
		var exemp = getInputData(12);
		
		var pack  = getInputData( 3);
		var grid  = getInputData( 4);
		var alig  = getInputData( 5);
		var spac  = getInputData( 6);
		var spc2  = getInputData( 9);
		var padd  = getInputData( 7);
		
		var user  = getInputData(11);
		var rang  = getInputData( 8);
		
		var cDep  = attrDepth();
		
		printIf(log, $"Rendering animation {name}/{CURRENT_FRAME} [{anim_array_length}]");
		
		var arr = is_array(inpt);
		if((anim_array_length == 0 && is_array(inpt)) || (anim_array_length != array_length(inpt))) return;
		
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
		
		if(CURRENT_FRAME < _st || CURRENT_FRAME > _ed) return;
		if(safe_mod(CURRENT_FRAME - _st, skip) != 0)   return;
		
		#region check overlap
			if(array_length(anim_drawn) != TOTAL_FRAMES)
				array_resize(anim_drawn, TOTAL_FRAMES);
				
			if(CURRENT_FRAME >= 0 && CURRENT_FRAME < TOTAL_FRAMES && anim_drawn[CURRENT_FRAME]) {
				printIf(log, $"   > Skip drawn");
				return;
			}
		#endregion
		
		var _atli;
		var oupt   = outputs[0].getValue();
		var drawn  = false;
		
		var _px = padd[2];
		var _py = padd[1];
		var _sx = 0;
		var _sy = 0;
			
		for(var i = 0, n = array_length(inpt); i < n; i++) {
			var _surfi = inpt[i];
			var _out   = is_array(oupt)? oupt[i] : oupt;
			
			if(!is_surface(_out))                 { printIf(log, $"   > Skip output not surface");                    break; }
			if(!is_surface(_surfi))               { printIf(log, $"   > Skip input not surface"); atlases[i] = noone; continue; } 
			if(exemp && surface_is_empty(_surfi)) { printIf(log, $"   > Skip input empty");                           continue; } 
			
			var _frame = anim_frames[i]; 
			var ww = surface_get_width(_out);
			var hh = surface_get_height(_out);
			var sw = surface_get_width(_surfi);
			var sh = surface_get_height(_surfi);
			
			if(anim_curr_w != sw || anim_curr_h != sh) noti_warning(noti_dimension_txt, noone, self);
			
			switch(pack) {
				case SPRITE_STACK.horizontal :
					_px = padd[2] + _frame * sw + max(0, _frame) * spac;
					_sx = _px;
					
					switch(alig) {
						case 0 : _sy = _py;                 break;
						case 1 : _sy = _py + (hh - sh) / 2; break;
						case 2 : _sy = _py + (hh - sh);     break;
					}
					break;
					
				case SPRITE_STACK.vertical :
					_py = padd[1] + _frame * sh + max(0, _frame) * spac;
					_sy = _py;
					
					switch(alig) {
						case 0 : _sx = _px;                 break;
						case 1 : _sx = _px + (ww - sw) / 2; break;
						case 2 : _sx = _px + (ww - sw);     break;
					}
					break;
					
				case SPRITE_STACK.grid :
					var _col = safe_mod(_frame, grid);
					var _row = floor(_frame / grid);
					
					_sx = _px + _col * sw + max(0, _col) * spc2[0];
					_sy = _py + _row * sh + max(0, _row) * spc2[1];
					break;
			}
			
			_atli    = atlases[i];
			_atli[i] = new SurfaceAtlas(_surfi, _sx, _sy);
			
			if(exemp) {
				var _new_w, _new_h;
				anim_surface_cache = surface_verify(anim_surface_cache, surface_get_width(_out), surface_get_height(_out));
				surface_set_shader(anim_surface_cache);
					draw_surface(_out,0,0);
				surface_reset_shader();
				
				switch(pack) {
					case SPRITE_STACK.horizontal : 
						_new_w = _sx + sw + padd[0];
						_new_h = sh + padd[1] + padd[3];
						break;
					
					case SPRITE_STACK.vertical : 
						_new_w = sw + padd[0] + padd[2];
						_new_h = _sy + sh + padd[3];
						break;
					
					case SPRITE_STACK.grid : 
						var _col = safe_mod(_frame, grid);
						var _row = floor(_frame / grid);
						
						_new_w = _col * sw + max(0, _col) * spc2[0] + padd[0] + padd[2];
						_new_h = _row * sh + max(0, _row) * spc2[1] + padd[1] + padd[3];
						break;
				}
				
				surface_resize(_out, _new_w, _new_h);
				surface_set_shader(_out);
					draw_surface(anim_surface_cache,0,0);
					draw_surface(_surfi, _sx, _sy);
				surface_reset_shader();
				
				if(is_array(oupt)) oupt[i] = _out;
				else oupt = _out;
				
			} else {
				surface_set_shader(_out, noone, false, BLEND.over);
					draw_surface(_surfi, _sx, _sy);
				surface_reset_shader();
				
			}
			
			anim_frames[i]++;
			drawn = true;
		}
		
		if(drawn) array_safe_set(anim_drawn, CURRENT_FRAME, true);
		outputs[0].setValue(oupt);
		outputs[1].setValue(array_spread(atlases));
	}

}