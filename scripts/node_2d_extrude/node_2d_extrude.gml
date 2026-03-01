function Node_2D_Extrude(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "2D Extrude";
	
	////- =Surface
	newInput( 0, nodeValue_Surface(  "Surface In" ));
	newInput( 9, nodeValue_Surface(  "Mask"       ));
	
	////- =Extrude
	newInput( 1, nodeValue_Rotation( "Angle",     0             ));
	newInput( 2, nodeValue_Float(    "Distance", .5             )).setUnitSimple();
	newInput( 8, nodeValue_Slider(   "Shift",     0, [-1,1,.01] )).setUnitSimple();
	newInput( 7, nodeValue_Bool(     "Wrap",      false         ));
	newInput(15, nodeValue_PathNode( "Path"                     ));
	newInput(16, nodeValue_Int(      "Path Resolution", 32      ));
	
	////- =Transform
	newInput(11, nodeValue_Anchor(   "Anchor"                          ));
	newInput(12, nodeValue_RotRange( "Rotation Modulate", [ 0, 0 ]     ));
	newInput(13, nodeValue_Curve(    "Scale Modulate",    CURVE_DEF_11 ));
	
	////- =Render
	newInput( 3, nodeValue_Gradient(    "Color",        gra_white          ));
	newInput( 4, nodeValue_Enum_Scroll( "Clone Color",  0, [ "None", "Multiply", "Additive" ] ));
	newInput(10, nodeValue_Range(       "Depth Range", [0,1]  ));
	
	////- =Highlight
	newInput( 5, nodeValue_Bool(  "Highlight",       false    ));
	newInput(14, nodeValue_Float( "Highlight Width", 1        ));
	newInput( 6, nodeValue_Color( "Highlight Color", ca_white ));
	// input 17
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone)).setDrawGroup(0);
	newOutput(1, nodeValue_Output("Depth",       VALUE_TYPE.surface, noone)).setDrawGroup(0);
	
	input_display_list = [
	    [ "Surface",   false    ],  0,  9, 
	    [ "Extrude",   false    ],  1,  2,  8,  7, 15, 16, 
		[ "Transform", false    ], 11, 12, 13, 
	    [ "Render",    false    ],  3,  4, 10, 
	    [ "Highlight", false, 5 ], 14,  6, 
    ];
	
    ////- Nodes
	
	temp_surface    = [ 0 ];
	anchor_index    = 0;
	anchor_dragging = false;
	anchor_drag_mx  = 0;
	anchor_drag_my  = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _path = getInputSingle(15);
		if(is_path(_path)) {
			InputDrawOverlay(inputs[15].drawOverlay( w_hoverable, active, _x, _y, _s, _mx, _my, _params ));
			return;
		}
		
		var _dim = getDimension();
		var _px  = _x + _dim[0] / 2 * _s;
		var _py  = _y + _dim[1] / 2 * _s;
		
		var _ang  = getInputSingle( 1);
		var _dist = getInputSingle( 2);
		
		var _dx = lengthdir_x(_dist, _ang) * _s;
		var _dy = lengthdir_y(_dist, _ang) * _s;
		
		var _ax = _px + _dx;
		var _ay = _py + _dy;
		
		var _hov = hover && point_in_circle(_mx, _my, _ax, _ay, ui(8));
		anchor_index = lerp_float(anchor_index, _hov || anchor_dragging, 5);
		
		draw_set_color(COLORS._main_accent);
		draw_circle(_px, _py, ui(4), false);
		draw_line_dashed(_px, _py, _ax, _ay);
		draw_sprite_ui(THEME.arrow4_24, 0, _ax, _ay, 1, 1, 0, COLORS._main_accent);
		draw_anchor(anchor_index, _ax, _ay, ui(10), 1);
		
		if(anchor_dragging) {
			var _dir = point_direction( _px, _py, _mx, _my);
			var _dis = point_distance(  _px, _py, _mx, _my) / _s;
			
			if(key_mod_press(CTRL)) {
				_dir = value_snap(_dir, 15);
				_dis = round(_dis);
			}
			
			var h1 = inputs[1].setValue(_dir);
			var h2 = inputs[2].setValue(_dis);
			
			if(h1 || h2) UNDO_HOLDING = true;
			
			if(mouse_lrelease()) {
				anchor_dragging = false;
				UNDO_HOLDING    = false;
			}
		}
		
		if(mouse_lpress(_hov)) {
			anchor_dragging = true;
			anchor_drag_mx  = _mx;
			anchor_drag_my  = _my;
		}
		
		InputDrawOverlay(inputs[11].drawOverlay( w_hoverable, active,  _x,  _y, _s, _mx, _my, 1, _dim ));
		InputDrawOverlay(inputs[12].drawOverlay( w_hoverable, active, _ax, _ay, _s, _mx, _my          ));
		
		return _hov;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
		    var _surf = _data[ 0];
		    var _mask = _data[ 9], _use_mask = is_surface(_mask);
		    
		    var _ang  = _data[ 1];
		    var _dist = _data[ 2];
		    var _shft = _data[ 8];
		    var _wrap = _data[ 7];
		    var _path = _data[15];
		    var _pthr = _data[16];
		    
			var _anch = _data[11];
			var _rota = _data[12];
			var _scal = _data[13];
			
		    var _grad = _data[ 3];
		    var _clne = _data[ 4];
		    var _deth = _data[10];
		    
		    var _high = _data[ 5];
		    var _hgwd = _data[14];
		    var _hgcl = _data[ 6];
		    
		    var _dim  = surface_get_dimension(_surf);
	    #endregion
	    
	    var _usePath = is_path(_path);
	    var _points  = [];
	    if(_usePath) {
	    	_points = array_create((_pthr + 1) * 2);
			var _astep = 1 / _pthr;
			var _prg   = 0;
			var _p     = new __vec2P();
			var i = 0;
			
			_p    = _path.getPointRatio(0, 0, _p);
			var ofx = _p.x;
			var ofy = _p.y;
			
			repeat(_pthr + 1) {
				_p    = _path.getPointRatio(_prg, 0, _p);
				_prg += _astep;
				
				_points[i++] = (_p.x - ofx) / _dim[0];
				_points[i++] = (_p.y - ofy) / _dim[1];
			}
	    }
	    
	    temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_r16float);
	    
	    surface_set_shader(temp_surface[0], sh_2d_extrude);
	        shader_set_dim( "dimension",  _surf     );
	        shader_set_s(   "mask",       _mask     );
	        shader_set_i(   "useMask",    _use_mask );
	        
			shader_set_f(   "shift",       _shft / _dim[0] );
			shader_set_f(   "angle",       degtorad(_ang)  );
			shader_set_f(   "extDistance", _dist           );
			shader_set_i(   "wrap",        _wrap           );
			
			shader_set_i( "useExpath",    _usePath );
			shader_set_f( "expathData",   _points  );
			shader_set_i( "expathSample", _pthr    );
			
			shader_set_2( "anchor",      _anch );
			shader_set_2( "rotations",   _rota );
			shader_set_curve( "scale",   _scal );
			
	        draw_surface_safe(_surf);
	    surface_reset_shader();
	    
	    surface_set_shader(_outData, sh_2d_extrude_apply);
	    	shader_set_dim( "dimension",    _surf           );
	    	shader_set_s(   "extrudeMap",   temp_surface[0] );
	    	shader_set_s(   "mask",         _mask           );
	        shader_set_i(   "useMask",      _use_mask       );
	        
	    	shader_set_2(   "depth",        _deth  );
	    	shader_set_f(   "angle",        degtorad(_ang)  );
			shader_set_f(   "extDistance",  _dist           );
			shader_set_f(   "shift",        _shft / _dim[0] );
			shader_set_i(   "wrap",         _wrap           );
			
			_grad.shader_submit();
			shader_set_i( "cloneColor",     _clne );
	        shader_set_i( "highlight",      _high );
	        shader_set_f( "highlightWidth", _hgwd );
	        shader_set_c( "highlightColor", _hgcl );
	        
	    	draw_surface_safe(_surf);
	    surface_reset_shader();
	    
	    return _outData; 
	}
}