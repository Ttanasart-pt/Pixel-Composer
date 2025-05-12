enum FLARE_TYPE {
	circle,
	ring,
	star,
	line,
	
	size
}

function __FlarePart(_type = FLARE_TYPE.circle, _t = 0, _r = 4, _a = 0.5, _seg = 16, _seg_s = false, _blend = c_white, _shade = [ 0, 1 ], _ir = 1, _ratio = 1, _th = [ 1, 0 ]) constructor {
	type  = _type  
	t     = _t     
	r     = _r     
	a     = _a     
	seg   = _seg   
	seg_s = _seg_s 
	blend = _blend 
	shade = _shade 
	ir    = _ir    
	ratio = _ratio 
	th    = _th    
}

function Node_MK_Flare(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Lens Flare";
	
	newInput(0, nodeValue_Surface("Background", self));
	
	newInput(1, nodeValue_Vec2("Origin", self, [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	newInput(2, nodeValue_Dimension(self));
		
	newInput(3, nodeValue_Float("Scale", self, 1))
		
	newInput(4, nodeValue_Float("Alpha", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(5, nodeValue_Struct("Flares", self, [
		new __FlarePart( FLARE_TYPE.circle,   0,  8,   0.75, 16, false, , [ 0, 1 ] ),
		new __FlarePart( FLARE_TYPE.circle,   0, 16,   0.5,  16, false, , [ 0, 1 ] ),
		new __FlarePart( FLARE_TYPE.star,     0, 14,   0.3,   8, true,  , [ 0.2, 0.8 ], 2, 0.85 ),
		new __FlarePart( FLARE_TYPE.ring,     0,  6,   0.25, 16, false, , [ 0, 0.5 ],,, [ 1, 0.1 ] ),
		
		new __FlarePart( FLARE_TYPE.circle, 0.7,  2,   0.6,  16, false, , [ 0, 0.25 ] ),
		new __FlarePart( FLARE_TYPE.circle, 0.9,  2,   0.6,   6, false, , [ 0, 0.50 ] ),
		new __FlarePart( FLARE_TYPE.circle, 1.2,  0.5, 0.5,   4, false, , [ 0, 0.00 ] ),
												  			 
		new __FlarePart( FLARE_TYPE.circle, 1.5,  5,   0.6,  16, false, , [ 0, 0.7 ] ),
		new __FlarePart( FLARE_TYPE.circle, 1.6,  3,   0.4,   6, false, , [ 0, 0.  ] ),
		new __FlarePart( FLARE_TYPE.ring,   1.9,  4,   0.5,  16, false, , [ 0, 0.  ],,, [ 1, 0 ] ),
		new __FlarePart( FLARE_TYPE.circle, 1.9,  3,   0.5,  16, false, , [ 0, 0.5 ] ),
	]))
		.setArrayDepth(1)
		.setArrayDynamic();
		
	newInput(6, nodeValue_Vec2("Focus", self, [ 0.5, 0.5 ]))
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
		
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
		
	newOutput(1, nodeValue_Output("Light only", self, VALUE_TYPE.surface, noone));
	
	static __frame = function(_x, _y, _w, _h, _m, _hover) {  
		var _hv = point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h) && _hover;
		
		draw_sprite_stretched_ext(THEME.ui_panel, 0, _x, _y, _w, _h, _hv? CDEF.main_black : CDEF.main_mdblack,  1);
		draw_sprite_stretched_ext(THEME.ui_panel, 1, _x, _y, _w, _h, CDEF.main_dkgrey, 1);
		
		return _hv;
	}
	
	flare_editing      = noone;
	flare_editing_prop = "";
	flare_editing_mx   = 0;
	flare_editing_my   = 0;
	flare_editing_sx   = 0;
	flare_editing_sy   = 0;
	
	flare_color_editing = -1;
	
	flare_draw_x = 0;
	flare_draw_y = 0;
	
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
		var _h  = (_amo + 1) * (_fh + ui(4));
		
		var _ffh = _fh - ui(8);
		
		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
		
		if(flare_editing != noone) {
			var _flare = _flares[flare_editing];
			CURSOR = cr_size_we;
			
			switch(flare_editing_prop) {
				case "type" :
					_flare.a    = clamp(flare_editing_sx + (_m[0] - flare_editing_mx) / 64, 0, 1);
					_flare.type = clamp(floor((_m[1] - flare_editing_my) / _ffh), 0, FLARE_TYPE.size - 1);
					
					if(_flare.type == FLARE_TYPE.ring || _flare.type == FLARE_TYPE.line)
						if(!struct_has(_flare, "th"))    _flare.th = [ 1, 0 ];
					else if(_flare.type == FLARE_TYPE.star) {
						if(!struct_has(_flare, "ir"))    _flare.ir    = 1;
						if(!struct_has(_flare, "ratio")) _flare.ratio = 1;
					}
					CURSOR = cr_size_all;
					break;
					
				case "t" :   _flare.t        =       flare_editing_sx + (_m[0] - flare_editing_mx) / 64;        if(abs(_flare.t - round(_flare.t * 10) / 10) < 0.02) _flare.t = round(_flare.t * 10) / 10;								break;
				case "r" :   _flare.r        =       flare_editing_sx + (_m[0] - flare_editing_mx) / 64;        if(abs(_flare.r - round(_flare.r)) < 0.2) _flare.r = round(_flare.r);													break;
				case "seg" : _flare.seg      = round(flare_editing_sx + (_m[0] - flare_editing_mx) / 32);																																break;
				case "r0" :  _flare.shade[0] = clamp(flare_editing_sx + (_m[0] - flare_editing_mx) / 64, 0, 1); if(abs(_flare.shade[0] - round(_flare.shade[0] * 10) / 10) < 0.02) _flare.shade[0] = round(_flare.shade[0] * 10) / 10;	break;
				case "r1" :  _flare.shade[1] = clamp(flare_editing_sx + (_m[0] - flare_editing_mx) / 64, 0, 1); if(abs(_flare.shade[1] - round(_flare.shade[1] * 10) / 10) < 0.02) _flare.shade[1] = round(_flare.shade[1] * 10) / 10;	break;
				case "th0" : _flare.th[0]    =       flare_editing_sx + (_m[0] - flare_editing_mx) / 64;        if(abs(_flare.th[0] - round(_flare.th[0])) < 0.2) _flare.th[0] = round(_flare.th[0]);									break;
				case "th1" : _flare.th[1]    =       flare_editing_sx + (_m[0] - flare_editing_mx) / 64;        if(abs(_flare.th[1] - round(_flare.th[1])) < 0.2) _flare.th[1] = round(_flare.th[1]);									break;
				case "ir" :  _flare.ir       =       flare_editing_sx + (_m[0] - flare_editing_mx) / 64;        if(abs(_flare.ir    - round(_flare.ir   )) < 0.2) _flare.ir    = round(_flare.ir   );									break;
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
			
			draw_sprite_stretched_ext(THEME.ui_panel, 0, _fx, _fy, _w,  _fh, CDEF.main_dkblack, 1);
			
			var _hov = __frame(_ffx, _ffy, _ffw, _ffh, _m, _hover);
			draw_sprite_stretched_ext(THEME.ui_panel, 0, _ffx, _ffy, _ffw * _flare.a, _ffh, CDEF.main_dkgrey, 1);
			draw_sprite_ext(s_flare_type, _flare.type, _ffx + _ffh / 2, _ffy + _ffh / 2, 1, 1, 0, c_white, 1);
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
			var _hov = __frame(_ffx, _ffy, _ffw, _ffh, _m, _hover);
			draw_sprite_stretched_ext(THEME.palette_mask, 1, _ffx + ui(4), _ffy + ui(4), _ffw - ui(8), _ffh - ui(8), _flare.blend, 1);
			if(_hov && mouse_press(mb_left, _focus)) {
				flare_color_editing = i;
				
				var dialog = dialogCall(o_dialog_color_selector)
								.setDefault(_flare.blend)
								.setApply(edit_flare_color);
			}
			_ffx += _ffw + ui(4);
			
			_ffw  = ui(40);
			
			var _hov = __frame(_ffx, _ffy, _ffw, _ffh, _m, _hover);
			draw_sprite_stretched_ext(THEME.ui_panel, 0, _ffx, _ffy, _ffw * clamp(_flare.t, 0., 2.) / 2, _ffh, CDEF.main_dkgrey, 1);
			draw_text_add(_ffx + _ffw / 2, _ffy + _ffh / 2, string(_flare.t));
			if(_hov && mouse_press(mb_left, _focus)) {
				flare_editing = i;
				flare_editing_prop = "t";
				flare_editing_mx   = _m[0];
				flare_editing_sx   = _flare.t;
			}
			_ffx += _ffw + ui(4);
			
			var _hov = __frame(_ffx, _ffy, _ffw, _ffh, _m, _hover);
			draw_text_add(_ffx + _ffw / 2, _ffy + _ffh / 2, string(_flare.r));
			if(_hov && mouse_press(mb_left, _focus)) {
				flare_editing = i;
				flare_editing_prop = "r";
				flare_editing_mx   = _m[0];
				flare_editing_sx   = _flare.r;
			}
			_ffx += _ffw + ui(4);
			
			_ffw  = _ffh;
			var _hov = __frame(_ffx, _ffy, _ffw, _ffh, _m, _hover);
			draw_set_color(CDEF.main_dkgrey);
			draw_polygon(_ffx + _ffw / 2, _ffy + _ffh / 2, _ffh / 2 - ui(2), _flare.seg);
			
			draw_set_color(COLORS._main_text); 
			draw_text_add(_ffx + _ffw / 2, _ffy + _ffh / 2, string(_flare.seg));
			if(_hov && mouse_press(mb_left, _focus)) {
				flare_editing = i;
				flare_editing_prop = "seg";
				flare_editing_mx   = _m[0];
				flare_editing_sx   = _flare.seg;
			}
			_ffx += _ffw + ui(4);
			
			_ffw  = ui(80);
			var _hov = __frame(_ffx, _ffy, _ffw, _ffh, _m, _hover);
			draw_sprite_stretched_ext(THEME.ui_panel, 0, _ffx + _ffw * _flare.shade[0], _ffy, _ffw * (_flare.shade[1] - _flare.shade[0]), _ffh, CDEF.main_dkgrey, 1);
			draw_text_add(_ffx + _ffw / 4,     _ffy + _ffh / 2, string(_flare.shade[0]));
			draw_text_add(_ffx + _ffw / 4 * 3, _ffy + _ffh / 2, string(_flare.shade[1]));
			if(_hov && mouse_press(mb_left, _focus)) {
				flare_editing      = i;
				flare_editing_prop = _m[0] < _ffx + _ffw / 2? "r0" : "r1";
				flare_editing_mx   = _m[0];
				flare_editing_sx   = _m[0] < _ffx + _ffw / 2? _flare.shade[0] : _flare.shade[1];
			}
			_ffx += _ffw + ui(4);
			
			switch(_flare.type) {
				case FLARE_TYPE.ring :
				case FLARE_TYPE.line :
					_ffw  = ui(80);
					var _hov = __frame(_ffx, _ffy, _ffw, _ffh, _m, _hover);
					draw_text_add(_ffx + _ffw / 4,     _ffy + _ffh / 2, string(_flare.th[0]));
					draw_text_add(_ffx + _ffw / 4 * 3, _ffy + _ffh / 2, string(_flare.th[1]));
					if(_hov && mouse_press(mb_left, _focus)) {
						flare_editing      = i;
						flare_editing_prop = _m[0] < _ffx + _ffw / 2? "th0" : "th1";
						flare_editing_mx   = _m[0];
						flare_editing_sx   = _m[0] < _ffx + _ffw / 2? _flare.th[0] : _flare.th[1];
					}
					_ffx += _ffw + ui(4);
					break;
					
				case FLARE_TYPE.star :
					_ffw  = ui(40);
					var _hov = __frame(_ffx, _ffy, _ffw, _ffh, _m, _hover);
					draw_text_add(_ffx + _ffw / 2, _ffy + _ffh / 2, string(_flare.ir));
					if(_hov && mouse_press(mb_left, _focus)) {
						flare_editing = i;
						flare_editing_prop = "ir";
						flare_editing_mx   = _m[0];
						flare_editing_sx   = _flare.ir;
					}
					_ffx += _ffw + ui(4);
					break;
			}
			
			_fy += _fh + ui(4);
		}
		
		var bx = _fx;
		var by = _fy;
		var bs = ui(24);
		
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
			array_push(_flares, new __FlarePart());
			inputs[5].setValue(_flares);
			triggerRender();
		}
		
		bx += bs + ui(8);
		
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
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 
		["Surfaces",  false], 0, 2, 
		["Positions", false], 1, 6, 
		["Flare",     false], flare_builder,
		["Render",	  false], 3, 4, 
	]
	
	temp_surface = [ surface_create(1, 1) ];
	seed         = seed_random();
	
	flares = [];
	
	ox = 0;
	oy = 0;
	cx = 0
	cy = 0
		
	dir = 0;
	dis = 0;
		
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		InputDrawOverlay(inputs[6].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static getDimension = function(arr = 0) {
		var _sr = getSingleValue(0, arr);
		var _dm = getSingleValue(2, arr);
		
		if(is_surface(_sr)) 
			return surface_get_dimension(_sr);
		return _dm;
	}
	
	static flare_circle   = function(_t, _r, _a, _side = 16, _angle = 0, _s0 = 0, _s1 = 0, _b = c_white) {
		var _x = lerp(ox, cx, _t);
		var _y = lerp(oy, cy, _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", _s0, _s1);
			draw_primitive_begin(pr_trianglelist);
			
			for( var i = 0; i < _side; i++ ) {
				var a0 = ((i + 0.0) / _side) * 360 + _angle;
				var a1 = ((i + 1.0) / _side) * 360 + _angle;
				
				draw_vertex_color(_r, _r, c_white, 1)
				draw_vertex_color(_r + lengthdir_x(_r, a0), _r + lengthdir_y(_r, a0), c_black, 1)
				draw_vertex_color(_r + lengthdir_x(_r, a1), _r + lengthdir_y(_r, a1), c_black, 1)
			}
			
			draw_primitive_end();
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, _b, _a);
	}
	
	static flare_crescent = function(_t, _r, _a, _side = 16, _angle = 0, _s0 = 0, _s1 = 0, _b = c_white, _ir = 0, _dist = 0) {
		var _x = lerp(ox, cx, _t);
		var _y = lerp(oy, cy, _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", _s0, _s1);
			
			draw_circle_color(_r, _r, _r, c_white, c_black, false);
			
			var _rx = _r + lengthdir_x(_dist, _angle);
			var _ry = _r + lengthdir_y(_dist, _angle);
			
			BLEND_SUBTRACT
			draw_circle_color(_rx, _ry, _ir, c_white, c_black, false);
			BLEND_NORMAL
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, _b, _a);
	}
	
	static flare_ring     = function(_t, _r, _a, _side = 16, _angle = 0, _s0 = 0, _s1 = 0, _b = c_white, _th = 1) {
		var _x = lerp(ox, cx, _t);
		var _y = lerp(oy, cy, _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		var _r0 = _r - _th;
		var _r1 = _r - _th / 2;
		var _r2 = _r;
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", _s0, _s1);
			draw_primitive_begin(pr_trianglelist);
			
			for( var i = 0; i < _side; i++ ) {
				var a0 = ((i + 0.0) / _side) * 360 + _angle;
				var a1 = ((i + 1.0) / _side) * 360 + _angle;
				
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
					      
	static flare_star     = function(_t, _r, _a, _side = 16, _angle = 0, _s0 = 0, _s1 = 1, _b = c_white, _ir = 0, _rt = 1) {
		var _x = lerp(ox, cx, _t);
		var _y = lerp(oy, cy, _t);
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		var cc = _r;
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			draw_primitive_begin(pr_trianglelist);
			shader_set_f("smooth", _s0, _s1);
			random_set_seed(seed);
			
			for( var i = 0; i < _side; i++ ) {
				var a0 = ((i + 0.0) / _side) * 360 + _angle;
				var a1 = ((i + random_range(0., 1.)) / _side) * 360 + _angle;
				var a2 = ((i + 1.0) / _side) * 360 + _angle;
				
				draw_vertex_color(cc, cc, c_white, 1);
				draw_vertex_color(cc + lengthdir_x(_ir, a0), cc + lengthdir_y(_ir, a0), c_grey,  1);
				draw_vertex_color(cc + lengthdir_x(_r , a1), cc + lengthdir_y(_r , a1), c_black, 1);
				
				draw_vertex_color(cc, cc, c_white, 1);
				draw_vertex_color(cc + lengthdir_x(_r , a1), cc + lengthdir_y(_r , a1), c_black, 1);
				draw_vertex_color(cc + lengthdir_x(_ir, a2), cc + lengthdir_y(_ir, a2), c_grey,  1);
			}
			
			draw_primitive_end();
		surface_reset_shader();
		
		BLEND_ADD draw_surface_ext(temp_surface[0], _x - _r, _y - _r, 1, 1, 0, _b, _a);
	}
					      
	static flare_line     = function(_r, _a, _th, _dir, _b = c_white) {
		var _x = cx;
		var _y = cy;
		
		temp_surface[0] = surface_verify(temp_surface[0], _r * 2, _r * 2);
		
		surface_set_shader(temp_surface[0], sh_draw_grey_alpha);
			shader_set_f("smooth", 0, 1);
			
			draw_primitive_begin(pr_trianglelist);
			
			var x0 = _r + lengthdir_x(_r,  _dir);
			var y0 = _r + lengthdir_y(_r,  _dir);
			var x1 = _r + lengthdir_x(_th, _dir +  90);
			var y1 = _r + lengthdir_y(_th, _dir +  90);
			var x2 = _r + lengthdir_x(_th, _dir + 270);
			var y2 = _r + lengthdir_y(_th, _dir + 270);
			var x3 = _r + lengthdir_x(_r,  _dir + 180);
			var y3 = _r + lengthdir_y(_r,  _dir + 180);
			
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
		
		var _surf   = _data[0];
		var _origin = _data[1];
		var _dim    = _data[2];
		var _sca    = _data[3];
		var _alp    = _data[4];
		var _flares = _data[5];
		var _focus  = _data[6];
		
		var _bg = is_surface(_surf);
		
		var _sw = _bg? surface_get_width_safe(_surf)  : _dim[0];
		var _sh = _bg? surface_get_height_safe(_surf) : _dim[1];
		
		var _outSurf  = surface_verify(_outData[0], _sw, _sh);
		var flareSurf = surface_verify(_outData[1], _sw, _sh);
		
		ox = _origin[0];
		oy = _origin[1];
		cx = _focus[0];
		cy = _focus[1];
		
		dir = point_direction(cx, cy, ox, oy);
		dis = point_distance(cx, cy, ox, oy);
		
		var _x, _y;
		
		surface_set_target(flareSurf);
			draw_clear_alpha(c_black, 0);
			
			for( var i = 0, n = array_length(_flares); i < n; i++ ) {
				var _flare = _flares[i];
				
				var _t = _flare.t;
				var _r = _flare.r; _r = is_array(_r)? _r[0] + _r[1] * _sca : _r * _sca;
				var _a = _flare.a; _a = _a * _alp;
				var _g = _flare.seg_s? _flare.seg * _sca : _flare.seg;
				var _h = _flare.shade;
				var _b = _flare.blend;
				
				switch(_flare.type) {
					case FLARE_TYPE.circle : 
						flare_circle(_t, _r, _a, _g, dir, _h[0], _h[1], _b); 
						break;
					
					case FLARE_TYPE.ring   : 
						var _th = _flare.th; _th = is_array(_th)? _th[0] + _th[1] * _sca : _th * _sca;
						flare_ring(_t, _r, _a, _g, dir, _h[0], _h[1], _b, _th); 
						break;
						
					case FLARE_TYPE.star   : 
						var _ir = _flare.ir; _ir = is_array(_ir)? _ir[0] + _ir[1] * _sca : _ir * _sca;
						var _rt = _flare.ratio;
						flare_star(_t, _r, _a, _g, dir, _h[0], _h[1], _b, _ir, _rt); 
						break;
						
					case FLARE_TYPE.line   : 
						var _th = _flare.th; _th = is_array(_th)? _th[0] + _th[1] * _sca : _th * _sca;
						flare_line(_r, _a, _th, dir, _b); 
						break;
				}
			}
			
			BLEND_NORMAL
		surface_reset_target();
		
		surface_set_target(_outSurf);
			
			if(_bg) {
				draw_clear_alpha(c_black, 0);
				BLEND_OVERRIDE
				draw_surface_safe(_surf);
			} else 
				draw_clear_alpha(c_black, 1);
			
			BLEND_ADD
			draw_surface_safe(flareSurf);
				
			BLEND_NORMAL
		surface_reset_target();
		
		return _outData;
	}
}
