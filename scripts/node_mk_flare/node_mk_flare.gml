enum FLARE_TYPE {
	circle,
	ring,
	star,
	line,
	
	size
}

function __FlarePart(_type = FLARE_TYPE.circle, _t = 0, _r = 4, _a = 0.5, _seg = 16, _seg_s = false, _blend = c_white, _shade = [ 0, 1 ], _ir = 1, _ratio = 1, _th = [ 1, 0 ]) constructor {
	type  = _type;
	t     = _t;
	r     = _r;
	a     = _a;
	seg   = _seg;
	seg_s = _seg_s;
	blend = _blend;
	shade = _shade;
	ir    = _ir;
	ratio = _ratio;
	th    = _th;
	
	t2    = 0;
	
	disp_h = undefined;
}

function Node_MK_Flare(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Lens Flare";
	
	newInput(7, nodeValueSeed());
	
	////- =Surfaces
	newInput(0, nodeValue_Surface("Background"));
	newInput(2, nodeValue_Dimension());
	
	////- =Positions
	newInput(1, nodeValue_Vec2( "Origin", [ 0, 0] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(6, nodeValue_Vec2( "Focus",  [.5,.5] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	
	////- =Flare
	newInput(5, nodeValue_Struct("Flares", [
		new __FlarePart( FLARE_TYPE.circle,   0,  8,   0.75, 32, false, , [ 0,  1 ] ),
		new __FlarePart( FLARE_TYPE.circle,   0, 16,   0.5,  32, false, , [ 0,  1 ] ),
		new __FlarePart( FLARE_TYPE.star,     0, 14,   0.3,   8, true,  , [.2, .8 ], 2, 0.85 ),
		new __FlarePart( FLARE_TYPE.ring,     0,  6,   0.25, 32, false, , [ 0, .5 ], 1, 1, [ 1, .1 ] ),
		
		new __FlarePart( FLARE_TYPE.circle, 0.7,  2,   0.6,  32, false, , [ 0, .25] ),
		new __FlarePart( FLARE_TYPE.circle, 0.9,  2,   0.6,   6, false, , [ 0, .5 ] ),
		new __FlarePart( FLARE_TYPE.circle, 1.2,  0.5, 0.5,   4, false, , [ 0,  0 ] ),
												  			 
		new __FlarePart( FLARE_TYPE.circle, 1.5,  5,   0.6,  32, false, , [ 0, .7 ] ),
		new __FlarePart( FLARE_TYPE.circle, 1.6,  3,   0.4,   6, false, , [ 0,  0 ] ),
		new __FlarePart( FLARE_TYPE.ring,   1.9,  4,   0.5,  32, false, , [ 0,  0 ], 1, 1, [ 1, 0 ] ),
		new __FlarePart( FLARE_TYPE.circle, 1.9,  3,   0.5,  32, false, , [ 0, .5 ] ),
	])).setConstructor(__FlarePart).setArrayDepth(1).setArrayDynamic();
	
	////- =Blending
	newInput( 3, nodeValue_Float(  "Scale",     1     ))
	newInput( 9, nodeValue_Float(  "Intensity", 1     ))
	newInput( 4, nodeValue_Slider( "Alpha",     1     ));
	
	////- =FXAA
	newInput( 8, nodeValue_Bool(   "FXAA",          false ));
	newInput(10, nodeValue_Slider( "FXAA Strength", 1     ));
	
	////- =Aberration
	newInput(11, nodeValue_Bool(   "Aberration",    false ));
	newInput(12, nodeValue_Float(  "Ab. Strength",  16    ));
	newInput(13, nodeValue_Slider( "Ab. Intensity", 1     ));
	newInput(14, nodeValue_Slider( "Shift",         0, [ -1,  1, 0.01] ));
	newInput(15, nodeValue_Slider( "Scale",         1, [  0, 16, 0.01] ));
	// 16
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Light only",  VALUE_TYPE.surface, noone));
	
	static draw_ui_frame = function(_x, _y, _w, _h, _m, _hover) {  
		var _hv = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h) && _hover;
		draw_sprite_stretched_ext(THEME.ui_panel, 0, _x, _y, _w, _h, _hv? CDEF.main_black : CDEF.main_mdblack,  1);
		draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _y, _w, _h, CDEF.main_dkgrey, 1);
		return _hv;
	}
	
	#region flare editor
		flare_editing      = noone;
		flare_editing_prop = "";
		flare_editing_indx = 0;
		flare_editing_mx   = 0;
		flare_editing_my   = 0;
		flare_editing_sx   = 0;
		flare_editing_sy   = 0;
		
		flare_color_editing = -1;
		
		flare_draw_x = 0;
		flare_draw_y = 0;
		
		flare_hovering = noone;
			
		flare_edit = [
			{
				name : "Position",
				w    : ui(32),
				spr  : THEME.prop_position, 
				key  : "t", 
			}, 
			{
				name : "Exponent",
				w    : ui(32),
				spr  : noone, 
				key  : "t2", 
			}, 
			{
				name : "Size",
				w    : ui(32),
				spr  : THEME.prop_scale, 
				key  : "r", 
			}, 
			{
				name : "Segments",
				w    : ui(24),
				spr  : THEME.prop_segment, 
				key  : "seg", 
			}, 
			{
				name : "Level",
				w    : ui(56),
				spr  : THEME.prop_level, 
				key  : "shade", 
			}, 
		];
		
		flare_edit_ring = array_merge(flare_edit, [
			{
				name : "Rings",
				w    : ui(56),
				spr  : THEME.prop_radius_inner, 
				key  : "th", 
			}
		]);
		
		flare_edit_line = array_merge(flare_edit, [
			{
				name : "Size",
				w    : ui(56),
				spr  : THEME.prop_radius_inner, 
				key  : "th", 
			}
		]);
		
		flare_edit_star = array_merge(flare_edit, [
			{
				name : "Inner Rad",
				w    : ui(32),
				spr  : THEME.prop_radius_inner, 
				key  : "ir", 
			}
		]);
			
		function edit_flare_color(color) {
			var _flares = inputs[5].getValue();
			_flares[flare_color_editing].blend = color;
			triggerRender();
		}
		
		flare_builder = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
			var _flares = inputs[5].getValue();
			var _amo = array_length(_flares);
			
			var _fx = _x;
			var _fy = _y + ui(8);
			var _fh = ui(32);
			var _h  = 0;
			
			var _ffh = _fh - ui(8);
			
			draw_set_text(f_p4, fa_center, fa_center, COLORS._main_text);
			flare_hovering = noone;
			
			if(flare_editing != noone) {
				var _flare = _flares[flare_editing];
				CURSOR = cr_size_we;
				
				switch(flare_editing_prop) {
					case "type" :
						_flare.a    = clamp(flare_editing_sx + (_m[0] - flare_editing_mx) / 64, 0, 1);
						_flare.type = clamp(floor((_m[1] - flare_editing_my) / _ffh), 0, FLARE_TYPE.size - 1);
						
						if(_flare.type == FLARE_TYPE.ring || _flare.type == FLARE_TYPE.line)
							if(!has(_flare, "th"))    _flare.th = [ 1, 0 ];
							
						else if(_flare.type == FLARE_TYPE.star) {
							if(!has(_flare, "ir"))    _flare.ir    = 1;
							if(!has(_flare, "ratio")) _flare.ratio = 1;
						}
						CURSOR = cr_size_all;
						break;
						
					case "t" :      
						_flare.t = flare_editing_sx + (_m[0] - flare_editing_mx) / 64;
						if(abs(_flare.t - round(_flare.t * 10) / 10) < 0.02) 
							_flare.t = round(_flare.t * 10) / 10;
						break;
						
					case "t2" :      
						_flare.t2 = flare_editing_sx + (_m[0] - flare_editing_mx) / 64;
						if(abs(_flare.t2 - round(_flare.t2 * 10) / 10) < 0.02) 
							_flare.t2 = round(_flare.t2 * 10) / 10;
						break;
						
					case "r" :      
						_flare.r = flare_editing_sx + (_m[0] - flare_editing_mx) / 64;
						if(abs(_flare.r - round(_flare.r)) < 0.2) 
							_flare.r = round(_flare.r);
						break;
						
					case "seg" :    
						_flare.seg = round(flare_editing_sx + (_m[0] - flare_editing_mx) / 32);
						break;
						
					case "shade" : 
						_flare.shade[flare_editing_indx] = clamp(flare_editing_sx + (_m[0] - flare_editing_mx) / 64, 0, 1); 
						if(abs(_flare.shade[flare_editing_indx] - round(_flare.shade[flare_editing_indx] * 10) / 10) < 0.02) 
							_flare.shade[flare_editing_indx] = round(_flare.shade[flare_editing_indx] * 10) / 10;	
						break;
						
					case "th" :    
						_flare.th[flare_editing_indx] = flare_editing_sx + (_m[0] - flare_editing_mx) / 64;
						if(abs(_flare.th[flare_editing_indx] - round(_flare.th[flare_editing_indx])) < 0.2) 
							_flare.th[flare_editing_indx] = round(_flare.th[flare_editing_indx]);
						break;
						
					case "ir" :     
						_flare.ir = flare_editing_sx + (_m[0] - flare_editing_mx) / 64;
						if(abs(_flare.ir - round(_flare.ir)) < 0.2) 
							_flare.ir = round(_flare.ir);
						break;
						
				}
				
				triggerRender();
				
				if(mouse_release(mb_left)) 
					flare_editing = noone;
			}
			
			for( var i = 0; i < _amo; i++ ) {
				var _flare = _flares[i];
				var _ffx = _fx + ui(4);
				var _ffy = _fy + ui(4);
				var _ffw = _ffh;
				var _fxs = _ffx;
				
				var _dh  = _flare[$ "disp_h"] ?? _fh;
				var _hh  = _fh;
				var _hv  = _hover && point_in_rectangle(_m[0], _m[1], _fx, _fy, _fx + _w, _fy + _dh);
				
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _fx, _fy, _w, _dh, CDEF.main_dkblack, 1);
				
				if(_hv) {
					draw_sprite_stretched_add(THEME.ui_panel, 1, _fx, _fy, _w, _dh, c_white, .25);
					flare_hovering = i;
				}
				
				var _hov = draw_ui_frame(_ffx, _ffy, _ffw, _ffh, _m, _hover);
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _ffx, _ffy, _ffw * _flare.a, _ffh, CDEF.main_dkgrey, 1);
				draw_sprite_ext(s_flare_type, _flare.type, _ffx + _ffh / 2, _ffy + _ffh / 2, 1, 1, 0, c_white, 1);
				if(_hov) {
					_hv     = false;
					TOOLTIP = __txt("Shape");
				}
				
				if(_hov && mouse_press(mb_left, _focus)) {
					flare_editing = i;
					flare_editing_prop = "type";
					flare_editing_mx   = _m[0];
					flare_editing_my   = _ffy - _flare.type * _ffh;
					flare_editing_sx   = _flare.a;
					flare_editing_sy   = _flare.type;
					
					flare_draw_x = _ffx;
					flare_draw_y = _ffy - _flare.type * _ffh;
				}
				_ffx += _ffw + ui(4);
				
				_ffw  = ui(16);
				var _hov = draw_ui_frame(_ffx, _ffy, _ffw, _ffh, _m, _hover);
				draw_sprite_stretched_ext(THEME.palette_mask, 1, _ffx + ui(4), _ffy + ui(4), _ffw - ui(8), _ffh - ui(8), _flare.blend, 1);
				if(_hov) {
					_hv     = false;
					TOOLTIP = __txt("Color");
				}
				
				if(_hov && mouse_press(mb_left, _focus)) {
					flare_color_editing = i;
					var dialog = dialogCall(o_dialog_color_selector).setDefault(_flare.blend).setApply(edit_flare_color);
				}
				_ffx += _ffw + ui(4);
				_fxs  = _ffx;
				
				////////////////////////////////
				
				var _edits = flare_edit;
				switch(_flare.type) {
					case FLARE_TYPE.ring : _edits = flare_edit_ring; break;
					case FLARE_TYPE.line : _edits = flare_edit_line; break;
					case FLARE_TYPE.star : _edits = flare_edit_star; break;
				}
				
				for( var j = 0, m = array_length(_edits); j < m; j++ ) {
					var _fedit = _edits[j];
					var _ffw   = _fedit.w;
					var _spr   = _fedit.spr;
					var _txt   = _fedit.name;
					var _key   = _fedit.key;
					var _val   = _flare[$ _key];
					var _edt   = flare_editing == i && flare_editing_prop == _key;
					
					if(_ffx + _ffw + (bool(_spr) * ui(24)) > _fx + _w - ui(4)) { 
						_ffx  = _fxs; 
						_ffy += _fh; 
						_hh  += _fh; 
					}
					
					var ic = COLORS._main_icon;
					if(_edt) {
						ic = COLORS._main_accent;
						
					} else if(point_in_rectangle(_m[0], _m[1], _ffx, _ffy, _ffx + _ffw + ui(24), _ffy + _ffh)) {
						_hv = false;
						
						if(flare_editing == noone) {
							TOOLTIP = __txt(_txt);
							ic      = c_white;
						}
					}
					
					if(_spr) {
						draw_sprite_ui(_spr, 0, _ffx + ui(12), _ffy + _ffh/2, .6, .6, 0, ic);
						_ffx += ui(24);
					}
					
					var _hov = draw_ui_frame(_ffx, _ffy, _ffw, _ffh, _m, _hover) && flare_editing == noone;
					
					if(is_array(_val)) {
						draw_text_add(_ffx + _ffw / 4,     _ffy + _ffh / 2, string(_val[0]));
						draw_text_add(_ffx + _ffw / 4 * 3, _ffy + _ffh / 2, string(_val[1]));
					} else 
						draw_text_add(_ffx + _ffw / 2, _ffy + _ffh / 2, string(_val));
					
					if(_hov && mouse_press(mb_left, _focus)) {
						flare_editing      = i;
						flare_editing_mx   = _m[0];
						
						flare_editing_prop = _key;
						flare_editing_sx   = _val;
						flare_editing_indx = _m[0] > _ffx + _ffw / 2;
						
						if(is_array(_val)) flare_editing_sx = _val[flare_editing_indx];
					}
					_ffx += _ffw + ui(4);
				}
				
				if(_hv && mouse_rpress(_focus)) {
					menuCall("", [
						new MenuItem(__txt("Delete"), function(_data) /*=>*/ { 
							array_delete(_data.flare, _data.index, 1);
							inputs[5].setValue(_data.flare);
							triggerRender();
						}, THEME.cross).setParam({flare: _flares, index: i})
					])
				}
				
				////////////////////////////////
				
				_flare.disp_h = _hh;
				_fy += _hh + ui(4);
				_h  += _hh + ui(4);
			}
			
			if(flare_editing != noone) flare_hovering = flare_editing;
			
			var bx = _fx;
			var by = _fy;
			var bs = ui(24);
			
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
				array_push(_flares, new __FlarePart());
				inputs[5].setValue(_flares);
				triggerRender();
			}
			
			bx += bs + ui(8);
			_h += bs + ui(8);
			
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, COLORS._main_value_negative) == 2) {
				array_delete(_flares, array_length(_flares) - 1, 1);
				inputs[5].setValue(_flares);
				triggerRender();
			}
			
			if(flare_editing != noone && flare_editing_prop == "type") {
				var _fdx = flare_draw_x;
				var _fdy = flare_draw_y;
				
				var _fdw = _fh - ui(8);
				var _fdh = _fdw * FLARE_TYPE.size;
				
				draw_sprite_stretched_ext(THEME.ui_panel, 0, _fdx, _fdy, _fdw, _fdh, CDEF.main_mdblack, 1);
				draw_sprite_stretched_ext(THEME.ui_panel, 1, _fdx, _fdy, _fdw, _fdh, CDEF.main_dkgrey,  1);
				
				var _flare = _flares[flare_editing];
				
				for( var i = 0; i < FLARE_TYPE.size; i++ ) {
					var _ddx = _fdx;
					var _ddy = _fdy + _fdw * i;
					
					if(i == _flare.type)
						draw_sprite_stretched_ext(THEME.ui_panel, 0, _ddx, _ddy, _fdw, _fdw, CDEF.main_dkgrey, 1);
					draw_sprite_ext(s_flare_type, i, _ddx + _fdw / 2, _ddy + _fdw / 2, 1, 1, 0, i == _flare.type? c_white : COLORS._main_icon, 1);
				}
			}
			
			return _h;
		});
	#endregion
		
	input_display_list = [ new Inspector_Sprite(s_MKFX), 7, 
		[ "Surfaces",   false ], 0, 2, 
		[ "Positions",  false ], 1, 6, 
		[ "Flare",      false ], flare_builder,
		[ "Blending",   false ], 3, 9, 4, 
		[ "FXAA",        true,  8 ], 10, 
		[ "Aberration",  true, 11 ], 12, 13, 14, 15, 
	]
	
	////- Nodes
	
	temp_surface = [ noone, noone, noone ];
	
	ox = 0; oy = 0;
	cx = 0; cy = 0;
	dx = 0; dy = 0;
	
	sca = 1;
	alp = 1;
	dir = 0;
	dis = 0;
		
	static drawOverlay    = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _flares = getSingleValue(5);
		var _sca    = getSingleValue(3);
		
		draw_set_circle_precision(32);
		for( var i = 0, n = array_length(_flares); i < n; i++ ) {
			var _flare = _flares[i];
			
			var _t  = _flare.t;
			var _t2 = _flare.t2;
			var _r  = _flare.r; _r = is_array(_r)? _r[0] + _r[1] * _sca : _r * _sca;
			
			var xx = cx + sign(dx) * power(abs(dx), 1 + _t2) * (1 - _t);
			var yy = cy + sign(dy) * power(abs(dy), 1 + _t2) * (1 - _t);
			
			    xx = _x + xx * _s;
			    yy = _y + yy * _s;
			    
			var hv = i == flare_hovering;
			
			draw_set_color(hv? COLORS._main_accent : COLORS._main_icon);
			draw_set_alpha(.5 + hv * .5);
			
			switch(_flare.type) {
				case FLARE_TYPE.circle : 
				case FLARE_TYPE.ring   : 
				case FLARE_TYPE.star   : draw_circle_border(xx, yy, _r * _s, 1 + hv); break;
					
				case FLARE_TYPE.line   : 
					var x0 = xx - lengthdir_x(_r * _s, dir);
					var y0 = yy - lengthdir_y(_r * _s, dir);
					var x1 = xx + lengthdir_x(_r * _s, dir);
					var y1 = yy + lengthdir_y(_r * _s, dir);
					
					draw_line_width(x0, y0, x1, y1, 1 + hv);
					break;
			}
		}
		
		draw_set_alpha(1);
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, 1));
		InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, 1));
		
		return w_hovering;
	}
	
	static getDimension   = function(arr = 0) {
		var _sr = getSingleValue(0, arr);
		var _dm = getSingleValue(2, arr);
		
		if(is_surface(_sr)) 
			return surface_get_dimension(_sr);
		return _dm;
	}
	
	static flare_circle   = function(_flare) {
		var _t  = _flare.t;
		var _t2 = _flare.t2;
		var _r  = is_array(_flare.r)? _flare.r[0] + _flare.r[1] * sca : _flare.r * sca;
		var _a  = _flare.a * alp;
		var _g  = _flare.seg_s? _flare.seg * sca : _flare.seg;
		var _h  = _flare.shade;
		var _b  = _flare.blend;
		
		var _x  = cx + sign(dx) * power(abs(dx), 1 + _t2) * (1 - _t);
		var _y  = cy + sign(dy) * power(abs(dy), 1 + _t2) * (1 - _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", _h[0], _h[1]);
			draw_primitive_begin(pr_trianglelist);
			
			for( var i = 0; i < _g; i++ ) {
				var a0 = ((i + 0) / _g) * 360 + dir;
				var a1 = ((i + 1) / _g) * 360 + dir;
				
				draw_vertex_color(_r, _r, c_white, 1)
				draw_vertex_color(_r + lengthdir_x(_r, a0), _r + lengthdir_y(_r, a0), c_black, 1)
				draw_vertex_color(_r + lengthdir_x(_r, a1), _r + lengthdir_y(_r, a1), c_black, 1)
			}
			
			draw_primitive_end();
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, _b, _a);
	}
	
	static flare_crescent = function(_flare) {
		var _t  = _flare.t;
		var _t2 = _flare.t2;
		var _r  = is_array(_flare.r)? _flare.r[0] + _flare.r[1] * sca : _flare.r * sca;
		var _a  = _flare.a * alp;
		var _g  = _flare.seg_s? _flare.seg * sca : _flare.seg;
		var _h  = _flare.shade;
		var _b  = _flare.blend;
				    
		var _x  = cx + sign(dx) * power(abs(dx), 1 + _t2) * (1 - _t);
		var _y  = cy + sign(dy) * power(abs(dy), 1 + _t2) * (1 - _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", _h[0], _h[1]);
			
			draw_circle_color(_r, _r, _r, c_white, c_black, false);
			
			var _rx = _r + lengthdir_x(_dist, dir);
			var _ry = _r + lengthdir_y(_dist, dir);
			
			BLEND_SUBTRACT
			draw_circle_color(_rx, _ry, _ir, c_white, c_black, false);
			BLEND_NORMAL
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, _b, _a);
	}
	
	static flare_ring     = function(_flare) {
		var _t  = _flare.t;
		var _t2 = _flare.t2;
		var _r  = is_array(_flare.r)? _flare.r[0] + _flare.r[1] * sca : _flare.r * sca;
		var _a  = _flare.a * alp;
		var _g  = _flare.seg_s? _flare.seg * sca : _flare.seg;
		var _h  = _flare.shade;
		var _b  = _flare.blend;
		var _th = is_array(_flare.th)? _flare.th[0] + _flare.th[1] * sca : _flare.th * sca;
			    
		var _x  = cx + sign(dx) * power(abs(dx), 1 + _t2) * (1 - _t);
		var _y  = cy + sign(dy) * power(abs(dy), 1 + _t2) * (1 - _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		var _r0 = _r - _th;
		var _r1 = _r - _th / 2;
		var _r2 = _r;
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", _h[0], _h[1]);
			draw_primitive_begin(pr_trianglelist);
			
			for( var i = 0; i < _g; i++ ) {
				var a0 = ((i + 0.0) / _g) * 360 + dir;
				var a1 = ((i + 1.0) / _g) * 360 + dir;
				
				draw_vertex_color(_r + lengthdir_x(_r1, a0), _r + lengthdir_y(_r1, a0), c_white, 1);
				draw_vertex_color(_r + lengthdir_x(_r0, a0), _r + lengthdir_y(_r0, a0), c_black, 1);
				draw_vertex_color(_r + lengthdir_x(_r1, a1), _r + lengthdir_y(_r1, a1), c_white, 1);
				
				draw_vertex_color(_r + lengthdir_x(_r0, a0), _r + lengthdir_y(_r0, a0), c_black, 1);
				draw_vertex_color(_r + lengthdir_x(_r1, a1), _r + lengthdir_y(_r1, a1), c_white, 1);
				draw_vertex_color(_r + lengthdir_x(_r0, a1), _r + lengthdir_y(_r0, a1), c_black, 1);
				
				draw_vertex_color(_r + lengthdir_x(_r1, a0), _r + lengthdir_y(_r1, a0), c_white, 1);
				draw_vertex_color(_r + lengthdir_x(_r2, a0), _r + lengthdir_y(_r2, a0), c_black, 1);
				draw_vertex_color(_r + lengthdir_x(_r1, a1), _r + lengthdir_y(_r1, a1), c_white, 1);
				
				draw_vertex_color(_r + lengthdir_x(_r2, a0), _r + lengthdir_y(_r2, a0), c_black, 1);
				draw_vertex_color(_r + lengthdir_x(_r1, a1), _r + lengthdir_y(_r1, a1), c_white, 1);
				draw_vertex_color(_r + lengthdir_x(_r2, a1), _r + lengthdir_y(_r2, a1), c_black, 1);
			}
			
			draw_primitive_end();
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, _b, _a);
	}
					      
	static flare_star = function(_flare) {
		var _t  = _flare.t;
		var _t2 = _flare.t2;
		var _r  = is_array(_flare.r)? _flare.r[0] + _flare.r[1] * sca : _flare.r * sca;
		var _a  = _flare.a * alp;
		var _g  = _flare.seg_s? _flare.seg * sca : _flare.seg;
		var _h  = _flare.shade;
		var _b  = _flare.blend;
			
		var _ir = is_array(_flare.ir)? _flare.ir[0] + _flare.ir[1] * sca : _flare.ir * sca;
		var _rt = _flare.ratio;
		  
		var _x  = cx + sign(dx) * power(abs(dx), 1 + _t2) * (1 - _t);
		var _y  = cy + sign(dy) * power(abs(dy), 1 + _t2) * (1 - _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		var cc = _r;
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			draw_primitive_begin(pr_trianglelist);
			shader_set_f("smooth", _h[0], _h[1]);
			
			for( var i = 0; i < _g; i++ ) {
				var a0 = ((i + 0.0) / _g)                  * 360 + dir;
				var a1 = ((i + random_range(0., 1.)) / _g) * 360 + dir;
				var a2 = ((i + 1.0) / _g)                  * 360 + dir;
				
				draw_vertex_color(cc, cc, c_white, 1);
				draw_vertex_color(cc + lengthdir_x(_ir, a0), cc + lengthdir_y(_ir, a0), c_grey,  1);
				draw_vertex_color(cc + lengthdir_x(_r , a1), cc + lengthdir_y(_r , a1), c_black, 1);
				
				draw_vertex_color(cc, cc, c_white, 1);
				draw_vertex_color(cc + lengthdir_x(_r , a1), cc + lengthdir_y(_r , a1), c_black, 1);
				draw_vertex_color(cc + lengthdir_x(_ir, a2), cc + lengthdir_y(_ir, a2), c_grey,  1);
				
				if(i && i % 32 == 0) {
					draw_primitive_end();
					draw_primitive_begin(pr_trianglelist);
				}
			}
			
			draw_primitive_end();
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, _b, _a);
	}
					      
	static flare_line     = function(_flare) {
		var _t  = _flare.t;
		var _t2 = _flare.t2;
		var _r  = is_array(_flare.r)? _flare.r[0] + _flare.r[1] * sca : _flare.r * sca;
		var _a  = _flare.a * alp;
		var _g  = _flare.seg_s? _flare.seg * sca : _flare.seg;
		var _h  = _flare.shade;
		var _b  = _flare.blend;
		var _th = is_array(_flare.th)? _flare.th[0] + _flare.th[1] * sca : _flare.th * sca;
		
		var _x  = lerp(ox, cx, _t);
		var _y  = lerp(oy, cy, _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", 0, 1);
			
			draw_primitive_begin(pr_trianglelist);
			
			var x0 = _r + lengthdir_x(_r,  dir);
			var y0 = _r + lengthdir_y(_r,  dir);
			var x1 = _r + lengthdir_x(_th, dir +  90);
			var y1 = _r + lengthdir_y(_th, dir +  90);
			var x2 = _r + lengthdir_x(_th, dir + 270);
			var y2 = _r + lengthdir_y(_th, dir + 270);
			var x3 = _r + lengthdir_x(_r,  dir + 180);
			var y3 = _r + lengthdir_y(_r,  dir + 180);
			
			draw_vertex_color(_r, _r, c_white, 1);
			draw_vertex_color(x0, y0, c_black, 1);
			draw_vertex_color(x1, y1, c_black, 1);
			
			draw_vertex_color(_r, _r, c_white, 1);
			draw_vertex_color(x0, y0, c_black, 1);
			draw_vertex_color(x2, y2, c_black, 1);
			
			draw_vertex_color(_r, _r, c_white, 1);
			draw_vertex_color(x3, y3, c_black, 1);
			draw_vertex_color(x1, y1, c_black, 1);
			
			draw_vertex_color(_r, _r, c_white, 1);
			draw_vertex_color(x3, y3, c_black, 1);
			draw_vertex_color(x2, y2, c_black, 1);
			
			draw_primitive_end();
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, _b, _a);
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _flares = _data[5];
			
			var _seed   = _data[7];
			
			var _surf   = _data[0];
			var _dim    = _data[2];
			
			var _origin = _data[1];
			var _focus  = _data[6];
			
			     sca    = _data[3]; 
			     alp    = _data[4];
			var _ints   = _data[9]; 
			
			var _fxaa   = _data[ 8];
			var _fxaaD  = _data[10];
			
			var _abbr    = _data[11];
			var _abbrS   = _data[12];
			var _abbrI   = _data[13];
			var _abbrShf = _data[14];
			var _abbrSca = _data[15];
		#endregion
		
		var _bg = is_surface(_surf);
		
		random_set_seed(_seed);
		
		var _sw = _bg? surface_get_width_safe(_surf)  : _dim[0];
		var _sh = _bg? surface_get_height_safe(_surf) : _dim[1];
		
		var _outSurf  = surface_verify(_outData[0], _sw, _sh);
		var flareSurf = surface_verify(_outData[1], _sw, _sh);
		
		ox = _origin[0];
		oy = _origin[1];
		cx = _focus[0];
		cy = _focus[1];
		dx = ox - cx;
		dy = oy - cy;
		
		dir = point_direction(cx, cy, ox, oy);
		dis = point_distance(cx, cy, ox, oy);
		
		var _x, _y;
		
		surface_set_target(flareSurf);
			draw_clear_alpha(c_black, 0);
			
			for( var i = 0, n = array_length(_flares); i < n; i++ ) {
				var _flare = _flares[i];
				
				switch(_flare.type) {
					case FLARE_TYPE.circle : flare_circle(_flare); break;
					case FLARE_TYPE.ring   : flare_ring(_flare);   break;
					case FLARE_TYPE.star   : flare_star(_flare);   break;
					case FLARE_TYPE.line   : flare_line(_flare);   break;
				}
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		if(_fxaa) {
			temp_surface[1] = surface_verify(temp_surface[1], _sw, _sh);
			
			surface_set_shader(temp_surface[1], sh_FXAA);
				gpu_set_tex_filter(true);
				shader_set_2("dimension", [_sw, _sh] );
				shader_set_f("cornerDis", _fxaaD     );
				shader_set_f("mixAmo",    1          );
				
				draw_surface_safe(flareSurf);
				gpu_set_tex_filter(false);
			surface_reset_shader();
			
			flareSurf = temp_surface[1];
		}
		
		if(_abbr) {
			temp_surface[2] = surface_verify(temp_surface[2], _sw, _sh);
			
			surface_set_shader(temp_surface[2], sh_chromatic_aberration);
				gpu_set_tex_filter(true);
				shader_set_interpolation(flareSurf);
				shader_set_uv(noone);
				
				shader_set_2("dimension",     [_sw,_sh] );
				shader_set_f("resolution",    64        );
				shader_set_i("type",          1         );
				shader_set_2("center",        _focus    );
				shader_set_f_map("strength",  _abbrS    );
				shader_set_f_map("intensity", _abbrI    );
				shader_set_f_map("chromaShf", _abbrShf  );
				shader_set_f_map("chromaSca", _abbrSca  );
				shader_set_i("s_curve_use",   0         );
				
				draw_surface_safe(flareSurf);
				gpu_set_tex_filter(false);
			surface_reset_shader();
			
			flareSurf = temp_surface[2];
		}
		
		surface_set_target(_outSurf);
			if(_bg) {
				draw_clear_alpha(c_black, 0);
				BLEND_OVERRIDE
				draw_surface_safe(_surf);
			} else 
				draw_clear_alpha(c_black, 1);
			
			shader_set(sh_mk_flare_multiply);
				shader_set_f("intensity", _ints);
				BLEND_ADD
				draw_surface_safe(flareSurf);
				BLEND_NORMAL
			shader_reset();
		surface_reset_target();
		
		return _outData;
	}
}
