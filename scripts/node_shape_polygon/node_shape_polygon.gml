#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Shape_Polygon", "Shape > Rectangle", "R", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue(0); });
		addHotkey("Node_Shape_Polygon", "Shape > Ellipse",   "E", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue(1); });
	});
#endregion

function Node_Shape_Polygon(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Shape Polygon";
	
	shapesArray = [ 
		    "Rectangle", "Diamond", "Trapezoid", "Parallelogram", 
		-1, "Ellipse", "Arc", "Ring", "Crescent", "Pie", "Squircle", 
		-1, "Regular Polygon", "Star", "Cross", 
		-1, "Capsule", 
		-1, "Leaf", "Gear", 
	];
	__ind = 0; array_map_ext(shapesArray, function(v, i) /*=>*/ {return v == -1? -1 : new scrollItem(v, s_node_shape_poly_type, __ind++)});
	
	newInput(16, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	////- =Output
	
	newInput( 0, nodeValue_Dimension());
	
	////- =Transform
	
	newInput( 5, nodeValue_Vec2(     "Position", [.5,.5])).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	newInput( 6, nodeValue_Rotation( "Rotation", 0));
	newInput( 7, nodeValue_Vec2(     "Scale",    [.5,.5])).setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	
	////- =Shape
	
	newInput( 4, nodeValue_Enum_Scroll("Shape",  0, { data: shapesArray, horizontal: true, text_pad: ui(16) }))
		.setHistory([ shapesArray, { cond: function() /*=>*/ {return LOADING_VERSION < 1_18_09_0}, list: global.node_shape_polygon_keys_1809 }, 
		                           //{ cond: () => LOADING_VERSION < 1_19_02_0, list: global.node_shape_polygon_keys_1902 },
                    ]);
	
	newInput( 8, nodeValue_ISlider(        "Sides",           16,     [2, 64, .1]));
	newInput( 9, nodeValue_Slider(         "Inner Radius",    .5));
	newInput(10, nodeValue_Slider(         "Radius",          .5));
	newInput(11, nodeValue_ISlider(        "Teeth",            6,     [3, 16, .1]));
	newInput(12, nodeValue_Slider(         "Teeth Height",    .2));
	newInput(13, nodeValue_Slider(         "Teeth Taper",      0,     [-.5, .5, .01]));
	newInput(14, nodeValue_Rotation_Range( "Angle Range",     [0,360]));
	newInput(15, nodeValue_Bool(           "Round Cap",        0));
	newInput(17, nodeValue_Slider(         "Explode",          0,     [-1, 1, .01]));
	newInput(25, nodeValue_Slider(         "Trapezoid Sides", .5));
	newInput(26, nodeValue_Slider(         "Skew",            .5,     [-1, 1, .01]));
	newInput(27, nodeValue_Float(          "Factor",           3));
	
	////- =Piecewise
	
	newInput(18, nodeValue_Rotation( "Piece Rotation", 0));
	newInput(22, nodeValue_Float(    "Piece Scale",    1));
	
	////- =Render
	
	newInput( 3, nodeValue_Color(    "Shape color",     ca_white));
	newInput(23, nodeValue_Palette(  "Shape Palette",  [ca_white]));
	newInput(19, nodeValue_Color(    "Vertex Color 1",  ca_white));
	newInput(20, nodeValue_Color(    "Vertex Color 2",  ca_white));
	newInput(21, nodeValue_Color(    "Vertex Color 3",  ca_white));
	newInput(24, nodeValue_Enum_Scroll("SSAA", 0, [ "None", "2x", "4x", "8x" ]));
	
	////- =Background
	
	newInput( 1, nodeValue_Bool(  "Background",       false));
	newInput( 2, nodeValue_Color( "Background color", ca_black));
	
	// inputs 28
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface,  noone));
	newOutput(1, nodeValue_Output( "Mesh",        VALUE_TYPE.mesh,     noone));
	newOutput(2, nodeValue_Output( "Path",        VALUE_TYPE.pathnode, noone));
	
	input_display_list = [ 16, 
		["Output",     false   ], 0, 
		["Transform",  false   ], 5, 6, 7, 
		["Shape",      false   ], 4, 8, 9, 10, 11, 12, 13, 14, 15, 17, 25, 26, 27, 
		["Piecewise",  false   ], 18, 22, 
		["Render",      true   ], 3, 23, 19, 20, 21, 24, 
		["Background",  true, 1], 2, 
	];
	
	attribute_surface_depth();
	
	////- Nodes
	
	node_draw_transform_init();
	
	temp_surface = [ noone ];
	
	mesh = new Mesh();
	path = new PathSegment();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(array_length(current_data) != array_length(inputs)) return;
		if(process_amount > 1) return;
		
		draw_set_color(c_grey);
		mesh.draw(_x, _y, _s);
		node_draw_transform_box(active, _x, _y, _s, _mx, _my, _snx, _sny, 5, 6, 7, true);
		
		draw_set_color(COLORS._main_accent);
		path.draw(_x, _y, _s);
	}
	
	static vertex_apply = function(_p, _pos, _rot, _color = c_white, _alpha = 1, _aa = 1) {
		var p = point_rotate(_p.x, _p.y, 0, 0, _rot);
		_p.x = _pos[0] + p[0];
		_p.y = _pos[1] + p[1];
		
		draw_vertex_color(_p.x * _aa, _p.y * _aa, _color, _alpha);
	}
	
	static processData = function(_outData, _data, _array_index) {
		var _dim  = _data[0];
		var _bg   = _data[1];
		var _bgc  = _data[2];
		var _shc  = _data[3];
		var _shp  = _data[4];
		var _pos  = _data[5];
		var _rot  = _data[6];
		var _sca  = _data[7];
		var _mesh = _data[16];
		var _prot = _data[18];
		var _psca = _data[22];
		var _pall = _data[23];
		var _aa   = power(2, _data[24]);
		
		outputs[2].setVisible(!is(_mesh, Mesh));
		
		var data = {
			scale:    _data[ 7],
			side:	  _data[ 8],
			inner:	  _data[ 9],
			radius:   _data[10],
			radRan:   _data[14],
			teeth:	  _data[11],
			teethH:   _data[12],
			teethT:   _data[13],
			cap:      _data[15],
			explode:  _data[17],
			trep:     _data[25], 
			palAng:   _data[26], 
			factor:   _data[27], 
		};
		
		var _shapeHide = [8, 9, 10, 11, 12, 13, 14, 15, 17, 25, 26, 27];
		var _shapeShow = [];
		var _shapeName = array_safe_get_fast(shapesArray, _shp).name;
		var _shapeFn   = noone;
		
		switch(_shapeName) {
			case "Rectangle"       : _shapeFn = SHAPE_rectangle;                                   break;
			case "Diamond"         : _shapeFn = SHAPE_diamond;                                     break;
			
			case "Trapezoid"       : _shapeFn = SHAPE_trapezoid;     _shapeShow = [25];            break;
			case "Parallelogram"   : _shapeFn = SHAPE_parallelogram; _shapeShow = [26];            break;
				
			case "Ellipse"         : _shapeFn = SHAPE_circle;        _shapeShow = [8, 17];         break;
			case "Arc"             : _shapeFn = SHAPE_arc;           _shapeShow = [8, 9, 14, 15];  break;
			case "Ring"            : _shapeFn = SHAPE_ring;          _shapeShow = [8, 9];          break;
			case "Crescent"        : _shapeFn = SHAPE_crescent;      _shapeShow = [8, 9];          break;
			case "Pie"             : _shapeFn = SHAPE_pie;           _shapeShow = [8, 14];         break;
			case "Squircle"        : _shapeFn = SHAPE_squircle;      _shapeShow = [8, 27];         break;
				
			case "Regular Polygon" : _shapeFn = SHAPE_reg_poly;      _shapeShow = [8];             break;
			case "Star"            : _shapeFn = SHAPE_star;          _shapeShow = [8, 9];          break;
			case "Cross"           : _shapeFn = SHAPE_cross;         _shapeShow = [9];             break;
				
			case "Capsule"         : _shapeFn = SHAPE_capsule;       _shapeShow = [8, 10];         break;
				
			case "Leaf"            : _shapeFn = SHAPE_leaf;          _shapeShow = [8];             break;
			case "Gear"            : _shapeFn = SHAPE_gear;          _shapeShow = [9, 11, 12, 13]; break;
		}
		
		array_foreach(_shapeHide, function(v) /*=>*/ {return inputs[v].setVisible(false)});
		array_foreach(_shapeShow, function(v) /*=>*/ {return inputs[v].setVisible(true)});
		
		// Draw
		
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0] * _aa, _dim[1] * _aa, attrDepth());
		var _outSurf    = surface_verify(_outData[0], _dim[0], _dim[1], attrDepth());
		var _cPassAA    = temp_surface[0];
		
		var tri0 = colorMultiply(_shc, _data[19]); 
		var tri1 = colorMultiply(_shc, _data[20]); 
		var tri2 = colorMultiply(_shc, _data[21]);
		
		surface_set_target(_cPassAA);
		if(_bg) draw_clear(_bgc);
		else	DRAW_CLEAR
		
		draw_primitive_begin(pr_trianglelist);
		
		
		if(is(_mesh, Mesh)) {
			
			for( var j = 0; j < array_length(_mesh.triangles); j++ ) {
				var tri = _mesh.triangles[j];
				var p0  = _mesh.points[tri[0]];
				var p1  = _mesh.points[tri[1]];
				var p2  = _mesh.points[tri[2]];
				
				draw_vertex(p0.x * _aa, p0.y * _aa);
				draw_vertex(p1.x * _aa, p1.y * _aa);
				draw_vertex(p2.x * _aa, p2.y * _aa);
			}
			
		} else {
			if(_shapeFn == noone) {
				draw_primitive_end();
				draw_set_alpha(1);
				
				surface_reset_target();
				return [ _outSurf, mesh, path ];
			}
			
			shapeData = _shapeFn(data);
			objects   = shapeData[0];
			segment   = shapeData[1];
			
			if(_prot != 0 || _psca != 1)
			for( var i = 0, n = array_length(objects); i < n; i++ ) {
				var _tri = objects[i].triangles;
				for( var j = 0; j < array_length(_tri); j++ ) {
					var tri = _tri[j];
					var t0  = tri[0];
					var t1  = tri[1];
					var t2  = tri[2];
					
					var cx  = (t0.x + t1.x + t2.x) / 3;
					var cy  = (t0.y + t1.y + t2.y) / 3;
					
					var p = point_rotate(t0.x - cx, t0.y - cy, 0, 0, _prot);
					t0.x = cx + _psca * p[0];
					t0.y = cy + _psca * p[1];
					
					var p = point_rotate(t1.x - cx, t1.y - cy, 0, 0, _prot);
					t1.x = cx + _psca * p[0];
					t1.y = cy + _psca * p[1];
					
					var p = point_rotate(t2.x - cx, t2.y - cy, 0, 0, _prot);
					t2.x = cx + _psca * p[0];
					t2.y = cy + _psca * p[1];
					
				}
			}
			
			for( var i = 0, n = array_length(segment); i < n; i++ ) {
				var _p = segment[i];
				var p = point_rotate(_p.x, _p.y, 0, 0, _rot);
				_p.x = _pos[0] + p[0];
				_p.y = _pos[1] + p[1];
			}
			path.setSegment(segment);
			
			var shapes = array_create_ext(array_length(objects), function(i) /*=>*/ {return objects[i].triangles});
			var _plen  = array_length(_pall);
			
			var mpoints    = [];
			var mtriangles = [];
			
			for( var i = 0, n = array_length(shapes); i < n; i++ ) {
				var triangles = shapes[i];
				var shapetyp  = objects[i].type;
				
				for( var j = 0; j < array_length(triangles); j++ ) {
					var tri = triangles[j];
					
					var shapeind = shapetyp == SHAPE_TYPE.rectangle? floor(j / 2) : j;
					var trc = array_safe_get(_pall, shapeind % _plen, c_white)
					
					vertex_apply(tri[0], _pos, _rot, colorMultiply(trc, tri0), 1, _aa);
					vertex_apply(tri[1], _pos, _rot, colorMultiply(trc, tri1), 1, _aa);
					vertex_apply(tri[2], _pos, _rot, colorMultiply(trc, tri2), 1, _aa);
					
					var p0 = array_length(mpoints); array_push(mpoints, tri[0]);
					var p1 = array_length(mpoints); array_push(mpoints, tri[1]);
					var p2 = array_length(mpoints); array_push(mpoints, tri[2]);
					
					array_push( mtriangles, [p0, p1, p2] );
				}
			}
			
			mesh.points    = mpoints;
			mesh.triangles = mtriangles;
			mesh.calcCoM();
		}
		draw_primitive_end();
		draw_set_alpha(1);
			
		surface_reset_target();
		
		surface_set_shader(_outSurf, sh_downsample, true, BLEND.over);
			shader_set_dim("dimension", _cPassAA);
			shader_set_f("down", _aa);
			draw_surface(_cPassAA, 0, 0);
		surface_reset_shader();
		
		return [ _outSurf, mesh, path ];
	}
}

global.node_shape_polygon_keys_1809 = [ "Rectangle", "Ellipse", "Star", "Capsule", "Ring", "Arc", "Gear", "Cross" ];
global.node_shape_polygon_keys_1902 = [ 
	    "Rectangle", "Diamond", "Trapezoid", "Parallelogram", 
	-1, "Ellipse", "Arc", "Ring", "Crescent", "Pie", "Squircle", 
	-1, "Regular Polygon", "Star", "Cross", 
	-1, "Capsule", 
	-1, "Leaf", "Gear", 
];