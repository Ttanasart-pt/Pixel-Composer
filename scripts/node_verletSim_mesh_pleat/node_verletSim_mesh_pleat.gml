function Node_VerletSim_Mesh_Pleat(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Pleat Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	////- =Target
	newInput(1, nodeValue_Area(   "Area", DEF_AREA_REF, { useShape : false } )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	
	////- =Pleat
	newInput(3, nodeValue_Slider( "Strength", .5, [0, 4, 0.01] ));
	newInput(2, nodeValue_Float(  "Amount",    4 ));
	newInput(6, nodeValue_Curve(  "Stretch Falloff", CURVE_DEF_11 ));
	newInput(4, nodeValue_Float(  "Offset",    2 ));
	newInput(5, nodeValue_Curve(  "Offset Falloff",  CURVE_DEF_10 ));
	newInput(7, nodeValue_Slider( "Contract",  1 ));
	
	// input 8
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 0, 
		[ "Target", false ], 1, 
		[ "Pleat",  false ], 3, 2, 6, 4, 5, 7, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _msh = getInputData(0);
		
		if(is(_msh, Mesh)) {
			draw_set_color(COLORS._main_icon);
			_msh.draw(_x, _y, _s);
		}
		
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
	
	static update = function() {
		var _mesh   = getInputData(0);
		outputs[0].setValue(_mesh);
		
		var _area = getInputData(1);
		
		var _str  = getInputData(3);
		var _amo  = getInputData(2); _amo = max(1, _amo);
		var _strC = getInputData(6);
		var _off  = getInputData(4);
		var _offC = getInputData(5);
		var _cont = getInputData(7);
		
		if(!is(_mesh, __verlet_Mesh)) return;
		
		var cx = _area[0];
		var cy = _area[1];
		var x0 = _area[0] - _area[2], y0 = _area[1] - _area[3];
		var x1 = _area[0] + _area[2], y1 = _area[1] + _area[3];
		var ww = _area[2] * 2;
		var hh = _area[3] * 2;
		
		var _sw = ww / _amo;
		
		for( var i = 0, n = array_length(_mesh.points); i < n; i++ ) {
			var  p  = _mesh.points[i];
			
			if(!is(p, __vec2) || !p.pin) continue;
			if(!point_in_rectangle(p.sx, p.sy, x0, y0, x1, y1)) continue;
			
			var _dx = p.sx - x0;
			var _ps = floor(_dx / _sw);
			
			var _cx = x0 + (_ps + .5) * _sw;
			var _pg = abs(p.sx - _cx) / _sw * 2;
			var _of = eval_curve_x(_offC, clamp(_pg, 0., 1.));
			var _se = eval_curve_x(_strC, clamp(_pg, 0., 1.));
			
			var _px = _cx + (p.sx - _cx) * 2 * _se;
			    _px =  cx + (_px - cx) * _cont;
			    
			var _py = _ps % 2 == 0? p.sy + _off * _of : p.sy - _off * _of;
			
			p.x = lerp(p.sx, _px, _str);
			p.y = lerp(p.sy, _py, _str);
			
		}
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_verletsim_mesh_pleat, 0, bbox);
	}
}
