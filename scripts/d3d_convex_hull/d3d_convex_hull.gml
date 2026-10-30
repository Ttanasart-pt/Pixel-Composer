function __3dConvexHull() : __3dObject() constructor {
	VB = [ noone ];
	VF = global.VF_POS_NORM_TEX_COL;
	render_type = pr_trianglelist;
	
	points = [];
	
	static initModel = function() {
		var _vert = [];
		var _edge = [];
		var _in = 0;
		
		var hull = convex_hull_3d(points);
		
		for( var i = 0, n = array_length(hull); i < n; i++ ) {
			var _tri = hull[i];
			
			var p0 = points[_tri[0]];
			var p1 = points[_tri[2]];
			var p2 = points[_tri[1]];

            var nr = _hull_cross(_hull_sub(p1, p0), _hull_sub(p2, p0));
			
			_vert[_in++] = new __vertex(p0[0], p0[1], p0[2]).setNormal(nr[0], nr[1], nr[2]); 
			_vert[_in++] = new __vertex(p1[0], p1[1], p1[2]).setNormal(nr[0], nr[1], nr[2]); 
			_vert[_in++] = new __vertex(p2[0], p2[1], p2[2]).setNormal(nr[0], nr[1], nr[2]); 
		}
		
		vertex = [ _vert ];
		edges  = [ _edge ];
		VB = build();
	} initModel();

	onParameterUpdate = initModel;
}

function _hull_sub(a, b)   { return [a[0]-b[0], a[1]-b[1], a[2]-b[2]];                               }
function _hull_cross(u, v) { return [u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2], u[0]*v[1]-u[1]*v[0]]; }
function _hull_dot(u, v)   { return u[0]*v[0] + u[1]*v[1] + u[2]*v[2];                               }

// > 0 means p is outside the plane abc (abc is CCW seen from outside)
function hull_face_side(pa, pb, pc, p) {
    var n = _hull_cross(_hull_sub(pb, pa), _hull_sub(pc, pa));
    return _hull_dot(n, _hull_sub(p, pa));
}

function convex_hull_3d(points, eps = .00001) {
    var l = array_length(points);
    if(l < 4) return [];

    // seed tetrahedron
    var i0 = 0, i1 = -1, i2 = -1, i3 = -1, i;
    for(i = 1; i < l; i++) {
        var d = _hull_sub(points[i], points[i0]);
        if(_hull_dot(d, d) > eps) { i1 = i; break; }
    }
    if(i1 < 0) return [];

    for(i = 1; i < l; i++) {
        if(i == i1) continue;
        var c = _hull_cross(_hull_sub(points[i1], points[i0]), _hull_sub(points[i], points[i0]));
        if(_hull_dot(c, c) > eps) { i2 = i; break; }
    }
    if(i2 < 0) return [];

    for(i = 1; i < l; i++) {
        if(i == i1 || i == i2) continue;
        if(abs(hull_face_side(points[i0], points[i1], points[i2], points[i])) > eps) { i3 = i; break; }
    }
    if(i3 < 0) return [];

    var hull = [[i0, i1, i2], [i0, i1, i3], [i0, i2, i3], [i1, i2, i3]];
    var opp  = [i3, i2, i1, i0];
    for(i = 0; i < 4; i++) {
        var f = hull[i];
        if(hull_face_side(points[f[0]], points[f[1]], points[f[2]], points[opp[i]]) > 0)
            hull[i] = [f[0], f[2], f[1]];
    }

    // incremental insertion
    for(var n = 0; n < l; n++) {
        if(n == i0 || n == i1 || n == i2 || n == i3) continue;
        var p = points[n];

        var m     = array_length(hull);
        var v     = array_create(m, false);
        var any   = false;
        var edges = ds_map_create();

        for(i = 0; i < m; i++) {
            var f = hull[i];
            if(hull_face_side(points[f[0]], points[f[1]], points[f[2]], p) > eps) {
                v[i] = true;
                any = true;
                for(var k = 0; k < 3; k++)
                    edges[? f[k] * l + f[(k + 1) % 3]] = true;
            }
        }

        if(!any) { ds_map_destroy(edges); continue; } // inside

        var newHull = [];
        for(i = 0; i < m; i++) {
            var f = hull[i];
            if(!v[i]) { array_push(newHull, f); continue; }

            for(var k = 0; k < 3; k++) {
                var a = f[k], b = f[(k + 1) % 3];
                if(!ds_map_exists(edges, b * l + a)) // horizon edge
                    array_push(newHull, [a, b, n]);
            }
        }

        ds_map_destroy(edges);
        hull = newHull;
    }

    return hull;
}