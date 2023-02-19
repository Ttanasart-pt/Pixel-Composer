function Node_Shape_Polygon(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Polygon Shape";
	
	shapesArray = [ "Rectangle", "Ellipse", "Star", "Capsule", "Ring", "Arc", "Gear", "Cross" ];
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2 )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Backgroud", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue("Backgroud color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 3] = nodeValue("Shape color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 4] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, shapesArray);
	
	inputs[| 5] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	inputs[| 6] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 7] = nodeValue("Scale", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0.5, 0.5 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { return getDimension(index); }, VALUE_UNIT.reference);
	
	inputs[| 8] = nodeValue("Sides", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 32)
		.setDisplay(VALUE_DISPLAY.slider, [2, 64, 1]);
	
	inputs[| 9] = nodeValue("Inner radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 10] = nodeValue("Radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 11] = nodeValue("Teeth", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 6)
		.setDisplay(VALUE_DISPLAY.slider, [3, 16, 1]);
	
	inputs[| 12] = nodeValue("Teeth height", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.2)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 13] = nodeValue("Teeth taper", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [-0.5, 0.5, 0.01]);
	
	inputs[| 14] = nodeValue("Angle range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 360 ])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 15] = nodeValue("Round cap", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Surface",		false], 0, 
		["Transform",	false], 5, 6, 7, 
		["Shape",		false], 4, 8, 9, 10, 11, 12, 13, 14, 15, 
		["Render",		 true],	1, 2, 3, 
	];
	
	node_draw_transform_init();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		if(array_length(current_data) != ds_list_size(inputs)) return;
		if(process_amount > 1) return;
		
		node_draw_transform_box(active, _x, _y, _s, _mx, _my, _snx, _sny, 5, 6, 7);
	}
	
	static draw_vertex_transform = function(_x, _y, _pos, _rot) {
		var p = point_rotate(_x, _y, 0, 0, _rot);
		draw_vertex(p[0] + _pos[0], p[1] + _pos[1]);
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
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
		
		inputs[|  8].setVisible(_shp == 1 || _shp == 2 || _shp == 3 || _shp == 4 || _shp == 5);
		inputs[|  9].setVisible(_shp == 2 || _shp == 4 || _shp == 5 || _shp == 6 || _shp == 7);
		inputs[| 10].setVisible(_shp == 3);
		inputs[| 11].setVisible(_shp == 6);
		inputs[| 12].setVisible(_shp == 6);
		inputs[| 13].setVisible(_shp == 6);
		inputs[| 14].setVisible(_shp == 5);
		inputs[| 15].setVisible(_shp == 5);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		var data = {
			side:	_side,
			inner:	_inner,
			radius: _rad,
			radRan: _aRan,
			teeth:	_teeth,
			teethH: _thHei,
			teethT: _thTap,
			cap:    _cap,
		};
		
		surface_set_target(_outSurf);
			if(_bg) draw_clear_alpha(_bgc, 1);
			else	draw_clear_alpha(0, 0);
			
			draw_set_color(_shc);
			draw_primitive_begin(pr_trianglelist);
			var points = [];
			
			switch(array_safe_get(shapesArray, _shp)) {
				case "Rectangle" : points = SHAPE_rectangle(_sca);		break;
				case "Ellipse"	 : points = SHAPE_circle(_sca, data);	break;
				case "Star"		 : points = SHAPE_star(_sca, data);		break;
				case "Capsule"	 : points = SHAPE_capsule(_sca, data);	break;
				case "Ring"		 : points = SHAPE_ring(_sca, data);		break;
				case "Arc"		 : points = SHAPE_arc(_sca, data);		break;
				case "Gear"		 : points = SHAPE_gear(_sca, data);		break;
				case "Cross"	 : points = SHAPE_cross(_sca, data);	break;
			}
			
			var shapes = [];
			for( var i = 0; i < array_length(points); i++ ) {
				if(points[i].type == SHAPE_TYPE.points)
					shapes[i] = polygon_triangulate(points[i].points);
				else if(points[i].type == SHAPE_TYPE.triangles)
					shapes[i] = points[i].triangles;
			}
			
			for( var i = 0; i < array_length(shapes); i++ ) {
				var triangles = shapes[i];
				
				for( var j = 0; j < array_length(triangles); j++ ) {
					var tri = triangles[j];
					var p0 = tri[0];
					var p1 = tri[1];
					var p2 = tri[2];
					
					draw_vertex_transform(p0[0], p0[1], _pos, _rot);
					draw_vertex_transform(p1[0], p1[1], _pos, _rot);
					draw_vertex_transform(p2[0], p2[1], _pos, _rot);
				}
			}
			draw_primitive_end();
			
		surface_reset_target();
		
		return _outSurf;
	}
}