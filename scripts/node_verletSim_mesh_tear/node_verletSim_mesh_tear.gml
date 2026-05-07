function Node_VerletSim_Mesh_Tear(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tear Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	setDrawIcon();
	setDimension(96, 48);
	
	newActiveInput(4);
	newInput( 7, nodeValueSeed());
	
	////- =Mesh
	newInput(0, nodeValue_Mesh( "Mesh" )).setCustomData(global.VERLET_MESH_JUNC).setVisible(true, true);
	
	////- =Target
	newInput( 1, nodeValue_EScroll( "Source",     0, [ "Area", "Surface", "Edge Loop" ] ));
	newInput( 2, nodeValue_Area(    "Area",       DEF_AREA_REF, { useShape : false } )).setHotkey("A").setUnitSimple();
	newInput( 3, nodeValue_Surface( "Surface",    noone ));
	newInput( 5, nodeValue_Int(     "Edge Index", 0     ));
	
	////- =Tear
	newInput( 6, nodeValue_Slider(  "Chance",       1     ));
	newInput( 8, nodeValue_Bool(    "Break Vertex", false ));
	// input 9
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone)).setCustomData(global.VERLET_MESH_JUNC);
	
	input_display_list = [  4, 7, 
		[ "Mesh",   false ],  0, 
		[ "Target", false ],  1,  2,  3,  5, 
		[ "Tear",   false ],  6,  8,  
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _mesh = getInputData(0);
		var _type = getInputData(1);
		
		if(!is(_mesh, __verlet_Mesh)) return;
		
		draw_set_color(COLORS._main_icon);
		_mesh.draw(_x, _y, _s);
		
		switch(_type) {
			case 0 : InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my)); break;
			case 2 :
				var _edge = array_safe_get_fast(_mesh.vedges, getInputData(5));
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
			var _active = getInputData( 4);
			var _seed = getInputData( 7);
			
			var _mesh = getInputData( 0);
			
			var _type = getInputData( 1);
			var _area = getInputData( 2);
			var _surf = getInputData( 3);
			var _edge = getInputData( 5);
			
			var _chan = getInputData( 6);
			var _vetx = getInputData( 8);
			
			inputs[2].setVisible(_type == 0);
			inputs[3].setVisible(_type == 1, _type == 1);
			inputs[5].setVisible(_type == 2);
			
			outputs[0].setValue(_mesh);
		#endregion
		
		if(!IS_PLAYING || !_active)   return;
		if(!is(_mesh, __verlet_Mesh)) return;
		
		random_set_seed(_seed);
		
		if(_type == 2) {
			var _edge = array_safe_get_fast(_mesh.vedges, _edge);
			if(_edge == 0) return;
			
			if(random(1) < _chan) {
				_edge.active    = false;
				if(_vetx) {
					_edge.p0.active = false;
					_edge.p1.active = false;
				}
			}
			
			var p  = _edge.prevEdge;
			while(p != undefined) {
				if(random(1) < _chan) {
					p.active    = false;
					if(_vetx) {
						p.p0.active = false;
						p.p1.active = false;
					}
				}
				p = p.prevEdge;
			}
			
			var p = _edge.nextEdge;
			while(p != undefined) {
				if(random(1) < _chan) {
					p.active    = false;
					if(_vetx) {
						p.p0.active = false;
						p.p1.active = false;
					}
				}
				p = p.nextEdge;
			}
			
			return;
		}
		
		if(_type == 1) {
			if(!is_surface(_surf)) return;
			var _samp = new Surface_sampler(_surf);
		}
		
		var x0 = _area[0] - _area[2], y0 = _area[1] - _area[3];
		var x1 = _area[0] + _area[2], y1 = _area[1] + _area[3];
		
		for( var i = 0, n = array_length(_mesh.vedges); i < n; i++ ) {
			var e = _mesh.vedges[i];
			if(random(1) > _chan) continue;
			if(!e.active)         continue;
			
			var _tear = false;
			var cx = (e.p0.x + e.p1.x) / 2;
			var cy = (e.p0.y + e.p1.y) / 2;
			
			switch(_type) {
				case 0 : _tear = point_in_rectangle(cx, cy, x0, y0, x1, y1); break;
				case 1 : _tear = bool(_samp.getPixel(cx, cy) & 0x00FFFFFF);  break;
			}
			
			if(!_tear) continue;
			
			e.active = false;
			if(_vetx) {
				e.p0.active = false;
				e.p1.active = false;
			}
		}
		
	}
	
}
