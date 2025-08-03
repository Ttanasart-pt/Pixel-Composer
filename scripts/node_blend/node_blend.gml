#region create
	function Node_create_Blend(_x, _y, _group = noone, _param = {}) {
		var node = new Node_Blend(_x, _y, _group);
		node.skipDefault();
		
		var query = struct_try_get(_param, "query", "");
		var ind   = array_find(global.node_blend_keys, query);
		if(ind >= 0) node.inputs[2].setValue(ind);
		return node;
	}
	
	enum NODE_BLEND_OUTPUT {
		background,
		foreground,
		mask,
		maximum,
		constant
	}
	
	enum NODE_BLEND_FILL {
		none,
		stretch,
		tile
	}
	
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Blend", "Blend mode > Multiply",  "M", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue(array_find(BLEND_TYPES, "Multiply")); });
        addHotkey("Node_Blend", "Blend mode > Add",       "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue(array_find(BLEND_TYPES, "Add"));      });
        addHotkey("Node_Blend", "Blend mode > Screen",    "C", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue(array_find(BLEND_TYPES, "Screen"));   });
        addHotkey("Node_Blend", "Blend mode > Subtract",  "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue(array_find(BLEND_TYPES, "Subtract")); });
        addHotkey("Node_Blend", "Preserve alpha > Toggle","P", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[9].setValue(!_n.inputs[9].getValue()); });
        
        addHotkey("Node_Blend", "Inputs > Swap", "Q", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS 
        	var _i0 = _n.inputs[0].value_from;
        	var _i1 = _n.inputs[1].value_from;
        	if(_i0 == _i1) return;
        	
        	_n.inputs[1].setFrom(_i0);
        	_n.inputs[0].setFrom(_i1);
        });
	});
	
#endregion

function Node_Blend(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blend";
	manage_atlas = false;
	
	newActiveInput(8);
	
	////- =Surfaces
	
	newInput( 0, nodeValue_Surface(     "Background" ));
	newInput( 1, nodeValue_Surface(     "Foreground" ));
	newInput( 4, nodeValue_Surface(     "Mask" ));
	newInput(12, nodeValue_Bool(        "Invert mask",        false ));
	newInput(13, nodeValue_Slider(      "Mask feather",       1, [1, 16, 0.1] ));
	newInput( 6, nodeValue_Enum_Scroll( "Output dimension",   0, [ "Background", "Forground", "Mask", "Maximum", "Constant" ])).rejectArray();
	newInput( 7, nodeValue_Vec2(        "Constant dimension", DEF_SURF ));
	
	////- =Blend
	
	newInput(2, nodeValue_Enum_Scroll( "Blend mode",     0, BLEND_TYPES ))
		.setHistory([ BLEND_TYPES, { cond: function() /*=>*/ {return LOADING_VERSION < 1_18_00_0}, list: global.BLEND_TYPES_18 } ]);
	
	newInput(3, nodeValue_Slider(      "Opacity",        1 ));
	newInput(9, nodeValue_Bool(        "Preserve alpha", false));
	
	////- =Transform
	
	newInput( 5, nodeValue_Enum_Scroll( "Fill mode",         0, [ "None", "Stretch", "Tile" ]));
	newInput(14, nodeValue_Vec2(        "Position",        [.5,.5] ));
	newInput(10, nodeValue_Enum_Button( "Horizontal Align",  0, array_create(3, THEME.inspector_surface_halign)));
	newInput(11, nodeValue_Enum_Button( "Vertical Align",    0, array_create(3, THEME.inspector_surface_valign)));
	
	//- inputs 15
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 8, 
		["Surfaces",   true], 0, 1, 4, 12, 13, 6, 7,
		["Blend",     false], 2, 3, 9,
		["Transform", false], 5, 14, 
	]
	
	////- Nodes
	
	attribute_surface_depth();
	
	temp_surface	   = [ surface_create(1, 1), surface_create(1, 1) ];
	blend_temp_surface = temp_surface[1];
	
	dragging = false;
	drag_sx  = 0;
	drag_sy  = 0;
	drag_mx  = 0;
	drag_my  = 0;
	
	fg_transforms = [];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _surf = outputs[0].getValue();
		if(is_array(_surf)) _surf = array_safe_get_fast(_surf, preview_index);
		if(is_struct(_surf)) return;
		if(!surface_exists(_surf)) return;
		
		var _fore = getSingleValue( 1);
		var _fill = getSingleValue( 5);
		var _posi = getSingleValue(14);
		if(_fill) return;
		
		var sw = surface_get_width_safe( _surf);
		var sh = surface_get_height_safe(_surf);
		var fw = surface_get_width_safe( _fore);
		var fh = surface_get_height_safe(_fore);
		
		var _rx = _posi[0] * sw - fw / 2;
		var _ry = _posi[1] * sh - fh / 2;
		    _rx = _x + _rx * _s;
			_ry = _y + _ry * _s;
		var _rw = fw * _s;
		var _rh = fh * _s;
		
		if(dragging) {
			var px = drag_sx + (_mx - drag_mx) / _s;
			var py = drag_sy + (_my - drag_my) / _s;
			
			px /= sw;
			py /= sh;
			
			if(inputs[14].setValue([ px, py ]))
				UNDO_HOLDING = true;
			
			if(mouse_release(mb_left)) {
				UNDO_HOLDING = false;
				dragging     = false;
			}
		} 
		
		draw_set_color(COLORS._main_accent);
		if(dragging || (active && point_in_rectangle(_mx, _my, _rx, _ry, _rx + _rw, _ry + _rh))) {
			draw_rectangle_width(_rx, _ry, _rx + _rw, _ry + _rh, 2);
			
			if(mouse_press(mb_left)) {
				dragging = true;
				drag_sx  = _posi[0] * sw;
				drag_sy  = _posi[1] * sh;
				drag_mx  = _mx;
				drag_my  = _my;
			}
		} else 
			draw_rectangle(_rx, _ry, _rx + _rw, _ry + _rh, true);
	}
	
	static drawOverlayTransform = function(_node) { 
		if(_node == inputs[1].getNodeFrom())
			return array_safe_get(fg_transforms, preview_index, noone);
		return noone;
	}
	
	static processData_prebatch  = function() {
		var _back = getSingleValue(0);
		var _fore = getSingleValue(1);
		var _fill = getSingleValue(5);
		var _outp = getSingleValue(6);
		
		var _atlas  = is_instanceof(_fore, SurfaceAtlas);
		
		inputs[5].setVisible(!_atlas);
		inputs[6].editWidget.data_list = _atlas? [ "Background", "Forground" ] : [ "Background", "Forground", "Mask", "Maximum", "Constant" ];
		inputs[7].setVisible(_outp == 4);
		
		inputs[14].setVisible(_fill == 0 && !_atlas);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _back	 = _data[0];
		var _fore	 = _data[1];
		var _type	 = _data[2];
		var _opacity = _data[3];
		var _mask	 = _data[4];
		var _fill	 = _data[5];
		
		var _outp	 = _data[6];
		var _out_dim = _data[7];
		var _pre_alp = _data[9];
		
		var _halign = _data[10];
		var _valign = _data[11];
		var _posit  = _data[14];
		
		var _mskInv = _data[12];
		var _mskFea = _data[13];
		
		var cDep    = attrDepth();
		
		#region dimension
			var ww = 1;
			var hh = 1;
			var _atlas  = is_instanceof(_fore, SurfaceAtlas);
		
			switch(_outp) {
				case NODE_BLEND_OUTPUT.background :
					ww = surface_get_width_safe(_back);
					hh = surface_get_height_safe(_back);
					break;
					
				case NODE_BLEND_OUTPUT.foreground :
					ww = surface_get_width_safe(_fore);
					hh = surface_get_height_safe(_fore);
					break;
					
				case NODE_BLEND_OUTPUT.mask :
					ww = surface_get_width_safe(_mask);
					hh = surface_get_height_safe(_mask);
					break;
					
				case NODE_BLEND_OUTPUT.maximum :
					ww = max(surface_get_width_safe(_back),  surface_get_width_safe(_fore),  surface_get_width_safe(_mask));
					hh = max(surface_get_height_safe(_back), surface_get_height_safe(_fore), surface_get_height_safe(_mask));
					break;
					
				case NODE_BLEND_OUTPUT.constant :
					ww = _out_dim[0];
					hh = _out_dim[1];
					break;
			}
		#endregion
		
		for( var i = 0; i < 2; i++ ) temp_surface[i] = surface_verify(temp_surface[i], ww, hh, cDep);
		
		var _backDraw = temp_surface[0];
		var _foreDraw = temp_surface[1];
		fg_transforms[_array_index] = [ 0, 0, 1 ];
		
		surface_set_shader(_backDraw, noone,, BLEND.over);
			draw_surface_safe(_back);
		surface_reset_shader();
		
		if(_fill == NODE_BLEND_FILL.none || _atlas) {
			
			if(_atlas) {
				if(_outp == NODE_BLEND_OUTPUT.background) {
					surface_set_shader(_foreDraw, noone,, BLEND.over);
						draw_surface_safe(_fore.getSurface(), _fore.x, _fore.y);
					surface_reset_shader();
					
					_backDraw = _back;
					
				} else if(_outp == NODE_BLEND_OUTPUT.foreground) {
					surface_set_shader(_foreDraw, noone,, BLEND.over);
						draw_surface_safe(_fore);
					surface_reset_shader();
					
					surface_set_shader(_backDraw, noone,, BLEND.over);
						draw_surface_safe(_back, -_fore.x, -_fore.y);
					surface_reset_shader();
				}
				
			} else if(is_surface(_fore)) {
				var sx = 0;
				var sy = 0;
			
				var fw = surface_get_width_safe(_fore);
				var fh = surface_get_height_safe(_fore);
			
				var px = _posit[0] * ww;
				var py = _posit[1] * hh;
				
				surface_set_shader(_foreDraw, noone,, BLEND.over);
					draw_surface_safe(_fore, px - fw / 2, py - fh / 2);
				surface_reset_shader();
				
				fg_transforms[_array_index] = [ px - fw / 2, py - fh / 2, 1, 1, 0 ];
				_backDraw = _back;
			}
			
		} else if(_fill == NODE_BLEND_FILL.stretch) {
			surface_set_shader(_foreDraw, noone,, BLEND.over);
				draw_surface_stretched_safe(_fore, 0, 0, ww, hh);
			surface_reset_shader();
			
		} else if(_fill == NODE_BLEND_FILL.tile) {
			surface_set_shader(_foreDraw, noone,, BLEND.over);
				draw_surface_tiled_safe(_fore);
			surface_reset_shader();
		}
		
		var _osurf  = is_instanceof(_outSurf, SurfaceAtlas)? _outSurf.surface.surface : _outSurf;
		var _output = surface_verify(_osurf, ww, hh, cDep);
		
		_mask = mask_modify(_mask, _mskInv, _mskFea);
		
		surface_set_shader(_output, noone);
			if(!is_surface(_fore)) draw_surface_safe(_backDraw);
			else {
				try { draw_surface_blend(_backDraw, _foreDraw, _type, _opacity, _pre_alp, _mask); }
				catch(e) { noti_warning(e, noone, self); }
			}
		surface_reset_shader();
		
		if(_atlas) {
			var _newAtl = _fore.clone();
			
			if(_outp == NODE_BLEND_OUTPUT.background) {
				_newAtl.x = 0;
				_newAtl.y = 0;
			}
			
			_newAtl.setSurface(_output);
			return _newAtl;
		}
		
		if(is_instanceof(_outSurf, SurfaceAtlas)) _outSurf.surface.surface = _output;
		else _outSurf = _output;
		
		return _outSurf;
	}

}