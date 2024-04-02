function Node_Mesh_Create_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Path to Mesh";
	
	setDimension(96, 80);
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Sample", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 8);
	
	inputs[| 2] = nodeValue("Algorithm", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Ear Clipping", "Convex Fan", "Delaunay" ]);
	
	outputs[| 0] = nodeValue("Mesh", self, JUNCTION_CONNECT.output, VALUE_TYPE.mesh, noone);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var mesh = outputs[| 0].getValue();
		if(mesh == noone) return;
		
		draw_set_color(COLORS._main_accent);
		mesh.draw(_x, _y, _s);
	}
	
	static update = function() {  
		var _pth  = getInputData(0);
		var _sam  = getInputData(1);
		var _algo = getInputData(2);
		var mesh = new Mesh();
		
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
			case 0 : triangles = polygon_triangulate(points); break;
			case 1 : triangles = polygon_triangulate_convex_fan(points); break;
			case 2 : triangles = delaunay_triangulation(points); break;
		}
		
		mesh.points    = points;
		mesh.triangles = triangles;
		
		outputs[| 0].setValue(mesh);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_mesh_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}