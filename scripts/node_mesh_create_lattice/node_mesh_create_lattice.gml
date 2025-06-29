function Node_Mesh_Create_Lattice(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Lattice Mesh";
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Area(  "Area", DEF_AREA_REF, { useShape : false } )).setUnitRef(function(i) /*=>*/ {return DEF_SURF}, VALUE_UNIT.reference);
	newInput( 1, nodeValue_IVec2( "Sample", [ 8, 8 ] ));
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone ));
	
	input_display_list = [
		0, 1, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var mesh = outputs[0].getValue();
		if(mesh == noone) {
			InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
			return w_hovering;
		}
		
		draw_set_color(COLORS._main_icon);
		mesh.draw(_x, _y, _s);
		InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static update = function() {  
		var _area = getInputData(0);
		var _samp = getInputData(1);
		var  mesh = new Mesh();
		
		var x0 = _area[0] - _area[2];
		var x1 = _area[0] + _area[2];
		var y0 = _area[1] - _area[3];
		var y1 = _area[1] + _area[3];
		
		var gw = max(1, _samp[0]);
		var gh = max(1, _samp[1]);
		var sx = 1 / gw;
		var sy = 1 / gh;
		
		var _i = 0;
		var points    = array_create((gw + 1) * (gh + 1));
		var triangles = [];
		
		for( var j = 0; j <= gh; j++ )
		for( var i = 0; i <= gw; i++ ) {
			var _x0 = lerp(x0, x1, i * sx);
			var _y0 = lerp(y0, y1, j * sy);
			
			points[j*(gw+1)+i] = new __vec2(_x0, _y0);
		}
		
		for( var j = 0; j < gh; j++ )
		for( var i = 0; i < gw; i++ ) {
			var p0 = (j    ) * (gw+1) + (i    );
			var p1 = (j    ) * (gw+1) + (i + 1);
			var p2 = (j + 1) * (gw+1) + (i    );
			var p3 = (j + 1) * (gw+1) + (i + 1);
			
			triangles[_i++] = [ p0, p1, p2 ];
			triangles[_i++] = [ p2, p1, p3 ];
		}
		
		mesh.points    = points;
		mesh.triangles = triangles;
		mesh.calcCoM();
		outputs[0].setValue(mesh);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_mesh_create_lattice, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}