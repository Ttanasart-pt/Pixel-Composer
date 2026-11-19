function Node_Mesh_Create_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path to Mesh";
	setDimension(96, 48);
	setDrawIcon();
	
	////- =Path
	newInput( 0, nodeValue_Path(    "Path"      ));
	newInput( 1, nodeValue_Float(   "Sample", 8 ));
	
	////- =Mesh
	newInput( 2, nodeValue_EScroll( "Algorithm", 0, [ "Ear Clipping", "Convex Fan", "Delaunay" ] ));
	// 3
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone));
	
	input_display_list = [
		[ "Path", false ],  0,  1, 
		[ "Mesh", false ],  2, 
	]
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		drawOverlayInput(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _params));
	
		var mesh = outputs[0].getValue();
		if(mesh == noone) return w_hovering;
		
		draw_set_color(COLORS._main_icon);
		mesh.draw(_x, _y, _s);
		
		return w_hovering;
	}
	
	static update = function() {  
		#region data 
			var _pth  = getInputData(0);
			
			var _sam  = getInputData(1);
			var _algo = getInputData(2);
		#endregion
			
		var mesh  = new Mesh();
		
		if(_pth == noone) return;
		
		var points	 = [];
		var segCount = _pth.getSegmentCount();
		if(segCount < 1) return;
		
		var quality  = _sam;
		var sample   = round(quality * segCount);
		var polygon  = [];
		
		if(sample < 1) return;
		
		for( var i = 0; i < sample; i++ ) {
			var t   = i / sample;
			var pos = _pth.getPointRatio(t);
			
			array_push(points, pos);
			array_push(polygon, [pos.x, pos.y]);
		}
		
		var triangles = [];
		switch(_algo) {
			case 0 : triangles = polygon_triangulate(points, 4, true)[0];         break;
			case 1 : triangles = polygon_triangulate_convex_fan(points, true);    break;
			case 2 : triangles = delaunay_triangulation_c(points, polygon, true); break;
		}
		
		for( var i = 0, n = array_length(triangles); i < n; i++ ) {
			var tr = triangles[i];
			
			if(_triangle_is_ccw([ points[tr[0]], points[tr[1]], points[tr[2]] ])) {
	    		var p0 = tr[0];
	    		var p1 = tr[1];
	    		var p2 = tr[2];
	    		
	    		tr[0] = p0;
				tr[1] = p2;
				tr[2] = p1;
			}
		}
		
		mesh.points    = points;
		mesh.triangles = triangles;
		mesh.calcCoM();
		
		outputs[0].setValue(mesh);
	}
}