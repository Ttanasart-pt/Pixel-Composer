#region global
	global.MKTREE_JUNC = {
		icon:  function() /*=>*/ {return THEME.node_junction_mktree},
		color: function() /*=>*/ {return COLORS.node_blend_mktree},
		widg:  function() /*=>*/ {return new mktreeBox()},
	}
	
	global.MKTREE_LEAVES_JUNC = {
		icon:  function() /*=>*/ {return THEME.node_junction_mktree_leaves},
		color: function() /*=>*/ {return COLORS.node_blend_mktree},
		widg:  function() /*=>*/ {return new mktreeBox()},
	}
	
	enum MKLEAF_TYPE {
		Leaf, 
		Complex_Leaf, 
		Line, 
		Circle, 
		Surface,
		Mesh, 
	}
#endregion

function __MK_Tree_Leaf(_pos, _shp, _x, _y, _dir, _sx, _sy, _span) constructor {
	root = undefined;
	rootPosition = _pos;
	shape        = _shp;
	
	x  = _x;
	y  = _y;
	gravity = -90;
	
	startx = _x;
	starty = _y;
	
	scale = 1;
	sx  = _sx;
	sy  = _sy;
	dir = _dir;
	sp  = _span;
	
	surface   = noone;
	surf_w    = 1;
	surf_h    = 1;
	color     = c_white;
	colorE    = c_white;
	colorU    = undefined;
	colorLeaf = undefined;
	
	growShift = 0;
	growSpeed = 1;
	
	resolution =  0;
	geometry   = undefined;
	geometry1  = undefined;
	geoGrav    = .1;
	geoTwist   =  0;
	geoWigg    =  0;
	geoWiggC   = undefined;
	
	mesh = undefined;
	
	static recalDir = function() {
		dx = lengthdir_x(sx, dir);
		dy = lengthdir_y(sx, dir);
		
		dsx = lengthdir_x(sy, dir + 90);
		dsy = lengthdir_y(sy, dir + 90);
		
	} recalDir();
	
	static drawOverlay = function(_x, _y, _s) { draw_circle(_x + x * _s, _y + y * _s, 3, false); }
	
	static draw = function() {
		if(scale <= 0) return;
		
		var x0 = x;
		var y0 = y;
		
		var x1 = x + dx * scale;
		var y1 = y + dy * scale;
		
		var x2 = x + dx * sp * scale;
		var y2 = y + dy * sp * scale;
		
		var _cTop = colorU? colorU : colorE;
		var _cBot = colorE;
						
		switch(shape) {
			case MKLEAF_TYPE.Leaf : 
				var _sg   = -sign(dsy);
				var _scsg = scale * _sg;
				
				var _dsx = dsx * _scsg;
				var _dsy = dsy * _scsg;
		
				var c0 = colorLeaf.evalFast(  0 );
				var c2 = colorLeaf.evalFast( .5 );
				var c1 = colorLeaf.evalFast(  1 );
				
				var oc  = colorMultiply(color, c0);
				
				var tc2 = colorMultiply(_cTop, c2);
				var bc2 = colorMultiply(_cBot, c2);
				
				var tc1 = colorMultiply(_cTop, c1);
				var bc1 = colorMultiply(_cBot, c1);
				
				draw_primitive_begin(pr_trianglelist);
					draw_vertex_color(x0,        y0,        oc,  1);
					draw_vertex_color(x1,        y1,        tc1, 1);
					draw_vertex_color(x2 + _dsx, y2 + _dsy, tc2, 1);
					
					draw_vertex_color(x0,        y0,        oc,  1);
					draw_vertex_color(x1,        y1,        bc1, 1);
					draw_vertex_color(x2 - _dsx, y2 - _dsy, bc2, 1);
				draw_primitive_end();
				break;
				
			case MKLEAF_TYPE.Complex_Leaf : 
				if(geometry == undefined) break;
				
				var g0 = geometry;
				var g1 = geometry1;
				
				var _samp = resolution;
				var ds = sx / _samp;
				var os = g1 == undefined? g0.get(0) : random_range(g0.get(0), g1.get(0));
				var ns = os;
				var od = dir,         nd = od;
				var ox = x0,          nx = ox;
				var oy = y0,          ny = oy;
				var oc = colorLeaf.evalFast(0), nc = oc;
				var gg = geoGrav / _samp;
				var rr;
				var wd;
				
				draw_primitive_begin(pr_trianglelist);
					for( var i = 1; i <= _samp; i++ ) {
						var _t = i / _samp;
						
						ns = g1 == undefined? g0.get(_t) : random_range(g0.get(_t), g1.get(_t));
						
						wd = random_range(-geoWigg, geoWigg) * (geoWiggC? geoWiggC.get(_t) : 1) * sign(geoWigg);
						nx = ox + lengthdir_x(ds, nd) + lengthdir_x(wd, nd + 90);
						ny = oy + lengthdir_y(ds, nd) + lengthdir_y(wd, nd + 90);
						nd = lerp_angle_direct(nd, gravity, gg) + geoTwist / _samp;
						nc = colorLeaf.evalFast(i / _samp);
						
						var _odx = lengthdir_x(sy, od + 90);
						var _ody = lengthdir_y(sy, od + 90);
						
						var _ndx = lengthdir_x(sy, nd + 90);
						var _ndy = lengthdir_y(sy, nd + 90);
						
						var x00 = ox + _odx * os;
						var y00 = oy + _ody * os;
						
						var x01 = ox - _odx * os;
						var y01 = oy - _ody * os;
						
						var x10 = nx + _ndx * ns;
						var y10 = ny + _ndy * ns;
						
						var x11 = nx - _ndx * ns;
						var y11 = ny - _ndy * ns;
						
						var occ = colorMultiply(color, oc);
						var ncc = colorMultiply(color, nc);
						
						var otc = colorMultiply(_cTop, oc);
						var ntc = colorMultiply(_cTop, nc);
						
						var obc = colorMultiply(_cBot, oc);
						var nbc = colorMultiply(_cBot, nc);
						
						draw_vertex_color(x00, y00, otc, 1);
						draw_vertex_color( ox,  oy, occ, 1);
						draw_vertex_color( nx,  ny, ncc, 1);
						
						draw_vertex_color(x00, y00, otc, 1);
						draw_vertex_color( nx,  ny, ncc, 1);
						draw_vertex_color(x10, y10, ntc, 1);
						
						//////////////////////////////////////
						
						draw_vertex_color(x01, y01, obc, 1);
						draw_vertex_color( ox,  oy, occ, 1);
						draw_vertex_color( nx,  ny, ncc, 1);
						
						draw_vertex_color(x01, y01, obc, 1);
						draw_vertex_color( nx,  ny, ncc, 1);
						draw_vertex_color(x11, y11, nbc, 1);
						
						od = nd;
						os = ns;
						ox = nx;
						oy = ny;
						oc = nc;
					}
				draw_primitive_end();
				break;
				
			case MKLEAF_TYPE.Line : 
				var _samp = resolution;
				var ds = sx / _samp;
				var od = dir,         nd = od;
				var ox = x0,          nx = ox;
				var oy = y0,          ny = oy;
				var oc = colorLeaf.evalFast(0), nc = oc;
				var gg = geoGrav / _samp;
				
				for( var i = 1; i < _samp; i++ ) {
					nx = ox + lengthdir_x(ds, nd);
					ny = oy + lengthdir_y(ds, nd);
					nd = lerp_angle_direct(nd, gravity, gg);
					nc = colorLeaf.evalFast(i/_samp);
					
					draw_line_round_color(ox, oy, nx, ny, sy, oc, nc);
					
					ox = nx;
					oy = ny;
					oc = nc;
				}
				break;
				
			case MKLEAF_TYPE.Circle : 
				draw_set_circle_precision(16)
				draw_circle_color(x2, y2, sx * scale, color, colorE, false);
				break;
				
			case MKLEAF_TYPE.Surface : 
				var _xx = x + lengthdir_x(surf_h * sy * scale / 2, 90 + dir);
				var _yy = y + lengthdir_y(surf_h * sy * scale / 2, 90 + dir);
				
				draw_surface_ext_safe(surface, _xx, _yy, sx * scale, sy * scale, dir, color); 
				break;
			
			case MKLEAF_TYPE.Mesh : 
				if(mesh == undefined) break;
				
				draw_set_color(colorMultiply(color, colorLeaf.evalFast(0)));
				draw_primitive_begin(pr_trianglelist);
				var _vtx = 0;
				var tris = mesh.triangles;
				var pnts = mesh.points;
				
				var _x = x;
				var _y = y;
				
				var _d  = dir;
				var _dc = dcos(_d);
				var _ds = dsin(_d);
				
				for( var i = 0, n = array_length(tris); i < n; i++ ) {
					var t  = tris[i];
					var p0 = pnts[t[0]];
					var p1 = pnts[t[1]];
					var p2 = pnts[t[2]];
						
				    var _x0 = p0.x * sx, _y0 = p0.y * sy;
				    var _x1 = p1.x * sx, _y1 = p1.y * sy;
				    var _x2 = p2.x * sx, _y2 = p2.y * sy;
					
				    var x0 = _x + (_x0 * _dc - _y0 * _ds), y0 = _y + (_x0 * _ds + _y0 * _dc);
				    var x1 = _x + (_x1 * _dc - _y1 * _ds), y1 = _y + (_x1 * _ds + _y1 * _dc);
				    var x2 = _x + (_x2 * _dc - _y2 * _ds), y2 = _y + (_x2 * _ds + _y2 * _dc);
				    
					draw_vertex(x0, y0);
					draw_vertex(x1, y1);
					draw_vertex(x2, y2);
					
					if(++_vtx > 64) {
						draw_primitive_end();
						draw_primitive_begin(pr_trianglelist);
					}
				}
				
				draw_primitive_end();
				break;
		}
	}
	
	static copy = function(_l) {
		gravity    = _l.gravity;
		surface    = _l.surface;
		surf_w     = _l.surf_w;
		surf_h     = _l.surf_h;
		
		color      = _l.color;
		colorE     = _l.colorE;
		colorU     = _l.colorU;
		colorLeaf  = _l.colorLeaf;
		
		geometry   = _l.geometry;
		geometry1  = _l.geometry1;
		
		resolution = _l.resolution;
		growShift  = _l.growShift;
		geoGrav    = _l.geoGrav;
		geoTwist   = _l.geoTwist;
		geoWigg    = _l.geoWigg;
		geoWiggC   = _l.geoWiggC;
		
		mesh       = _l.mesh;
		return self;
	}
	
	static clone = function() { return variable_clone(self, 1); }
}

function __MK_Tree_Segment(_x, _y, _t) constructor {
	x = _x;
	y = _y;
	thickness = _t;
	
	color      = c_white;
	colorEdgeL = c_white;
	colorEdgeR = c_white;
}

function __MK_Tree() constructor {
	root = self;
	
	x = 0;
	y = 0;
	
	rootPosition   = 0;
	curvPosition   = 0;
	amount         = 1;
	segments       = [];
	segmentLengths = [];
	segmentRatio   = [];
	totalLength    = 0;
	
	children  = [];
	leaves    = [];
	
	growShift = 0;
	growSpeed = 1;
	
	texture   = noone;
	
	////- Get
	
	static getPosition = function(rat, res) {
		if(array_length(segments) < 2) {
			res[0] = x;
			res[1] = y;
			return res;
		}
		
		rat = clamp(rat, 0, 1);
		
		var amo  = array_length(segmentRatio);
		var low  = 0;
		var high = amo - 1;
		
		while(low < high) {
			var mid = (low + high) >> 1;
			if(segmentRatio[mid] < rat)
				low = mid + 1;
			else
				high = mid;
		}
		
		if(low == 0) {
			res[0] = segments[0].x;
			res[1] = segments[0].y;
			res[2] = point_direction(segments[0].x, segments[0].y, segments[1].x, segments[1].y);
			return res;

		} else if(low >= amo) {
			res[0] = segments[amo - 1].x;
			res[1] = segments[amo - 1].y;
			res[2] = point_direction(segments[amo - 2].x, segments[amo - 2].y, segments[amo - 1].x, segments[amo - 1].y);
			return res;
		}
		
		var ox = segments[low - 1];
		var nx = segments[low];
		
		var _rr = (rat - segmentRatio[low - 1]) / (segmentRatio[low] - segmentRatio[low - 1]);
		
		res[0] = lerp(ox.x, nx.x, _rr);
		res[1] = lerp(ox.y, nx.y, _rr);
		res[2] = point_direction(ox.x, ox.y, nx.x, nx.y);
		
		return res;
	}
	
	static getColor = function(rat) {
		if(array_empty(segments))       return c_black;
		if(array_length(segments) == 1) return segments[0].color;
		
		rat = clamp(rat, 0, 1);
		
		var amo  = array_length(segmentRatio);
		var low  = 0;
		var high = amo - 1;
		
		while(low < high) {
			var mid = (low + high) >> 1;
			if(segmentRatio[mid] < rat)
				low = mid + 1;
			else
				high = mid;
		}
		
		if(low == 0)   return segments[0].color;
		if(low >= amo) return segments[amo - 1].color;
		
		var ox = segments[low - 1];
		var nx = segments[low];
		var rr = (rat - segmentRatio[low - 1]) / (segmentRatio[low] - segmentRatio[low - 1]);
		
		return merge_color(ox.color, nx.color, rr);
	}
	
	////- Build
	
	static getLength = function() {
		if(array_empty(segments)) return;
		
		segmentLengths = array_create(amount + 1);
		segmentRatio   = array_create(amount + 1);
		totalLength    = 0;
		
		var sg, nx, ny;
		var ox = segments[0].x;
		var oy = segments[0].y;
		
		for( var i = 1, n = array_length(segments); i < n; i++ ) {
			var sg = segments[i];
			nx = sg.x;
			ny = sg.y;
			
			var ll = point_distance(ox, oy, nx, ny);
			segmentLengths[i] = ll;
			totalLength += ll;
			
			ox = nx;
			oy = ny;
		}
		
		var l = 0;
		for( var i = 0, n = array_length(segmentLengths); i < n; i++ ) {
			l += segmentLengths[i];
			segmentRatio[i] = l / totalLength;
		}
	}
	
	static grow = function(_param) {
		var _length = _param.length;
		var _angle  = _param.angle;
		
		var _angleW  = _param.angleW;
		var _angleWC = _param.angleWC;
		
		var _grav   = _param.grav;
		var _gravC  = _param.gravC;
		var _gravD  = _param.gravD;
		
		var _thick  = _param.thick;
		var _thickC = _param.thickC;
		
		var _spirS  = _param.spirS;
		var _spirP  = _param.spirP;
		
		var _wave   = _param.wave;
		var _waveC  = _param.waveC;
		
		var _curl   = _param.curl;
		var _curlC  = _param.curlC;
		
		var _cBase   = _param.cBase, _cc = _cBase;
		var _cLen    = _param.cLen;
		var _cLenG   = _param.cLenG;
		var _cEdg    = _param.cEdg;
		var _cEdgL   = _param.cEdgL;
		var _cEdgR   = _param.cEdgR;
		
		segments       = array_create(amount + 1);
		segmentLengths = array_create(amount + 1);
		segmentRatio   = array_create(amount + 1);
		totalLength    = 0;
		
		var ox = x, oy = y;
		var t = _thick * (_thickC? _thickC.get(0) : 1);
		
		segments[0] = new __MK_Tree_Segment(ox, oy, t);
		var _sg = segments[0];
		var _a  = _angle;
		var ll  = _length / amount;
		
		var _gx = lengthdir_x(1, _gravD);
		var _gy = lengthdir_y(1, _gravD);
		var _gg;
		
		for( var i = 0; i <= amount; i++ ) {
			var p = i / amount;
			
			if(i) {
				var t  = _thick * (_thickC? _thickC.get(p) : 1);
				
				var aa = _a + random_range(_angleW[0], _angleW[1]) * choose(-1, 1) * (_angleWC? _angleWC.get(p) : 1);
				var dx = lengthdir_x(ll, aa);
				var dy = lengthdir_y(ll, aa);
				
				ox += dx;
				oy += dy;
				
				var _wav = _wave * (_waveC? _waveC.get(p) : 1) / amount;
				if(_wav != 0) {
					var _wLen = cos(_spirP + p * pi * _spirS) * _wav;
					ox += lengthdir_x(_wLen, aa + 90);
					oy += lengthdir_y(_wLen, aa + 90);
				}
				
				var _crl = _curl * (_curlC? _curlC.get(p) : 1);
				if(_crl != 0) {
					var _cLen = sin(_spirP + p * pi * _spirS) * _crl;
					ox += lengthdir_x(_cLen, aa);
					oy += lengthdir_y(_cLen, aa);
				}
				
				_sg = new __MK_Tree_Segment(ox, oy, t);
				segments[i] = _sg;
				segmentLengths[i] = ll;
				totalLength += ll;
				
				_gg = _grav * (_gravC? _gravC.get(p) : 1);
				dx += _gg * ll * _gx;
				dy += _gg * ll * _gy;
				
				_a = point_direction(0, 0, dx, dy);
			}
			
			switch(_cLen) {
				case 0 : _sg.color = _cc;                                     break;
				case 1 : _sg.color = _cLenG.evalFast(p);                      break;
				case 2 : _sg.color = colorMultiply( _cLenG.evalFast(p), _cc); break;
				case 3 : _sg.color = colorScreen(   _cLenG.evalFast(p), _cc); break;
			}
			
			switch(_cEdg) {
				case 0 : _sg.colorEdgeL = _sg.color;                                             break;
				case 1 : _sg.colorEdgeL = _cEdgL.evalFast(random(1));                            break;
				case 2 : _sg.colorEdgeL = colorMultiply( _cEdgL.evalFast(random(1)), _sg.color); break;
				case 3 : _sg.colorEdgeL = colorScreen(   _cEdgL.evalFast(random(1)), _sg.color); break;
			}
			
			switch(_cEdg) {
				case 0 : _sg.colorEdgeR = _sg.color;                                             break;
				case 1 : _sg.colorEdgeR = _cEdgR.evalFast(random(1));                            break;
				case 2 : _sg.colorEdgeR = colorMultiply( _cEdgR.evalFast(random(1)), _sg.color); break;
				case 3 : _sg.colorEdgeR = colorScreen(   _cEdgR.evalFast(random(1)), _sg.color); break;
			}
			
			_sg.colorEdgeL = merge_color(_sg.color, _sg.colorEdgeL, _color_get_alpha(_sg.colorEdgeL));
			_sg.colorEdgeR = merge_color(_sg.color, _sg.colorEdgeR, _color_get_alpha(_sg.colorEdgeR));
		}
		
		var l = 0;
		for( var i = 0, n = array_length(segmentLengths); i < n; i++ ) {
			l += segmentLengths[i];
			segmentRatio[i] = l / totalLength;
		}
	}
	
	////- Draw
	
	static drawOverlay = function(_x, _y, _s) {
		var ox, oy, nx, ny;
		
		draw_set_color(COLORS._main_icon)
		for( var i = 0, n = array_length(segments); i < n; i++ ) {
			var _seg = segments[i];
			
			nx = _x + _seg.x * _s;
			ny = _y + _seg.y * _s;
			
			if(i) { draw_line(ox, oy, nx, ny); }
			
			ox = nx;
			oy = ny;
		}
		
		__x = _x;
		__y = _y;
		__s = _s;
		
		draw_set_circle_precision(4);
		array_foreach(leaves,   function(l) /*=>*/ {return l.drawOverlay(__x, __y, __s)});
		array_foreach(children, function(c) /*=>*/ {return c.drawOverlay(__x, __y, __s)});
	}
	
	static drawBranch = function() {
		var ox, oy, ot, oa, oc, ocl, ocr, orat;
		var nx, ny, nt, na, nc, ncl, ncr, nrat;
		var tid = is_surface(texture)? surface_get_texture(texture) : -1;
		
		draw_set_circle_precision(16);
		draw_primitive_begin_texture(pr_trianglelist, tid);
		
		var len = array_length(segments);
		var ang = array_create(len);
		
		for( var i = 1; i < len; i++ ) {
			var _s0 = segments[i - 1];
			var _s1 = segments[i];
			
			ang[i] = point_direction(_s0.x, _s0.y, _s1.x, _s1.y) - 90;
		}
		
		for( var i = 0; i < len; i++ ) {
			var _seg = segments[i];
			
			nx  = _seg.x;
			ny  = _seg.y;
			nt  = _seg.thickness;
			nc  = _seg.color;
			ncl = _seg.colorEdgeL;
			ncr = _seg.colorEdgeR;
			aa  = 1;
			
			na  = ang[i];
			
			if(i > 0 && i < len - 1) na = lerp_angle_direct(ang[i], ang[i + 1], .5);
			
			if(i) {
				orat = segmentRatio[i - 1];
				nrat = segmentRatio[i];
				
				var _d0x = lengthdir_x(ot / 2, oa);
				var _d0y = lengthdir_y(ot / 2, oa);	
				var _d1x = lengthdir_x(nt / 2, na);
				var _d1y = lengthdir_y(nt / 2, na);
				
				draw_vertex_texture_color( ox,        oy,        .5, orat, oc,  aa);
				draw_vertex_texture_color( nx,        ny,        .5, nrat, nc,  aa);
				draw_vertex_texture_color( ox + _d0x, oy + _d0y,  1, orat, ocr, aa);
				
				draw_vertex_texture_color( ox + _d0x, oy + _d0y,  1, orat, ocr, aa);
				draw_vertex_texture_color( nx,        ny,        .5, nrat, nc,  aa);
				draw_vertex_texture_color( nx + _d1x, ny + _d1y,  1, nrat, ncr, aa);
				
				draw_vertex_texture_color( ox,        oy,        .5, orat, oc,  aa);
				draw_vertex_texture_color( nx,        ny,        .5, nrat, nc,  aa);
				draw_vertex_texture_color( ox - _d0x, oy - _d0y,  0, orat, ocl, aa);
				
				draw_vertex_texture_color( ox - _d0x, oy - _d0y,  0, orat, ocl, aa);
				draw_vertex_texture_color( nx,        ny,        .5, nrat, nc,  aa);
				draw_vertex_texture_color( nx - _d1x, ny - _d1y,  0, nrat, ncl, aa);
			}
			
			oa = na;
			ox = nx;
			oy = ny;
			ot = nt;
			
			oc  = nc;
			ocl = ncl; 
			ocr = ncr; 
			
			if(i && i % 32 == 0) {
				draw_primitive_end();
				draw_primitive_begin_texture(pr_trianglelist, tid);
			}
			
		}
		
		draw_primitive_end();
		
	}
	
	static draw = function() {
		if(array_length(segments) >= 2) drawBranch();
		
		array_foreach(leaves,   function(l) /*=>*/ { if(is(l, __MK_Tree_Leaf)) l.draw(); });
		array_foreach(children, function(c) /*=>*/ { if(is(c, __MK_Tree))      c.draw(); });
		
	}
	
}