#region create
	global.node_shape_keys = [ 
		"rectangle", "ellipse", "regular polygon", "star", "arc", "teardrop", "cross", "leaf", "crescent", "donut", 
		"square", "circle", "triangle", "pentagon", "hexagon", "ring", "diamond", "trapezoid", "parallelogram", "heart", 
		"arrow", 
	];
	
	function Node_create_Shape(_x, _y, _group = noone, _param = {}) { #region
		var query = struct_try_get(_param, "query", "");
		var node  = new Node_Shape(_x, _y, _group);
		var ind   = -1;
		
		switch(query) {
			case "square" :   ind = 0; break;
			case "circle" :   ind = 1; break;
			case "triangle" : ind = 2; node.inputs[| 4].setValue(3); break;
			case "pentagon" : ind = 2; node.inputs[| 4].setValue(5); break;
			case "hexagon" :  ind = 2; node.inputs[| 4].setValue(6); break;
			case "ring" :     ind = 9; break;
			
			default : ind = array_find_string(node.shape_types, query);
		}
		
		if(ind >= 0) node.inputs[| 2].setValue(ind);
		
		return node;
	}
	
#endregion

function Node_Shape(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shape";
	
	onSurfaceSize = function() { return getInputData(0, DEF_SURF); };
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	shape_types     = [ "Rectangle", "Diamond", "Trapezoid", "Parallelogram", 
						-1, 
						"Ellipse", "Arc", "Donut", "Crescent", "Disk Segment", "Pie", 
						-1, 
						"Regular polygon", "Star", "Cross", "Rounded Cross",  
						-1, 
						"Teardrop", "Leaf", "Heart", "Arrow", 
					];
	shape_types_str = [];
	
	var _ind = 0;
	for( var i = 0, n = array_length(shape_types); i < n; i++ ) {
		if(shape_types[i] == -1) 
			shape_types_str[i] = -1;
		else 
			shape_types_str[i] = new scrollItem(shape_types[i], s_node_shape_type, _ind++);
	}
	
	inputs[| 2] = nodeValue("Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, shape_types_str);
	
	inputs[| 3] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, DEF_AREA_REF)
		.setUnitRef(onSurfaceSize, VALUE_UNIT.reference)
		.setDisplay(VALUE_DISPLAY.area, { onSurfaceSize, useShape : false });
	
	inputs[| 4] = nodeValue("Sides", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 3)
		.setVisible(false);
	
	inputs[| 5] = nodeValue("Inner radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(false);
	
	inputs[| 6] = nodeValue("Anti-aliasing", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 7] = nodeValue("Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
	
	inputs[| 8] = nodeValue("Angle range", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 180 ])
		.setDisplay(VALUE_DISPLAY.rotation_range);
	
	inputs[| 9] = nodeValue("Corner radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.001] });
	
	inputs[| 10] = nodeValue("Shape color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 11] = nodeValue("Background color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black);
	
	inputs[| 12] = nodeValue("Height", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 13] = nodeValue("Start radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(false);
	
	inputs[| 14] = nodeValue("Shape path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 15] = nodeValue("Positioning Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Area", "Center + Scale", "Full Image" ])
		
	inputs[| 16] = nodeValue("Center", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W / 2, DEF_SURF_H / 2 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(onSurfaceSize);
		
	inputs[| 17] = nodeValue("Half Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ DEF_SURF_W / 2, DEF_SURF_H / 2 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(onSurfaceSize);
		
	inputs[| 18] = nodeValue("Tile", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 19] = nodeValue("Shape Rotation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.rotation);
		
	inputs[| 20] = nodeValue("Level", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 1 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
		
	inputs[| 21] = nodeValue("Angles", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.5, 1.0 ])
		.setDisplay(VALUE_DISPLAY.slider_range);
		
	inputs[| 22] = nodeValue("Skew", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5 )
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 23] = nodeValue("Arrow Sizes", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0.2, 0.3 ] )
		.setDisplay(VALUE_DISPLAY.slider_range);
		
	inputs[| 24] = nodeValue("Arrow Head", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 3 );
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",     false], 0, 6, 
		["Transform",  false], 15, 3, 16, 17, 19, 
		["Shape",	   false], 14, 2, 9, 4, 13, 5, 7, 8, 21, 22, 23, 24, 
		["Render",	    true], 10, 12, 20, 18,
		["Background",	true, 1], 11, 
	];
	
	temp_surface = [ noone ];
	use_path     = false;
	path_points  = [];
	point_simp   = [];
	triangles	 = []; 
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		PROCESSOR_OVERLAY_CHECK
		
		if(use_path) {
			draw_set_text(f_p3, fa_center, fa_top);
			draw_set_color(COLORS._main_accent);
			var ox, oy, nx, ny;
			
			for (var i = 0, n = array_length(point_simp); i < n; i++) {
				var p = point_simp[i];
				nx = _x + p.x * _s;
				ny = _y + p.y * _s;
				
				if(i) draw_line(ox, oy, nx, ny);
				
				ox = nx;
				oy = ny;
			}
			return;
		}
		
		var _type = current_data[15];
		
		if(_type == 0) {
			inputs[| 3].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		} else if(_type == 1) {
			var _pos = current_data[16];
			var _px  = _x + _pos[0] * _s;
			var _py  = _y + _pos[1] * _s;
			
			inputs[| 16].drawOverlay(hover, active,  _x,  _y, _s, _mx, _my, _snx, _sny);
			inputs[| 17].drawOverlay(hover, active, _px, _py, _s, _mx, _my, _snx, _sny);
		}
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _dim	= _data[0];
		var _bg		= _data[1];
		var _shape	= _data[2];
		var _aa		= _data[6];
		var _corner = _data[9];
		var _color  = _data[10];
		var _df		= _data[12];
		var _path	= _data[14];
		var _bgC    = _data[11];
		var _bgcol  = _bg? colToVec4(_data[11]) : [0, 0, 0, 0];
		
		var _posTyp	= _data[15];
		var _tile   = _data[18];
		var _rotat  = _data[19];
		var _level  = _data[20];
		
		var _center = [ 0, 0 ];
		var _scale  = [ 0, 0 ];
		
		switch(_posTyp) {
			case 0 :
				var _area = _data[3];
				
				_center = [ _area[0] / _dim[0], _area[1] / _dim[1] ];
				_scale  = [ _area[2] / _dim[0], _area[3] / _dim[1] ];
				break;
			case 1 :
				var _posit	= _data[16];
				var _scal 	= _data[17];
				
				_center = [ _posit[0] / _dim[0], _posit[1] / _dim[1] ];
				_scale  = [  _scal[0] / _dim[0],  _scal[1] / _dim[1] ];
				break;
			case 2 :
				_center = [ 0.5, 0.5 ];
				_scale  = [ 0.5, 0.5 ];
				break;
		}
		
		inputs[|  3].setVisible(_posTyp == 0);
		inputs[| 16].setVisible(_posTyp == 1);
		inputs[| 17].setVisible(_posTyp == 1);
		
		inputs[|  4].setVisible(true);
		inputs[|  5].setVisible(true);
		inputs[|  6].setVisible(_path == noone);
		inputs[|  7].setVisible(true);
		inputs[|  8].setVisible(true);
		inputs[|  9].setVisible(true);
		inputs[| 12].setVisible(_path == noone);
		inputs[| 20].setVisible(_path == noone);
		inputs[| 13].setVisible(true);
		inputs[| 15].setVisible(true);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		use_path = _path != noone && struct_has(_path, "getPointRatio");
		
		if(use_path) { #region
			inputs[|  3].setVisible(false);
			inputs[|  4].setVisible(false);
			inputs[|  5].setVisible(false);
			inputs[|  7].setVisible(false);
			inputs[|  8].setVisible(false);
			inputs[|  9].setVisible(false);
			inputs[| 13].setVisible(false);
			inputs[| 15].setVisible(false);
			
			surface_set_target(_outSurf);
				if(_bg) draw_clear_alpha(0, 1);
				else	DRAW_CLEAR
				
				var segCount = _path.getSegmentCount();
				if(segCount) {
					var quality = 8;
					var sample  = quality * segCount;
					var _step   = 1 / sample;
					
					path_points = array_verify(path_points, sample);
					for( var i = 0; i < sample; i++ ) 
						path_points[i] = _path.getPointRatio(i * _step, array_safe_get(path_points, i, undefined));
					
					var tri = polygon_triangulate(path_points);
					triangles  = tri[0];
					point_simp = tri[1];
					
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
			inputs[| 18].setVisible( true);
			inputs[| 21].setVisible(false);
			inputs[| 22].setVisible(false);
			inputs[| 23].setVisible(false);
			inputs[| 24].setVisible(false);
			
			var _shp = array_safe_get(shape_types, _shape, "");
			if(is_struct(_shp)) _shp = _shp.data;
			
			switch(_shp) { #region
				case "Rectangle" :
					inputs[|  9].setVisible( true);
					inputs[| 18].setVisible(false);
					
					shader_set_i("shape", 0);
					break;
					
				case "Diamond" :
					inputs[|  9].setVisible( true);
					
					shader_set_i("shape", 10);
					break;
										
				case "Trapezoid" :
					inputs[|  9].setVisible( true);
					inputs[| 21].setVisible( true);
					
					shader_set_i("shape", 11);
					shader_set_f("trep",  _data[21]);
					break;
					
				case "Parallelogram" :
					inputs[|  9].setVisible( true);
					inputs[| 22].setVisible( true);
					
					shader_set_i("shape",  12);
					shader_set_f("parall", _data[22]);
					break;
					
				case "Ellipse" :	
					shader_set_i("shape", 1);
					break;
					
				case "Regular polygon" :
					inputs[| 4].setVisible(true);
					inputs[| 7].setVisible(true);
					inputs[| 9].setVisible(true);
					
					shader_set_i("shape", 2);
					shader_set_i("sides", _data[4]);
					shader_set_f("angle", degtorad(_data[7]));
					break;
					
				case "Star" :
					inputs[| 4].setVisible(true);
					inputs[| 5].setVisible(true);
					inputs[| 7].setVisible(true);
					inputs[| 9].setVisible(true);
					
					inputs[| 5].name = "Inner radius";
					
					shader_set_i("shape", 3);
					shader_set_i("sides", _data[4]);
					shader_set_f("angle", degtorad(_data[7]));
					shader_set_f("inner", _data[5]);
					break;
					
				case "Arc" :
					inputs[| 5].setVisible(true);
					inputs[| 8].setVisible(true);
					
					inputs[| 5].name = "Inner radius";
					
					var ar = _data[8];
					var center =  degtorad(ar[0] + ar[1]) / 2;
					var range  =  degtorad(ar[0] - ar[1]) / 2;
					
					shader_set_i("shape", 4);
					shader_set_f("angle", center);
					shader_set_f("angle_range", [ sin(range), cos(range) ] );
					shader_set_f("inner", _data[5] / 2);
					break;
					
				case "Teardrop" :
					inputs[|  5].setVisible(true);
					inputs[| 13].setVisible(true);
					
					inputs[|  5].name = "End radius";
					inputs[| 13].name = "Start radius";
					
					shader_set_i("shape", 5);
					shader_set_f("edRad", _data[ 5]);
					shader_set_f("stRad", _data[13]);
					break;
					
				case "Cross" :
					inputs[|  9].setVisible(true);
					inputs[| 13].setVisible(true);
					
					inputs[| 13].name = "Outer radius";
					
					shader_set_i("shape", 6);
					shader_set_f("outer", _data[13]);
					break;
					
				case "Leaf" :
					inputs[|  5].setVisible(true);
					inputs[| 13].setVisible(true);
					
					inputs[|  5].name = "Inner radius";
					inputs[| 13].name = "Outer radius";
					
					shader_set_i("shape", 7);
					shader_set_f("inner", _data[ 5]);
					shader_set_f("outer", _data[13]);
					break;
					
				case "Crescent" :
					inputs[|  5].setVisible(true);
					inputs[|  7].setVisible(true);
					inputs[| 13].setVisible(true);
					
					inputs[|  5].name = "Shift";
					inputs[| 13].name = "Inner circle";
					
					shader_set_i("shape", 8);
					shader_set_f("outer", _data[ 5]);
					shader_set_f("angle", -degtorad(_data[7]));
					shader_set_f("inner", _data[13]);
					break;
					
				case "Donut" :
					inputs[| 13].setVisible(true);
					
					inputs[| 13].name = "Inner circle";
					
					shader_set_i("shape", 9);
					shader_set_f("inner", _data[13]);
					break;
				
				case "Heart":
					
					shader_set_i("shape", 13);
					break;
					
				case "Disk Segment":
					inputs[| 13].setVisible(true);
					
					inputs[| 13].name = "Segment Size";
					
					shader_set_i("shape", 14);
					shader_set_f("inner", -1 + _data[13] * 2.);
					break;
				
				case "Pie":
					inputs[|  7].setVisible(true);
					
					shader_set_i("shape", 15);
					shader_set_f("angle", degtorad(_data[7]));
					break;
					
				case "Rounded Cross":
					inputs[|  9].setVisible(true);
					
					shader_set_i("shape", 16);
					break;
					
				case "Arrow":
					inputs[| 23].setVisible(true);
					inputs[| 24].setVisible(true);
					
					shader_set_i("shape", 17);
					shader_set_f("arrow",      _data[23]);
					shader_set_f("arrow_head", _data[24]);
					break;
					
			} #endregion
			
			shader_set_f("dimension", _dim);
			shader_set_f("bgColor",   _bgcol);
			shader_set_i("aa",        _aa);
			shader_set_i("drawDF",    _df);
			shader_set_f("dfLevel",    _level);
			shader_set_i("tile",      _tile);
			shader_set_f("corner",    _corner);
			
			shader_set_f("center",    _center);
			shader_set_f("scale",     _scale );
			shader_set_f("rotation",  degtorad(_rotat));
			
			draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], _color, _color_get_alpha(_color));
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}