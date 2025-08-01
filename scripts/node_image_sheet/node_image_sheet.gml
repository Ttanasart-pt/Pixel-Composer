function Node_Image_Sheet(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Splice Spritesheet";
	
	////- =Sprite
	
	newInput(0, nodeValue_Surface( "Surface In"));
	newInput(1, nodeValue_Vec2(    "Sprite size", [32,32]   ));
	newInput(6, nodeValue_Padding( "Padding",     [0,0,0,0] ));
	newInput(2, nodeValue_Int(     "Row",          1        )); //unused
	
	////- =Sheet
	
	newInput( 3, nodeValue_Vec2(        "Amount", [1,1]  ));
	newInput(10, nodeValue_Trigger(     "Auto fill", "Automatically set amount based on sprite size."));
	b_auto_fill = button(function() /*=>*/ {
		var _sur = getInputData(0);
		if(!is_surface(_sur) || _sur == DEF_SURFACE) return;
		
		var ww = surface_get_width(_sur);
		var hh = surface_get_height(_sur);
		
		var _size = getInputData(1);
		var _offs = getInputData(4);
		var _spac = getInputData(5);
		
		var sh_w = _size[0] + _spac[0];
		var sh_h = _size[1] + _spac[1];
	
		var fill_w = floor((ww - _offs[0]) / sh_w);
		var fill_h = floor((hh - _offs[1]) / sh_h);
		
		inputs[3].setValue([ fill_w, fill_h ]);
	
		doUpdate();
	}).setText("Auto Fill");
	newInput( 9, nodeValue_Enum_Scroll( "Main Axis", 0, __enum_array_gen(["Horizontal", "Vertical"], s_node_alignment)));
	newInput( 4, nodeValue_Vec2(        "Offset",   [0,0] ));
	newInput( 5, nodeValue_Vec2(        "Spacing",  [0,0] ));
	
	////- =Output
	
	newInput( 7, nodeValue_Enum_Scroll( "Output",          1, [ "Animation", "Array" ]));
	newInput( 8, nodeValue_Float(       "Animation speed", 1 ));
	newInput(11, nodeValue_Trigger(     "Sync animation"     ));
	b_sync_frame = button(function() /*=>*/ { 
		var _atl = outputs[1].getValue();
		var _spd = getInputData(8);
		TOTAL_FRAMES = max(1, _spd == 0? 1 : ceil(array_length(_atl) / _spd));
	}).setText("Sync Frames");
		
	////- =Filter
	
	newInput(12, nodeValue_Bool(        "Filter empty output", false ));
	newInput(13, nodeValue_Enum_Scroll( "Filtered Pixel",      0, [ "Transparent", "Color" ]));
	newInput(14, nodeValue_Color(       "Filtered Color",      ca_black ));
	
	input_display_list = [
		[ "Sprite",      false     ], 0, 1, 6, 
		[ "Sheet",       false     ], 3, b_auto_fill, 9, 4, 5, 
		[ "Output",      false     ], 7, 8, b_sync_frame,
		[ "Filter Empty", true, 12 ], 13, 14, 
	];
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Atlas Data",  VALUE_TYPE.atlas,   []    )).setArrayDepth(1);
	
	////- Nodes
	
	attribute_surface_depth();
	
	drag_type    = 0;	
	drag_sx      = 0;
	drag_sy      = 0;
	drag_mx      = 0;
	drag_my      = 0;
	curr_off     = [0, 0];
	curr_dim     = [0, 0];
	curr_amo     = [0, 0];
	  
	surf_array   = [];
	atls_array   = [];
	
	surf_size_w  = 1;
	surf_size_h  = 1;
	 
	surf_space   = 0;
	surf_axis    = 0;
	
	sprite_pos   = [];
	sprite_valid = [];
	spliceSurf   = noone;
	
	temp_surface = [ noone ];
	
	static getPreviewValues  = function() { 
		switch(preview_channel) {
			case 0 : return getInputData(0); 
			case 1 : return outputs[0].getValue(); 
		}
		
		return noone;
	}
	
	getGraphPreviewSurface = getPreviewValues;
	
	static onValueFromUpdate = function() { _inSurf = noone; }
	static onValueUpdate     = function() { _inSurf = noone; }
	
	function getSpritePosition(index) {
		var _dim = curr_dim;
		var _off = curr_off;
		var _spa = surf_space;
		var _axs = surf_axis;
		
		var _irow, _icol;
		
		if(_axs == 0) {
			_irow = floor(index / curr_amo[0]);
			_icol = safe_mod(index, curr_amo[0]);
			
		} else {
			_icol = floor(index / curr_amo[1]);
			_irow = safe_mod(index, curr_amo[1]);
			
		}
		
		var _x, _y;
		
		var _x = _off[0] + _icol * (_dim[0] + _spa[0]);
		var _y = _off[1] + _irow * (_dim[1] + _spa[1]);
		
		return [ _x, _y ];
	} 
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(preview_channel != 0) return;
		
		var _inSurf  = getInputData(0);
		if(!is_surface(_inSurf)) return;
		
		var _out = getInputData(7);
		var _spc = getInputData(5);
		
		if(drag_type == 0) {
			curr_dim = getInputData(1);
			curr_amo = getInputData(3);
			curr_off = getInputData(4);
		}
		
		var __dim = getInputData(1);
		var __amo = getInputData(3);
		var __off = getInputData(4);
					
		var _amo = array_safe_get_fast(curr_amo, 0) * array_safe_get_fast(curr_amo, 1);
		
		if(_amo < 256) {
			for(var i = _amo - 1; i >= 0; i--) {
				if(!array_safe_get_fast(sprite_valid, i, false))
					continue;
				
				var _f = sprite_pos[i];
				var _fx0 = _x + _f[0] * _s;
				var _fy0 = _y + _f[1] * _s;
				var _fx1 = _fx0 + curr_dim[0] * _s;
				var _fy1 = _fy0 + curr_dim[1] * _s;
			
				draw_set_color(COLORS._main_accent);
				draw_set_alpha(i == 0? 1 : 0.75);
				draw_rectangle(_fx0, _fy0, _fx1 - 1, _fy1 - 1, true);
				draw_set_alpha(1);
			}
		} else {
			var _f = sprite_pos[0];
			var _fx0 = _x + _f[0] * _s;
			var _fy0 = _y + _f[1] * _s;
			var _fx1 = _fx0 + curr_dim[0] * _s;
			var _fy1 = _fy0 + curr_dim[1] * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_rectangle(_fx0, _fy0, _fx1 - 1, _fy1 - 1, true);
		}
		
		var __ax = curr_off[0];
		var __ay = curr_off[1];
		var __aw = curr_dim[0];
		var __ah = curr_dim[1];
						
		var _ax = __ax * _s + _x;
		var _ay = __ay * _s + _y;
		var _aw = __aw * _s;
		var _ah = __ah * _s;
		
		var _bw = curr_amo[0] * (curr_dim[0] + _spc[0]) - _spc[0]; _bw *= _s;
		var _bh = curr_amo[1] * (curr_dim[1] + _spc[1]) - _spc[1]; _bh *= _s;
		
		var _4 = 2 * _s;
		var x0 = _ax;
		var y0 = _ay;
		var x1 = _ax + _aw;
		var y1 = _ay + _ah;
		var x2 = _ax + (__aw + _spc[0]) * __amo[0] * _s;
		var y2 = _ay + (__ah + _spc[1]) * __amo[1] * _s;
		
		var wc = (x0 + x1) / 2;
		var hc = (y0 + y1) / 2;
		var xc = (x0 + x2) / 2;
		var yc = (y0 + y2) / 2;
		
		var _h0 = false, _h1 = false, _h2 = false, _h3 = false;
		if(active) {
			     if(point_in_circle(    _mx, _my, x1, y1, 8))      _h0 = true;
			else if(point_in_circle(    _mx, _my, x2 + _4, yc, 8)) _h1 = true;
			else if(point_in_circle(    _mx, _my, xc, y2 + _4, 8)) _h2 = true;
			else if(point_in_rectangle( _mx, _my, x0, y0, x1, y1)) _h3 = true;
		}
		
		draw_sprite_colored(THEME.anchor_selector, _h0, x1, y1);
		draw_sprite_colored(THEME.anchor_arrow,    _h1, x2 + _4, yc);
		draw_sprite_colored(THEME.anchor_arrow,    _h2, xc, y2 + _4, 1, -90);
		draw_sprite_colored(THEME.anchor,          _h3, wc, hc);
		
		var _ax = __off[0] * _s + _x;
		var _ay = __off[1] * _s + _y;
		var _aw = __dim[0] * _s;
		var _ah = __dim[1] * _s;
		
		if(drag_type == 1) {
			var _xx = value_snap(round(drag_sx + (_mx - drag_mx) / _s), _snx);
			var _yy = value_snap(round(drag_sy + (_my - drag_my) / _s), _sny);
						
			var off = [ _xx, _yy ];
			curr_off = off;
			inputs[4].setValue(off);
		
			if(mouse_release(mb_left)) drag_type = 0;
			
		} else if(drag_type == 2) {
			var _dx = value_snap(round(abs((_mx - drag_mx) / _s)), _snx);
			var _dy = value_snap(round(abs((_my - drag_my) / _s)), _sny);
			
			var dim = [_dx, _dy];
			curr_dim = dim;
						
			if(key_mod_press(SHIFT)) {
				dim[0] = max(_dx, _dy);
				dim[1] = max(_dx, _dy);
			}
			
			inputs[1].setValue(dim);
			
			if(mouse_release(mb_left)) drag_type = 0;
			
		} else if(drag_type == 3) {
			var _col = floor((abs(_mx - drag_mx) / _s - _spc[0]) / (__dim[0] + _spc[0]));
			curr_amo = [ _col, curr_amo[1] ];
			inputs[3].setValue(curr_amo);
			
			if(mouse_release(mb_left)) drag_type = 0;
			
		} else if(drag_type == 4) {
			var _row = floor((abs(_my - drag_my) / _s - _spc[1]) / (__dim[1] + _spc[1]));
			curr_amo = [ curr_amo[0], _row ];
			inputs[3].setValue(curr_amo);
			
			if(mouse_release(mb_left)) drag_type = 0;
			
		}
					
		if(mouse_press(mb_left, active)) {
			if(_h0) { // drag size
				drag_type = 2;
				drag_mx   = _ax;
				drag_my   = _ay;
				
			} else if(_h1) { // drag col
				drag_type = 3;
				drag_mx   = _ax;
				drag_my   = _ay;
				
			} else if(_h2) { // drag row
				drag_type = 4;
				drag_mx   = _ax;
				drag_my   = _ay;
				
			} else if(_h3) { // drag position
				drag_type = 1;	
				drag_sx   = __off[0];
				drag_sy   = __off[1];
				drag_mx   = _mx;
				drag_my   = _my;
				
			} 
		}
	}
	
	static step = function() {
		var _out  = getInputData(7);
		var _flty = getInputData(13);
		
		b_sync_frame.setVisible(!_out);
		inputs[11].setVisible(!_out);
		inputs[ 8].setVisible(!_out);
		inputs[14].setVisible(_flty);
	}
	
	static spliceSprite = function() {
		var _inSurf  = getInputData(0);
		if(!is_surface(_inSurf)) return;
		
		spliceSurf   = _inSurf;
		
		var _outSurf = outputs[0].getValue();
		var _out	 = getInputData(7);
		var _dim	 = getInputData(1);
		var _amo	 = getInputData(3);
		var _off	 = getInputData(4);
		var _total   = _amo[0] * _amo[1];
		var _pad	 = getInputData(6);
		 
		surf_space   = getInputData(5);
		surf_axis    = getInputData(9);
		
		var ww = _dim[0] + _pad[0] + _pad[2];
		var hh = _dim[1] + _pad[1] + _pad[3];
		
		var _resizeSurf = surf_size_w != ww || surf_size_h != hh;
		
		surf_size_w = ww;
		surf_size_h = hh;
		
		var _filt = getInputData(12);
		var _fltp = getInputData(13);
		var _flcl = getInputData(14);
		
		var cDep = attrDepth();
		curr_dim = _dim;
		curr_amo = is_array(_amo)? _amo : [1, 1];
		curr_off = _off;
		
		if(ww < 1 || hh < 1) return;
		
		if(_filt) {
			var filSize = 4;
			temp_surface[0] = surface_verify(temp_surface[0], surface_get_width_safe(_inSurf), surface_get_height_safe(_inSurf));
			
			surface_set_shader(temp_surface[0], sh_slice_spritesheet_empty_scan, true, BLEND.over);
				shader_set_dim("dimension",  _inSurf);
				shader_set_f("paddingStart", _off);
				shader_set_f("spacing",		 surf_space);
				shader_set_f("spriteDim",	 _dim);
				shader_set_color("color",	 _flcl);
				shader_set_i("empty",		!_fltp);
				
				draw_surface_safe(_inSurf);
			surface_reset_shader();
		}
		
		var _atl = array_create(_total);
		var _sar = array_create(_total);
		var _arrAmo = 0, _s, _a;
		
		for(var i = 0; i < _total; i++) 
			sprite_pos[i] = getSpritePosition(i);
		
		for(var i = 0; i < _total; i++) {
			_s = array_safe_get_fast(surf_array, i);
		    _s = surface_verify(_s, ww, hh, cDep);
			
			_a = array_safe_get_fast(atls_array, i, 0);
			if(_a == 0) _a = new SurfaceAtlas(_s, 0, 0);
			else        _a.setSurface(_s);
			
			var _spr_pos = sprite_pos[i];
			
			surface_set_shader(_s, noone, true, BLEND.over);
				draw_surface_part(_inSurf, _spr_pos[0], _spr_pos[1], _dim[0], _dim[1], _pad[2], _pad[1]);
			surface_reset_shader();
			
			_a.x = _spr_pos[0];
			_a.y = _spr_pos[1];
				
			if(!_filt) {
				_atl[_arrAmo] = _a;
				_sar[_arrAmo] = _s;
				_arrAmo++;
				
				sprite_valid[i] = true;
				continue;
			}
			
			var empPx = surface_get_pixel_ext(temp_surface[0], _spr_pos[0], _spr_pos[1]);
			var empty = empPx == 0.;
					
			if(!empty) {
				_atl[_arrAmo] = _a;
				_sar[_arrAmo] = _s;
				_arrAmo++;
			}
			sprite_valid[i] = !empty;
		}
		
		for( var i = _arrAmo, n = array_length(surf_array); i < n; i++ )
			if(is_surface(surf_array[i])) surface_free(surf_array[i]);
			
		surf_array = array_create(_arrAmo);
		array_copy(surf_array, 0, _sar, 0, _arrAmo);
		
		atls_array = array_create(_arrAmo);
		array_copy(atls_array, 0, _atl, 0, _arrAmo);
		
		if(_out == 1) outputs[0].setValue(surf_array);
		outputs[1].setValue(atls_array);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		spliceSprite();
		
		var _out = getInputData(7);
		if(_out == 1) { 
			update_on_frame = false;
			return;
		}
		
		var _spd = getInputData(8);
		update_on_frame = true;
		
		if(array_length(surf_array)) {
			var ind = safe_mod(CURRENT_FRAME * _spd, array_length(surf_array));
			outputs[0].setValue(array_safe_get_fast(surf_array, ind));
		}
	}

	static getOutputChannelAmount = function() /*=>*/ {return 2};
	static getOutputChannelName   = function(i) /*=>*/ {
		switch(i) {
			case 0 : return "Original";
			case 1 : return "Spliced";
		}
		return "";
	}
	
}