function Node_Path_SDF(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Path to SDF";
	dimension_index = 1;
	
	newInput(0, nodeValue_PathNode("Path", self, noone))
		.setVisible(true, true)
		.rejectArray();
		
	newInput(1, nodeValue_Dimension(self));
	
	newInput(2, nodeValue_Int("Subdivision", self, 64))
		.setValidator(VV_min(2))
		.rejectArray();
		
	newInput(3, nodeValue_Float("Max Distance", self, 16));
		
	newInput(4, nodeValue_Bool("Inverted", self, false));
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Path",   false], 1, 2,
		["Render", false], 3, 4, 
	]
	
	attribute_surface_depth();
	
	temp_surface = [ 0, 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getInputData(0);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _path = _data[0];
		var _dim  = _data[1];
		var _sub  = _data[2];
		var _maxd = _data[3];
		var _inv  = _data[4];
		
		if(_path == noone) return _outSurf;
		
		var _p   = array_create((_sub + 1) * 2);
		var _isb = 1 / _sub;
		var _pp  = new __vec2P();
		
		for( var i = 0; i <= _sub; i++ ) {
			var _prog = frac(i * _isb);
			
			_pp = _path.getPointRatio(_prog, 0, _pp);
			_p[i * 2 + 0] = _pp.x;
			_p[i * 2 + 1] = _pp.y;
		}
		
		surface_set_shader(_outSurf, sh_path_sdf);
			shader_set_2("dimension",   _dim);
			shader_set_i("subdivision", _sub);
			shader_set_f("points",      _p);
			shader_set_f("maxDistance", _maxd);
			shader_set_i("inverted",    _inv);
			
			draw_empty();
		surface_reset_shader();
		
		return _outSurf;
	}
} 