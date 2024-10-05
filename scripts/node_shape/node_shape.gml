global.node_shape_keys = [ 
	"rectangle", "ellipse", "regular polygon", "star", "arc", "teardrop", "cross", "leaf", "crescent", "donut", 
	"square", "circle", "triangle", "pentagon", "hexagon", "ring", "diamond", "trapezoid", "parallelogram", "heart", 
	"arrow", "gear", "squircle", 
];

function Node_create_Shape(_x, _y, _group = noone, _param = {}) {
	var query = struct_try_get(_param, "query", "");
	var node  = new Node_Shape(_x, _y, _group).skipDefault();
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

function Node_Shape(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Shape";
	
	onSurfaceSize = function() { return getInputData(0, DEF_SURF); };
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_Bool("Background", self, false));
	
	shape_types     = [ 
		"Rectangle", "Diamond", "Trapezoid", "Parallelogram", 
		-1, 
		"Ellipse", "Arc", "Donut", "Crescent", "Disk Segment", "Pie", "Squircle", 
		-1, 
		"Regular polygon", "Star", "Cross", "Rounded Cross",  
		-1, 
		"Teardrop", "Leaf", "Heart", "Arrow", "Gear", 
	];
	shape_types_str = [];
	
	var _ind = 0;
	for( var i = 0, n = array_length(shape_types); i < n; i++ )
		shape_types_str[i] = shape_types[i] == -1? -1 : new scrollItem(shape_types[i], s_node_shape_type, _ind++);
	
	newInput(2, nodeValue_Enum_Scroll("Shape", self,  0, { data: shape_types_str, horizontal: true, text_pad: ui(16) }));
	
	newInput(3, nodeValue_Area("Position", self, DEF_AREA_REF, { onSurfaceSize, useShape : false }))
		.setUnitRef(onSurfaceSize, VALUE_UNIT.reference);
	
	newInput(4, nodeValue_Int("Sides", self, 3))
		.setVisible(false);
	
	newInput(5, nodeValue_Float("Inner radius", self, 0.5))
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(false);
	
	newInput(6, nodeValue_Bool("Anti-aliasing", self, false));
	
	newInput(7, nodeValue_Rotation("Rotation", self, 0));
	
	newInput(8, nodeValue_Rotation_Range("Angle range", self, [ 0, 180 ]));
	
	newInput(9, nodeValue_Float("Corner radius", self, 0))
		.setValidator(VV_clamp(0, .5))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.001] });
	inputs[9].overlay_draw_text = false;
	
	newInput(10, nodeValue_Color("Shape color", self, c_white));
	
	newInput(11, nodeValue_Color("Background color", self, c_black));
	
	newInput(12, nodeValue_Bool("Height", self, false));
	
	newInput(13, nodeValue_Float("Start radius", self, 0.1))
		.setDisplay(VALUE_DISPLAY.slider)
		.setVisible(false);
	
	newInput(14, nodeValue_PathNode("Shape path", self, noone))
		.setVisible(true, true);
	
	newInput(15, nodeValue_Enum_Scroll("Positioning Mode", self,  2, [ "Area", "Center + Scale", "Full Image" ]))
		
	newInput(16, nodeValue_Vec2("Center", self, [ DEF_SURF_W / 2, DEF_SURF_H / 2 ] ))
		.setUnitRef(onSurfaceSize);
		
	newInput(17, nodeValue_Vec2("Half Size", self, [ DEF_SURF_W / 2, DEF_SURF_H / 2 ] ))
		.setUnitRef(onSurfaceSize);
		
	newInput(18, nodeValue_Bool("Tile", self, false));
	
	newInput(19, nodeValue_Rotation("Shape rotation", self, 0));
		
	newInput(20, nodeValue_Slider_Range("Level", self, [ 0, 1 ]));
		
	newInput(21, nodeValue_Slider_Range("Angles", self, [ 0.5, 1.0 ]));
		
	newInput(22, nodeValue_Float("Skew", self, 0.5 ))
		.setDisplay(VALUE_DISPLAY.slider);
		
	newInput(23, nodeValue_Slider_Range("Arrow Sizes", self, [ 0.2, 0.3 ] ));
		
	newInput(24, nodeValue_Float("Arrow Head", self, 3 ));
		
	newInput(25, nodeValue_Int("Teeth Amount", self, 6 ));
		
	newInput(26, nodeValue_Vec2("Teeth Size", self, [ 0.2, 0.2 ] , { slideSpeed : 0.01 }));
		
	newInput(27, nodeValue_Rotation("Teeth Rotation", self, 0));
	
	newInput(28, nodeValue_Float("Shape Scale", self, 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(29, nodeValue_Curve("Curve", self, CURVE_DEF_01));
	
	newInput(30, nodeValue_Bool("Caps", self, false));
	
	newInput(31, nodeValue_Float("Factor", self, 2.5));
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Output",     false], 0, 6, 
		["Transform",  false], 15, 3, 16, 17, 19, 28, 
		["Shape",	   false], 14, 2, 9, 4, 13, 5, 7, 8, 21, 22, 23, 24, 25, 26, 27, 30, 31, 
		["Render",	    true], 10, 18,
		["Height",	    true, 12], 29, 20, 
		["Background",	true, 1], 11, 
	];
	
	temp_surface = [ noone ];
	use_path     = false;
	path_points  = [];
	point_simp   = [];
	triangles	 = []; 
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _hov = false;
		
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
			return _hov;
		}
		
		var _type = current_data[15];
		var _pos  = [ 0, 0 ];
		var _sca  = [ 1, 1 ];
		var _px, _py;
		var hv;
		
		var _hov = false;
		var _int = hover;
		
		if(_type == 0) {
			_pos = [ current_data[3][0], current_data[3][1] ];
			_sca = [ current_data[3][2], current_data[3][3] ];
			
		} else if(_type == 1) {
			_pos = current_data[16];
			_sca = current_data[17];
			
		}
		
		if(_type != 2) {
			if(inputs[9].show_in_inspector) {
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
				
				hv = inputs[9].drawOverlay(_int, active, _x0, _y0, _s, _mx, _my, _snx, _sny, aa, _max_s, 1); _hov |= hv; _int &= !_hov;
			}
		}
		
		if(_type == 0) {
			hv = inputs[3].drawOverlay(_int, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv; _int &= !_hov;
			
		} else if(_type == 1) {
			_px  = _x + _pos[0] * _s;
			_py  = _y + _pos[1] * _s;
			
			hv = inputs[16].drawOverlay(_int, active,  _x,  _y, _s, _mx, _my, _snx, _sny); _hov |= hv; _int &= !_hov;
			hv = inputs[17].drawOverlay(_int, active, _px, _py, _s, _mx, _my, _snx, _sny); _hov |= hv; _int &= !_hov;
		
		}
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _dim	= _data[0];
		var _bg		= _data[1];
		var _shape	= _data[2];
		var _aa		= _data[6];
		var _corner = _data[9];  _corner = clamp(_corner, 0, .9);
		var _color  = _data[10];
		var _df		= _data[12];
		var _path	= _data[14];
		var _bgC    = _data[11];
		var _bgcol  = _bg? colToVec4(_data[11]) : [0, 0, 0, 0];
		
		var _posTyp	= _data[15];
		var _tile   = _data[18];
		var _rotat  = _data[19];
		var _level  = _data[20];
		var _curve  = _data[29];
		var _shpSca = _data[28];
		
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
		
		inputs[ 4].setVisible(true);
		inputs[ 5].setVisible(true);
		inputs[ 6].setVisible(_path == noone);
		inputs[ 7].setVisible(true);
		inputs[ 8].setVisible(true);
		inputs[ 9].setVisible(true);
		inputs[12].setVisible(_path == noone);
		inputs[20].setVisible(_path == noone);
		inputs[13].setVisible(true);
		inputs[15].setVisible(true);
		inputs[30].setVisible(false);
		inputs[31].setVisible(false);
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		use_path = _path != noone && struct_has(_path, "getPointRatio");
		
		if(use_path) {
			inputs[ 3].setVisible(false);
			inputs[ 4].setVisible(false);
			inputs[ 5].setVisible(false);
			inputs[ 7].setVisible(false);
			inputs[ 8].setVisible(false);
			inputs[ 9].setVisible(false);
			inputs[13].setVisible(false);
			inputs[15].setVisible(false);
			
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
		}
		
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
					inputs[4].setVisible(true);
					inputs[7].setVisible(true);
					inputs[9].setVisible(true);
					
					shader_set_i("shape", 2);
					shader_set_i("sides", _data[4]);
					shader_set_f("angle", degtorad(_data[7]));
					break;
					
				case "Star" :
					inputs[4].setVisible(true);
					inputs[5].setVisible(true);
					inputs[7].setVisible(true);
					inputs[9].setVisible(true);
					
					inputs[5].name = "Inner radius";
					
					shader_set_i("shape", 3);
					shader_set_i("sides", _data[4]);
					shader_set_f("angle", degtorad(_data[7]));
					shader_set_f("inner", _data[5]);
					break;
					
				case "Arc" :
					inputs[5].setVisible(true);
					inputs[8].setVisible(true);
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
					
					shader_set_i("shape", 17);
					shader_set_2("arrow",      _data[23]);
					shader_set_f("arrow_head", _data[24]);
					break;
					
				case "Gear":
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
					
			}
			
			shader_set_f("dimension", _dim);
			shader_set_f("bgColor",   _bgcol);
			shader_set_i("aa",        _aa);
			shader_set_i("drawBG",    _bg);
			shader_set_i("drawDF",    _df);
			shader_set_2("dfLevel",    _level);
			shader_set_i("tile",      _tile);
			shader_set_f("corner",    _corner);
			shader_set_f("w_curve",   _curve);
			shader_set_i("w_amount",  array_length(_curve));
			
			shader_set_2("center",    _center);
			shader_set_2("scale",     _scale );
			shader_set_f("shapeScale",_shpSca);
			shader_set_f("rotation",  degtorad(_rotat));
			
			draw_sprite_stretched_ext(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1], _color, _color_get_alpha(_color));
		surface_reset_shader();
		
		return _outSurf;
	}
}