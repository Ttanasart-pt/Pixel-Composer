#region create
	global.node_shape_keys = [ 
		"rectangle", "square", "diamond", "trapezoid", "parallelogram", "half", 
		"circle", "ellipse", "arc", "donut", "crescent", "ring", "squircle", 
		"regular polygon", "triangle", "pentagon", "hexagon", "star", "cross", 
		"line", "arrow", 
		"teardrop", "leaf", "heart", "gear", 
	];

	function Node_create_Shape(_x, _y, _group = noone, _param = {}) {
		var query = struct_try_get(_param, "query", "");
		var node  = new Node_Shape(_x, _y, _group);
		node.skipDefault();
		
		var ind   = -1;
		
		switch(query) {
			case "square" :   ind = array_find_string(node.shape_types, "rectangle");	break;
			case "circle" :   ind = array_find_string(node.shape_types, "ellipse"); 	break;
			case "ring" :     ind = array_find_string(node.shape_types, "donut");		break;
			case "triangle" : ind = array_find_string(node.shape_types, "regular polygon"); node.inputs[4].setValue(3); break;
			case "pentagon" : ind = array_find_string(node.shape_types, "regular polygon"); node.inputs[4].setValue(5); break;
			case "hexagon" :  ind = array_find_string(node.shape_types, "regular polygon"); node.inputs[4].setValue(6); break;
			
			default : ind = array_find_string(node.shape_types, query);
		}
		
		if(ind >= 0) node.inputs[2].setValue(ind);
		
		return node;
	}
	
	function __Node_Shape_Hotkeys_set_shape(_n, _key) { _n.inputs[2].setValue(array_find(_n.shape_types, _key)); }
	
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Shape", "Shape > Rectangle",       "R", 0, function() /*=>*/ { GRAPH_FOCUS __Node_Shape_Hotkeys_set_shape(_n, "Rectangle");       });
		addHotkey("Node_Shape", "Shape > Ellipse",         "E", 0, function() /*=>*/ { GRAPH_FOCUS __Node_Shape_Hotkeys_set_shape(_n, "Ellipse");         });
		addHotkey("Node_Shape", "Shape > Regular polygon", "P", 0, function() /*=>*/ { GRAPH_FOCUS __Node_Shape_Hotkeys_set_shape(_n, "Regular polygon"); });
		addHotkey("Node_Shape", "Shape > Star",            "S", 0, function() /*=>*/ { GRAPH_FOCUS __Node_Shape_Hotkeys_set_shape(_n, "Star");            });
		addHotkey("Node_Shape", "Anti-aliasing > Toggle",  "A", 0, function() /*=>*/ { GRAPH_FOCUS var i=_n.inputs[ 6]; i.setValue(!i.getValue());        });
		addHotkey("Node_Shape", "Height Render > Toggle",  "H", 0, function() /*=>*/ { GRAPH_FOCUS var i=_n.inputs[12]; i.setValue(!i.getValue());        });
		addHotkey("Node_Shape", "Background > Toggle",     "B", 0, function() /*=>*/ { GRAPH_FOCUS var i=_n.inputs[ 1]; i.setValue(!i.getValue());        });
		addHotkey("Node_Shape", "Dimension > Set",         KEY_GROUP.numeric, 0, function() /*=>*/ { GRAPH_FOCUS_NUMBER _n.inputs[0].setValue([KEYBOARD_NUMBER,KEYBOARD_NUMBER]); });
	});
	
#endregion

function Node_Shape(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name   = "Draw Shape";
	inputs = array_create(38);
	
	onSurfaceSize = function() /*=>*/ {return getInputData(0, DEF_SURF)};
	
	////- Output
	
	newInput(0, nodeValue_Dimension(self));
	newInput(6, nodeValue_Bool("Anti-aliasing", self, false));
	
	////- Transform
	
	newInput(15, nodeValue_Enum_Scroll( "Positioning Mode", self,  2, [ "Area", "Center + Scale", "Full Image" ]))
	newInput( 3, nodeValue_Area(        "Position",         self, DEF_AREA_REF, { onSurfaceSize, useShape : false })).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(16, nodeValue_Vec2(        "Center",           self, [ .5, .5 ] )).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(17, nodeValue_Vec2(        "Half Size",        self, [ .5, .5 ] )).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(19, nodeValue_Rotation(    "Shape rotation",   self, 0));
	newInput(28, nodeValue_Slider(      "Shape Scale",      self, 1));
	
	////- Shape
	
	shape_types = [ 
		    "Rectangle", "Diamond", "Trapezoid", "Parallelogram", "Half", 
		-1, "Ellipse", "Arc", "Donut", "Crescent", "Disk Segment", "Pie", "Squircle", 
		-1, "Regular polygon", "Star", "Cross", "Rounded Cross",  
		-1, "Line", "Arrow", 
		-1, "Teardrop", "Leaf", "Heart", "Gear", 
	];
	__ind = 0; shape_types_str = array_map(shape_types, function(v, i) /*=>*/ {return v == -1? -1 : new scrollItem(v, s_node_shape_type, __ind++)});
	
	newInput( 2, nodeValue_Enum_Scroll(    "Shape", self,  0, { data: shape_types_str, horizontal: true, text_pad: ui(16) }))
		.setHistory([ shape_types, { cond: function() /*=>*/ {return LOADING_VERSION < 1_18_00_0}, list: global.node_shape_keys_18 } ]);
	newInput(32, nodeValue_Vec2(   "Point 1",   self, [ 0, 0 ])).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(33, nodeValue_Vec2(   "Point 2",   self, [ 1, 1 ])).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(35, nodeValue_Vec2(   "Point 3",   self, [ 1, 0 ])).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(34, nodeValue_Slider( "Thickness", self, 0.1));
	
	newInput( 9, nodeValue_Slider(         "Corner radius",  self, 0, { range: [0, 0.5, 0.001] })).setValidator(VV_clamp(0, .5));
	inputs[9].overlay_draw_text = false;
	newInput( 4, nodeValue_Int(            "Sides",          self, 3)).setVisible(false);
	newInput(13, nodeValue_Slider(         "Start radius",   self, 0.1)).setVisible(false);
	newInput( 5, nodeValue_Slider(         "Inner radius",   self, 0.5)).setVisible(false);
	newInput( 7, nodeValue_Rotation(       "Rotation",       self, 0));
	newInput( 8, nodeValue_Rotation_Range( "Angle range",    self, [ 0, 180 ]));
	newInput(14, nodeValue_PathNode(       "Shape path",     self, noone));
	newInput(21, nodeValue_Slider_Range(   "Angles",         self, [ 0.5, 1.0 ]));
	newInput(22, nodeValue_Slider(         "Skew",           self, 0.5 ));
	newInput(23, nodeValue_Float(          "Arrow Sizes",    self, 0.3 ));
	newInput(24, nodeValue_Float(          "Arrow Head",     self, 1 ));
	newInput(25, nodeValue_Int(            "Teeth Amount",   self, 6 ));
	newInput(26, nodeValue_Vec2(           "Teeth Size",     self, [ 0.2, 0.2 ] , { slideSpeed : 0.01 }));
	newInput(27, nodeValue_Rotation(       "Teeth Rotation", self, 0));
	newInput(30, nodeValue_Bool(           "Caps",           self, false));
	newInput(31, nodeValue_Float(          "Factor",         self, 2.5));
	newInput(36, nodeValue_Enum_Button(    "Corner Shape",   self, 0, [ "Round", "Cut" ]))
	
	////- Render
		
	newInput(10, nodeValue_Color( "Shape color", self, ca_white));
	newInput(18, nodeValue_Bool(  "Tile",        self, false));
	
	////- Height
	
	newInput(12, nodeValue_Bool(         "Height",  self, false));
	newInput(29, nodeValue_Curve(        "Curve",   self, CURVE_DEF_01));
	newInput(20, nodeValue_Slider_Range( "Level",   self, [ 0, 1 ]));
	newInput(37, nodeValue_Bool(         "Opacity", self, false));
	
	////- Background
	
	newInput( 1, nodeValue_Bool(  "Background",       self, false));
	newInput(11, nodeValue_Color( "Background color", self, ca_black));
	
	/////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Output",     false],      0,  6, 
		["Transform",  false],     15,  3, 16, 17, 19, 28, 
		["Shape",	   false],      2, 32, 33, 35, 34, /**/ 9, 4, 13, 5, 7, 8, 21, 22, 23, 24, 25, 26, 27, 30, 31, 36, 
		["Render",	    true],     10, 18,
		["Height",	    true, 12], 29, 20, 37,  
		["Background",	true, 1],  11, 
	];
	
	temp_surface = [ noone ];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _shape   = current_data[ 2];
		var _posMode = current_data[15];
		var _pos  = [ 0, 0 ];
		var _sca  = [ 1, 1 ];
		var _px, _py;
		var hv;
		
		var _shp = array_safe_get(shape_types, _shape, "");
		if(is_struct(_shp)) _shp = _shp.data;
		
		switch(_shp) {
			case "Arrow"	:
			case "Line"	:
				InputDrawOverlay(inputs[32].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				InputDrawOverlay(inputs[33].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				return w_hovering;
				
			case "Half"	:
				InputDrawOverlay(inputs[32].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				return w_hovering;
		}
		
		if(_posMode == 0) {
			_pos = [ current_data[3][0], current_data[3][1] ];
			_sca = [ current_data[3][2], current_data[3][3] ];
			
		} else if(_posMode == 1) {
			_pos = current_data[16];
			_sca = current_data[17];
			
		}
		
		if(_posMode == 0) {
			InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
			
		} else if(_posMode == 1) {
			_px  = _x + _pos[0] * _s;
			_py  = _y + _pos[1] * _s;
			
			InputDrawOverlay(inputs[16].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
			InputDrawOverlay(inputs[17].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
		
		}
		
		if(inputs[9].show_in_inspector && _posMode != 2) { // corner
			var _px = _x  + _pos[0] * _s;
			var _py = _y  + _pos[1] * _s;
			
			var _x0 = _px - _sca[0] * _s;
			var _y0 = _py - _sca[1] * _s;
			var _x1 = _px + _sca[0] * _s;
			var _y1 = _py + _sca[1] * _s;
			
			var aa = -45;
			var ar = 90;
			
				 if(_sca[0] < 0 && _sca[1] < 0) { aa =  135; ar = -90; }
			else if(_sca[0] < 0 && _sca[1] > 0) { aa = -135; ar =   0; }
			else if(_sca[0] > 0 && _sca[1] < 0) { aa =   45; ar = 180; }
			
			var _max_s = max(abs(_sca[0]), abs(_sca[1]));
			var _corr  = current_data[9] * _s * _max_s;
			var _cor   = _corr / (sqrt(2) - 1);
			
			var cx = _x0 + lengthdir_x(_cor, aa);
			var cy = _y0 + lengthdir_y(_cor, aa);
			
			draw_set_color(COLORS._main_accent);
			draw_arc(cx, cy, _cor - _corr, ar, ar + 90, 2);
			
			InputDrawOverlay(inputs[9].drawOverlay(w_hoverable, active, _x0, _y0, _s, _mx, _my, _snx, _sny, aa, _max_s, 1));
		}
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _dim	= _data[0];
		var _bg		= _data[1];
		var _shape	= _data[2];
		var _aa		= _data[6];
		var _corner = _data[9];  _corner = clamp(_corner, 0, .9);
		var _color  = _data[10];
		var _df		= _data[12];
		var _bgcol  = _bg? colToVec4(_data[11]) : [0, 0, 0, 0];
		
		var _posTyp	= _data[15];
		var _tile   = _data[18];
		var _rotat  = _data[19];
		var _level  = _data[20];
		var _curve  = _data[29];
		var _shpSca = _data[28];
		
		var _crnPro = _data[36];
		var _draOpa = _data[37];
		
		var _center = [ 0, 0 ];
		var _scale  = [ 0, 0 ];
		
		switch(_posTyp) {
			case 0 :
				var _area = _data[3];
				
				_center = [     _area[0] / _dim[0],      _area[1] / _dim[1]  ];
				_scale  = [ abs(_area[2] / _dim[0]), abs(_area[3] / _dim[1]) ];
				break;
				
			case 1 :
				var _posit	= _data[16];
				var _scal 	= _data[17];
				
				_center = [     _posit[0] / _dim[0],     _posit[1] / _dim[1]  ];
				_scale  = [  abs(_scal[0] / _dim[0]), abs(_scal[1] / _dim[1]) ];
				break;
				
			case 2 :
				_center = [ 0.5, 0.5 ];
				_scale  = [ 0.5, 0.5 ];
				break;
		}
		
		_scale[0] *= _shpSca;
		_scale[1] *= _shpSca;
		
		_level = [ _level[0] / _shpSca, _level[1] / _shpSca];
		
		inputs[ 3].setVisible(_posTyp == 0);
		inputs[16].setVisible(_posTyp == 1);
		inputs[17].setVisible(_posTyp == 1);
		
		inputs[15].setVisible(true);
		
		inputs[30].setVisible(false);
		inputs[31].setVisible(false);
		inputs[32].setVisible(false);
		inputs[33].setVisible(false);
		inputs[34].setVisible(false);
		inputs[35].setVisible(false);
		inputs[36].setVisible(false);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		surface_set_shader(_outSurf, sh_shape);
			if(_bg) {
				draw_clear_alpha(0, 1);
			} else {
				DRAW_CLEAR
				BLEND_OVERRIDE
			}
			
			inputs[ 4].setVisible(false);
			inputs[ 5].setVisible(false);
			inputs[ 7].setVisible(false);
			inputs[ 8].setVisible(false);
			inputs[ 9].setVisible(false);
			inputs[13].setVisible(false);
			inputs[18].setVisible( true);
			inputs[21].setVisible(false);
			inputs[22].setVisible(false);
			inputs[23].setVisible(false);
			inputs[24].setVisible(false);
			inputs[25].setVisible(false);
			inputs[26].setVisible(false);
			inputs[27].setVisible(false);
			
			var _shp = array_safe_get(shape_types, _shape, "");
			if(is_struct(_shp)) _shp = _shp.data;
			
			switch(_shp) {
				case "Rectangle" :
					inputs[ 9].setVisible( true);
					inputs[18].setVisible(false);
					inputs[36].setVisible( true);
					
					shader_set_i("shape", 0);
					break;
					
				case "Diamond" :
					inputs[ 9].setVisible( true);
					
					shader_set_i("shape", 10);
					break;
										
				case "Trapezoid" :
					inputs[ 9].setVisible( true);
					inputs[21].setVisible( true);
					
					shader_set_i("shape", 11);
					shader_set_2("trep",  _data[21]);
					break;
					
				case "Parallelogram" :
					inputs[ 9].setVisible( true);
					inputs[22].setVisible( true);
					
					shader_set_i("shape",  12);
					shader_set_f("parall", _data[22]);
					break;
					
				case "Ellipse" :	
					shader_set_i("shape", 1);
					break;
					
				case "Regular polygon" :
					inputs[ 4].setVisible(true);
					inputs[ 7].setVisible(true);
					inputs[ 9].setVisible(true);
					inputs[36].setVisible(true);
					
					shader_set_i("shape", 2);
					shader_set_i("sides", _data[4]);
					shader_set_f("angle", degtorad(_data[7]));
					break;
					
				case "Star" :
					inputs[ 4].setVisible(true);
					inputs[ 5].setVisible(true);
					inputs[ 7].setVisible(true);
					inputs[ 9].setVisible(true);
					inputs[36].setVisible(true);
					
					inputs[5].name = "Inner radius";
					
					shader_set_i("shape", 3);
					shader_set_i("sides", _data[4]);
					shader_set_f("angle", degtorad(_data[7]));
					shader_set_f("inner", _data[5]);
					break;
					
				case "Arc" :
					inputs[ 5].setVisible(true);
					inputs[ 8].setVisible(true);
					inputs[30].setVisible(true);
					
					inputs[5].name = "Inner radius";
					
					var ar = _data[8];
					var center =  degtorad(ar[0] + ar[1]) / 2;
					var range  =  abs(degtorad(ar[0] - ar[1]) / 2);
					
					shader_set_i("shape",       4);
					shader_set_i("endcap",      _data[30]);
					shader_set_f("angle",       center);
					shader_set_f("angle_range", [ sin(range), cos(range) ] );
					shader_set_f("inner",       _data[5] / 2);
					break;
					
				case "Teardrop" :
					inputs[ 5].setVisible(true);
					inputs[13].setVisible(true);
					
					inputs[ 5].name = "End radius";
					inputs[13].name = "Start radius";
					
					shader_set_i("shape", 5);
					shader_set_f("edRad", _data[ 5]);
					shader_set_f("stRad", _data[13]);
					break;
					
				case "Cross" :
					inputs[ 9].setVisible(true);
					inputs[13].setVisible(true);
					inputs[36].setVisible(true);
					
					inputs[13].name = "Outer radius";
					
					shader_set_i("shape", 6);
					shader_set_f("outer", _data[13]);
					break;
					
				case "Leaf" :
					inputs[ 5].setVisible(true);
					inputs[13].setVisible(true);
					
					inputs[ 5].name = "Inner radius";
					inputs[13].name = "Outer radius";
					
					shader_set_i("shape", 7);
					shader_set_f("inner", _data[ 5]);
					shader_set_f("outer", _data[13]);
					break;
					
				case "Crescent" :
					inputs[ 5].setVisible(true);
					inputs[ 7].setVisible(true);
					inputs[13].setVisible(true);
					
					inputs[ 5].name = "Shift";
					inputs[13].name = "Inner circle";
					
					shader_set_i("shape", 8);
					shader_set_f("outer", _data[ 5]);
					shader_set_f("angle", -degtorad(_data[7]));
					shader_set_f("inner", _data[13]);
					break;
					
				case "Donut" :
					inputs[13].setVisible(true);
					
					inputs[13].name = "Inner circle";
					
					shader_set_i("shape", 9);
					shader_set_f("inner", _data[13]);
					break;
				
				case "Heart":
					
					shader_set_i("shape", 13);
					break;
					
				case "Disk Segment":
					inputs[13].setVisible(true);
					
					inputs[13].name = "Segment Size";
					
					shader_set_i("shape", 14);
					shader_set_f("inner", -1 + _data[13] * 2.);
					break;
				
				case "Pie":
					inputs[ 7].setVisible(true);
					
					shader_set_i("shape", 15);
					shader_set_f("angle", degtorad(_data[7]));
					break;
					
				case "Rounded Cross":
					inputs[ 9].setVisible(true);
					
					shader_set_i("shape", 16);
					break;
					
				case "Arrow":
					inputs[23].setVisible(true);
					inputs[24].setVisible(true);
					inputs[32].setVisible(true);
					inputs[33].setVisible(true);
					inputs[34].setVisible(true);
					
					shader_set_i("shape", 17);
					shader_set_f("arrow",      _data[23] / _data[24]);
					shader_set_f("arrow_head", _data[24]);
					
					shader_set_2("point1",	   _data[32]);
					shader_set_2("point2",	   _data[33]);
					shader_set_f("thickness",  _data[34]);
					break;
					
				case "Line":
					inputs[32].setVisible(true);
					inputs[33].setVisible(true);
					inputs[34].setVisible(true);
					inputs[36].setVisible(true);
					
					shader_set_i("shape", 20);
					shader_set_2("point1",	  _data[32]);
					shader_set_2("point2",	  _data[33]);
					shader_set_f("thickness", _data[34]);
					break;
					
				case "Gear":
					inputs[ 9].setVisible(true);
					inputs[13].setVisible(true);
					inputs[25].setVisible(true);
					inputs[26].setVisible(true);
					inputs[27].setVisible(true);
					
					inputs[13].name = "Inner Radius";
					
					shader_set_i("shape", 18);
					shader_set_f("inner", _data[13]);
					
					shader_set_i("teeth",		_data[25]);
					shader_set_2("teethSize",	_data[26]);
					shader_set_f("teethAngle",	_data[27]);
					break;
					
				case "Squircle" :	
					inputs[31].setVisible(true);
				
					shader_set_i("shape", 19);
					shader_set_f("squircle_factor", abs(_data[31]));
					break;
					
				case "Half":
					inputs[32].setVisible(true);
					
					shader_set_i("shape", 21);
					shader_set_2("point1",	 _data[32]);
					break;
					
			}
			
			shader_set_f("dimension",   _dim);
			shader_set_f("bgColor",     _bgcol);
			shader_set_i("aa",          _aa);
			shader_set_i("drawBG",      _bg);
			shader_set_i("drawOpacity", _draOpa);
			shader_set_i("drawDF",      _df);
			shader_set_2("dfLevel",     _level);
			shader_set_i("tile",        _tile);
			shader_set_f("corner",      _corner);
			shader_set_curve("w",       _curve);
			shader_set_i("cornerShape", _crnPro);
			
			shader_set_2("center",    _center);
			shader_set_2("scale",     _scale );
			shader_set_f("shapeScale",_shpSca);
			shader_set_f("rotation",  degtorad(_rotat));
			
			draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], _color, _color_get_alpha(_color));
		surface_reset_shader();
		
		return _outSurf;
	}
	
	static postDeserialize = function() {
		if(CLONING) return;
		
		if(LOADING_VERSION < 1_18_00_0) {
			
			if(array_length(load_map.inputs) <= 15)
				load_map.inputs[15] = { raw_value : { d : 0 } };
			
			if(array_length(load_map.inputs) >= 23) {
				var _dat = load_map.inputs[23].raw_value;
				for( var i = 0, n = array_length(_dat); i < n; i++ )
					_dat[i][1] = is_array(_dat[i][1])? array_safe_get(_dat[i][1], 1) : _dat[i][1];
			}
		}
	}
}

global.node_shape_keys_18 = [ 
	    "Rectangle", "Diamond", "Trapezoid", "Parallelogram", 
	-1, "Ellipse", "Arc", "Donut", "Crescent", "Disk Segment", "Pie", "Squircle", 
	-1, "Regular polygon", "Star", "Cross", "Rounded Cross",  
	-1, "Teardrop", "Leaf", "Heart", "Arrow", "Gear", 
];
