function Node_Mesh_Create_Points(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Mesh from Points";
	setDimension(96, 48);
	setDrawIcon();
	
	////- =Points
	newInput( 0, nodeValue_Vec2( "Points", [] )).setVisible(true, true).setArrayDepth(1);
	// 1
	
	newOutput( 0, nodeValue_Output( "Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var mesh = outputs[0].getValue();
		if(mesh != noone) {
			draw_set_color(COLORS._main_icon);
			mesh.draw(_x, _y, _s);
		}
	}
	
	static update = function() {
		var _pnts = getInputData( 0);
		if(array_get_depth(_pnts) != 2) return;
		
		var pamo = array_length(_pnts);
		
		var points = array_create(pamo);
		for( var i = 0; i < pamo; i++ ) 
			points[i] = new __vec2UV(_pnts[i][0], _pnts[i][1]);
		
		var edges     = [];
		var triangles = delaunay_triangulation_c(points, noone, true);
		
		var mesh = new Mesh().build(points, edges, triangles);
		outputs[0].setValue(mesh);
	}
}
