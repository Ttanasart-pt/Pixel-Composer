function Node_VerletSim_Mesh_Pin(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Pin Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	setDrawIcon();
	setDimension(96, 48);
	
	newActiveInput(5);
	
	////- =Mesh
	newInput( 0, nodeValue_Mesh( "Mesh" )).setCustomData(global.VERLET_MESH_JUNC).setVisible(true, true);
	
	////- =Mode
	newInput( 2, nodeValue_EButton( "Mode", 0, [ "Override", "Pin", "Unpin" ] ));
	
	////- =Target
	newInput( 3, nodeValue_EScroll( "Source",     0, [ "Area", "Surface", "Edge Loop" ] ));
	newInput( 1, nodeValue_Area(    "Area",       DEF_AREA_REF, { useShape : false } )).setUnitSimple();
	newInput( 4, nodeValue_Surface( "Surface",    noone ));
	newInput( 6, nodeValue_Int(     "Edge Index", 0     ));
	// input 7
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone)).setCustomData(global.VERLET_MESH_JUNC);
	
	input_display_list = [  5, 
		[ "Mesh",       false ],  0, 
		[ "Mode",       false ],  2,
		[ "Pin Target", false ],  3,  1,  4,  6, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _mesh = getInputData(0);
		var _type = getInputData(3);
		
		if(!is(_mesh, __verlet_Mesh)) return;
		
		draw_set_color(COLORS._main_icon);
		_mesh.draw(_x, _y, _s);
		_mesh.drawVertex(_x, _y, _s);
		
		switch(_type) {
			case 0 : drawOverlayInput(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my)); break;
			case 2 :
				var _edge = array_safe_get_fast(_mesh.vedges, getInputData(6));
				if(_edge == 0) break;
				
				var _p0x = _x + _edge.p0.sx * _s; 
				var _p0y = _y + _edge.p0.sy * _s;
				
				var _p1x = _x + _edge.p1.sx * _s; 
				var _p1y = _y + _edge.p1.sy * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_line_width(_p0x, _p0y, _p1x, _p1y, 2);
				break;
		}
		
		return w_hovering;
	}
	
	static update = function() {
		#region data
			var _active = getInputData(5);
			var _mesh   = getInputData(0);
			
			var _mode   = getInputData(2);
			
			var _type   = getInputData(3);
			var _area   = getInputData(1);
			var _surf   = getInputData(4);
			var _edge   = getInputData(6);
			
			inputs[1].setVisible(_type == 0);
			inputs[4].setVisible(_type == 1, _type == 1);
			inputs[6].setVisible(_type == 2);
			
			outputs[0].setValue(_mesh);
		#endregion
		
		if(!_active) return;
		if(!is(_mesh, __verlet_Mesh)) return;
		
		if(_type == 2) {
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
			
			for( var i = 0, n = array_length(_mesh.points); i < n; i++ ) {
				var p = _mesh.points[i];
				p.pin = false;
			}
			
			for( var i = 0, n = array_length(_loopP); i < n; i++ ) {
				var p = _loopP[i].p0;
				switch(_mode) {
					case 0 : p.pin = true;          break;
					case 1 : p.pin = p.pin || true; break;
					case 2 : p.pin = p.pin && true; break;
				}	
			}
			
			for( var i = 0, n = array_length(_loopN); i < n; i++ ) {
				var p = _loopN[i].p1;
				switch(_mode) {
					case 0 : p.pin = true;          break;
					case 1 : p.pin = p.pin || true; break;
					case 2 : p.pin = p.pin && true; break;
				}	
			}
			
			var p = _edge.p0;
			switch(_mode) {
				case 0 : p.pin = true;          break;
				case 1 : p.pin = p.pin || true; break;
				case 2 : p.pin = p.pin && true; break;
			}	
			
			var p = _edge.p1;
			switch(_mode) {
				case 0 : p.pin = true;          break;
				case 1 : p.pin = p.pin || true; break;
				case 2 : p.pin = p.pin && true; break;
			}	
			return;
		}
		
		if(_type == 1) {
			if(!is_surface(_surf)) return;
			var _samp = new Surface_sampler(_surf);
		}
		
		var x0 = _area[0] - _area[2], y0 = _area[1] - _area[3];
		var x1 = _area[0] + _area[2], y1 = _area[1] + _area[3];
		
		for( var i = 0, n = array_length(_mesh.points); i < n; i++ ) {
			var  p   = _mesh.points[i];
			if(!is(p, __vec2)) continue;
			var _pin = false;
			
			switch(_type) {
				case 0 : _pin = point_in_rectangle(p.x, p.y, x0, y0, x1, y1); break;
				case 1 : _pin = bool(_samp.getPixel(p.x, p.y) & 0x00FFFFFF);  break;
			}
			
			switch(_mode) {
				case 0 : p.pin = _pin;          break;
				case 1 : p.pin = p.pin || _pin; break;
				case 2 : p.pin = p.pin && _pin; break;
			}
			
		}
		
	}
	
}
