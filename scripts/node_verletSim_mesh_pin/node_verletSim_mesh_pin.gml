function Node_VerletSim_Mesh_Pin(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Pin Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	setDrawIcon(s_node_verletsim_mesh_pin);
	setDimension(96, 48);
	
	newActiveInput(5);
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	////- =Mode
	
	newInput(2, nodeValue_Enum_Button( "Mode", 0, [ "Override", "Pin", "Unpin" ] ));
	
	////- =Target
	
	newInput(3, nodeValue_Enum_Scroll( "Source",  0, [ "Area", "Surface" ] ));
	newInput(1, nodeValue_Area(        "Area",    DEF_AREA_REF, { useShape : false } )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	newInput(4, nodeValue_Surface(     "Surface", noone ));
	// input 6
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 5, 0, 
		[ "Mode",       false ], 2,
		[ "Pin Target", false ], 3, 1, 4, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _msh = getInputData(0);
		var _typ = getInputData(3);
		
		if(is(_msh, Mesh)) {
			draw_set_color(COLORS._main_icon);
			_msh.draw(_x, _y, _s);
		}
		
		if(is(_msh, __verlet_Mesh)) 
			_msh.drawVertex(_x, _y, _s);
		
		if(_typ == 0) 
			InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
	
	static update = function() {
		var _active = getInputData(5);
		var _mesh   = getInputData(0);
		
		var _mode   = getInputData(2);
		
		var _type   = getInputData(3);
		var _area   = getInputData(1);
		var _surf   = getInputData(4);
		
		inputs[3].setVisible(_type == 0);
		inputs[4].setVisible(_type == 1, _type == 1);
		
		outputs[0].setValue(_mesh);
		
		if(!_active) return;
		if(!is(_mesh, __verlet_Mesh)) return;
		
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
