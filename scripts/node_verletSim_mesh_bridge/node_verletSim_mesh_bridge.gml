function Node_VerletSim_Mesh_Bridge(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Bridge Mesh";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	parameters.inline_draw_input = true;
	
	setDrawIcon();
	setDimension(96, 48);
	
	////- =Mesh
	newInput( 0, nodeValue_IVec2(  "Subdivision", [4,4] ));
	newInput( 1, nodeValue_Bool(   "Quad",        false ));
	
	////- =Verlet
	newInput( 2, nodeValue_Slider( "Tension",     .5    ));
	newInput( 3, nodeValue_Slider( "Drag",         0    ));
	newInput( 7, nodeValue_Slider( "Stiffness",    0    ));
	
	////- =Paths
	newInput( 4, nodeValue_Bool(   "Loop",      false ));
	newInput( 5, nodeValue_Slider( "Shift",     0     ));
	newInput( 6, nodeValue_Bool(   "Pin First", false ));
	// input 7
	
	newOutput(0, nodeValue_Output("Mesh", VALUE_TYPE.mesh, noone)).setCustomData(global.VERLET_MESH_JUNC);
	
	input_display_list = [ 
		[ "Mesh",   false ],  0,  1,
		[ "Verlet", false ],  2,  3,  
		[ "Path",   false ],  4,  5,  6, 
	];
	
	function createNewInput(index = array_length(inputs)) {
		newInput(index, nodeValue_Path( "Path" )).setVisible(true, true);
		array_push(input_display_list, index);
		return inputs[index];
	} setDynamicInput(1);
	
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
			var _subd = getInputData(0);
			var _quad = getInputData(1);
			
			var _ten  = getInputData(2), _tens = 1 - _ten;
			var _drag = getInputData(3);
			var _adrg = getInputData(7);
			
			var _loop = getInputData(4);
			var _pshf = getInputData(5);
			var _pinf = getInputData(6);
		#endregion
		
		var _pathData = [];
		var _lamo = 0;
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var _path = getInputData(i);
			if(!is_path(_path)) continue;
			
			var _la = _path.getLineCount();
			_lamo += _la;
			for( var j = 0; j < _la; j++ )
				array_push(_pathData, [_path, j]);
		}
		
		if(_lamo <= 1) return;
		
		var _pPoint = array_create(_lamo);
		var _pSamp  = _subd[0];
		var _pStep  = 1 / _pSamp;
		var _p = new __vec2P();
		
		for( var i = 0; i < _lamo; i++ ) {
			var _pathD = _pathData[i];
			var _ps    = array_create(_pSamp + 1);
			_pPoint[i] = _ps;
			
			for( var j = 0; j <= _pSamp; j++ ) {
				var _rat = j * _pStep + _pshf;
				if(_loop) _rat = frac(_rat);
				
				_p = _pathD[0].getPointRatio(clamp(_rat, 0, 0.999), _pathD[1], _p);
				_ps[j] = [_p.x, _p.y];
			}
		}
		
		var mesh = new __verlet_Mesh();
		
		var _pLoop = _pSamp + !_loop;
		
		var gw = _subd[0];
		var gh = _subd[1];
		var sx = 1 / gw;
		var sy = 1 / gh;
		var sv = 1 / gh / (_lamo - 1);
		
		var _i = 0, _e = 0, _t = 0;
		var points = [];
		
		var edges  = [];
		var vedges = [];
		var _emap  = {};
		
		var tris   = [];
		var vtris  = [];
		
		for( var p = 0; p < _lamo - 1; p++ ) {
			var _st = p * (_pSamp+1) * (gh);
			
			var _point0 = _pPoint[p+0];
			var _point1 = _pPoint[p+1];
			var _pv = p / (_lamo - 1);
			
			for( var i = 0; i <= _pSamp; i++ ) {
				var _p0 = _point0[i];
				var _p1 = _point1[i];
				var _u  = i * sx;
				
				for( var j = bool(p); j <= gh; j++ ) {
					var _v = _pv + j * sv;
					
					var _x0 = lerp(_p0[0], _p1[0], j * sy);
					var _y0 = lerp(_p0[1], _p1[1], j * sy);
					
					var _ind     = _st + j*(_pSamp+1) + i;
					points[_ind] = new __verlet_vec2(_x0, _y0, _u, _v, _ind).setDrag(_drag);
					
					if(_pinf && j == 0) points[_ind].pin = true;
				}
			}
			
			for( var i = 0; i <= gw; i++ ) {
				var _pEdge = undefined;
				if(p) {
					var _pst = (p-1) * (gw+1) * (gh);
					var _ind = __verlet_edge_index(_pst + gh * (gw+1) + (i) % _pLoop, _pst + (gh+1) * (gw+1) + (i) % _pLoop);
					_pEdge = _emap[$ _ind];
				}
				
				for( var j = bool(p); j <  gh; j++ ) {
					var i0 = _st + (j  ) * (gw+1) + (i) % _pLoop;
					var i1 = _st + (j+1) * (gw+1) + (i) % _pLoop;
					
					edges[_e]  = [ i0, i1 ];
					vedges[_e] = new __verlet_edge(points[i0], points[i1], _tens, _adrg).setMap(_emap); 
					
					if(_pEdge) {
						_pEdge.setNEdge(vedges[_e]);
						vedges[_e].setPEdge(_pEdge);
					}
					_pEdge = vedges[_e];
					
					_e++;
				}
			}
			
			for( var j = bool(p); j <= gh; j++ ) {
				var _pEdge = undefined;
		 		for( var i = 0; i <  gw; i++ ) {
					var i0 = _st + (j) * (gw+1) + (i  ) % _pLoop;
					var i1 = _st + (j) * (gw+1) + (i+1) % _pLoop;
					
					edges[_e]  = [ i0, i1 ];
					vedges[_e] = new __verlet_edge(points[i0], points[i1], _tens, _adrg).setMap(_emap); 
					
					if(_pEdge) {
						_pEdge.setNEdge(vedges[_e]);
						vedges[_e].setPEdge(_pEdge);
					}
					_pEdge = vedges[_e];
					
					_e++;
				}
			}
			
			for( var j = 0; j < gh; j++ )
			for( var i = 0; i < gw; i++ ) {
				var i0 = _st + (j  ) * (gw+1) + (i  ) % _pLoop;
				var i1 = _st + (j  ) * (gw+1) + (i+1) % _pLoop;
				var i2 = _st + (j+1) * (gw+1) + (i  ) % _pLoop;
				var i3 = _st + (j+1) * (gw+1) + (i+1) % _pLoop;
				
				tris[_t]  = [ i0, i1, i2 ];
				vtris[_t] = new __verlet_triangle(points[i0], points[i1], points[i2]).getEdge(_emap);
				_t++;
				
				tris[_t]  = [ i2, i1, i3 ];
				vtris[_t] = new __verlet_triangle(points[i2], points[i1], points[i3]).getEdge(_emap);
				_t++;
			}
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
		
		mesh.calcCoM();
		
		outputs[0].setValue(mesh);
	}
	
}
