function Node_VerletSim_Mesh_Tear(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Tear Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	setDimension(96, 48);
	
	newActiveInput(4);
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	////- =Target
	newInput(1, nodeValue_Enum_Scroll( "Source",  0, [ "Area", "Surface" ] ));
	newInput(2, nodeValue_Area(        "Area",    DEF_AREA_REF, { useShape : false } )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	newInput(3, nodeValue_Surface(     "Surface", noone ));
	// input 5
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 4, 0, 
		[ "Target", false ], 1, 2, 3, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _msh = getInputData(0);
		var _typ = getInputData(1);
		
		if(is(_msh, Mesh)) {
			draw_set_color(COLORS._main_icon);
			_msh.draw(_x, _y, _s);
		}
		
		if(_typ == 0) InputDrawOverlay(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
	
	static update = function() {
		var _active = getInputData(4);
		var _mesh   = getInputData(0);
		outputs[0].setValue(_mesh);
		
		var _type = getInputData(1);
		var _area = getInputData(2);
		var _surf = getInputData(3);
		
		inputs[2].setVisible(_type == 0);
		inputs[3].setVisible(_type == 1, _type == 1);
		
		if(!_active) return;
		if(!is(_mesh, __verlet_Mesh)) return;
		
		if(_type == 1) {
			if(!is_surface(_surf)) return;
			var _samp = new Surface_sampler(_surf);
		}
		
		var x0 = _area[0] - _area[2], y0 = _area[1] - _area[3];
		var x1 = _area[0] + _area[2], y1 = _area[1] + _area[3];
		
		for( var i = 0, n = array_length(_mesh.vedges); i < n; i++ ) {
			var  e    = _mesh.vedges[i];
			if(!e.active) continue;
			
			var _tear = false;
			var cx = (e.p0.x + e.p1.x) / 2;
			var cy = (e.p0.y + e.p1.y) / 2;
			
			switch(_type) {
				case 0 : _tear = point_in_rectangle(cx, cy, x0, y0, x1, y1); break;
				case 1 : _tear = bool(_samp.getPixel(cx, cy) & 0x00FFFFFF);  break;
			}
			
			if(_tear) e.active = false;
		}
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_verletsim_mesh_tear, 0, bbox);
	}
}
