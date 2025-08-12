function __3dMeshExtrude() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	object_counts = 3;
	smooth = false;
	mesh   = noone;
	taper  = 0;
    height = 1;
	
	static initModel = function() { 
	    if(mesh == noone) return;
		
		edges   = [];
		var eid = 0;
	    
	    var _pnts = mesh.points;
	    var _tris = mesh.triangles;
	    var _bbox = mesh.bbox;
	    var _minx = _bbox[0], _miny = _bbox[1];
	    var _maxx = _bbox[2], _maxy = _bbox[3];
	    var _boxw = _maxx - _minx;
	    var _boxh = _maxy - _miny;
	    var _cx   = (_minx + _maxx) / 2;
	    var _cy   = (_miny + _maxy) / 2;
	    
	    var _tria = array_length(_tris);
	    if(_tria == 0) return;
	    
		var v0 = array_create(3 * _tria);
		var v1 = array_create(3 * _tria);
		var _h = height / 2;
		
		var _t = 1 - taper;
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		for( var i = 0; i < _tria; i++ ) { // caps
			var tr = _tris[i];
			var p0 = _pnts[tr[0]];
    		var p1 = _pnts[tr[1]];
    		var p2 = _pnts[tr[2]];
    		
    		var p0u  = (p0.x - _minx) / _boxw, _p0u  = p0u * 2 - 1;
    		var p0v  = (p0.y - _miny) / _boxh, _p0v  = p0v * 2 - 1;
    		var p1u  = (p1.x - _minx) / _boxw, _p1u  = p1u * 2 - 1;
    		var p1v  = (p1.y - _miny) / _boxh, _p1v  = p1v * 2 - 1;
    		var p2u  = (p2.x - _minx) / _boxw, _p2u  = p2u * 2 - 1;
    		var p2v  = (p2.y - _miny) / _boxh, _p2v  = p2v * 2 - 1;
    		
			v0[i*3+0] = new __vertex(_p0u * _t, _p0v * _t, _h).setNormal(0, 0,  1).setUV(p0u, p0v);
			v0[i*3+1] = new __vertex(_p1u * _t, _p1v * _t, _h).setNormal(0, 0,  1).setUV(p1u, p1v);
			v0[i*3+2] = new __vertex(_p2u * _t, _p2v * _t, _h).setNormal(0, 0,  1).setUV(p2u, p2v);
			
			v1[i*3+0] = new __vertex(_p0u, _p0v, -_h).setNormal(0, 0, -1).setUV(p0u, p0v);
			v1[i*3+1] = new __vertex(_p2u, _p2v, -_h).setNormal(0, 0, -1).setUV(p2u, p2v);
			v1[i*3+2] = new __vertex(_p1u, _p1v, -_h).setNormal(0, 0, -1).setUV(p1u, p1v);
			
			edges[eid++] = new __3dObject_Edge(v0[i*3+0].toArrayPos(), v0[i*3+1].toArrayPos());
			edges[eid++] = new __3dObject_Edge(v0[i*3+1].toArrayPos(), v0[i*3+2].toArrayPos());
			edges[eid++] = new __3dObject_Edge(v0[i*3+2].toArrayPos(), v0[i*3+0].toArrayPos());
			
			edges[eid++] = new __3dObject_Edge(v1[i*3+0].toArrayPos(), v1[i*3+1].toArrayPos());
			edges[eid++] = new __3dObject_Edge(v1[i*3+1].toArrayPos(), v1[i*3+2].toArrayPos());
			edges[eid++] = new __3dObject_Edge(v1[i*3+2].toArrayPos(), v1[i*3+0].toArrayPos());
			
		}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var br = mesh.mergePath(true);
	    var n  = array_length(br);
		var vs = array_create(3 * n * 2);
	    
    	for( var i = 0; i < n; i++ ) {
    		var pb = br[(i - 1 + n) % n];
			var p0 = br[(i + 0 + n) % n];
    		var p1 = br[(i + 1 + n) % n];
			var pa = br[(i + 2 + n) % n];
			
    		var p0u = (p0.x - _minx) / _boxw, _p0u = p0u * 2 - 1;
    		var p0v = (p0.y - _miny) / _boxh, _p0v = p0v * 2 - 1;
    		var p1u = (p1.x - _minx) / _boxw, _p1u = p1u * 2 - 1;
    		var p1v = (p1.y - _miny) / _boxh, _p1v = p1v * 2 - 1;
    		
    		var u0 =  i      / n;
    		var u1 = (i + 1) / n;
    		
    		if(smooth) {
	    		var pbu = (pb.x - _minx) / _boxw;
	    		var pbv = (pb.y - _miny) / _boxh;
	    		var pau = (pa.x - _minx) / _boxw;
	    		var pav = (pa.y - _miny) / _boxh;
	    			
    			var n0 = [-(p1v - pbv), p1u - pbu];
	    		var nl = sqrt(n0[0] * n0[0] + n0[1] * n0[1]);
	    		    n0[0] /= nl; n0[1] /= nl;
	    		    
	    		var n1 = [-(pav - p0v), pau - p0u];
	    		var nl = sqrt(n1[0] * n1[0] + n1[1] * n1[1]);
	    		    n1[0] /= nl; n1[1] /= nl;
	    		    
    		} else {
    			var n0 = [-(p1v - p0v), p1u - p0u];
    			var nl = sqrt(n0[0] * n0[0] + n0[1] * n0[1]);
	    		    n0[0] /= nl; n0[1] /= nl;
	    		    
	    		var n1 = n0;
    		}
    		
    		vs[i*6+0] = new __vertex(_p0u * _t, _p0v * _t,  _h).setNormal(n0[0], n0[1], 0).setUV(u0, 0);
			vs[i*6+1] = new __vertex(_p0u,      _p0v,      -_h).setNormal(n0[0], n0[1], 0).setUV(u0, 1);
			vs[i*6+2] = new __vertex(_p1u * _t, _p1v * _t,  _h).setNormal(n1[0], n1[1], 0).setUV(u1, 0);
			
			vs[i*6+3] = new __vertex(_p1u * _t, _p1v * _t,  _h).setNormal(n1[0], n1[1], 0).setUV(u1, 0);
			vs[i*6+4] = new __vertex(_p0u,      _p0v,      -_h).setNormal(n0[0], n0[1], 0).setUV(u0, 1);
			vs[i*6+5] = new __vertex(_p1u,      _p1v,      -_h).setNormal(n1[0], n1[1], 0).setUV(u1, 1);
			
			edges[eid++] = new __3dObject_Edge(vs[i*6+0].toArrayPos(), vs[i*6+1].toArrayPos());
			edges[eid++] = new __3dObject_Edge(vs[i*6+3].toArrayPos(), vs[i*6+5].toArrayPos());
		}
		
		edges  = [ edges ];
		vertex = [ v0, v1, vs ];
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}