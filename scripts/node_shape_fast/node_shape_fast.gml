#region create
	global.node_shapef_keys = [ 
		"rectangle", "square", "diamond", "trapezoid", "parallelogram", "half", 
		"circle", "ellipse", "arc", "donut", "crescent", "ring", "squircle", 
		"regular polygon", "triangle", "pentagon", "hexagon", "star", "cross", 
		"line", "arrow", 
		"teardrop", "leaf", "heart", "gear", 
	];

	function Node_create_Shape_Fast(_x, _y, _group = noone, _param = {}) {
		var query = struct_try_get(_param, "query", "");
		var node  = new Node_Shape_Fast(_x, _y, _group);
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
		
		if(ind >= 0) node.inputs[2].skipDefault().setValue(ind);
		
		return node;
	}
	
	function __Node_ShapeF_Hotkeys_set_shape(_n, _key) { _n.inputs[2].setValue(array_find(_n.shape_types, _key)); }
	
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Shape_Fast", "Shape > Rectangle",       "R", 0, function() /*=>*/ { GRAPH_FOCUS __Node_ShapeF_Hotkeys_set_shape(_n, "Rectangle");       });
		addHotkey("Node_Shape_Fast", "Shape > Ellipse",         "E", 0, function() /*=>*/ { GRAPH_FOCUS __Node_ShapeF_Hotkeys_set_shape(_n, "Ellipse");         });
		addHotkey("Node_Shape_Fast", "Shape > Regular polygon", "P", 0, function() /*=>*/ { GRAPH_FOCUS __Node_ShapeF_Hotkeys_set_shape(_n, "Regular polygon"); });
		addHotkey("Node_Shape_Fast", "Shape > Star",            "S", 0, function() /*=>*/ { GRAPH_FOCUS __Node_ShapeF_Hotkeys_set_shape(_n, "Star");            });
		addHotkey("Node_Shape_Fast", "Anti-aliasing > Toggle",  "A", 0, function() /*=>*/ { GRAPH_FOCUS var i=_n.inputs[ 6]; i.setValue(!i.getValue());        });
		addHotkey("Node_Shape_Fast", "Height Render > Toggle",  "H", 0, function() /*=>*/ { GRAPH_FOCUS var i=_n.inputs[12]; i.setValue(!i.getValue());        });
		addHotkey("Node_Shape_Fast", "Background > Toggle",     "B", 0, function() /*=>*/ { GRAPH_FOCUS var i=_n.inputs[ 1]; i.setValue(!i.getValue());        });
		
		addHotkey("Node_Shape_Fast", "Scale > Set",             KEY_GROUP.numeric, 0, function() /*=>*/ { 
			GRAPH_FOCUS_NUMBER 
			     if(keyboard_check(ord("S"))) { _n.inputs[ 4].setValue(round(KEYBOARD_NUMBER));     }
			else if(keyboard_check(ord("I"))) { _n.inputs[ 5].setValue(toDecimal(KEYBOARD_NUMBER)); }
			else if(keyboard_check(ord("C"))) { _n.inputs[ 9].setValue(toDecimal(KEYBOARD_NUMBER)); }
			else                                _n.inputs[28].setValue(toDecimal(KEYBOARD_NUMBER));
			
			KEYBOARD_STRING = "";
		});
	});
#endregion

function Node_Shape_Fast(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name     = "Draw Shape";
	doUpdate = doUpdateLite;
	
	onSurfaceSize = function() /*=>*/ {return getInputData(0, DEF_SURF)};
	
	////- =Output
	newInput(0, nodeValue_Dimension());
	newInput(6, nodeValue_Bool("Anti-aliasing", false));
	
	////- =Transform
	newInput(15, nodeValue_Enum_Scroll( "Positioning Mode",    2, [ "Area", "Center + Scale", "Full Image" ]))
	newInput( 3, nodeValue_Area(        "Position",          DEF_AREA_REF, { onSurfaceSize, useShape : false })).setHotkey("A").setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(16, nodeValue_Vec2(        "Center",            [.5,.5] )).setHotkey("G").setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(17, nodeValue_Vec2(        "Half Size",         [.5,.5] )).setHotkey("S").setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(19, nodeValue_Rotation(    "Shape Rotation",      0     )).setHotkey("R");
	newInput(28, nodeValue_Slider(      "Shape Scale",         1     ));
	
	////- =Shape
	shape_types = [ 
		    "Rectangle", "Diamond", "Trapezoid", "Parallelogram", "Half", 
		-1, "Ellipse", "Arc", "Donut", "Crescent", "Disk Segment", "Pie", "Squircle", 
		-1, "Regular polygon", "Star", "Cross", "Rounded Cross",  
		-1, "Line", "Arrow", 
		-1, "Teardrop", "Leaf", "Heart", "Gear", 
	];
	__ind = 0; shape_types_str = array_map(shape_types, function(v, i) /*=>*/ {return v == -1? -1 : new scrollItem(v, s_node_shape_type, __ind++)});
	
	newInput( 2, nodeValue_Enum_Scroll(    "Shape",  0, { data: shape_types_str, horizontal: true, text_pad: ui(16) }));
		
	newInput(32, nodeValue_Vec2(           "Point 1",       [ 0, 0]   )).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(33, nodeValue_Vec2(           "Point 2",       [ 1, 1]   )).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(35, nodeValue_Vec2(           "Point 3",       [ 1, 0]   )).setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	newInput(40, nodeValue_Vec2(           "Half Point",    [.5,.5]   )).setUnitRef(onSurfaceSize, VALUE_UNIT.reference).hideLabel();
	newInput(34, nodeValue_Slider(         "Thickness",      .1       )).hideLabel();
	
	newInput( 9, nodeValue_Slider(         "Corner radius",   0, [0, 0.5, 0.001] )).hideLabel().setValidator(VV_clamp(0, .5));
	newInput( 4, nodeValue_Int(            "Sides",           3       )).hideLabel().setVisible(false);
	newInput(13, nodeValue_Slider(         "Start radius",   .1       )).hideLabel().setVisible(false);
	newInput( 5, nodeValue_Slider(         "Inner radius",   .5       )).hideLabel().setVisible(false);
	newInput( 7, nodeValue_Rotation(       "Rotation",        0       )).hideLabel();
	newInput( 8, nodeValue_Rotation_Range( "Angle range",    [0,180]  )).hideLabel();
	newInput(14, nodeValue_PathNode(       "Shape path"               ));
	newInput(21, nodeValue_Slider_Range(   "Angles",         [.5, 1.] )).hideLabel();
	newInput(38, nodeValue_Slider(         "Top Side",        .5      )).hideLabel();
	newInput(39, nodeValue_Slider(         "Botton Side",      1      )).hideLabel();
	newInput(22, nodeValue_Slider(         "Skew",            .5      )).hideLabel();
	newInput(23, nodeValue_Float(          "Arrow Sizes",     .3      )).hideLabel();
	newInput(24, nodeValue_Float(          "Arrow Head",       1      )).hideLabel();
	newInput(25, nodeValue_Int(            "Teeth Amount",     6      )).hideLabel();
	newInput(26, nodeValue_Vec2(           "Teeth Size",     [.2,.2] , { slideSpeed : 0.01 })).hideLabel();
	newInput(27, nodeValue_Rotation(       "Teeth Rotation",   0      )).hideLabel();
	newInput(43, nodeValue_Slider(         "Teeth Taper",      0      ))
	newInput(30, nodeValue_Bool(           "Caps",             false  )).hideLabel();
	newInput(31, nodeValue_Float(          "Factor",           2.5    )).hideLabel();
	newInput(36, nodeValue_Enum_Button(    "Corner Shape",     0, [ "Round", "Cut" ] ))
	
	////- =Deform
	newInput(41, nodeValue_Slider(         "Twist",            0, [-1,1,.01 ] ))
	newInput(42, nodeValue_Vec2(           "Shear",           [0,0]           ))
	
	////- =Render
	newInput(10, nodeValue_Color(          "Shape color",      ca_white       ));
	newInput(18, nodeValue_Bool(           "Tile",             false          ));
	
	////- =Height
	newInput(12, nodeValue_Bool(           "Height",           false          ));
	newInput(29, nodeValue_Curve(          "Curve",            CURVE_DEF_01   ));
	newInput(20, nodeValue_Slider_Range(   "Level",            [0,1]          ));
	newInput(37, nodeValue_Bool(           "Opacity",          false          ));
	
	////- =Background
	newInput( 1, nodeValue_Bool(           "Background",       false    ));
	newInput(11, nodeValue_Color(          "Background color", ca_black ));
	// 44
	
	/////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output( "Colored", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Mask",    VALUE_TYPE.surface, noone ));
	newOutput(2, nodeValue_Output( "Height",  VALUE_TYPE.surface, noone ));
	
	b_replace_full = button(function() /*=>*/ {
		var _n = nodeBuild("Node_Shape", x, y, group);
		nodeReplace(self, _n);
		PANEL_GRAPH.setFocusingNode(_n);
	}).setText("Switch to Array version");
	
	input_display_list = [ b_replace_full, 
		[ "Output",    false     ],  0,  6, 
		[ "Transform", false     ], 15,  3, 16, 17, 19, 28, 
		[ "Shape",	   false     ],  2, 32, 33, 35, 40, 34, 9, 4, 13, 5, 7, 8, 38, 39, 22, 23, 24, 25, 26, 27, 43, 30, 31, 36, 
		[ "Deform",	    true     ], 41, 42, 
		[ "Render",	    true     ], 10, 18,
		[ "Height",	    true, 12 ], 29, 20, 37,  
		[ "Background",	true,  1 ], 11, 
	];
	
	////- Nodes
	
	temp_surface = [ noone ];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _dim     = inputs[ 0].getValue();
		var _shape   = inputs[ 2].getValue();
		var _posMode = inputs[15].getValue();
		var _pos     = [ 0, 0 ];
		var _sca     = [ 1, 1 ];
		
		switch(_posMode) {
			case 0 :	
				var _area = inputs[3].getValue();
				_pos = [ _area[0], _area[1] ];
				_sca = [ _area[2], _area[3] ];
				break;
				
			case 1 : 
				_pos = inputs[16].getValue();
				_sca = inputs[17].getValue();
				break;
				
			case 2 : 
				_pos = [ _dim[0] / 2, _dim[1] / 2 ];
				_sca = [ _dim[0] / 2, _dim[1] / 2 ];
				break;
		}
		
		var _px = _x  + _pos[0] * _s;
		var _py = _y  + _pos[1] * _s;
			
		var _x0 = _px - _sca[0] * _s;
		var _y0 = _py - _sca[1] * _s;
		var _x1 = _px + _sca[0] * _s;
		var _y1 = _py + _sca[1] * _s;
		
		var _shp = array_safe_get(shape_types, _shape, "");
		
		switch(_shp) {
			case "Arrow" :
			case "Line"	 :
				var _p0 = inputs[32].getValue();
				var _p1 = inputs[33].getValue();
				var _th = inputs[34].getValue();
				
				var _p0x = _x + _p0[0] * _s;
				var _p0y = _y + _p0[1] * _s;
				
				var _p1x = _x + _p1[0] * _s;
				var _p1y = _y + _p1[1] * _s;
				
				var _pcx = (_p0x + _p1x) / 2;
				var _pcy = (_p0y + _p1y) / 2;
				var _paa = point_direction(_p0x, _p0y, _p1x, _p1y);
				
				var _tx  = _pcx + lengthdir_x(_th * _s * _sca[0] * 2, _paa + 90);
				var _ty  = _pcy + lengthdir_y(_th * _s * _sca[0] * 2, _paa + 90);
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(_p0x, _p0y, _p1x, _p1y);
				draw_line_dashed(_pcx, _pcy, _tx, _ty);
				
				InputDrawOverlay(inputs[32].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, 2));
				InputDrawOverlay(inputs[33].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, 2));
				
				InputDrawOverlay(inputs[34].drawOverlay(w_hoverable, active, _pcx, _pcy, _s * _sca[0] * 2, _mx, _my, _snx, _sny, _paa + 90, 1, 1));
				
				if(_shp == "Arrow") {
					var _ars = inputs[23].getValue();
					var _arh = inputs[24].getValue();
					
					var _pds = _s * _sca[0] * 2;
					var _phs = _s * 16 * _ars / .25;
					
					var _phx = _p1x + lengthdir_x(_ars * _pds, _paa + 180);
					var _phy = _p1y + lengthdir_y(_ars * _pds, _paa + 180);
					
					var _pex = _phx + lengthdir_x(_arh * _phs, _paa -  90);
					var _pey = _phy + lengthdir_y(_arh * _phs, _paa -  90);
				
					draw_set_color(COLORS._main_accent);
					draw_line_dashed(_phx, _phy, _pex, _pey);
				
					InputDrawOverlay(inputs[23].drawOverlay(w_hoverable, active, _p1x, _p1y, _pds, _mx, _my, _snx, _sny, _paa + 180, 1, 1));
					InputDrawOverlay(inputs[24].drawOverlay(w_hoverable, active, _phx, _phy, _phs, _mx, _my, _snx, _sny, _paa -  90, 1, 1));
				}
				
				return w_hovering;
				
			case "Half"	:
				InputDrawOverlay(inputs[40].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny, 1));
				return w_hovering;
				
			case "Trapezoid" : 
				InputDrawOverlay(inputs[38].drawOverlay(w_hoverable, active, _px, _y0, _s * _sca[0], _mx, _my, _snx, _sny, 0, 1, 1));
				InputDrawOverlay(inputs[39].drawOverlay(w_hoverable, active, _px, _y1, _s * _sca[0], _mx, _my, _snx, _sny, 0, 1, 1));
				break;
				
			case "Parallelogram" : 
				InputDrawOverlay(inputs[22].drawOverlay(w_hoverable, active, _x0, _y1, _s * _sca[0] * 2, _mx, _my, _snx, _sny, 0, 1, 1));
				break;
				
			case "Pie" : 
				InputDrawOverlay(inputs[8].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
				break;
				
			case "Arc" : 
				var _inn = inputs[5].getValue();
				var _ix  = _x1 - _inn * _s * _sca[0];
				var _iy = _py;
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(_x1, _py, _ix, _iy);
				
				InputDrawOverlay(inputs[ 8].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
				InputDrawOverlay(inputs[ 5].drawOverlay(w_hoverable, active, _x1, _py, _s * _sca[0], _mx, _my, _snx, _sny, 180, 1, 1));
				break;
				
			case "Donut" : 
				var _inn = inputs[5].getValue();
				var _ix  = _x1 - _inn * _s * _sca[0];
				var _iy = _py;
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(_x1, _py, _ix, _iy);
				
				InputDrawOverlay(inputs[ 5].drawOverlay(w_hoverable, active, _x1, _py, _s * _sca[0], _mx, _my, _snx, _sny, 180, 1, 1));
				break;
				
			case "Crescent" : 
				var _shf = inputs[ 5].getValue();
				var _inn = inputs[13].getValue();
				
				var _ix = _x1 - _shf * _s * _sca[0] * _inn;
				var _iy = _py - _inn * _sca[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(_px, _py, _px, _iy);
				
				InputDrawOverlay(inputs[ 5].drawOverlay(w_hoverable, active, _x1, _py, _s * _sca[0] * _inn, _mx, _my, _snx, _sny, 180, 1, 1));
				InputDrawOverlay(inputs[13].drawOverlay(w_hoverable, active, _px, _py, _s * _sca[1], _mx, _my, _snx, _sny,  90, 1, 1));
				break;
				
			case "Disk Segment" : 
				InputDrawOverlay(inputs[13].drawOverlay(w_hoverable, active, _px, _y0, _s * _sca[1] * 2, _mx, _my, _snx, _sny, -90, 1, 1));
				break;
				
			case "Squircle" : 
				var _fact = inputs[31].getValue();
				
				var _ix = _px + _fact * _s * _sca[0] / 4;
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(_px, _py, _ix, _py);
				
				InputDrawOverlay(inputs[31].drawOverlay(w_hoverable, active, _px, _py, _s * _sca[0] / 4, _mx, _my, _snx, _sny, 0, 1, 1));
				break;
				
			case "Regular polygon" : 
				var _side = inputs[4].getValue();
				
				var _iy = _py - _side * _s * _sca[1] / 12;
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(_px, _py, _px, _iy);
				
				InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _px, _py, _s * _sca[1] / 12, _mx, _my, _snx, _sny, 90, 1, 1));
				break;
				
			case "Star" : 
				var _side = inputs[4].getValue();
				var _inn  = inputs[5].getValue();
				
				var _ix = _px + _inn * _s * _sca[0];
				var _iy = _py;
				
				var _sy = _py - _side * _s * _sca[1] / 12;
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(_px, _py, _ix, _iy);
				draw_line_dashed(_px, _py, _px, _sy);
				
				InputDrawOverlay(inputs[4].drawOverlay(w_hoverable, active, _px, _py, _s * _sca[1] / 12, _mx, _my, _snx, _sny, 90, 1, 1));
				InputDrawOverlay(inputs[5].drawOverlay(w_hoverable, active, _px, _py, _s * _sca[0], _mx, _my, _snx, _sny, 0, 1, 1));
				break;
				
			case "Cross" : 
				InputDrawOverlay(inputs[13].drawOverlay(w_hoverable, active, _px, _py, _s * _sca[0], _mx, _my, _snx, _sny, 0, 1, 1));
				break;
				
			case "Teardrop" : 
				var _r0 = inputs[ 5].getValue();
				var _r1 = inputs[13].getValue();
				
				var _ty0 = _py - _sca[1] * _s * .5;
				var _ty1 = _py + _sca[1] * _s * .5;
				
				draw_set_color(COLORS._main_accent);
				draw_circle_dash(_px, _ty1, _r0 * _s * _sca[0]);
				draw_circle_dash(_px, _ty0, _r1 * _s * _sca[0]);
				
				InputDrawOverlay(inputs[ 5].drawOverlay(w_hoverable, active, _px, _ty1, _s * _sca[0], _mx, _my, _snx, _sny, 0, 1, 1));
				InputDrawOverlay(inputs[13].drawOverlay(w_hoverable, active, _px, _ty0, _s * _sca[0], _mx, _my, _snx, _sny, 0, 1, 1));
				break;
				
			case "Leaf" : 
				var _r0 = inputs[ 5].getValue();
				var _r1 = inputs[13].getValue();
				
				var _ty0 = _py - _sca[1] * _s * .5;
				var _ty1 = _py + _sca[1] * _s * .5;
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(_px, _ty0, _px + _r0 * _s * _sca[0], _ty0);
				draw_line_dashed(_px, _ty1, _px + _r1 * _s * _sca[0], _ty1);
				
				InputDrawOverlay(inputs[ 5].drawOverlay(w_hoverable, active, _px, _ty0, _s * _sca[0], _mx, _my, _snx, _sny, 0, 1, 1));
				InputDrawOverlay(inputs[13].drawOverlay(w_hoverable, active, _px, _ty1, _s * _sca[0], _mx, _my, _snx, _sny, 0, 1, 1));
				break;
				
			case "Gear" : 
				var _inn = inputs[13].getValue();
				var _tam = inputs[25].getValue();
				
				var _sy = _py - _tam * _s * _sca[1] / 12;
				var _sx = _px + _inn * _s * _sca[0];
				
				draw_set_color(COLORS._main_accent);
				draw_line_dashed(_px, _py, _px, _sy);
				draw_line_dashed(_px, _py, _sx, _py);
				
				InputDrawOverlay(inputs[25].drawOverlay(w_hoverable, active, _px, _py, _s * _sca[1] / 12, _mx, _my, _snx, _sny, 90, 1, 1 ));
				InputDrawOverlay(inputs[13].drawOverlay(w_hoverable, active, _px, _py, _s * _sca[0],      _mx, _my, _snx, _sny,  0, 1, 1 ));
				InputDrawOverlay(inputs[27].drawOverlay(w_hoverable, active, _px, _py, _s,                _mx, _my, _snx, _sny           ));
				InputDrawOverlay(inputs[26].drawOverlay(w_hoverable, active, _px, _py, _s * _sca[0],      _mx, _my, _snx, _sny,  1       ));
				break;
		}
		
		if(inputs[7].show_in_inspector) InputDrawOverlay(inputs[7].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
		
		if(inputs[9].show_in_inspector) { // corner
			var aa = -45;
			var ar = 90;
			
				 if(_sca[0] < 0 && _sca[1] < 0) { aa =  135; ar = -90; }
			else if(_sca[0] < 0 && _sca[1] > 0) { aa = -135; ar =   0; }
			else if(_sca[0] > 0 && _sca[1] < 0) { aa =   45; ar = 180; }
			
			var _max_s = max(abs(_sca[0]), abs(_sca[1])) * 2;
			var _corr  = inputs[9].getValue() * _s * _max_s;
			var _cor   = _corr / sqrt(2);
			
			var cx = _x0 + lengthdir_x(_corr, aa);
			var cy = _y0 + lengthdir_y(_corr, aa);
			
			draw_set_color(COLORS._main_accent);
			draw_arc(cx, cy, _cor, ar, ar + 90);
			
			InputDrawOverlay(inputs[9].drawOverlay(w_hoverable, active, _x0, _y0, _s, _mx, _my, _snx, _sny, aa, _max_s, 2));
		}
		
		switch(_posMode) {
			case 0 : 
				InputDrawOverlay(inputs[3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
				break;
			
			case 1 : 
				InputDrawOverlay(inputs[16].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my, _snx, _sny));
				InputDrawOverlay(inputs[17].drawOverlay(w_hoverable, active, _px, _py, _s, _mx, _my, _snx, _sny));
				break;
		}
		
		return w_hovering;
	}
	
	static update = function() {
		#region data
			var _dim	= inputs[ 0].getValue();
			var _bg		= inputs[ 1].getValue();
			var _shape	= inputs[ 2].getValue();
			var _aa		= inputs[ 6].getValue();
			var _corner = inputs[ 9].getValue(); _corner = clamp(_corner, 0, .9);
			var _color  = inputs[10].getValue();
			var _hegiht = inputs[12].getValue();
			var _bgcol  = _bg? colToVec4(inputs[11].getValue()) : [0, 0, 0, 0];
			
			var _posTyp	= inputs[15].getValue();
			var _tile   = inputs[18].getValue();
			var _rotat  = inputs[19].getValue();
			var _level  = inputs[20].getValue();
			var _curve  = inputs[29].getValue();
			var _shpSca = inputs[28].getValue();
			
			var _crnPro = inputs[36].getValue();
			var _draOpa = inputs[37].getValue();
			
			var _twst   = inputs[41].getValue();
			var _sher   = inputs[42].getValue();
			
			var _center = [ 0, 0 ];
			var _scale  = [ 0, 0 ];
			
			switch(_posTyp) {
				case 0 :
					var _area = inputs[3].getValue();
					
					_center = [     _area[0] / _dim[0],      _area[1] / _dim[1]  ];
					_scale  = [ abs(_area[2] / _dim[0]), abs(_area[3] / _dim[1]) ];
					break;
					
				case 1 :
					var _posit = inputs[16].getValue();
					var _scal  = inputs[17].getValue();
					
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
			inputs[43].setVisible(false);
			
			inputs[ 4].setVisible(false);
			inputs[ 5].setVisible(false);
			inputs[ 7].setVisible(false);
			inputs[ 8].setVisible(false);
			inputs[ 9].setVisible(false);
			inputs[13].setVisible(false);
			inputs[18].setVisible( true);
			inputs[21].setVisible(false);
			inputs[38].setVisible(false);
			inputs[39].setVisible(false);
			inputs[40].setVisible(false);
			inputs[22].setVisible(false);
			inputs[23].setVisible(false);
			inputs[24].setVisible(false);
			inputs[25].setVisible(false);
			inputs[26].setVisible(false);
			inputs[27].setVisible(false);
		#endregion
			
		var _outData = [];
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			_outData[i] = surface_verify(outputs[i].getValue(), _dim[0], _dim[1], attrDepth());
			outputs[i].setValue(_outData[i]);
		}
		
		surface_set_shader(_outData, sh_shape);
			draw_clear_alpha(0, _bg);
			if(!_bg) BLEND_OVERRIDE
			
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
					inputs[38].setVisible( true);
					inputs[39].setVisible( true);
					
					shader_set_i("shape", 11);
					shader_set_2("trep",  [inputs[38].getValue(), inputs[39].getValue()]);
					break;
					
				case "Parallelogram" :
					inputs[ 9].setVisible( true);
					inputs[22].setVisible( true);
					
					shader_set_i("shape",  12);
					shader_set_f("parall", inputs[22].getValue());
					break;
					
				case "Half":
					inputs[40].setVisible(true);
					
					shader_set_i("shape", 21);
					shader_set_2("point1", inputs[40].getValue());
					break;
				
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
				case "Ellipse" :	
					shader_set_i("shape", 1);
					break;
					
				case "Arc" :
					inputs[ 5].setVisible(true);
					inputs[ 8].setVisible(true);
					inputs[30].setVisible(true);
					
					inputs[5].name = "Thickness";
					
					var ar = inputs[8].getValue();
					var center =  degtorad(ar[0] + ar[1]) / 2;
					var range  =  abs(degtorad(ar[0] - ar[1]) / 2);
					
					shader_set_i("shape",       4);
					shader_set_i("endcap",      inputs[30].getValue());
					shader_set_f("angle",       center);
					shader_set_f("angle_range", [ sin(range), cos(range) ] );
					shader_set_f("inner",       inputs[5].getValue() / 2);
					break;
					
				case "Donut" :
					inputs[ 5].setVisible(true);
					
					inputs[ 5].name = "Thickness";
					
					shader_set_i("shape", 9);
					shader_set_f("inner", 1 - inputs[5].getValue());
					break;
				
				case "Crescent" :
					inputs[ 5].setVisible(true);
					inputs[ 7].setVisible(true);
					inputs[13].setVisible(true);
					
					inputs[ 5].name = "Shift";
					inputs[13].name = "Inner circle";
					
					shader_set_i("shape", 8);
					shader_set_f("outer", inputs[5].getValue());
					shader_set_f("angle", -degtorad(inputs[7].getValue()));
					shader_set_f("inner", inputs[13].getValue());
					break;
					
				case "Disk Segment":
					inputs[13].setVisible(true);
					
					inputs[13].name = "Segment Size";
					
					shader_set_i("shape", 14);
					shader_set_f("inner", -1 + clamp(inputs[13].getValue(), 0, 1) * 2.);
					break;
				
				case "Pie":
					inputs[ 8].setVisible(true);
					
					var ar = inputs[8].getValue();
					var center =  degtorad(ar[0] + ar[1]) / 2;
					var range  =  abs(degtorad(ar[0] - ar[1]) / 2);
					
					shader_set_i("shape", 15);
					shader_set_f("angle",       center);
					shader_set_f("angle_range", [ sin(range), cos(range) ] );
					break;
					
				case "Squircle" :	
					inputs[31].setVisible(true);
				
					shader_set_i("shape", 19);
					shader_set_f("squircle_factor", abs(inputs[31].getValue()));
					break;
					
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
				case "Regular polygon" :
					inputs[ 4].setVisible(true);
					inputs[ 7].setVisible(true);
					inputs[ 9].setVisible(true);
					inputs[36].setVisible(true);
					
					shader_set_i("shape", 2);
					shader_set_i("sides", inputs[4].getValue());
					shader_set_f("angle", degtorad(inputs[7].getValue()));
					break;
					
				case "Star" :
					inputs[ 4].setVisible(true);
					inputs[ 5].setVisible(true);
					inputs[ 7].setVisible(true);
					inputs[ 9].setVisible(true);
					inputs[36].setVisible(true);
					
					inputs[5].name = "Inner radius";
					
					shader_set_i("shape", 3);
					shader_set_i("sides", inputs[4].getValue());
					shader_set_f("angle", degtorad(inputs[7].getValue()));
					shader_set_f("inner", 1 - inputs[5].getValue());
					break;
					
				case "Cross" :
					inputs[ 9].setVisible(true);
					inputs[13].setVisible(true);
					inputs[36].setVisible(true);
					
					inputs[13].name = "Outer radius";
					
					shader_set_i("shape", 6);
					shader_set_f("outer", inputs[13].getValue());
					break;
					
				case "Rounded Cross":
					inputs[ 9].setVisible(true);
					
					shader_set_i("shape", 16);
					break;
					
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
				case "Line":
					inputs[32].setVisible(true);
					inputs[33].setVisible(true);
					inputs[34].setVisible(true);
					inputs[36].setVisible(true);
					
					shader_set_i("shape", 20);
					shader_set_2("point1",	  inputs[32].getValue());
					shader_set_2("point2",	  inputs[33].getValue());
					shader_set_f("thickness", inputs[34].getValue());
					break;
					
				case "Arrow":
					inputs[23].setVisible(true);
					inputs[24].setVisible(true);
					inputs[32].setVisible(true);
					inputs[33].setVisible(true);
					inputs[34].setVisible(true);
					
					shader_set_i("shape", 17);
					shader_set_f("arrow",      inputs[23].getValue() * inputs[24].getValue());
					shader_set_f("arrow_head", 1 / inputs[24].getValue());
					
					shader_set_2("point1",	   inputs[32].getValue());
					shader_set_2("point2",	   inputs[33].getValue());
					shader_set_f("thickness",  inputs[34].getValue());
					break;
					
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
				case "Teardrop" :
					inputs[ 5].setVisible(true);
					inputs[13].setVisible(true);
					
					inputs[ 5].name = "End radius";
					inputs[13].name = "Start radius";
					
					shader_set_i("shape", 5);
					shader_set_f("edRad", inputs[ 5].getValue());
					shader_set_f("stRad", inputs[13].getValue());
					break;
					
				case "Leaf" :
					inputs[ 5].setVisible(true);
					inputs[13].setVisible(true);
					
					inputs[ 5].name = "Inner radius";
					inputs[13].name = "Outer radius";
					
					shader_set_i("shape", 7);
					shader_set_f("inner", inputs[ 5].getValue());
					shader_set_f("outer", inputs[13].getValue());
					break;
					
				case "Heart":
					
					shader_set_i("shape", 13);
					break;
					
				case "Gear":
					inputs[ 9].setVisible(true);
					inputs[13].setVisible(true);
					inputs[25].setVisible(true);
					inputs[26].setVisible(true);
					inputs[27].setVisible(true);
					inputs[43].setVisible(true);
					
					inputs[13].name = "Inner Radius";
					
					shader_set_i("shape", 18);
					shader_set_f("inner", inputs[13].getValue());
					
					shader_set_i("teeth",		inputs[25].getValue());
					shader_set_2("teethSize",	inputs[26].getValue());
					shader_set_f("teethAngle",	inputs[27].getValue());
					shader_set_f("teethTaper",	inputs[43].getValue());
					break;
					
			}
			
			shader_set_f("dimension",   _dim    );
			shader_set_f("bgColor",     _bgcol  );
			shader_set_i("aa",          _aa     );
			shader_set_i("drawBG",      _bg     );
			shader_set_i("drawOpacity", _draOpa );
			shader_set_i("drawDF",      _hegiht );
			shader_set_2("dfLevel",     _level  );
			shader_set_i("tile",        _tile   );
			shader_set_f("corner",      _corner );
			shader_set_curve("w",       _curve  );
			shader_set_i("cornerShape", _crnPro );
			
			shader_set_f("twist",	    _twst   );
			shader_set_2("shear",	    _sher   );
			
			shader_set_2("center",      _center );
			shader_set_2("scale",       _scale  );
			shader_set_f("shapeScale",  _shpSca );
			shader_set_f("rotation",    degtorad(_rotat));
			shader_set_c("baseColor",   _color  );
			
			draw_empty();
		surface_reset_shader();
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

global.node_shapef_keys_18 = [ 
	    "Rectangle", "Diamond", "Trapezoid", "Parallelogram", 
	-1, "Ellipse", "Arc", "Donut", "Crescent", "Disk Segment", "Pie", "Squircle", 
	-1, "Regular polygon", "Star", "Cross", "Rounded Cross",  
	-1, "Teardrop", "Leaf", "Heart", "Arrow", "Gear", 
];
