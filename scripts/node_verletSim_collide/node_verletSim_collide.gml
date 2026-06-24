function Node_VerletSim_Collide(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Collide";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	update_on_frame = true;
	setDrawIcon();
	setDimension(96, 48);
	
	newActiveInput(1);
	
	////- =Mesh
	newInput( 0, nodeValue_Mesh( "Mesh" )).setCustomData(global.VERLET_MESH_JUNC).setVisible(true, true);
	
	////- =Collider
	newInput( 2, nodeValue_Area(    "Area", [ .5, .5, .2, .2, AREA_SHAPE.rectangle, AREA_MODE.area ], false )).setUnitSimple();
	newInput( 3, nodeValue_EScroll( "Shape", 0, [ "Rectangle", "Circle" ] ));
	// input 4
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone)).setCustomData(global.VERLET_MESH_JUNC);
	
	input_display_list = [ 1, 
		[ "Mesh",     false ], 0, 
		[ "Collider", false ], 2, 3, 
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_VerletSim_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _mesh = getInputData(0);
		var _area = getInputData(2);
		var _shap = getInputData(3);
		
		if(is(_mesh, __verlet_Mesh)) {
			draw_set_color(COLORS._main_icon);
			_mesh.draw(_x, _y, _s);
		}
		
		drawOverlayInput(inputs[2].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		return w_hovering;
	}
	
	static update = function() {
		if(!is(inline_context, Node_VerletSim_Inline)) return;
		
		#region data
			var _active = getInputData(1);
			var _mesh   = getInputData(0);
			
			var _area   = getInputData(2);
			var _shap   = getInputData(3);
			
			outputs[0].setValue(_mesh);
		#endregion
		
		if(!_active) return;
		
		var _collider = {
			shape : _shap, 
			area  : _area, 
		}
		
		array_push(inline_context.colliders, _collider);
	}
	
}
