#region create
	global.node_blend_keys = [ 
		"normal",  "add",     "subtract",   "multiply",   "screen", 
		"overlay", "hue",     "saturation", "luminosity", "maximum", 
		"minimum", "replace", "difference" 
	];
	
	function Node_create_Blend(_x, _y, _group = noone, _param = {}) {
		var node  = new Node_Blend(_x, _y, _group);
		var query = struct_try_get(_param, "query", "");
		
		var ind   = array_find(global.node_blend_keys, query);
		if(ind >= 0) node.inputs[| 2].setValue(ind);
		
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
#endregion

function Node_Blend(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blend";
	manage_atlas = false;
	
	inputs[| 0] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	inputs[| 1] = nodeValue("Foreground", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, BLEND_TYPES );
	
	inputs[| 3] = nodeValue("Opacity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 4] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 5] = nodeValue("Fill mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "None", "Stretch", "Tile" ]);
	
	inputs[| 6] = nodeValue("Output dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Background", "Forground", "Mask", "Maximum", "Constant" ])
		.rejectArray();
	
	inputs[| 7] = nodeValue("Constant dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 8] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 8;
		
	inputs[| 9] = nodeValue("Preserve alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
		
	inputs[| 10] = nodeValue("Horizontal Align", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ THEME.inspector_surface_halign, THEME.inspector_surface_halign, THEME.inspector_surface_halign]);
		
	inputs[| 11] = nodeValue("Vertical Align", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ THEME.inspector_surface_valign, THEME.inspector_surface_valign, THEME.inspector_surface_valign]);
	
	inputs[| 12] = nodeValue("Invert mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 13] = nodeValue("Mask feather", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
	
	inputs[| 14] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 8, 
		["Surfaces",	 true],	0, 1, 4, 12, 13, 6, 7,
		["Blend",		false], 2, 3, 9,
		["Transform",	false], 5, 14, 
	]
	
	attribute_surface_depth();
	
	temp_surface	   = [ surface_create(1, 1), surface_create(1, 1) ];
	blend_temp_surface = temp_surface[1];
	
	dragging = false;
	drag_sx  = 0;
	drag_sy  = 0;
	drag_mx  = 0;
	drag_my  = 0;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _surf = outputs[| 0].getValue();
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
			
			if(inputs[| 14].setValue([ px, py ]))
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
	
	static step = function() {
		var _back = getSingleValue(0);
		var _fore = getSingleValue(1);
		var _fill = getSingleValue(5);
		var _outp = getSingleValue(6);
		
		var _atlas  = is_instanceof(_fore, SurfaceAtlas);
		
		inputs[| 5].setVisible(!_atlas);
		inputs[| 6].editWidget.data_list = _atlas? [ "Background", "Forground" ] : [ "Background", "Forground", "Mask", "Maximum", "Constant" ];
		inputs[| 7].setVisible(_outp == 4);
		
		inputs[| 14].setVisible(_fill == 0 && !_atlas);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
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
			if(is_surface(_fore)) draw_surface_blend(_backDraw, _foreDraw, _type, _opacity, _pre_alp, _mask);
			else                  draw_surface_safe(_backDraw);
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
		
		return _outSurf;
	}
}