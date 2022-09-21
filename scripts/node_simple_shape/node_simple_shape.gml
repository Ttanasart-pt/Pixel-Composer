function Node_create_Shape(_x, _y) {
	var node = new Node_Shape(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

enum NODE_SHAPE_TYPE {
	rectangle,
	elipse,
	regular,
	star,
	arc, 
	capsule
}

function Node_Shape(_x, _y) : Node_Processor(_x, _y) constructor {
	name = "Shape";
	
	shader = sh_shape;
	uniform_shape	= shader_get_uniform(shader, "shape");
	uniform_cent	= shader_get_uniform(shader, "center");
	uniform_scal	= shader_get_uniform(shader, "scale");
	uniform_side	= shader_get_uniform(shader, "sides");
	uniform_angle	= shader_get_uniform(shader, "angle");
	uniform_inner	= shader_get_uniform(shader, "inner");
	uniform_corner	= shader_get_uniform(shader, "corner");
	uniform_arange	= shader_get_uniform(shader, "angle_range");
	uniform_aa		= shader_get_uniform(shader, "aa");
	uniform_dim		= shader_get_uniform(shader, "dimension");
	uniform_bgCol	= shader_get_uniform(shader, "bgColor");
	
	inputs[| 0] = nodeValue(0, "Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, def_surf_size2, VALUE_TAG.dimension_2d )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue(1, "Backgroud", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue(2, "Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Rectangle", "Ellipse", "Regular polygon", "Star", "Arc", "Rounded rectangle" ]);
	
	inputs[| 3] = nodeValue(3, "Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, def_surf_size / 2, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, function() { return inputs[| 0].getValue(); });
	
	inputs[| 4] = nodeValue(4, "Sides", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 3)
		.setVisible(false);
	
	inputs[| 5] = nodeValue(5, "Inner radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01])
		.setVisible(false);
	
	inputs[| 6] = nodeValue(6, "Anti alising", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 7] = nodeValue(7, "Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 8] = nodeValue(8, "Angle range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 9] = nodeValue(9, "Corner radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 0.5, 0.01]);
	
	inputs[| 10] = nodeValue(10, "Shape color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 11] = nodeValue(11, "Background color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, PIXEL_SURFACE);
	
	input_display_list = [
		["Surface", false], 0, 6, 
		["Shape",	false], 2, 3, 9, 4, 5, 7, 8, 
		["Render",	true],	10, 1, 11
	];
	
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		inputs[| 3].drawOverlay(_active, _x, _y, _s, _mx, _my);
	}
	
	static process_data = function(_outSurf, _data, _output_index) {
		var _dim	= _data[0];
		var _bg		= _data[1];
		var _shape	= _data[2];
		var _posit	= _data[3];
		var _aa		= _data[6];
		var _corner = _data[9];
		var _color  = _data[10];
		var _bgcol  = _bg? colToVec4(_data[11]) : [0, 0, 0, 0];
		
		inputs[| 11].setVisible(_bg);
		
		if(!is_surface(_outSurf)) {
			_outSurf = surface_create(surface_valid(_dim[0]), surface_valid(_dim[1]));
		} else
			surface_size_to(_outSurf, surface_valid(_dim[0]), surface_valid(_dim[1]));
		
		surface_set_target(_outSurf);
			if(_bg) draw_clear_alpha(0, 1);
			else	draw_clear_alpha(0, 0);
			
			shader_set(shader);
			
			switch(_shape) {
				case NODE_SHAPE_TYPE.rectangle :	
				case NODE_SHAPE_TYPE.elipse :	
					inputs[| 4].setVisible(false);
					inputs[| 5].setVisible(false);
					inputs[| 7].setVisible(false);
					inputs[| 8].setVisible(false);
					inputs[| 9].setVisible(false);
					break;
				case NODE_SHAPE_TYPE.regular :
					inputs[| 4].setVisible(true);
					inputs[| 5].setVisible(false);
					inputs[| 7].setVisible(true);
					inputs[| 8].setVisible(false);
					inputs[| 9].setVisible(true);
					
					shader_set_uniform_i(uniform_side, _data[4]);
					shader_set_uniform_f(uniform_angle, degtorad(_data[7]));
					break;
				case NODE_SHAPE_TYPE.star :
					inputs[| 4].setVisible(true);
					inputs[| 5].setVisible(true);
					inputs[| 7].setVisible(true);
					inputs[| 8].setVisible(false);
					inputs[| 9].setVisible(true);
				
					shader_set_uniform_i(uniform_side, _data[4]);
					shader_set_uniform_f(uniform_angle, degtorad(_data[7]));
					shader_set_uniform_f(uniform_inner, _data[5]);
					break;
				case NODE_SHAPE_TYPE.arc :
					inputs[| 4].setVisible(false);
					inputs[| 5].setVisible(true);
					inputs[| 7].setVisible(false);
					inputs[| 8].setVisible(true);
					inputs[| 9].setVisible(true);
					
					var ar = _data[8];
					var center =  degtorad(ar[0] + ar[1]) / 2;
					var range  =  degtorad(ar[0] - ar[1]) / 2;
					shader_set_uniform_f(uniform_angle, center);
					shader_set_uniform_f_array(uniform_arange, [ sin(range), cos(range) ] );
					shader_set_uniform_f(uniform_inner, _data[5] / 2);
					break;
				case NODE_SHAPE_TYPE.capsule :	
					inputs[| 4].setVisible(false);
					inputs[| 5].setVisible(false);
					inputs[| 7].setVisible(false);
					inputs[| 8].setVisible(false);
					inputs[| 9].setVisible(true);
					break;
			}
			
			shader_set_uniform_f_array(uniform_dim, _dim);
			shader_set_uniform_i(uniform_shape, _shape);
			shader_set_uniform_f_array(uniform_bgCol, _bgcol);
			shader_set_uniform_i(uniform_aa, _aa);
			shader_set_uniform_f(uniform_corner, _corner);
					
			shader_set_uniform_f_array(uniform_cent, [ _posit[0] / _dim[0], _posit[1] / _dim[1] ]);
			shader_set_uniform_f_array(uniform_scal, [ _posit[2] / _dim[0], _posit[3] / _dim[1] ]);
			
			draw_sprite_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], 0, _color, 1);
			shader_reset();
		surface_reset_target();
	}
	doUpdate();
}