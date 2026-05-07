function Node_VerletSim_Step(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Step";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	update_on_frame = true;
	
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Mesh
	newInput( 0, nodeValue_Mesh( "Mesh" )).setCustomData(global.VERLET_MESH_JUNC).setVisible(true, true);
	
	////- =Simulation
	newInput( 1, nodeValue_Bool( "Pre-render", false ));
	newInput( 2, nodeValue_Int(  "Step",       1     ));
	// 3
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone)).setCustomData(global.VERLET_MESH_JUNC);
	
	input_display_list = [ 
		[ "Mesh",       false ],  0, 
		[ "Simulation", false ],  1,  2, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var mesh = getInputData(0);
		if(is(mesh, __verlet_Mesh)) {
			draw_set_color(COLORS._main_icon);
			mesh.draw(_x, _y, _s);
		}
		
		return w_hovering;
	}
	
	static update = function(_frame = CURRENT_FRAME) {
		if(!is(inline_context, Node_VerletSim_Inline)) return;
		if(!IS_PLAYING) return;
		
		#region data
			var _mesh = getInputData(0);
			
			var _prer = getInputData(1);
			var _step = getInputData(2);
		#endregion
		
		if(!is(_mesh, __verlet_Mesh)) return;
		outputs[0].setValue(_mesh);
		
		if(_prer && !IS_FIRST_FRAME) return;
		repeat(_step) inline_context.verletStep(_mesh);
		
	}
	
}
