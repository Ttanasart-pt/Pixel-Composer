function Node_Shape_Polygon(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Shape Polygon";
	
	shapesArray = [ "Rectangle", "Ellipse", "Star", "Capsule", "Ring", "Arc", "Gear", "Cross" ];
	for( var i = 0, n = array_length(shapesArray); i < n; i++ ) 
		shapesArray[i] = new scrollItem(shapesArray[i], s_node_shape_poly_type, i);
		
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Bool("Background", self, false));
	
	newInput(2, nodeValue_Color("Background color", self, c_black));
	
	newInput(3, nodeValue_Color("Shape color", self, c_white));
	
	newInput(4, nodeValue_Enum_Scroll("Shape", self,  0, shapesArray));
	
	newInput(5, nodeValue_Vec2("Position", self, [ 0.5, 0.5 ]))
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	newInput(6, nodeValue_Rotation("Rotation", self, 0));
	
	newInput(7, nodeValue_Vec2("Scale", self, [ 0.5, 0.5 ]))
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
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
	
	newInput(19, nodeValue_Color("Vertex Color 1", self, c_white));
	
	newInput(20, nodeValue_Color("Vertex Color 2", self, c_white));
	
	newInput(21, nodeValue_Color("Vertex Color 3", self, c_white));
	
	////////////
	
	newInput(22, nodeValue_Float("Piece Scale", self, 1));
	
	newInput(23, nodeValue_Palette("Shape Palette", self, [ cola(c_white) ]));
	
	newInput(24, nodeValue_Enum_Scroll("SSAA", self, 0, [ "None", "2x", "4x", "8x" ]));
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
		
	newOutput(1, nodeValue_Output("Mesh", self, VALUE_TYPE.mesh, noone));
		
	newOutput(2, nodeValue_Output("Path", self, VALUE_TYPE.pathnode, noone));
	
	input_display_list = [ 16, 
		["Output", 		false], 0, 
		["Transform",	false], 5, 6, 7, 
		["Shape",		false], 4, 8, 9, 10, 11, 12, 13, 14, 15, 17, 
		["Piecewise",	false], 18, 22, 
		["Render",		 true],	3, 23, 19, 20, 21, 24, 
		["Background",	 true, 1], 2, 
	];
	
	attribute_surface_depth();
	
	node_draw_transform_init();
	
	temp_surfaces = [ noone ];
	
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
	
	mesh = new Mesh();
	path = new PathSegment();
	
	static processData = function(_outData, _data, _output_index, _array_index) {
		var _dim	= _data[0];
		var _bg		= _data[1];
		var _bgc	= _data[2];
		var _shc	= _data[3];
		var _shp	= _data[4];
		var _pos	= _data[5];
		var _rot	= _data[6];
		var _sca	= _data[7];
		var _side	= _data[8];
		var _inner	= _data[9];
		var _rad	= _data[10];
		var _teeth  = _data[11];
		var _thHei  = _data[12];
		var _thTap  = _data[13];
		var _aRan   = _data[14];
		var _cap    = _data[15];
		var _mesh   = _data[16];
		var _expld  = _data[17];
		var _prot   = _data[18];
		var _psca   = _data[22];
		var _pall   = _data[23];
		var _aa     = power(2, _data[24]);
		
		inputs[ 8].setVisible(false);
		inputs[ 9].setVisible(false);
		inputs[10].setVisible(false);
		inputs[11].setVisible(false);
		inputs[12].setVisible(false);
		inputs[13].setVisible(false);
		inputs[14].setVisible(false);
		inputs[15].setVisible(false);
		inputs[17].setVisible(false);
		
		var _shapeName = array_safe_get_fast(shapesArray, _shp).name; 
		
		switch(_shapeName) {
			case "Rectangle" : // 0
				break;
				
			case "Ellipse"	 : // 1
				inputs[ 8].setVisible(true);
				inputs[17].setVisible(true);
				break;
				
			case "Star"		 : // 2
				inputs[ 8].setVisible(true);
				inputs[ 9].setVisible(true);
				break;
				
			case "Capsule"	 : // 3
				inputs[ 8].setVisible(true);
				inputs[10].setVisible(true);
				break;
				
			case "Ring"		 : // 4
				inputs[ 8].setVisible(true);
				inputs[ 9].setVisible(true);
				break;
				
			case "Arc"		 : // 5
				inputs[ 8].setVisible(true);
				inputs[ 9].setVisible(true);
				inputs[14].setVisible(true);
				inputs[15].setVisible(true);
				break;
				
			case "Gear"		 : // 6
				inputs[ 9].setVisible(true);	
				inputs[11].setVisible(true);
				inputs[12].setVisible(true);
				inputs[13].setVisible(true);
				break;
				
			case "Cross"	 : // 7
				inputs[ 9].setVisible(true);
				break;
				
		}
				
		var _outSurf = surface_verify(_outData[0], _dim[0], _dim[1], attrDepth());
		
		temp_surfaces[0] = surface_verify(temp_surfaces[0], _dim[0] * _aa, _dim[1] * _aa, attrDepth());
		var _cPassAA = temp_surfaces[0];
		
		var data = {
			side:	   _side,
			inner:	   _inner,
			radius:    _rad,
			radRan:    _aRan,
			teeth:	   _teeth,
			teethH:    _thHei,
			teethT:    _thTap,
			cap:       _cap,
			explode:   _expld,
		};
		
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
				
				var shapeData = [];
			
				switch(_shapeName) {
					case "Rectangle" : shapeData = SHAPE_rectangle( _sca      );	break;
					case "Ellipse"	 : shapeData = SHAPE_circle(	_sca, data);	break;
					case "Star"		 : shapeData = SHAPE_star(  	_sca, data);	break;
					case "Capsule"	 : shapeData = SHAPE_capsule(	_sca, data);	break;
					case "Ring"		 : shapeData = SHAPE_ring(  	_sca, data);	break;
					case "Arc"		 : shapeData = SHAPE_arc(       _sca, data);	break;
					case "Gear"		 : shapeData = SHAPE_gear(  	_sca, data);	break;
					case "Cross"	 : shapeData = SHAPE_cross( 	_sca, data);	break;
					
					default: 
						draw_primitive_end();
						draw_set_alpha(1);
			
						surface_reset_target();
						return [ _outSurf, mesh, path ];
				}
				
				var points  = shapeData[0];
				var segment = shapeData[1];
				
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
				for( var i = 0, n = array_length(points); i < n; i++ ) {
					if(points[i].type == SHAPE_TYPE.points)
						shapes[i] = polygon_triangulate(points[i].points)[0];
					else 
						shapes[i] = points[i].triangles;
				}
				
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