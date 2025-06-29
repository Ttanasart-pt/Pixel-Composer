function Node_VerletSim_Mesh_Pin(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Pin Mesh";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	////- =Mode
	
	newInput(2, nodeValue_Enum_Button( "Mode", 0, [ "Override", "Pin", "Unpin" ] ));
	
	////- =Target
	
	newInput(3, nodeValue_Enum_Scroll( "Pin Type", 0, [ "Area" ] ));
	newInput(1, nodeValue_Area(        "Pin Area", DEF_AREA_REF, { useShape : false } )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	// input 2
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 0, 
		[ "Mode",       false ], 2,
		[ "Pin Target", false ], 3, 1,
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
		var _mesh = getInputData(0);
		
		var _mode = getInputData(2);
		
		var _type = getInputData(3);
		var _area = getInputData(1);
		
		outputs[0].setValue(_mesh);
		if(!is(_mesh, __verlet_Mesh)) return;
		
		var x0 = _area[0] - _area[2], y0 = _area[1] - _area[3];
		var x1 = _area[0] + _area[2], y1 = _area[1] + _area[3];
		
		for( var i = 0, n = array_length(_mesh.points); i < n; i++ ) {
			var  p   = _mesh.points[i];
			var _pin = point_in_rectangle(p.x, p.y, x0, y0, x1, y1);
			
			switch(_mode) {
				case 0 : p.pin = _pin;          break;
				case 1 : p.pin = p.pin || _pin; break;
				case 2 : p.pin = p.pin && _pin; break;
			}
			
		}
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_verletsim_mesh_pin, 0, bbox);
	}
}
