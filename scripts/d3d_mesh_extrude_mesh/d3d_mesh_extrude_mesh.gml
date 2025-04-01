function __3dMeshExtrude() : __3dObject() constructor {
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	object_counts = 3;
	mesh   = noone;
    height = 1;
	
	static initModel = function() { 
	    if(mesh == noone) return;
	    
	    var _tris = mesh.triangles;
	    var _bbox = mesh.bbox;
	    var _minx = _bbox[0], _miny = _bbox[1];
	    var _maxx = _bbox[2], _maxy = _bbox[3];
	    var _boxw = _maxx - _minx;
	    var _boxh = _maxy - _miny;
	    
	    var _tria = array_length(_tris);
	    if(_tria == 0) return;
	    
		var v0 = array_create(3 * _tria);
		var v1 = array_create(3 * _tria);
		var _h = height / 2;
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		for( var i = 0; i < _tria; i++ ) { // caps
			var tr = _tris[i];
			var p0 = tr[0];
    		var p1 = tr[1];
    		var p2 = tr[2];
    		
    		var p0u  = (p0.x - _minx) / _boxw;
    		var p0v  = (p0.y - _miny) / _boxh;
    		var p1u  = (p1.x - _minx) / _boxw;
    		var p1v  = (p1.y - _miny) / _boxh;
    		var p2u  = (p2.x - _minx) / _boxw;
    		var p2v  = (p2.y - _miny) / _boxh;
    		
			v0[i * 3 + 0] = new __vertex(p0u * 2 - 1, p0v * 2 - 1, _h).setNormal(0, 0,  1).setUV(p0u, p0v);
			v0[i * 3 + 1] = new __vertex(p1u * 2 - 1, p1v * 2 - 1, _h).setNormal(0, 0,  1).setUV(p1u, p1v);
			v0[i * 3 + 2] = new __vertex(p2u * 2 - 1, p2v * 2 - 1, _h).setNormal(0, 0,  1).setUV(p2u, p2v);
			
			v1[i * 3 + 0] = new __vertex(p0u * 2 - 1, p0v * 2 - 1, -_h).setNormal(0, 0, -1).setUV(p0u, p0v);
			v1[i * 3 + 1] = new __vertex(p2u * 2 - 1, p2v * 2 - 1, -_h).setNormal(0, 0, -1).setUV(p2u, p2v);
			v1[i * 3 + 2] = new __vertex(p1u * 2 - 1, p1v * 2 - 1, -_h).setNormal(0, 0, -1).setUV(p1u, p1v);
		}
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		var br = mesh.mergePath(false);
		var vs = array_create(3 * array_length(br) * 2);
	    
		for( var i = 0, n = array_length(br); i < n; i++ ) {
			var p0 = br[i][0];
    		var p1 = br[i][1];
    		
    		var p0u  = (p0.x - _minx) / _boxw;
    		var p0v  = (p0.y - _miny) / _boxh;
    		var p1u  = (p1.x - _minx) / _boxw;
    		var p1v  = (p1.y - _miny) / _boxh;
    		
    		var nrm = d3_cross_product([0, 0, 1], [p1.x - p0.x, p1.y - p0.y, 0]);
    		
    		vs[i * 6 + 0] = new __vertex(p0u * 2 - 1, p0v * 2 - 1,  _h).setNormal(nrm[0], nrm[1], nrm[2]).setUV(0, 0);
			vs[i * 6 + 1] = new __vertex(p0u * 2 - 1, p0v * 2 - 1, -_h).setNormal(nrm[0], nrm[1], nrm[2]).setUV(0, 1);
			vs[i * 6 + 2] = new __vertex(p1u * 2 - 1, p1v * 2 - 1,  _h).setNormal(nrm[0], nrm[1], nrm[2]).setUV(1, 0);
			
			vs[i * 6 + 3] = new __vertex(p1u * 2 - 1, p1v * 2 - 1,  _h).setNormal(nrm[0], nrm[1], nrm[2]).setUV(1, 0);
			vs[i * 6 + 4] = new __vertex(p0u * 2 - 1, p0v * 2 - 1, -_h).setNormal(nrm[0], nrm[1], nrm[2]).setUV(0, 1);
			vs[i * 6 + 5] = new __vertex(p1u * 2 - 1, p1v * 2 - 1, -_h).setNormal(nrm[0], nrm[1], nrm[2]).setUV(1, 1);
		}
		
		vertex = [ v0, v1, vs ];
		VB = build();
	} initModel();
	
	static onParameterUpdate = initModel;
}