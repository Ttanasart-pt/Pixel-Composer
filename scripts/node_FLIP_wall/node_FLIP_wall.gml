function Node_FLIP_Wall(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Wall";
	color = COLORS.node_blend_fluid;
	icon  = THEME.fluid_sim;
	setDrawIcon(s_node_flip_wall);
	setDimension(96, 96);
	
	manual_ungroupable = false;
	
	newInput( 0, nodeValue_Fdomain( "Domain" )).setVisible(true, true);
	
	////- =Collider
	newInput( 1, nodeValue_Area( "Area", DEF_AREA_REF, { useShape : false } )).setUnitSimple();
	// input 2
	
	newOutput(0, nodeValue_Output("Domain", VALUE_TYPE.fdomain, noone ));
	
	input_display_list = [ 0, 
		[ "Collider", false ], 1
	];
	
	////- Node
	
	obstracle = new FLIP_Obstracle();
	
	static getDimension = function() { var d = getInputData(0); return instance_exists(d)? d.getSize() : [ 1, 1 ]; }
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active,  _x,  _y, _s, _mx, _my));
		return w_hovering;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var domain = getInputData(0);
		var _area  = getInputData(1);
		if(!instance_exists(domain)) return;
		
		outputs[0].setValue(domain);
		FLIP_setSolid_rectangle(domain.domain, _area[0], _area[1], _area[2], _area[3]);
	}
	
}