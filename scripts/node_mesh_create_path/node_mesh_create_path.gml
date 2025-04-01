function Node_Mesh_Create_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Path to Mesh";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode("Path", self, noone))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Int("Sample", self, 8));
	
	newInput(2, nodeValue_Enum_Scroll("Algorithm", self,  0, [ "Ear Clipping", "Convex Fan", "Delaunay" ]));
	
	newOutput(0, nodeValue_Output("Mesh", self, VALUE_TYPE.mesh, noone));
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _hov = false;
		var  hv  = inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= bool(hv);
	
		var mesh = outputs[0].getValue();
		if(mesh == noone) return;
		
		draw_set_color(COLORS._main_accent);
		mesh.draw(_x, _y, _s);
	}
	
	static update = function() {  
		var _pth  = getInputData(0);
		var _sam  = getInputData(1);
		var _algo = getInputData(2);
		var mesh  = new Mesh();
		
		if(_pth == noone) return;
		_sam = max(_sam, 1);
		
		var points	 = [];
		var segCount = _pth.getSegmentCount();
		if(segCount < 1) return;
		
		var quality  = _sam;
		var sample   = quality * segCount;
		
		for( var i = 0; i < sample; i++ ) {
			var t   = i / sample;
			var pos = _pth.getPointRatio(t);
			
			array_push(points, pos);
		}
		
		var triangles = [];
		switch(_algo) {
			case 0 : triangles = polygon_triangulate(points)[0];         break;
			case 1 : triangles = polygon_triangulate_convex_fan(points); break;
			case 2 : triangles = delaunay_triangulation(points);         break;
		}
		
		for( var i = 0, n = array_length(triangles); i < n; i++ ) {
			var tr = triangles[i];
			
			if(_triangle_is_ccw(tr)) {
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
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_mesh_create_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}