function Node_VerletSim_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Mesh From Path";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	setDimension(96, 48);
	setDrawIcon(s_node_verletsim_path);
	
	////- =Path
	newInput(0, nodeValue_PathNode( "Path"         )).setVisible(true, true);
	newInput(1, nodeValue_Int(      "Samples",   8 ));
	newInput(2, nodeValue_Slider(   "Tension",  .5 ));
	newInput(3, nodeValue_Slider(   "Drag",      0 ));
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 
		[ "Path",   false ], 0, 1, 2, 3
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		
		return w_hovering;
	}
	
	static update = function() {
		if(!IS_FIRST_FRAME) return;
		
		var _path = getInputData(0);
		var _samp = getInputData(1); _samp = max(_samp, 1);
		var _tens = getInputData(2);
		var _drag = getInputData(3);
		
		if(!is_path(_path)) return;
		
		var _mesh = new __verlet_Mesh();
		
		var _points = array_create(_samp + 1);
		var _edges  = array_create(_samp);
		var _p = new __vec2P();
		
		for( var i = 0; i <= _samp; i++ ) {
			var _rat = clamp(i / _samp, 0, .999);
			
			_p = _path.getPointRatio(_rat, 0, _p);
			_points[i] = new __verlet_vec2().set2(_p);
			_p.drag = _drag;
			
			if(i) _edges[i-1] = new __verlet_edge(_points[i-1], _points[i], 1 - _tens); 
 		}
		
		_mesh.points = _points;
		_mesh.vedges = _edges;
		
		outputs[0].setValue(_mesh);
	}
	
}