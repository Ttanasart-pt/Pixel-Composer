enum NODE_SHAPE_TYPE {
	rectangle,
	elipse,
	regular,
	star,
	arc,
	teardrop,
	cross,
	leaf
}

function Node_Shape(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shape";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Rectangle", "Ellipse", "Regular polygon", "Star", "Arc", "Teardrop", "Cross", "Leaf" ]);
	
	onSurfaceSize = function() { return surface_get_dimension(getInputData(0, DEF_SURF)); };
	inputs[| 3] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W / 2, DEF_SURF_H / 2, DEF_SURF_W / 2, DEF_SURF_H / 2, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.area, { onSurfaceSize });
	
	inputs[| 4] = nodeValue("Sides", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 3)
		.setVisible(false);
	
	inputs[| 5] = nodeValue("Inner radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(false);
	
	inputs[| 6] = nodeValue("Anti alising", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 7] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 8] = nodeValue("Angle range", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [ 0, 180 ])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 9] = nodeValue("Corner radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.01] });
	
	inputs[| 10] = nodeValue("Shape color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 11] = nodeValue("Background color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 12] = nodeValue("Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 13] = nodeValue("Start radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(false);
	
	inputs[| 14] = nodeValue("Shape path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",  false], 0, 6, 
		["Shape",	false], 2, 14, 3, 9, 4, 13, 5, 7, 8, 
		["Render",	 true],	10, 1, 11, 12
	];
	
	temp_surface = [ noone ];
	
	attribute_surface_depth();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _path	= getInputData(14);
		if(_path != noone && struct_has(_path, "getPointRatio")) return;
		inputs[| 3].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _dim	= _data[0];
		var _bg		= _data[1];
		var _shape	= _data[2];
		var _posit	= _data[3];
		var _aa		= _data[6];
		var _corner = _data[9];
		var _color  = _data[10];
		var _df		= _data[12];
		var _path	= _data[14];
		var _bgC    = _data[11];
		var _bgcol  = _bg? colToVec4(_data[11]) : [0, 0, 0, 0];
		
		inputs[|  3].setVisible(true);
		inputs[|  4].setVisible(true);
		inputs[|  5].setVisible(true);
		inputs[|  6].setVisible(_path == noone);
		inputs[|  7].setVisible(true);
		inputs[|  8].setVisible(true);
		inputs[|  9].setVisible(true);
		inputs[| 11].setVisible(_bg);
		inputs[| 13].setVisible(true);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		
		if(_path != noone && struct_has(_path, "getPointRatio")) { #region
			inputs[|  3].setVisible(false);
			inputs[|  4].setVisible(false);
			inputs[|  5].setVisible(false);
			inputs[|  7].setVisible(false);
			inputs[|  8].setVisible(false);
			inputs[|  9].setVisible(false);
			inputs[| 13].setVisible(false);
			
			surface_set_target(_outSurf);
				if(_bg) draw_clear_alpha(0, 1);
				else	DRAW_CLEAR
				
				var points = [];
				var segCount = _path.getSegmentCount();
				if(segCount) {
					var quality = 8;
					var sample = quality * segCount;
					
					for( var i = 0; i < sample; i++ ) {
						var t = i / sample;
						var pos = _path.getPointRatio(t);
					
						array_push(points, pos);
					}
					
					var triangles = polygon_triangulate(points);
					
					draw_set_color(_color);
					draw_primitive_begin(pr_trianglelist);
					for( var i = 0, n = array_length(triangles); i < n; i++ ) {
						var tri = triangles[i];
						var p0  = tri[0];
						var p1  = tri[1];
						var p2  = tri[2];
						
						draw_vertex(p0.x, p0.y);
						draw_vertex(p1.x, p1.y);
						draw_vertex(p2.x, p2.y);
					}
					draw_primitive_end();
				}
			surface_reset_target();
			
			return _outSurf;
		} #endregion
		
		surface_set_shader(_outSurf, sh_shape);
			if(_bg) draw_clear_alpha(0, 1);
			else	DRAW_CLEAR
			
			inputs[|  4].setVisible(false);
			inputs[|  5].setVisible(false);
			inputs[|  7].setVisible(false);
			inputs[|  8].setVisible(false);
			inputs[|  9].setVisible(false);
			inputs[| 13].setVisible(false);
			
			switch(_shape) { #region
				case NODE_SHAPE_TYPE.rectangle :
					inputs[| 9].setVisible(true);
					break;
				case NODE_SHAPE_TYPE.elipse :	
					break;
				case NODE_SHAPE_TYPE.regular :
					inputs[| 4].setVisible(true);
					inputs[| 7].setVisible(true);
					inputs[| 9].setVisible(true);
					
					shader_set_i("sides", _data[4]);
					shader_set_f("angle", degtorad(_data[7]));
					break;
				case NODE_SHAPE_TYPE.star :
					inputs[| 4].setVisible(true);
					inputs[| 5].setVisible(true);
					inputs[| 7].setVisible(true);
					inputs[| 9].setVisible(true);
					
					inputs[| 5].name = "Inner radius";
					
					shader_set_i("sides", _data[4]);
					shader_set_f("angle", degtorad(_data[7]));
					shader_set_f("inner", _data[5]);
					break;
				case NODE_SHAPE_TYPE.arc :
					inputs[| 5].setVisible(true);
					inputs[| 8].setVisible(true);
					
					inputs[| 5].name = "Inner radius";
					
					var ar = _data[8];
					var center =  degtorad(ar[0] + ar[1]) / 2;
					var range  =  degtorad(ar[0] - ar[1]) / 2;
					shader_set_f("angle", center);
					shader_set_f("angle_range", [ sin(range), cos(range) ] );
					shader_set_f("inner", _data[5] / 2);
					break;
				case NODE_SHAPE_TYPE.teardrop :
					inputs[|  5].setVisible(true);
					inputs[| 13].setVisible(true);
					
					inputs[|  5].name = "End radius";
					inputs[| 13].name = "Start radius";
					
					shader_set_f("edRad", _data[ 5]);
					shader_set_f("stRad", _data[13]);
					break;
				case NODE_SHAPE_TYPE.cross :
					inputs[|  9].setVisible(true);
					inputs[| 13].setVisible(true);
					
					inputs[| 13].name = "Outer radius";
					
					shader_set_f("outer", _data[13]);
					break;
				case NODE_SHAPE_TYPE.leaf :
					inputs[|  5].setVisible(true);
					inputs[| 13].setVisible(true);
					
					inputs[|  5].name = "Inner radius";
					inputs[| 13].name = "Outer radius";
					
					shader_set_f("inner", _data[ 5]);
					shader_set_f("outer", _data[13]);
					break;
			} #endregion
			
			shader_set_f("dimension", _dim);
			shader_set_i("shape", _shape);
			shader_set_f("bgColor", _bgcol);
			shader_set_i("aa", _aa);
			shader_set_i("drawDF", _df);
			shader_set_f("corner", _corner);
			
			shader_set_f("center", [ _posit[0] / _dim[0], _posit[1] / _dim[1] ]);
			shader_set_f("scale",  [ _posit[2] / _dim[0], _posit[3] / _dim[1] ]);
			
			draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], _color, 1);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}