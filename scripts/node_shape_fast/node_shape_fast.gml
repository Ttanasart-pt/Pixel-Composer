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
	newInput(28, nodeValue_Slider(      "Shape Scale",         1     )).hideLabel();
	
	////- =Shape
	shape_types = [ 
		    "Rectangle", "Diamond", "Trapezoid", "Parallelogram", "Half", 
		-1, "Ellipse", "Arc", "Donut", "Crescent", "Disk Segment", "Pie", "Squircle", 
		-1, "Regular polygon", "Star", "Cross", "Rounded Cross",  
		-1, "Line", "Arrow", 
		-1, "Teardrop", "Leaf", "Heart", "Gear", 
	];
	__ind = 0; shape_types_str = array_map(shape_types, function(v, i) /*=>*/ {return v == -1? -1 : new scrollItem(v, s_node_shape_type, __ind++)});
	
	newInput( 2, nodeValue_Enum_Scroll(    "Shape",  0, { data: shape_types_str, horizontal: 1, text_pad: ui(16) }));
		
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
	newInput(14, nodeValue_PathNode(       "Shape path"               )).hideLabel();
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
	
	b_replace_full = button(function() /*=>*/ { nodeReplace(self, nodeBuild("Node_Shape", x, y, group), true); })
		.setText("Switch to Array version");
		
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
	
	drawOverlay = method(self, Node_Shape_drawOverlay);
	
	static update = function() {
		#region data
			var _amo = array_length(inputs);
			current_data = array_verify(current_data, _amo);
			for( var i = 0; i < _amo; i++ ) current_data[i] = inputs[i].getValue();
		
			var _dim	= current_data[ 0];
			var _bg		= current_data[ 1];
			var _shape	= current_data[ 2];
			var _aa		= current_data[ 6];
			var _corner = current_data[ 9]; _corner = clamp(_corner, 0, .9);
			var _color  = current_data[10];
			var _hegiht = current_data[12];
			var _bgcol  = _bg? colToVec4(current_data[11]) : [0, 0, 0, 0];
			
			var _posTyp	= current_data[15];
			var _tile   = current_data[18];
			var _rotat  = current_data[19];
			var _level  = current_data[20];
			var _curve  = current_data[29];
			var _shpSca = current_data[28];
			
			var _crnPro = current_data[36];
			var _draOpa = current_data[37];
			
			var _twst   = current_data[41];
			var _sher   = current_data[42];
			
			var _center = [ 0, 0 ];
			var _scale  = [ 0, 0 ];
			
			switch(_posTyp) {
				case 0 :
					var _area = current_data[3];
					
					_center = [     _area[0] / _dim[0],      _area[1] / _dim[1]  ];
					_scale  = [ abs(_area[2] / _dim[0]), abs(_area[3] / _dim[1]) ];
					break;
					
				case 1 :
					var _posit = current_data[16];
					var _scal  = current_data[17];
					
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
					shader_set_2("trep",  [current_data[38], current_data[39]]);
					break;
					
				case "Parallelogram" :
					inputs[ 9].setVisible( true);
					inputs[22].setVisible( true);
					
					shader_set_i("shape",  12);
					shader_set_f("parall", current_data[22]);
					break;
					
				case "Half":
					inputs[40].setVisible(true);
					
					shader_set_i("shape", 21);
					shader_set_2("point1", current_data[40]);
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
					
					var ar = current_data[8];
					var center =  degtorad(ar[0] + ar[1]) / 2;
					var range  =  abs(degtorad(ar[0] - ar[1]) / 2);
					
					shader_set_i("shape",       4);
					shader_set_i("endcap",      current_data[30]);
					shader_set_f("angle",       center);
					shader_set_f("angle_range", [ sin(range), cos(range) ] );
					shader_set_f("inner",       current_data[5] / 2);
					break;
					
				case "Donut" :
					inputs[ 5].setVisible(true);
					
					inputs[ 5].name = "Thickness";
					
					shader_set_i("shape", 9);
					shader_set_f("inner", 1 - current_data[5]);
					break;
				
				case "Crescent" :
					inputs[ 5].setVisible(true);
					inputs[ 7].setVisible(true);
					inputs[13].setVisible(true);
					
					inputs[ 5].name = "Shift";
					inputs[13].name = "Inner circle";
					
					shader_set_i("shape", 8);
					shader_set_f("outer", current_data[5]);
					shader_set_f("angle", -degtorad(current_data[7]));
					shader_set_f("inner", current_data[13]);
					break;
					
				case "Disk Segment":
					inputs[13].setVisible(true);
					
					inputs[13].name = "Segment Size";
					
					shader_set_i("shape", 14);
					shader_set_f("inner", -1 + clamp(current_data[13], 0, 1) * 2.);
					break;
				
				case "Pie":
					inputs[ 8].setVisible(true);
					
					var ar = current_data[8];
					var center =  degtorad(ar[0] + ar[1]) / 2;
					var range  =  abs(degtorad(ar[0] - ar[1]) / 2);
					
					shader_set_i("shape", 15);
					shader_set_f("angle",       center);
					shader_set_f("angle_range", [ sin(range), cos(range) ] );
					break;
					
				case "Squircle" :	
					inputs[31].setVisible(true);
				
					shader_set_i("shape", 19);
					shader_set_f("squircle_factor", abs(current_data[31]));
					break;
					
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
				case "Regular polygon" :
					inputs[ 4].setVisible(true);
					inputs[ 7].setVisible(true);
					inputs[ 9].setVisible(true);
					inputs[36].setVisible(true);
					
					shader_set_i("shape", 2);
					shader_set_i("sides", current_data[4]);
					shader_set_f("angle", degtorad(current_data[7]));
					break;
					
				case "Star" :
					inputs[ 4].setVisible(true);
					inputs[ 5].setVisible(true);
					inputs[ 7].setVisible(true);
					inputs[ 9].setVisible(true);
					inputs[36].setVisible(true);
					
					inputs[5].name = "Inner radius";
					
					shader_set_i("shape", 3);
					shader_set_i("sides", current_data[4]);
					shader_set_f("angle", degtorad(current_data[7]));
					shader_set_f("inner", 1 - current_data[5]);
					break;
					
				case "Cross" :
					inputs[ 9].setVisible(true);
					inputs[13].setVisible(true);
					inputs[36].setVisible(true);
					
					inputs[13].name = "Outer radius";
					
					shader_set_i("shape", 6);
					shader_set_f("outer", current_data[13]);
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
					shader_set_2("point1",	  current_data[32]);
					shader_set_2("point2",	  current_data[33]);
					shader_set_f("thickness", current_data[34]);
					break;
					
				case "Arrow":
					inputs[23].setVisible(true);
					inputs[24].setVisible(true);
					inputs[32].setVisible(true);
					inputs[33].setVisible(true);
					inputs[34].setVisible(true);
					
					shader_set_i("shape", 17);
					shader_set_f("arrow",      current_data[23] * current_data[24]);
					shader_set_f("arrow_head", 1 / current_data[24]);
					
					shader_set_2("point1",	   current_data[32]);
					shader_set_2("point2",	   current_data[33]);
					shader_set_f("thickness",  current_data[34]);
					break;
					
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
				case "Teardrop" :
					inputs[ 5].setVisible(true);
					inputs[13].setVisible(true);
					
					inputs[ 5].name = "End radius";
					inputs[13].name = "Start radius";
					
					shader_set_i("shape", 5);
					shader_set_f("edRad", current_data[ 5]);
					shader_set_f("stRad", current_data[13]);
					break;
					
				case "Leaf" :
					inputs[ 5].setVisible(true);
					inputs[13].setVisible(true);
					
					inputs[ 5].name = "Inner radius";
					inputs[13].name = "Outer radius";
					
					shader_set_i("shape", 7);
					shader_set_f("inner", current_data[ 5]);
					shader_set_f("outer", current_data[13]);
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
					shader_set_f("inner", current_data[13]);
					
					shader_set_i("teeth",		current_data[25]);
					shader_set_2("teethSize",	current_data[26]);
					shader_set_f("teethAngle",	current_data[27]);
					shader_set_f("teethTaper",	current_data[43]);
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
