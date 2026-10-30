function Node_Path_Orbital(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Orbital Path";
	setDrawIcon();
	setDimension(96, 48);
	
	newInput( 0, nodeValueSeed());
	
	////- =Object
	newInput( 1, nodeValue_Vec2(  "Origin",           [.25,.25] )).setUnitSimple();
	newInput( 2, nodeValue_Vec2(  "Initial Velocity", [4,0]     )).setUnitSimple(false);
	newInput( 5, nodeValue_Float( "Mass",              10       ));
	
	////- =Path
	newInput( 3, nodeValue_Float( "Length",      32  ));
	newInput( 4, nodeValue_Int(   "Resolution",  16  ));
	// 6
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, noone));
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index+0, nodeValue_Vec2(  "Position", [.5,.5] )).setUnitSimple().hideLabel();
		newInput(index+1, nodeValue_Float( "Mass",     10      ));
		
		postCreateNewInput(index);
		refreshDynamicDisplay();
		
		return inputs[index];
	} 
	
	gravity_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var bs = ui(24);
		var bx = _x + ui(20);
		var by = _y;
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
			createNewInput();
			triggerRender();
		}
			
		var amo = getInputAmount();
		var lh  = ui(28);
		var _h  = ui(12) + lh * amo;
		var yy  = _y + bs + ui(4);
		
		var toDel = -1;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, yy, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		for(var i = 0; i < amo; i++) {
			var _x0 = _x + ui(24);
			var _x1 = _x + _w - ui(16);
			var _yy = ui(6) + yy + i * lh + lh / 2;
			
			var _ind = input_fix_len + i * data_length;
			
			var tc   = i == dynamic_input_inspecting? COLORS._main_text_accent : COLORS._main_icon;
			var hov  = _hover && point_in_rectangle(_m[0], _m[1], _x0, _yy - lh / 2, _x1, _yy + lh / 2 - 1);
			
			if(hov && _m[0] < _x1 - ui(32)) {
				tc = COLORS._main_text;
				
				if(mouse_lpress(_focus)) {
					dynamic_input_inspecting = dynamic_input_inspecting == i? noone : i;
					refreshDynamicDisplay();
				}
			}
			
			draw_sprite_ext(s_node_2d_light_shape, 0, _x0 + ui(8), _yy, 1, 1, 0, c_white, .5 + .5 * (i == dynamic_input_inspecting));
			
			draw_set_text(f_p2, fa_left, fa_center, tc);
			draw_text_add(_x0 + ui(28), _yy, "Gravity Source");
			
			if(amo > 1) {
				var bs = ui(24);
				var bx = _x1 - bs;
				var by = _yy - bs / 2;
				if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
					toDel = i;	
			}
		}
		
		if(toDel > -1) 
			deleteDynamicInput(toDel);
		
		return ui(32) + _h;
	});
	
	input_display_list = [  0, 
		[ "Object", false ],  1,  2,  5,
		[ "Path",   false ],  3,  4,
		new Inspector_Spacer(ui(6), true, false), 
		gravity_renderer,
	];
	
	input_display_dynamic = [ [ "Source", false ], 0, 1 ];
	
	setDynamicInput(2, false);
	if(!LOADING && !APPENDING) createNewInput();
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) {
		var _outPath = outputs[0].getValue();
		if(is(_outPath, Path)) _outPath.drawUI(_x, _y, _s);
		
		drawOverlayInput(inputs[ 1].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
		
		var _amo = getInputAmount();
		for( var i = 0; i < _amo; i++ ) {
			var _ind = input_fix_len + i * data_length;
			var _sel = dynamic_input_inspecting == noone || i == dynamic_input_inspecting;
			
			drawOverlayInput(inputs[_ind+0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, 2 - _sel));
		}
	}
	
	static update = function() {
		#region data
			var _seed = getInputData( 0);
			
			var _orig = getInputData( 1);
			var _velo = getInputData( 2);
			var _mass = getInputData( 5);
			
			var _len  = getInputData( 3);
			var _reso = getInputData( 4);
		#endregion
		
		var _amo = getInputAmount();
		var _src = array_create(_amo);
		
		for( var i = 0; i < _amo; i++ ) {
			var _ind  = input_fix_len + i * data_length;
			var _spos = getInputData(_ind+0);
			var _smas = getInputData(_ind+1);
			
			_src[i] = [ _spos, _smas ];
		}
		
		var _path = outputs[0].getValue();
		if(!is(_path, PathSegment)) 
			_path = new PathSegment();
		
		random_set_seed(_seed);
		var segment = [];
		var _stl = _len / _reso;
		var G    = 10 * _stl;
		
		var _px = _orig[0];
		var _py = _orig[1];
		
		var _vx = _velo[0];
		var _vy = _velo[1];
		
		array_push(segment, new __vec2(_px, _py))
		
		for( var i = 0; i < _reso; i++ ) {
			var _gx = 0;
			var _gy = 0;
			
			for( var j = 0; j < _amo; j++ ) {
				var src = _src[j];
				var sx  = src[0][0];
				var sy  = src[0][1];
				
				var _d = point_distance(_px, _py, sx, sy);
				var _g = G * _mass * src[1] / (_d * _d);
				
				_gx += (sx - _px) / _d * _g;
				_gy += (sy - _py) / _d * _g;
			}
			
			_vx += _gx;
			_vy += _gy;
			
			_px += _vx * _stl;
			_py += _vy * _stl;
			
			array_push(segment, new __vec2(_px, _py));
		}
		
		_path.setSegment(segment);
		
		outputs[0].setValue(_path);
	}
}
