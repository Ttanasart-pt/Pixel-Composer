function Node_MK_Flag(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Flag";
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 3] = nodeValue("Pin side", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Left", "Right", "Up", "Down" ]);
	
	inputs[| 4] = nodeValue("Subdivision", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 5] = nodeValue("Wind speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2);
	
	inputs[| 6] = nodeValue("Wave width", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 2);
	
	inputs[| 7] = nodeValue("Wave size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 4);
	
	inputs[| 8] = nodeValue("Phase", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	input_display_list = [ 0, 
		["Flag",	false], 4, 1, 2, 3, 
		["Wave",	false], 6, 7, 5, 8, 
	];
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	attributes.iteration = 4;
	array_push(attributeEditors, "Verlet solver");
	array_push(attributeEditors, ["Iteration", function() { return attributes.iteration; }, 
		new textBox(TEXTBOX_INPUT.number, function(val) { 
			attributes.iteration = val; 
			triggerRender();
		})]);
		
	function fPoints(_x, _y, _u, _v) constructor { #region
		x   = _x;
		y   = _y;
		sx  = _x;
		sy  = _y;
		u   = _u;
		v   = _v;
		pin = false;
	} #endregion
	
	function fLink(_p0, _p1) constructor { #region
		p0 = _p0;
		p1 = _p1;
		dist = point_distance(_p0.x, _p0.y, _p1.x, _p1.y);
	} #endregion
	
	function fMesh(_p0, _p1, _p2) constructor { #region
		p0 = _p0;
		p1 = _p1;
		p2 = _p2;
	} #endregion
	
	points = [];
	links  = [];
	meshes = [];
	
	static setGeometry = function() { #region
		var _surf  = getSingleValue(1); if(!is_surface(_surf)) return;
		var _start = getSingleValue(2);
		var _pinn  = getSingleValue(3);
		var _subd  = getSingleValue(4);
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf);
		
		points = array_create((_subd + 1) * (_subd + 1));
		links  = array_create(2 * _subd * (_subd + 1));
		meshes = array_create(2 * _subd * _subd);
		
		var _ind = 0;
		for( var i = 0; i <= _subd; i++ ) 
		for( var j = 0; j <= _subd; j++ ) {
			var _x = _start[0] + i / _subd * _sw;
			var _y = _start[1] + j / _subd * _sh;
			
			points[_ind++] = new fPoints(_x, _y, i / _subd, j / _subd);
		}
		
		switch(_pinn) {
			case 0 : for( var i = 0; i <= _subd; i++ ) points[i].pin = true; break;
			case 1 : for( var i = 0; i <= _subd; i++ ) points[_subd * (_subd + 1) + i].pin = true; break;
			case 2 : for( var i = 0; i <= _subd; i++ ) points[i * (_subd + 1) + 0].pin     = true; break;
			case 3 : for( var i = 0; i <= _subd; i++ ) points[i * (_subd + 1) + _subd].pin = true; break;
		}
		
		var _ind = 0;
		for( var k = 0; k < 2; k++)
		for( var i = 0; i <  _subd; i++ ) 
		for( var j = 0; j <= _subd; j++ ) {
			var p0x = k? i : j;
			var p0y = k? j : i;
			var p1x = k? i + 1 : j;
			var p1y = k? j : i + 1;
			
			var i0 = p0y * (_subd + 1) + p0x;
			var i1 = p1y * (_subd + 1) + p1x;
			
			links[_ind++] = new fLink(points[i0], points[i1]);
		}
		
		var _ind = 0;
		for( var i = 0; i < _subd; i++ ) 
		for( var j = 0; j < _subd; j++ ) {
			var i0 = i * (_subd + 1) + j;
			var i1 = i * (_subd + 1) + j + 1;
			var i2 = (i + 1) * (_subd + 1) + j;
			
			meshes[_ind++] = new fMesh(points[i0], points[i1], points[i2]);
			
			var i0 = i * (_subd + 1) + j + 1;
			var i1 = (i + 1) * (_subd + 1) + j;
			var i2 = (i + 1) * (_subd + 1) + j + 1;
			
			meshes[_ind++] = new fMesh(points[i0], points[i1], points[i2]);
		}
	} #endregion
	
	static stepFlag = function() { #region
		var _pinn = getSingleValue(3);
		var _wspd = getSingleValue(5);
		var _wave = getSingleValue(6);
		var _wavz = getSingleValue(7);
		var _wphs = getSingleValue(8);
		
		var _tps = CURRENT_FRAME / TOTAL_FRAMES * _wspd * pi * 2;
		
		for( var i = 0, n = array_length(points); i < n; i++ ) {
			var p = points[i];
			
			switch(_pinn) {
				case 0 : 
					var y0 = p.sy + max(-0.2, sin(p.u           * pi * _wave - _tps)) * _wavz * p.u; 
					var y1 = p.sy + min( 0.2, sin((p.u - _wphs) * pi * _wave - _tps)) * _wavz * p.u;
					
					p.y = lerp(y0, y1, p.v);
					break;
			}
		}
	} #endregion
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _a = inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny); active &= _a;
		
		//for( var i = 0, n = array_length(links); i < n; i++ ) {
		//	var _l = links[i];
			
		//	var p0 = _l.p0;
		//	var p1 = _l.p1;
			
		//	var _p0x = _x + p0.x * _s;
		//	var _p0y = _y + p0.y * _s;
		//	var _p1x = _x + p1.x * _s;
		//	var _p1y = _y + p1.y * _s;
			
		//	if(p0.pin && p1.pin) {
		//		draw_set_color(COLORS._main_text);
		//		draw_line_width(_p0x, _p0y, _p1x, _p1y, 2);
		//	} else {
		//		draw_set_color(COLORS._main_accent);
		//		draw_line(_p0x, _p0y, _p1x, _p1y);
		//	}
		//}
	} #endregion
	
	static processData_prebatch  = function() { #region
		if(CURRENT_FRAME == 0) setGeometry();
		stepFlag();
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _dim = _data[0];
		var _tex = _data[1];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		if(!is_surface(_tex)) return _outSurf;
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			draw_set_color(c_white);
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_tex));
			
			for( var i = 0, n = array_length(meshes); i < n; i++ ) {
				var m = meshes[i];
				
				var p0 = m.p0;
				var p1 = m.p1;
				var p2 = m.p2;
				
				draw_vertex_texture(p0.x, p0.y, p0.u, p0.v);
				draw_vertex_texture(p1.x, p1.y, p1.u, p1.v);
				draw_vertex_texture(p2.x, p2.y, p2.u, p2.v);
			}
			
			draw_primitive_end();
		surface_reset_target();
		
		return _outSurf;
	} #endregion
}