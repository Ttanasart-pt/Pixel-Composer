#region create
	global.node_plot_linear_keys = [ "plot", "bar chart", "graph", "waveform" ];
	
	function Node_create_Plot_Linear(_x, _y, _group = noone, _param = {}) {
		var node  = new Node_Plot_Linear(_x, _y, _group);
		node.skipDefault();
	
		var query = struct_try_get(_param, "query", "");
		
		switch(query) {
			case "waveform" : 
			case "graph" : 
				node.inputs[11].skipDefault().setValue(1); 
				break;
		}
		
		return node;
	}
	
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Plot_Linear", "Type > Toggle", "T", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[11].setValue((_n.inputs[11].getValue() + 1) % 2); });
	});
#endregion

function Node_Plot_Linear(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Bar / Graph";
	
	newInput(0, nodeValue_Dimension());
	
	////- =Data
	newInput( 1, nodeValue_Float(    "Data",              []                           )).setArrayDepth(1).setVisible(true, true);
	newInput(12, nodeValue_Float(    "Value Offset",      0                            ));
	newInput(21, nodeValue_Bool(     "Flip Value",        false                        ));
	newInput(14, nodeValue_EScroll(  "Trim mode",         0, [ "Range", "Window" ]     ));
	newInput( 2, nodeValue_Slider_Range( "Range",        [0,1]                         ));
	newInput( 3, nodeValue_Float(    "Sample frequency",  1                            ));
	newInput(15, nodeValue_Int(      "Window Size",       8                            ));
	newInput(16, nodeValue_Float(    "Window Offset",     0                            ));
	
	////- =Plot
	newInput(11, nodeValue_EScroll(  "Type",              0, __enum_array_gen([ "Bar chart", "Graph"], s_node_plot_linear_type)));
	newInput( 4, nodeValue_Vec2(     "Origin",          [ 0,.5 ] )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(10, nodeValue_Rotation( "Direction",         0      ));
	newInput(20, nodeValue_PathNode( "Path"                      ));
	newInput( 5, nodeValue_Float(    "Scale",             .5     )).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput(22, nodeValue_Bool(     "Loop",              false  ));
	newInput(23, nodeValue_Slider(   "Smooth",            0      ));
	
	////- =Shape
	newInput( 7, nodeValue_Float(    "Graph Thickness",   1      ));
	newInput(18, nodeValue_Float(    "Bar Width",         4      ));
	newInput(17, nodeValue_Float(    "Spacing",           1      ));
	newInput(19, nodeValue_Bool(     "Rounded Bar",       false  ));
	
	////- =Color
	b_setRange = button(function() /*=>*/ {setDataRange()}).setIcon(THEME.value_range, 1, COLORS._main_icon).iconPad().setTooltip(__txt("Use data range"));
	
	newInput( 6, nodeValue_Color(    "Base Color",        ca_white                     ));
	newInput(13, nodeValue_Gradient( "Color Over Sample", new gradientObject(ca_white) )).setMappable(27);
	newInput(24, nodeValue_Gradient( "Color Over Value",  new gradientObject(ca_white) )).setMappable(29);
	newInput(25, nodeValue_Range(    "Value range",      [0,1]                         )).setSideButton(b_setRange);
	newInput(26, nodeValue_Bool(     "Absolute",         false, "Use absolute value to calculate color." ));
	
	////- =Background
	newInput( 8, nodeValue_Bool(     "Background",        false    ));
	newInput( 9, nodeValue_Color(    "Background Color",  ca_black ));
	// inputs 31
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Data", 	    true    ],  1, 12, 21, 14,  2,  3, 15, 16, 
		[ "Plot",	   false    ], 11,  4, 10, 20,  5, 22, 23, 
		[ "Shape",	   false    ],  7, 18, 17, 19, 
		[ "Color",	   false    ],  6, 13, 27, 24, 29, 25, 26, 
		[ "Background",	true, 8 ],  9, 
	];
	
	////- Nodes
	
	attribute_surface_depth();
	
	static setDataRange = function() {
		var _data = getInputData(1);
		var _minn =  infinity;
		var _maxx = -infinity;
		if(!is_array(_data) || array_empty(_data)) return;
		
		for( var i = 0, n = array_length(_data); i < n; i++ ) {
			var _d = _data[i];
			if(!is_numeric(_d)) continue;
			
			_minn = min(_minn, _d);
			_maxx = max(_maxx, _d);
		}
		
		inputs[25].setValue([_minn, _maxx]);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _use_path = current_data[20] != noone;
		if(!_use_path) InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		InputDrawOverlay(inputs[20].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		InputDrawOverlay(inputs[28].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, current_data[0]));
		InputDrawOverlay(inputs[30].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, current_data[0]));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _dim  = _data[ 0];
			
			var _dat  = _data[ 1];
			var _off  = _data[12];
			var _flip = _data[21];
			var _trim = _data[14];
			var _ran  = _data[ 2];
			var _samp = _data[ 3]; _samp = max(1,  _samp);
			var _wsiz = _data[15];
			var _woff = _data[16]; _woff = max(0, _woff);
			
			var _typ  = _data[11];
			var _ori  = _data[ 4];
			var _ang  = _data[10];
			var _path = _data[20];
			var _amp  = _data[ 5];
			var _loop = _data[22];
			var _smt  = _data[23];
			
			var _lineth   = _data[ 7];
			var _bar_wid  = _data[18];
			var _bar_rnd  = _data[19];
			var _pnt_spac = _data[17];
			
			var _lcl     = _data[ 6];
			var _cls     = _data[13], _cls_map = _data[27], _cls_rng = _data[28];
			var _clv     = _data[24], _clv_map = _data[29], _clv_rng = _data[30];
			var _clv_r   = _data[25];
			var _clv_a   = _data[26];
			
			var _ubg = _data[ 8];
			var _bgc = _data[ 9];
			
			var _use_path = _path != noone;
			
			inputs[ 2].setVisible(_trim == 0);
			inputs[15].setVisible(_trim == 1);
			inputs[16].setVisible(_trim == 1);
			
			inputs[ 9].setVisible(_ubg);
			inputs[ 7].setVisible(_typ == 1);
			inputs[18].setVisible(_typ == 0);
			inputs[19].setVisible(_typ == 0);
			inputs[22].setVisible(_typ == 1);
			inputs[23].setVisible(_typ == 1);
			
			inputs[ 4].setVisible(!_use_path);
			inputs[10].setVisible(!_use_path);
		#endregion
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_target(_outSurf);
			if(_ubg) draw_clear(_bgc);
			else	 DRAW_CLEAR
			
			var _len = array_length(_dat);
			var _st  = clamp(_ran[0], 0, 1) * _len;
			var _ed  = clamp(_ran[1], 0, 1) * _len;
			var ox, oy, nx, ny, fx, fy;
			
			if(_typ == 1)
				draw_set_circle_precision(4);
			
			var _dat_amo = array_length(_dat);
			var _smp_data = [];
			var _ind = 0;
			
			if(_trim == 0) {
				for( var i = _st; i < _ed; i += _samp )
					_smp_data[_ind++] = _dat[i];
					
			} else if(_trim == 1) {
				for( var i = 0; i < _wsiz; i++ ) {
					_ind = _woff + i *  _samp;
					
					if(_ind >= _dat_amo) break;
					if(frac(_ind) != 0 && floor(_ind) + 1 < _dat_amo)
						_smp_data[i] = lerp(_dat[floor(_ind)], _dat[floor(_ind) + 1], frac(_ind));
					else
						_smp_data[i] = _dat[_ind];
					
					if(_flip)
						_smp_data[i] = -_smp_data[i];
				}
			}
			
			var amo = array_length(_smp_data);
			var _px, _py, _ang_nor, _val, _col_sam, _col_val;
			var _pnt, _ppnt = undefined;
			var _bar_spc = _typ == 1? _pnt_spac + 1 : _pnt_spac + _bar_wid;
			var _oc;
			
			for( var i = 0; i < amo; i++ ) {
				if(_use_path) {
					_pnt    = _path.getPointRatio(i / amo);
					_ppnt ??= _path.getPointRatio(i / amo - 0.001);
					
					_px = _pnt.x;
					_py = _pnt.y;
					_ang = point_direction(_ppnt.x, _ppnt.y, _pnt.x, _pnt.y)
					
					_ppnt = _pnt;
					
				} else {
					_px = _ori[0] + lengthdir_x(i * _bar_spc, _ang);
					_py = _ori[1] + lengthdir_y(i * _bar_spc, _ang);
				}
				
				_ang_nor = _ang + 90;
				_val	 = _smp_data[i] + _off;
				_col_sam = evaluate_gradient_map(i / amo, _cls, _cls_map, _cls_rng, inputs[13]);
				
				var _val_p = _clv_a? abs(_val) : _val;
				var _val_prog = (_val_p - _clv_r[0]) / (_clv_r[1] - _clv_r[0]);
				_col_val = evaluate_gradient_map(_val_prog, _clv, _clv_map, _clv_rng, inputs[24]);
				
				var _c1 = colorMultiply(_lcl, _col_sam);
				var _c2 = _col_val;
				var _col_final = colorMultiply(_c1, _c2);
				
				draw_set_color(_col_final);
				
				nx = _px + lengthdir_x(_amp * _val, _ang_nor);
				ny = _py + lengthdir_y(_amp * _val, _ang_nor);
				
				switch(_typ) {
					case 0 :
						if(_bar_rnd) draw_line_round(_px, _py, nx, ny, _bar_wid);
						else		 draw_line_width(_px, _py, nx, ny, _bar_wid);
						break;
					case 1 :
						if(i > _st) {
							if(_smt > 0) {
								var dist = dot_product(nx - ox, ny - oy, lengthdir_x(1, _ang), lengthdir_y(1, _ang));
								var _b0x = ox + lengthdir_x(dist * _smt, _ang);
								var _b0y = oy + lengthdir_y(dist * _smt, _ang);
								var _b1x = nx + lengthdir_x(dist * _smt, _ang + 180);
								var _b1y = ny + lengthdir_y(dist * _smt, _ang + 180);
								
								var _ox = ox, _oy = oy, _nx, _ny;
								
								for( var j = 1; j <= 8; j++ ) {
									var _t  = 1 - j / 8;
									_nx = ox * power(_t, 3) + 3 * _b0x * power(_t, 2) * (1 - _t) + 3 * _b1x * (_t) * power(1 - _t, 2) + nx * power(1 - _t, 3);
									_ny = oy * power(_t, 3) + 3 * _b0y * power(_t, 2) * (1 - _t) + 3 * _b1y * (_t) * power(1 - _t, 2) + ny * power(1 - _t, 3);
									
									if(_lineth > 1) draw_line_round(_ox, _oy, _nx, _ny, _lineth);
									else		 draw_line(_ox, _oy, _nx, _ny);
									
									_ox = _nx;
									_oy = _ny;
								}
							} else {
								if(_lineth > 1) draw_line_round_color(ox, oy, nx, ny, _lineth, _oc, _col_final);
								else		 draw_line_color(ox, oy, nx, ny, _oc, _col_final);
							}
						}
						break;
				}
				
				ox = nx;
				oy = ny;
				_oc = _col_final;
				
				if(i == 0) {
					fx = nx;
					fy = ny;
				}
			}
			
			if(_loop && amo > 1 && _typ == 1)
				draw_line_round(fx, fy, nx, ny, _lineth);
			
			draw_set_circle_precision(64);
		surface_reset_target();
		return _outSurf;
	}
}