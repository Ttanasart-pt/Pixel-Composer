#region create
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_2D_Extrude", "Angle > Rotate CCW","R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[1].setValue((_n.inputs[1].getValue() + 90) % 360);    });
		addHotkey("Node_2D_Extrude", "Distance > Set", KEY_GROUP.numeric, 0, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[2].setValueDirect(toDecimal(KEYBOARD_NUMBER)); });
	});
#endregion

function Node_2D_Extrude(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "2D Extrude";
	
	////- =Surface
	newInput( 0, nodeValue_Surface(  "Surface In" ));
	newInput( 9, nodeValue_Surface(  "Mask"       ));
	
	////- =Extrude
	newInput( 1, nodeValue_Rotation( "Angle",       0             )).setPieMenu();
	newInput( 2, nodeValue_Float(    "Distance",   .5             )).setUnitSimple().setPieMenu();
	newInput( 8, nodeValue_Slider(   "Shift",       0, [-1,1,.01] )).setUnitSimple().setPieMenu();
	newInput( 7, nodeValue_Bool(     "Wrap",        false         ));
	newInput(18, nodeValue_EScroll(  "Depth Order", 0, [ "Minimum", "Maximum" ] ));
	
		////- =/Path
	newInput(15, nodeValue_Path(     "Path"                     ));
	newInput(16, nodeValue_Int(      "Path Resolution", 32      ));
	
	////- =Transform
	newInput(11, nodeValue_Anchor(   "Anchor"                          ));
	newInput(12, nodeValue_RotRange( "Rotation Modulate", [ 0, 0 ]     ));
	newInput(13, nodeValue_Curve(    "Scale Modulate",    CURVE_DEF_11 ));
	
	////- =Render
	newInput(21, nodeValue_Surface(  "Texture"                   ));
	newInput( 3, nodeValue_Gradient( "Color",         gra_white )).addShift(20).setHotkeyAuto("C").setPieMenu();
	newInput( 4, nodeValue_EScroll(  "Clone Color",    0, [ "None", "Multiply", "Additive" ] ));
	newInput(10, nodeValue_Range(    "Depth Range",   [0,1]      ));
	newInput(17, nodeValue_Bool(     "Draw Original", true       ));
	
	////- =Highlight
	newInput( 5, nodeValue_Bool(     "Highlight", false    ));
	newInput(14, nodeValue_Float(    "Width",     1        ));
	newInput( 6, nodeValue_Color(    "Color",     ca_white ));
	newInput(19, nodeValue_Slider(   "Intensity", 1        ));
	// 22
	
	newOutput( 0, nodeValue_Output( "Surface Out",  VALUE_TYPE.surface, noone )).setDrawGroup(0);
	newOutput( 1, nodeValue_Output( "Depth",        VALUE_TYPE.surface, noone )).setDrawGroup(0);
	newOutput( 2, nodeValue_Output( "Extrude Only", VALUE_TYPE.surface, noone ));
	newOutput( 3, nodeValue_Output( "Face Only",    VALUE_TYPE.surface, noone ));
	
	input_display_list = [
	    [ "Surface",   false    ],  0,  9, 
	    [ "Extrude",   false    ],  1,  2,  8,  7, 18, 
	    	[ "/Path", false    ], 15, 16, 
		[ "Transform", false    ], 11, 12, 13, 
	    [ "Render",    false    ], 21, [3, true], 20, -1,  4, 10, 17, 
	    [ "Highlight", false, 5 ], 14,  6, 19, 
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
			drawOverlayInput(inputs[15].drawOverlay( w_hoverable, active, _x, _y, _s, _mx, _my, _params ));
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
		draw_anchor(anchor_index, _ax, _ay, ui(8), 1);
		
		if(anchor_dragging) {
			var _dir = point_direction( _px, _py, _mx, _my);
			var _dis = point_distance(  _px, _py, _mx, _my) / _s;
			
			if(key_mod_press(SHIFT)) { _dir = value_snap(_dir, 15); _dis = round(_dis); }
			
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
		
		drawOverlayInput(inputs[11].drawOverlay( w_hoverable, active,  _x,  _y, _s, _mx, _my, 1, _dim ));
		drawOverlayInput(inputs[12].drawOverlay( w_hoverable, active, _ax, _ay, _s, _mx, _my          ));
		
		return _hov;
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
		    var _surf  = _data[ 0];
		    var _mask  = _data[ 9], _use_mask = is_surface(_mask);
		    
		    var _ang   = _data[ 1];
		    var _dist  = _data[ 2];
		    var _shft  = _data[ 8];
		    var _wrap  = _data[ 7];
		    var _depth = _data[18];
		    var _path  = _data[15];
		    var _pthr  = _data[16];
		    
			var _anch  = _data[11];
			var _rota  = _data[12];
			var _scal  = _data[13];
			
		    var _text  = _data[21];
		    var _grad  = _data[ 3];
		    var _grdS  = _data[20];
		    var _clne  = _data[ 4];
		    var _deth  = _data[10];
		    var _draw  = _data[17];
		    
		    var _high  = _data[ 5];
		    var _hgwd  = _data[14];
		    var _hgcl  = _data[ 6];
		    var _hgin  = _data[19];
		    
		    var _dim   = surface_get_dimension(_surf);
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
	    
	    temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_rgba16float);
	    
	    surface_set_shader(temp_surface[0], sh_2d_extrude);
	        shader_set_2( "dimension",  _dim     );
	        shader_set_s( "mask",       _mask     );
	        shader_set_i( "useMask",    _use_mask );
	        
			shader_set_f( "shift",       _shft / _dim[0] );
			shader_set_f( "angle",       degtorad(_ang)  );
			shader_set_f( "extDistance", _dist           );
			shader_set_i( "wrap",        _wrap           );
			
			shader_set_i( "useExpath",    _usePath );
			shader_set_f( "expathData",   _points  );
			shader_set_i( "expathSample", _pthr    );
			shader_set_i( "depthOrder",   _depth   );
			
			shader_set_2( "anchor",      _anch );
			shader_set_2( "rotations",   _rota );
			shader_set_curve( "scale",   _scal );
			
	        draw_surface_safe(_surf);
	    surface_reset_shader();
	    
	    surface_set_shader(_outData, sh_2d_extrude_apply);
	    	shader_set_2( "dimension",    _dim           );
	    	shader_set_s( "extrudeMap",   temp_surface[0] );
	    	shader_set_s( "mask",         _mask           );
	        shader_set_i( "useMask",      _use_mask       );
	        shader_set_i( "drawBase",     _draw           );
	        
	    	shader_set_2( "depth",        _deth  );
	    	shader_set_f( "angle",        degtorad(_ang)  );
			shader_set_f( "extDistance",  _dist           );
			shader_set_f( "shift",        _shft / _dim[0] );
			shader_set_i( "wrap",         _wrap           );
			
			shader_set_f( "gradient_shift", _grdS );
			_grad.shader_submit();
			
			shader_set_s( "texture",        _text             );
			shader_set_i( "useTexture",     is_surface(_text) );
			
			shader_set_i( "cloneColor",     _clne );
	        shader_set_i( "highlight",      _high );
	        shader_set_f( "highlightWidth", _hgwd );
	        shader_set_c( "highlightColor", _hgcl );
	        shader_set_f( "highlightInten", _hgin );
	        
	    	draw_surface_safe(_surf);
	    surface_reset_shader();
	    
	    return _outData; 
	}
}