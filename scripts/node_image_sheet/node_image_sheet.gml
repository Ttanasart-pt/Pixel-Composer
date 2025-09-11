function Node_Image_Sheet(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Splice Spritesheet";
	
	////- =Sprite
	newInput(0, nodeValue_Surface( "Surface In" ));
	newInput(1, nodeValue_Vec2(    "Sprite size", [32,32]   ));
	newInput(6, nodeValue_Padding( "Padding",     [0,0,0,0] ));
	newInput(2, nodeValue_Int(     "Row",          1        )); //unused
	
	////- =Sheet
	newInput( 3, nodeValue_Vec2(    "Amount",    [1,1] ));
	newInput(10, nodeValue_Trigger( "Auto fill", "Automatically set amount based on sprite size." ));
	
	b_auto_fill = button(function() /*=>*/ {
		var _sur = getInputData(0);
		if(is_array(_sur)) _sur = array_safe_get_fast(_sur, 0);
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
	
	newInput(15, nodeValue_Bool(       "Flatten Array", true ));
		
	////- =Filter
	newInput(12, nodeValue_Bool(        "Filter empty output", false ));
	newInput(13, nodeValue_Enum_Scroll( "Filtered Pixel",      0, [ "Transparent", "Color" ]));
	newInput(14, nodeValue_Color(       "Filtered Color",      ca_black ));
	//16
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Atlas Data",  VALUE_TYPE.atlas,   []    )).setArrayDepth(1);
	
	input_display_list = [
		[ "Sprite",      false     ], 0, 1, 6, 
		[ "Sheet",       false     ], 3, b_auto_fill, 9, 4, 5, 
		[ "Output",      false     ], 7, 8, b_sync_frame, 15, 
		[ "Filter Empty", true, 12 ], 13, 14, 
	];
	
	////- Preview
	
	attribute_surface_depth();
	
	drag_type    = 0;	
	drag_sx      = 0;
	drag_sy      = 0;
	drag_mx      = 0;
	drag_my      = 0;
	curr_off     = [0, 0];
	curr_dim     = [0, 0];
	curr_amo     = [0, 0];
	  
	surface_pool = [];
	atlas_pool   = [];
	
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
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		if(preview_channel != 0) return;
		
		var hovering = false;
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
			
		hovering = hovering || _h0 || _h1 || _h2 || _h3;
					
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
		
		return hovering;
	}
	
	////- Update
	
	static spliceSprite = function(_surf, _pool_i = 0) {
		if(!is_surface(_surf)) return undefined;
		spliceSurf   = _surf;
		
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
		
		if(ww < 1 || hh < 1) return undefined;
		
		var _sar = array_create(_total);
		var _atl = array_create(_total);
		var _arrAmo = 0, _s, _a;
		
		for(var i = 0; i < _total; i++) 
			sprite_pos[i] = getSpritePosition(i);
		
		for(var i = 0; i < _total; i++) {
			_s = array_safe_get_fast(surface_pool, _pool_i + i);
		    _s = surface_verify(_s, ww, hh, cDep);
		    surface_pool[_pool_i + i] = _s;
			
			_a = array_safe_get_fast(atlas_pool, _pool_i + i, 0);
			if(_a == 0) _a = new SurfaceAtlas(_s, 0, 0);
			else        _a.setSurface(_s);
			atlas_pool[_pool_i + i] = _a;
			
			var _spr_pos = sprite_pos[i];
			
			surface_set_shader(_s, noone, true, BLEND.over);
				draw_surface_part(_surf, _spr_pos[0], _spr_pos[1], _dim[0], _dim[1], _pad[2], _pad[1]);
			surface_reset_shader();
			
			_a.x = _spr_pos[0];
			_a.y = _spr_pos[1];
				
			if(!_filt) {
				_sar[_arrAmo] = _s;
				_atl[_arrAmo] = _a;
				_arrAmo++;
				
				sprite_valid[i] = true;
				continue;
			}
			
			var _empty = _fltp == 0? surface_is_empty(_s) : surface_is_color(_s, _flcl);
					
			if(!_empty) {
				_sar[_arrAmo] = _s;
				_atl[_arrAmo] = _a;
				_arrAmo++;
			}
			sprite_valid[i] = !_empty;
		}
		
		array_resize(_sar, _arrAmo);
		array_resize(_atl, _arrAmo);
		
		return [_sar, _atl]
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _inSurf = getInputData( 0);
		var _out    = getInputData( 7);
		var _spd    = getInputData( 8);
		var _fltp   = getInputData(13);
		var _flat   = getInputData(15);
		
		b_sync_frame.setVisible( _out == 0 );
		inputs[11].setVisible( _out == 0 );
		inputs[ 8].setVisible( _out == 0 );
		inputs[15].setVisible( _out == 1 );
		inputs[14].setVisible(_fltp);
		
		var _surfDat = undefined;
		
		if(is_array(_inSurf)) {
			_surfDat = [ [], [] ];
			var _i = 0;
			
			for( var i = 0, n = array_length(_inSurf); i < n; i++ ) {
				if(!is_surface(_inSurf[i])) continue;
				var _dat = spliceSprite(_inSurf[i], _i);
				if(_dat == undefined) continue;
				
				_i += array_length(_dat[0]) + 1;
				
				if(_flat) {
					array_append(_surfDat[0], _dat[0]);
					array_append(_surfDat[1], _dat[1]);
					
				} else {
					array_push(_surfDat[0], _dat[0]);
					array_push(_surfDat[1], _dat[1]);
				}
			}
			
		} else if(is_surface(_inSurf))
			_surfDat = spliceSprite(_inSurf);
		
		if(_surfDat == undefined) return;
		
		if(_out == 0) {
			update_on_frame = true;
			if(array_length(_surfDat[0])) {
				var ind = safe_mod(CURRENT_FRAME * _spd, array_length(_surfDat[0]));
				outputs[0].setValue(array_safe_get_fast(_surfDat[0], ind));
			}
			
		} else if(_out == 1) {
			update_on_frame = false;
			outputs[0].setValue(_surfDat[0]);
		}
		
		outputs[1].setValue(_surfDat[1]);
		
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