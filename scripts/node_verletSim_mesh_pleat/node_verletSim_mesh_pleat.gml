function Node_VerletSim_Mesh_Pleat(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Pleat Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Mesh
	newInput( 0, nodeValue_Mesh( "Mesh" )).setCustomData(global.VERLET_MESH_JUNC).setVisible(true, true);
	
	////- =Target
	newInput( 8, nodeValue_EScroll( "Source",     1, [ "Area", "Edge Loop" ] ));
	newInput( 1, nodeValue_Area(    "Area",       DEF_AREA_REF, { useShape : false } )).setHotkey("A").setUnitSimple();
	newInput( 9, nodeValue_Int(     "Edge Index", 0 ));
	
	////- =Pleat
	newInput( 3, nodeValue_Slider( "Strength", .5, [0, 4, 0.01] ));
	newInput( 2, nodeValue_Float(  "Amount",    4 ));
	newInput( 6, nodeValue_Curve(  "Stretch Falloff", CURVE_DEF_11 ));
	newInput( 7, nodeValue_Slider( "Contract",  1 ));
	
	////- =Y Offset
	newInput( 4, nodeValue_Float(  "Offset",    2 ));
	newInput( 5, nodeValue_Curve(  "Offset Falloff",  CURVE_DEF_10 ));
	// input 8
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone)).setCustomData(global.VERLET_MESH_JUNC);
	
	input_display_list = [ 
		[ "Mesh",     false ],  0, 
		[ "Target",   false ],  8,  1,  9, 
		[ "Pleat",    false ],  3,  2,  6,  7, 
		[ "Y Offset", false ],  4,  5, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _mesh = getInputData( 0);
		var _type = getInputData( 8);
		if(!is(_mesh, Mesh)) return;
		
		draw_set_color(COLORS._main_icon);
		_mesh.drawRendered(_x, _y, _s);
		
		switch(_type) {
			case 0 : InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my)); break;
			case 1 :
				var _edge = array_safe_get_fast(_mesh.vedges, getInputData(9));
				if(_edge == 0) break;
				
				var _p0x = _x + _edge.p0.x * _s; 
				var _p0y = _y + _edge.p0.y * _s;
				
				var _p1x = _x + _edge.p1.x * _s; 
				var _p1y = _y + _edge.p1.y * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_line_width(_p0x, _p0y, _p1x, _p1y, 2);
				break;
		}
		
		return w_hovering;
	}
	
	static update = function() {
		if(!IS_PLAYING) return;
		
		#region data
			var _mesh = getInputData( 0);
			
			var _type = getInputData( 8);
			var _area = getInputData( 1);
			var _edge = getInputData( 9);
			
			var _str  = getInputData( 3);
			var _amo  = getInputData( 2); _amo = max(1, _amo);
			var _strC = getInputData( 6);
			var _cont = getInputData( 7);
			
			var _off  = getInputData( 4);
			var _offC = getInputData( 5);
			
			inputs[1].setVisible(_type == 0);
			inputs[9].setVisible(_type == 1);
			
			if(!is(_mesh, __verlet_Mesh)) return;
			outputs[0].setValue(_mesh);
		#endregion
		
		if(_type == 0) {
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
				
		} else if(_type == 1) {
			var _edge = array_safe_get_fast(_mesh.vedges, _edge);
			if(_edge == 0) return;
			
			var _loopP = [];
			var p = _edge.prevEdge;
			while(p != undefined) {
				array_push(_loopP, p);
				p = p.prevEdge;
			}
			
			var _loopN = [ ];
			var p = _edge.nextEdge;
			while(p != undefined) {
				array_push(_loopN, p);
				p = p.nextEdge;
			}
			
			var _loop  = array_reverse(_loopP);
			array_push(   _loop, _edge  );
			array_append( _loop, _loopN );
			
			var _verts = [_loop[0].p0];
			for( var i = 0, n = array_length(_loop); i < n; i++ ) 
				array_push(_verts, _loop[i].p1);
				
			for( var i = 0, n = array_length(_verts); i < n; i++ ) {
				var p = _verts[i];
				var prg = i / (n - 1) * _amo;
				
				var _pg = abs(frac(prg) * 2 - 1);
				var _se = eval_curve_x(_strC, clamp(_pg, 0., 1.));
				var _of = eval_curve_x(_offC, clamp(_pg, 0., 1.));
				
				var _px = p.sx + _se;
				var _py = p.sy + _off * _of;
				
				p.x = lerp(p.sx, _px, _str);
				p.y = lerp(p.sy, _py, _str);
			}
		}
		
	}
	
}
