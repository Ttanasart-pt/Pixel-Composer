function Node_Path_Map(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Map Path";
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true)
		.rejectArray();
	
	inputs[| 1] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF)
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 2] = nodeValue("Texture", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 3] = nodeValue("Subdivision", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 16)
		.rejectArray();
		
	outputs[| 0] = nodeValue("Rendered", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 0, 
		["Mapping", false], 1, 2, 3, 
	]
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _path = getInputData(0);
		if(_path) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
		
	static update = function() { #region
		var _path = getInputData(0);
		if(_path == noone) return;
		
		var _dim  = getInputData(1);
		var _surf = getInputData(2);
		var _sub  = getInputData(3);
		
		var _amo  = _path.getLineCount();
		
		if(!is_surface(_surf) || _amo < 2) return;
		
		var _pnt = array_create(_amo + 1);
		var _isb = 1 / _sub;
		var _pp  = new __vec2();
		
		for( var i = 0; i < _amo; i++ ) {
			var _p   = array_create(_sub + 1);
			var _ind = 0;
			
			for( var j = 0; j <= 1; j += _isb ) {
				_pp = _path.getPointRatio(j, i, _pp);
				_p[_ind++] = [ _pp.x, _pp.y ];
			}
			
			_pnt[i] = _p;
		}
		
		var _out = outputs[| 0].getValue();
		    _out = surface_verify(_out, _dim[0], _dim[1])
		
		surface_set_shader(_out, noone);
			draw_set_color(c_white);
			
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
				for( var i = 0; i < _amo - 1; i++ ) 
				for( var j = 0; j < _sub - 1; j++ ) {
					var p0 = _pnt[i + 0][j + 0];
					var p1 = _pnt[i + 1][j + 0];
					var p2 = _pnt[i + 0][j + 1];
					var p3 = _pnt[i + 1][j + 1];
				
					var p0u = (j + 0) / (_sub - 1), p0v = (i + 0) / (_amo - 1);
					var p1u = (j + 0) / (_sub - 1), p1v = (i + 1) / (_amo - 1);
					var p2u = (j + 1) / (_sub - 1), p2v = (i + 0) / (_amo - 1);
					var p3u = (j + 1) / (_sub - 1), p3v = (i + 1) / (_amo - 1);
				
					draw_vertex_texture(p0[0], p0[1], p0u, p0v);
					draw_vertex_texture(p1[0], p1[1], p1u, p1v);
					draw_vertex_texture(p2[0], p2[1], p2u, p2v);
				
					draw_vertex_texture(p1[0], p1[1], p1u, p1v);
					draw_vertex_texture(p2[0], p2[1], p2u, p2v);
					draw_vertex_texture(p3[0], p3[1], p3u, p3v);
				
				}
			draw_primitive_end();
		surface_reset_shader();
		
		outputs[| 0].setValue(_out);
	} #endregion
} 