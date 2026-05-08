function Node_VerletSim_Bloat(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Bloat";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	update_on_frame = true;
	setDrawIcon();
	setDimension(96, 48);
	
	newActiveInput(1);
	
	////- =Mesh
	newInput( 0, nodeValue_Mesh( "Mesh" )).setCustomData(global.VERLET_MESH_JUNC).setVisible(true, true);
	
	////- =Bloat
	newInput( 2, nodeValue_Area(  "Area", AREA_DEF_REF )).setHotkey("G").setUnitSimple();
	newInput( 3, nodeValue_Float( "Falloff",       4     ));
	newInput( 4, nodeValue_Curve( "Falloff Curve", CURVE_DEF_01 ));
	newInput( 5, nodeValue_Float( "Strength",      1     ));
	
	////- =Effect
	newInput( 6, nodeValue_Bool( "Use origin", true ));
	// 7
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone)).setCustomData(global.VERLET_MESH_JUNC);
	
	input_display_list = [ 1, 
		[ "Mesh",   false ],  0, 
		[ "Bloat",  false ],  2,  3,  4,  5, 
		[ "Effect", false ],  6, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _mesh = getInputData(0);
		
		if(is(_mesh, __verlet_Mesh)) {
			draw_set_color(COLORS._main_icon);
			_mesh.draw(_x, _y, _s);
		}
		
		InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		return w_hovering;
	}
	
	static update = function() {
		if(!IS_PLAYING) return;
		
		#region data
			var _active = getInputData( 1);
			var _mesh   = getInputData( 0);
			outputs[0].setValue(_mesh);
			
			var _area   = getInputData( 2);
			var _fall   = getInputData( 3);
			var _fcurv  = getInputData( 4), _falloff_curve = new curveMap(_fcurv);
			var _stren  = getInputData( 5);
			
			var _useo   = getInputData( 6);
			
			if(!_active) return;
			if(!is(_mesh, __verlet_Mesh)) return;
		#endregion
		
		var cx = _area[0];
		var cy = _area[1];
		var tx = 0;
		var ty = 0;
		
		for( var i = 0, n = array_length(_mesh.points); i < n; i++ ) {
			var  p  = _mesh.points[i];
			if(!is(p, __vec2) || p.pin) continue;
			
			var _x = _useo? p.sx : p.x;
			var _y = _useo? p.sy : p.y;
			
			var _inf = area_get_point_influence(_area, _fall, _falloff_curve, _x, _y);
			if(_inf <= 0) continue;
			
			var _dis = point_distance(cx, cy, _x, _y);
			if(_dis <= 0) continue;
			
			var _dir = point_direction(cx, cy, _x, _y);
			var _blo = _inf * _stren;
			
			var dx = lengthdir_x(_blo, _dir);
			var dy = lengthdir_y(_blo, _dir);
			
			p.x += dx;
			p.y += dy;
			
			tx += dx;
			ty += dy;
		}
		
	}
	
}
