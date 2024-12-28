function Node_Path_Morph(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Morph Path";
	
	newInput(0, nodeValue_PathNode("Path 1", self, noone))
		.setVisible(true, true)
		.rejectArray();
	
	newInput(1, nodeValue_PathNode("Path 2", self, noone))
		.setVisible(true, true)
		.rejectArray();
		
	newInput(2, nodeValue_Dimension(self));
	
	newInput(3, nodeValue_Int("Subdivision", self, 512))
		.setValidator(VV_min(2))
		.rejectArray();
		
	newOutput(0, nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 1, 
		["Morphing", false], 2, 3, 
	]
	
	temp_surface = [ 0 ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getInputData(0);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _path = getInputData(1);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static update = function() {
		var _path1 = getInputData(0);
		var _path2 = getInputData(1);
		if(_path1 == noone || _path2 == noone) return;
		
		var _dim = getInputData(2);
		var _sub = getInputData(3);
		
		var _p1 = array_create(_sub * 2);
		var _p2 = array_create(_sub * 2);
		
		var _isb = 1 / (_sub - 1);
		var _pp  = new __vec2();
		
		for( var i = 0; i < _sub; i++ ) {
			var _prog = frac(i * _isb);
			
			_pp = _path1.getPointRatio(_prog, 0, _pp);
			_p1[i * 2 + 0] = _pp.x;
			_p1[i * 2 + 1] = _pp.y;
			
			_pp = _path2.getPointRatio(_prog, 0, _pp);
			_p2[i * 2 + 0] = _pp.x;
			_p2[i * 2 + 1] = _pp.y;
		}
		
		var _out = outputs[0].getValue();
		    _out = surface_verify(_out, _dim[0], _dim[1])
		
		surface_set_shader(_out, sh_path_morph);
			shader_set_2("dimension",   _dim);
			shader_set_i("subdivision", _sub);
			shader_set_f("point1",      _p1);
			shader_set_f("point2",      _p2);
			
			draw_empty();
		surface_reset_shader();
		
		outputs[0].setValue(_out);
	}
} 