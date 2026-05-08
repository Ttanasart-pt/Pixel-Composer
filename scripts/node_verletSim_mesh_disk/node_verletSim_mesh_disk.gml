function Node_VerletSim_Mesh_Disk(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Disk Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	parameters.inline_draw_input = true;
	
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Mesh
	newInput( 0, nodeValue_Area(   "Area", DEF_AREA_REF, false )).setUnitSimple();
	newInput( 1, nodeValue_IVec2(  "Subdivision", [12,4] ));
	newInput( 4, nodeValue_Bool(   "Quad",        false  ));
	
	////- =Verlet
	newInput( 2, nodeValue_Slider( "Tension",     .5    ));
	newInput( 3, nodeValue_Slider( "Drag",         0    ));
	newInput( 5, nodeValue_Slider( "Stiffness",    0    ));
	
	////- =UV
	newInput( 6, nodeValue_Bool( "Cartesian", false ));
	// input 7
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone)).setCustomData(global.VERLET_MESH_JUNC);
	
	input_display_list = [ 
		[ "Mesh",   false ],  0,  1,  4, 
		[ "Verlet", false ],  2,  3,  5, 
		[ "UV",     false ],  6, 
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
			var _area = getInputData( 0);
			var _subd = getInputData( 1);
			var _quad = getInputData( 4);
			
			var _ten  = getInputData( 2), _tens = 1 - _ten;
			var _drag = getInputData( 3);
			var _adrg = getInputData( 5);
			
			var _cart = getInputData( 6);
		#endregion
		
		var mesh = new __verlet_Mesh();
		
		var cx = _area[0];
		var cy = _area[1];
		var cw = _area[2];
		var ch = _area[3];
		
		var gw = max(1, _subd[0]);
		var gh = max(1, _subd[1]);
		var sx = 1 / gw;
		var sy = 1 / gh;
		
		var _i = 0;
		var points = array_create(1 + gw * (gh + 1));
		
		points[0] = new __verlet_vec2(cx, cy, _cart? .5 : 0, _cart? .5 : 0, 0).setDrag(_drag);
		
		for( var j = 0; j <= gh; j++ )
		for( var i = 0; i <  gw; i++ ) {
			var _rr = (j + 1) / (gh + 1);
			var _ra = i / gw * 360;
			
			var _dx = lengthdir_x(_rr, _ra);
			var _dy = lengthdir_y(_rr, _ra);
			
			var _x0 = cx + _dx * cw;
			var _y0 = cy + _dy * ch;
			
			var _u  = _cart? .5 + _dx * .5 : i * sx;
			var _v  = _cart? .5 + _dy * .5 : j * sy;
			
			var _ind     = 1 + j * gw + i;
			points[_ind] = new __verlet_vec2(_x0, _y0, _u, _v, _ind).setDrag(_drag);
		}
		
		var edges  = array_create(gh * (gw + 1) + (gh + 1) * gw);
		var vedges = array_create(gh * (gw + 1) + (gh + 1) * gw);
		var _emap  = {};
		
		_i = 0;
		for( var i = 0; i <= gw; i++ ) {
			var _pEdge = undefined;
			for( var j = -1; j <  gh; j++ ) {
				var i0 = j < 0? 0 : 1 + (j  ) * gw + (i) % gw;
				var i1 = 1 + (j+1) * gw + (i) % gw;
				
				edges[_i]  = [ i0, i1 ];
				vedges[_i] = new __verlet_edge(points[i0], points[i1], _tens, _adrg).setMap(_emap); 
				
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
				var i0 = 1 + (j) * gw + (i  ) % gw;
				var i1 = 1 + (j) * gw + (i+1) % gw;
				
				edges[_i]  = [ i0, i1 ];
				vedges[_i] = new __verlet_edge(points[i0], points[i1], _tens, _adrg).setMap(_emap); 
				
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
			var i0 = 1 + (j  ) * gw + (i  ) % gw;
			var i1 = 1 + (j  ) * gw + (i+1) % gw;
			var i2 = 1 + (j+1) * gw + (i  ) % gw;
			var i3 = 1 + (j+1) * gw + (i+1) % gw;
			
			tris[_i]  = [ i0, i1, i2 ];
			vtris[_i] = new __verlet_triangle(points[i0], points[i1], points[i2]).getEdge(_emap);
			_i++;
			
			tris[_i]  = [ i2, i1, i3 ];
			vtris[_i] = new __verlet_triangle(points[i2], points[i1], points[i3]).getEdge(_emap);
			_i++;
		}
		
		for( var i = 0; i < gw; i++ ) {
			var i1 = 0;
			var i2 = 1 + (i  ) % gw;
			var i3 = 1 + (i+1) % gw;
			
			tris[_i]  = [ i1, i2, i3 ];
			vtris[_i] = new __verlet_triangle(points[i1], points[i2], points[i3]).getEdge(_emap);
			_i++;
		}
		
		if(_quad) {
			var _q = [];
			for( var i = 0, n = array_length(vtris); i < n; i += 2 ) 
				_q[i] = [i, i+1];
			
			mesh.quads = _q;
		}
		
		mesh.points     = points;
		mesh.edges      = edges;
		mesh.triangles  = tris;
		mesh.vedges     = vedges;
		mesh.vtriangles = vtris;
		
		mesh.center     = [_area[0], _area[1]];
		mesh.bbox       = [_area[0] - _area[2], _area[1] - _area[3], _area[0] + _area[2], _area[1] + _area[3]];
		
		mesh.calcCoM();
		
		outputs[0].setValue(mesh);
	}
	
}
