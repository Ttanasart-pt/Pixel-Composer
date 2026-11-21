function Node_Mesh_Set_Points(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Mesh set Point";
	setDimension(96, 48);
	setDrawIcon();
	
	////- =Mesh
	newInput( 0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	////- =Points
	newInput( 1, nodeValue_Vec2( "Points", [] )).setVisible(true, true).setArrayDepth(1);
	// 2
	
	newOutput( 0, nodeValue_Output( "Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 
		[ "Mesh",   false ],  0, 
		[ "Points", false ],  1, 
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var mesh = outputs[0].getValue();
		if(mesh != noone) {
			draw_set_color(COLORS._main_icon);
			mesh.draw(_x, _y, _s);
		}
	}
	
	static update = function() {
		#region data
			var _mesh = getInputData( 0);
			var _pnts = getInputData( 1);
		#endregion
		
		if(array_get_depth(_pnts) != 2) return;
		
		var mesh = outputs[0].getValue();
		if(!is(mesh, Mesh)) mesh = new Mesh();
		outputs[0].setValue(mesh);
		
		mesh.edges     = _mesh.edges;
		
		mesh.useShape  = _mesh.useShape;
		mesh.triangles = _mesh.triangles;
		mesh.quads     = _mesh.quads;
		
		var pamo   = array_length(_pnts);
		var points = array_create(pamo);
		for( var i = 0; i < pamo; i++ ) 
			points[i] = new __vec2UV(_pnts[i][0], _pnts[i][1]);
		
		mesh.points    = points;
	}
}
