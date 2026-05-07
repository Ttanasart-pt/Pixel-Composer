function Node_VerletSim_Mesh_Grid(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Grid Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	parameters.inline_draw_input = true;
	
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Mesh
	newInput( 0, nodeValue_Area(   "Area", DEF_AREA_REF )).setUnitSimple();
	newInput( 1, nodeValue_IVec2(  "Subdivision", [4,4] ));
	newInput( 4, nodeValue_Bool(   "Quad",        false ));
	
	////- =Verlet
	newInput( 2, nodeValue_Slider( "Tension",     .5    ));
	newInput( 3, nodeValue_Slider( "Drag",         0    ));
	// input 5
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone)).setCustomData(global.VERLET_MESH_JUNC);
	
	input_display_list = [ 
		[ "Mesh",   false ],  0,  1,  4, 
		[ "Verlet", false ],  2,  3,  
	];
	
	////- Nodes
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_VerletSim_Inline)? inline_context.getDimension() : DEF_SURF};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _msh = outputs[0].getValue();
		
		if(is(_msh, Mesh)) {
			draw_set_color(COLORS._main_icon);
			_msh.draw(_x, _y, _s);
			_msh.drawVertex(_x, _y, _s);
		}
		
		InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
		
		return w_hovering;
	}
	
	static update = function() {
		if(!IS_FIRST_FRAME) return;
		
		#region data
			var _area = getInputData(0);
			var _subd = getInputData(1);
			var _quad = getInputData(4);
			
			var _ten  = getInputData(2), _tens = 1 - _ten;
			var _drag = getInputData(3);
		#endregion
		
		var mesh = new __verlet_Mesh();
		
		var x0 = _area[0] - _area[2];
		var x1 = _area[0] + _area[2];
		var y0 = _area[1] - _area[3];
		var y1 = _area[1] + _area[3];
		
		var gw = max(1, _subd[0]);
		var gh = max(1, _subd[1]);
		var sx = 1 / gw;
		var sy = 1 / gh;
		
		var _i = 0;
		var points = array_create((gw + 1) * (gh + 1));
		
		for( var j = 0; j <= gh; j++ )
		for( var i = 0; i <= gw; i++ ) {
			var _u  = i * sx;
			var _v  = j * sy;
			
			var _x0 = lerp(x0, x1, _u);
			var _y0 = lerp(y0, y1, _v);
			
			var _ind     = j*(gw+1)+i;
			points[_ind] = new __verlet_vec2(_x0, _y0, _u, _v, _ind);
		}
		
		var edges  = array_create(gh * (gw + 1) + (gh + 1) * gw);
		var vedges = array_create(gh * (gw + 1) + (gh + 1) * gw);
		var _emap  = {};
		
		_i = 0;
		for( var i = 0; i <= gw; i++ ) {
			var _pEdge = undefined;
			for( var j = 0; j <  gh; j++ ) {
				var i0 = (j  ) * (gw+1) + (i);
				var i1 = (j+1) * (gw+1) + (i);
				
				edges[_i]  = [ i0, i1 ];
				vedges[_i] = new __verlet_edge(points[i0], points[i1], _tens).setMap(_emap); 
				
				if(_pEdge) {
					_pEdge.setNEdge(vedges[_i]);
					vedges[_i].setPEdge(_pEdge);
				}
				_pEdge = vedges[_i];
				
				_i++;
			}
		}
		
		for( var j = 0; j <= gh; j++ ) {
			var _pEdge = undefined;
	 		for( var i = 0; i <  gw; i++ ) {
				var i0 = (j) * (gw+1) + (i  );
				var i1 = (j) * (gw+1) + (i+1);
				
				edges[_i]  = [ i0, i1 ];
				vedges[_i] = new __verlet_edge(points[i0], points[i1], _tens).setMap(_emap); 
				
				if(_pEdge) {
					_pEdge.setNEdge(vedges[_i]);
					vedges[_i].setPEdge(_pEdge);
				}
				_pEdge = vedges[_i];
				
				_i++;
			}
		}
		
		var tris   = array_create(gw * gh);
		var vtris  = array_create(gw * gh);
		
		_i = 0;
		for( var j = 0; j < gh; j++ )
		for( var i = 0; i < gw; i++ ) {
			var i0 = (j  ) * (gw+1) + (i  );
			var i1 = (j  ) * (gw+1) + (i+1);
			var i2 = (j+1) * (gw+1) + (i  );
			var i3 = (j+1) * (gw+1) + (i+1);
			
			tris[_i]  = [ i0, i1, i2 ];
			vtris[_i] = new __verlet_triangle(points[i0], points[i1], points[i2]).getEdge(_emap);
			_i++;
			
			tris[_i]  = [ i2, i1, i3 ];
			vtris[_i] = new __verlet_triangle(points[i2], points[i1], points[i3]).getEdge(_emap);
			_i++;
		}
		
		_i = 0;
		if(_quad) {
			var _qamo = gw * gh;
			var _q = array_create(_qamo);
			
			for( var i = 0; i < _qamo; i++ )
				_q[i] = [i*2, i*2+1];
			
			mesh.quads = _q;
		}
		
		mesh.points     = points;
		mesh.edges      = edges;
		mesh.triangles  = tris;
		mesh.vedges     = vedges;
		mesh.vtriangles = vtris;
		
		mesh.center     = [_area[0], _area[1]];
		mesh.bbox       = [x0, y0, x1, y1];
		
		mesh.calcCoM();
		
		outputs[0].setValue(mesh);
	}
	
}
