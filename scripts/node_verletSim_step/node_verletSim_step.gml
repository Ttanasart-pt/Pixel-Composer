function Node_VerletSim_Step(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Step";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	update_on_frame = true;
	
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 0,  
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		
		var mesh = getInputData(0);
		if(is(mesh, __verlet_Mesh)) {
			draw_set_color(COLORS._main_icon);
			mesh.draw(_x, _y, _s);
		}
		
		return w_hovering;
	}
	
	static update = function() {
		if(!is(inline_context, Node_VerletSim_Inline)) return;
		if(!IS_PLAYING) return;
		
		var _msh = getInputData(0);
		outputs[0].setValue(_msh);
		
		if(!is(_msh, __verlet_Mesh)) return;
		inline_context.verletStep(_msh);
		
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_verletsim_step, 0, bbox);
	}
	
}
