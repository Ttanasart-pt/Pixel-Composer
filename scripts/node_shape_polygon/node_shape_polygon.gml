#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Shape_Polygon", "Shape > Rectangle", "R", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[4].setValue(0); });
		addHotkey("Node_Shape_Polygon", "Shape > Ellipse",   "E", MOD_KEY.none, function() /*=>*/ { PANEL_GRAPH_FOCUS_STR _n.inputs[4].setValue(1); });
	});
#endregion

function Node_Shape_Polygon(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Shape Polygon";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Bool("Background", self, false));
	
	newInput(2, nodeValue_Color("Background color", self, ca_black));
	
	newInput(3, nodeValue_Color("Shape color", self, ca_white));
	
	shapesArray = [ 
		    "Rectangle", "Diamond", "Trapezoid", "Parallelogram", 
		-1, "Ellipse", "Arc", "Ring", "Crescent", "Pie", "Squircle", 
		-1, "Regular Polygon", "Star", "Cross", 
		-1, "Capsule", 
		-1, "Leaf", "Gear", 
	];
	__ind = 0; array_map_ext(shapesArray, function(v, i) /*=>*/ {return v == -1? -1 : new scrollItem(v, s_node_shape_poly_type, __ind++)});
	
	newInput(4, nodeValue_Enum_Scroll("Shape", self,  0, { data: shapesArray, horizontal: true, text_pad: ui(16) }))
		.setHistory([ shapesArray, { cond: function() /*=>*/ {return LOADING_VERSION < 1_18_09_0}, list: global.node_shape_polygon_keys_1809 } ]);
	
	newInput(5, nodeValue_Vec2("Position", self, [ 0.5, 0.5 ]))
		.setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	
	newInput(6, nodeValue_Rotation("Rotation", self, 0));
	
	newInput(7, nodeValue_Vec2("Scale", self, [ 0.5, 0.5 ]))
		.setUnitRef(function(i) /*=>*/ {return getDimension(i)}, VALUE_UNIT.reference);
	
	newInput(8, nodeValue_Int("Sides", self, 16))
		.setDisplay(VALUE_DISPLAY.slider, { range: [2, 64, 0.1] });
	
	newInput(9, nodeValue_Float("Inner radius", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(10, nodeValue_Float("Radius", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(11, nodeValue_Int("Teeth", self, 6))
		.setDisplay(VALUE_DISPLAY.slider, { range: [3, 16, 0.1] });
	
	newInput(12, nodeValue_Float("Teeth height", self, 0.2))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(13, nodeValue_Float("Teeth taper", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-0.5, 0.5, 0.01] });
	
	newInput(14, nodeValue_Rotation_Range("Angle range", self, [ 0, 360 ]));
	
	newInput(15, nodeValue_Bool("Round cap", self, false));
	
	newInput(16, nodeValue("Mesh", self, CONNECT_TYPE.input, VALUE_TYPE.mesh, noone))
		.setVisible(true, true);
		
	newInput(17, nodeValue_Float("Explode", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [-1, 1, 0.01] });
	
	newInput(18, nodeValue_Rotation("Piece Rotation", self, 0));
	
	////////////
	
	newInput(19, nodeValue_Color("Vertex Color 1", self, ca_white));
	
	newInput(20, nodeValue_Color("Vertex Color 2", self, ca_white));
	
	newInput(21, nodeValue_Color("Vertex Color 3", self, ca_white));
	
	////////////
	
	newInput(22, nodeValue_Float("Piece Scale", self, 1));
	
	newInput(23, nodeValue_Palette("Shape Palette", self, [ ca_white ]));
	
	newInput(24, nodeValue_Enum_Scroll("SSAA", self, 0, [ "None", "2x", "4x", "8x" ]));
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newInput(25, nodeValue_Float("Trapezoid sides", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(26, nodeValue_Float("Skew", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
	
	newInput(27, nodeValue_Float("Factor", self, 3));
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
		
	newOutput(1, nodeValue_Output("Mesh", self, VALUE_TYPE.mesh, noone));
		
	newOutput(2, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, noone));
	
	input_display_list = [ 16, 
		["Output", 		false], 0, 
		["Transform",	false], 5, 6, 7, 
		["Shape",		false], 4, 8, 9, 10, 11, 12, 13, 14, 15, 17, 25, 26, 27, 
		["Piecewise",	false], 18, 22, 
		["Render",		 true],	3, 23, 19, 20, 21, 24, 
		["Background",	 true, 1], 2, 
	];
	
	attribute_surface_depth();
	
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
	
	static processData = function(_outData, _data, _output_index, _array_index) {
		var _dim	= _data[0];
		var _bg		= _data[1];
		var _bgc	= _data[2];
		var _shc	= _data[3];
		var _shp	= _data[4];
		var _pos	= _data[5];
		var _rot	= _data[6];
		var _sca	= _data[7];
		var _mesh   = _data[16];
		var _prot   = _data[18];
		var _psca   = _data[22];
		var _pall   = _data[23];
		var _aa     = power(2, _data[24]);
		
		var data = {
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
		
		inputs[ 8].setVisible(false);
		inputs[ 9].setVisible(false);
		inputs[10].setVisible(false);
		inputs[11].setVisible(false);
		inputs[12].setVisible(false);
		inputs[13].setVisible(false);
		inputs[14].setVisible(false);
		inputs[15].setVisible(false);
		inputs[17].setVisible(false);
		inputs[25].setVisible(false);
		inputs[26].setVisible(false);
		inputs[27].setVisible(false);
		
		var _shapeName = array_safe_get_fast(shapesArray, _shp).name; 
		var _shapeFn   = noone;
		
		switch(_shapeName) {
			case "Rectangle" : _shapeFn = SHAPE_rectangle; break;
			case "Diamond"   : _shapeFn = SHAPE_diamond;   break;
			
			case "Trapezoid" : _shapeFn = SHAPE_trapezoid; 
				inputs[25].setVisible(true);
				break;
				
			case "Parallelogram" : _shapeFn = SHAPE_parallelogram; 
				inputs[26].setVisible(true);
				break;
			
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
			case "Ellipse"	 : _shapeFn = SHAPE_circle; 
				inputs[ 8].setVisible(true);
				inputs[17].setVisible(true);
				break;
				
			case "Arc"		 : _shapeFn = SHAPE_arc; 
				inputs[ 8].setVisible(true);
				inputs[ 9].setVisible(true);
				inputs[14].setVisible(true);
				inputs[15].setVisible(true);
				break;
				
			case "Ring"		 : _shapeFn = SHAPE_ring; 
				inputs[ 8].setVisible(true);
				inputs[ 9].setVisible(true);
				break;
				
			case "Crescent"  : _shapeFn = SHAPE_crescent; 
				inputs[ 8].setVisible(true);
				inputs[ 9].setVisible(true);
				break;
				
			case "Pie"  :      _shapeFn = SHAPE_pie;
				inputs[ 8].setVisible(true);
				inputs[14].setVisible(true);
				break;
				
			case "Squircle"  : _shapeFn = SHAPE_squircle;
				inputs[ 8].setVisible(true);
				inputs[27].setVisible(true);
				break;
				
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
			case "Regular Polygon" : _shapeFn = SHAPE_reg_poly;
				inputs[ 8].setVisible(true);
				break;
				
			case "Star"		 : _shapeFn = SHAPE_star; 
				inputs[ 8].setVisible(true);
				inputs[ 9].setVisible(true);
				break;
				
			case "Cross"	 : _shapeFn = SHAPE_cross; 
				inputs[ 9].setVisible(true);
				break;
				
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
			case "Capsule"	 : _shapeFn = SHAPE_capsule; 
				inputs[ 8].setVisible(true);
				inputs[10].setVisible(true);
				break;
				
			////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				
			case "Leaf"		 : _shapeFn = SHAPE_leaf;
				inputs[ 8].setVisible(true);
				break;
			
			case "Gear"		 : _shapeFn = SHAPE_gear; 
				inputs[ 9].setVisible(true);	
				inputs[11].setVisible(true);
				inputs[12].setVisible(true);
				inputs[13].setVisible(true);
				break;
				
		}
		
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
			
			outputs[2].setVisible(_mesh == noone);
			
			if(_mesh != noone) {
				for( var j = 0; j < array_length(_mesh.triangles); j++ ) {
					var tri = _mesh.triangles[j];
					var p0 = tri[0];
					var p1 = tri[1];
					var p2 = tri[2];
					
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
				
				var shapeData = _shapeFn(_sca, data);
				var points    = shapeData[0];
				var segment   = shapeData[1];
				
				if(_prot != 0 || _psca != 1)
				for( var i = 0, n = array_length(points); i < n; i++ ) {
					if(points[i].type == SHAPE_TYPE.points) continue;
					
					var _tri = points[i].triangles;
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
				
				var shapes = [];
				for( var i = 0, n = array_length(points); i < n; i++ )
					shapes[i] = points[i].type == SHAPE_TYPE.points? polygon_triangulate(points[i].points)[0] : points[i].triangles;
				
				var _plen = array_length(_pall);
				mesh.triangles = [];
				for( var i = 0, n = array_length(shapes); i < n; i++ ) {
					var triangles = shapes[i];
					var shapetyp  = points[i].type;
					
					for( var j = 0; j < array_length(triangles); j++ ) {
						var tri = triangles[j];
						
						var shapeind = shapetyp == SHAPE_TYPE.rectangle? floor(j / 2) : j;
						var trc = array_safe_get(_pall, shapeind % _plen, c_white)
						
						vertex_apply(tri[0], _pos, _rot, colorMultiply(trc, tri0), 1, _aa);
						vertex_apply(tri[1], _pos, _rot, colorMultiply(trc, tri1), 1, _aa);
						vertex_apply(tri[2], _pos, _rot, colorMultiply(trc, tri2), 1, _aa);
						
						array_push(mesh.triangles, tri);
					}
				}
				
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