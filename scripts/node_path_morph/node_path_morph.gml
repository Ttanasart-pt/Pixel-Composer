function Node_Path_Morph(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Morph Path";
	dimension_index = 2;
	
	newInput(0, nodeValue_PathNode("Path 1", self, noone))
		.setVisible(true, true)
		.rejectArray();
	
	newInput(1, nodeValue_PathNode("Path 2", self, noone))
		.setVisible(true, true)
		.rejectArray();
		
	newInput(2, nodeValue_Dimension(self));
	
	newInput(3, nodeValue_Int("Subdivision", self, 64))
		.setValidator(VV_min(2))
		.rejectArray();
		
	newInput(4, nodeValue_Bool("Clip In-Out", self, false))
		
	newInput(5, nodeValue_Curve("Curve", self, CURVE_DEF_01));
	
	newInput(6, nodeValue_Bool("Match index", self, false))
	
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 1, 
		["Morphing",  false], 2, 3, 6, 
		["Rendering", false], 5, 4, 
	]
	
	attribute_surface_depth();
	
	temp_surface = [ 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getInputData(0);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _path = getInputData(1);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _path1 = _data[0];
		var _path2 = _data[1];
		if(_path1 == noone || _path2 == noone) return _outSurf;
		
		var _dim = _data[2];
		var _sub = _data[3] + 1;
		var _clp = _data[4];
		var _cur = _data[5];
		var _mid = _data[6];
		
		var _isb = 1 / (_sub - 1);
		var _pp  = new __vec2P();
		
		if(_mid) {
			var _p1 = array_create(_sub * 2);
			var _p2 = array_create(_sub * 2);
			var  p1 = array_create(_sub);
			var  p2 = array_create(_sub);
			
			cx1 = 0; cy1 = 0;
			cx2 = 0; cy2 = 0;
			
			for( var i = 0; i < _sub; i++ ) {
				var _prog = frac(i * _isb);
				
				_pp   = _path1.getPointRatio(_prog, 0, _pp);
				p1[i] = [ _pp.x, _pp.y ];
				
				cx1 += _pp.x;
				cy1 += _pp.y;
				
				_pp   = _path2.getPointRatio(_prog, 0, _pp);
				p2[i] = [ _pp.x, _pp.y ];
				
				cx2 += _pp.x;
				cy2 += _pp.y;
			}
			
			cx1 /= _sub;
			cy1 /= _sub;
			cx2 /= _sub;
			cy2 /= _sub;
			
			// array_sort(p1, (a,b) => { return point_direction(cx1, cy1, a[0], a[1]) - point_direction(cx1, cy1, b[0], b[1]); });
			// array_sort(p2, (a,b) => { return point_direction(cx2, cy2, a[0], a[1]) - point_direction(cx2, cy2, b[0], b[1]); });
			
			for( var i = 0; i < _sub; i++ ) {
				_p1[i * 2 + 0] = p1[i][0];
				_p1[i * 2 + 1] = p1[i][1];
				
				_p2[i * 2 + 0] = p2[i][0];
				_p2[i * 2 + 1] = p2[i][1];
			}
			
		} else {
			var _p1 = array_create(_sub * 2);
			var _p2 = array_create(_sub * 2);
			
			for( var i = 0; i < _sub; i++ ) {
				var _prog = frac(i * _isb);
				
				_pp = _path1.getPointRatio(_prog, 0, _pp);
				_p1[i * 2 + 0] = _pp.x;
				_p1[i * 2 + 1] = _pp.y;
				
				_pp = _path2.getPointRatio(_prog, 0, _pp);
				_p2[i * 2 + 0] = _pp.x;
				_p2[i * 2 + 1] = _pp.y;
			}
		}
		
		surface_set_shader(_outSurf, sh_path_morph);
			shader_set_2("dimension",   _dim);
			shader_set_i("subdivision", _sub);
			shader_set_i("clip",        _clp);
			shader_set_i("matchIndex",  _mid);
			shader_set_f("point1",      _p1);
			shader_set_f("point2",      _p2);
			
			shader_set_f("w_curve",   _cur);
			shader_set_i("w_amount",  array_length(_cur));
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
} 