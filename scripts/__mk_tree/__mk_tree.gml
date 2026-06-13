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
	
	enum MK_TREE_TYPE {
		segment,
		points
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

function __MK_Tree_Element(_root = undefined) constructor {
	root = _root;
	
	static drawOverlay = function(_x,_y,_s) /*=>*/ {}
	static draw        = function()         /*=>*/ {}
	
	////- Action
	
	static clone    = function() /*=>*/ {return variable_clone(self)};
	static toString = function() /*=>*/ {return $"[MK Leaf]"};
}

function __MK_Tree_Segment(_x, _y, _t) constructor {
	x = _x;
	y = _y;
	thickness = _t;
	
	color      = c_white;
	colorEdgeL = undefined;
	colorEdgeR = undefined;
}

function __MK_Tree(_root = undefined, _x = 0, _y = 0, _seed = 0) : __MK_Tree_Element(_root) constructor {
	root = _root ?? self;
	seed = _seed;
	
	x = _x;
	y = _y;
	
	mode = MK_TREE_TYPE.segment;
	
	rootPosition   = 0;
	rootDirection  = undefined;
	curvPosition   = 0;
	
	amount         = 1;
	segments       = [];
	segmentLengths = [];
	segmentRatio   = [];
	totalLength    = 0;
	
	points    = [];
	pointAmo  = 0;
	
	children  = [];
	leaves    = [];
	
	growShift = 0;
	growSpeed = 1;
	
	doDraw    = true;
	texture   = noone;
	drawStep  = 1;
	drawLine  = false;
	drawn     = false;
	
	mesh = undefined;
	
	////- Set
	
	static setDraw    = function(v,l=0) /*=>*/ { doDraw  = v; drawLine = l; return self; }
	static setTexture = function(v)     /*=>*/ { texture = v; return self; }
	
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
	
	static grow = function(_amount, _param) {
		amount = _amount;
		
		var _length = _param.length;
		var _angle  = _param.angle;
		
		var _wigg   = _param.wigg;
		var _wiggC  = _param.wiggC;
		var _wiggF  = _param.wiggF;
		var _wiggP  = _param.wiggP;
		
		var _grav   = _param.grav;
		var _gravC  = _param.gravC;
		var _gravD  = _param.gravD;
		
		var _thick  = _param.thick;
		var _thickC = _param.thickC;
		
		var _spirA  = _param.spirA;
		var _spirAC = _param.spirAC;
		var _spirS  = _param.spirS;
		var _spirSC = _param.spirSC;
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
		
		var _sprAmp = _spirA / (amount * amount) * 2;
		var _sprAng = 0;
		
		for( var i = 0; i <= amount; i++ ) {
			var p = i / amount;
			
			if(i) {
				var t  = _thick * (_thickC? _thickC.get(p) : 1);
				var aa = _a;
				
				if(_wigg != 0) {
					var _wan = wiggle(-1, 1, _wiggF, p + _wiggP, seed + i);
					var _wam = _wigg * (_wiggC? _wiggC.get(p) : 1);
					aa += _wan * _wam;
				}
				
				var _spr = _sprAmp * (_spirAC? _spirAC.get(p) : 1);
				_sprAng += _spr;
				aa += _sprAng;
				
				var dx = lengthdir_x(ll, aa);
				var dy = lengthdir_y(ll, aa);
				
				ox += dx;
				oy += dy;
				
				var _sps = _spirS * (_spirSC? _spirSC.get(p) : 1);
				var _wav = _wave  * (_waveC? _waveC.get(p) : 1);
				
				if(_wav != 0) {
					var _wLen = cos(_spirP + p * pi * _sps) * _wav * _sps / amount;
					ox += lengthdir_x(_wLen, aa + 90);
					oy += lengthdir_y(_wLen, aa + 90);
				}
				
				var _crl = _curl * (_curlC? _curlC.get(p) : 1);
				if(_crl != 0) {
					var _crLen = sin(_spirP + p * pi * _sps) * _wav * _crl / amount;
					ox += lengthdir_x(_crLen, aa);
					oy += lengthdir_y(_crLen, aa);
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
	
	static setPoints = function(_points) {
		amount         = array_length(_points);
		segments       = array_create(amount);
		segmentLengths = array_create(amount);
		segmentRatio   = array_create(amount);
		totalLength    = 0;
		
		var ox, oy, nx, ny, t;
		var c, cl, cr;
		
		for( var i = 0; i < amount; i++ ) {
			var p = _points[i];
			
			nx = p[0];
			ny = p[1];
			t  = p[2];
			c  = p[3];
			cl = p[4];
			cr = p[5];
			
			segments[i] = new __MK_Tree_Segment(nx, ny, t);
			segments[i].color      = c;
			segments[i].colorEdgeL = cl;
			segments[i].colorEdgeR = cr;
			
			if(i) {
				var l = point_distance(ox, oy, nx, ny)
				segmentLengths[i] = l;
				totalLength += l;
			}
			
			ox = nx;
			oy = ny;
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
		
		if(mode == MK_TREE_TYPE.segment) {
			for( var i = 0, n = array_length(segments); i < n; i++ ) {
				var _seg = segments[i];
				
				nx = _x + _seg.x * _s;
				ny = _y + _seg.y * _s;
				
				if(i) { draw_line(ox, oy, nx, ny); }
				
				ox = nx;
				oy = ny;
			}
			
		} else if(mode == MK_TREE_TYPE.points) {
			for( var i = 0, n = array_length(points); i < n; i++ ) {
				var _p = points[i];
				
				nx = _x + _p[0] * _s;
				ny = _y + _p[1] * _s;
				
				draw_circle(nx, ny, 3, false);
			}
			
		}
		
		__x = _x;
		__y = _y;
		__s = _s;
		
		draw_set_circle_precision(4);
		array_foreach(leaves,   function(l,i) /*=>*/ {return l.drawOverlay(__x, __y, __s)});
		array_foreach(children, function(c,i) /*=>*/ {return c.drawOverlay(__x, __y, __s)});
	}
	
	static drawBranchLine = function() {
		var ox, oy, ot, oc;
		var nx, ny, nt, nc;
		var tid = is_surface(texture)? surface_get_texture(texture) : -1;
		
		draw_set_circle_precision(16);
		
		var len = array_length(segments);
		
		for( var i = 0; i < len; i += drawStep ) {
			var _seg = segments[i];
			
			nx  = _seg.x;
			ny  = _seg.y;
			nt  = _seg.thickness;
			nc  = _seg.color;
			
			if(i) draw_line_width2(ox, oy, nx, ny, ot, nt, true, oc, nc);
			
			ox = nx;
			oy = ny;
			ot = nt;
			
			oc  = nc;
		}
		
	}
	
	static drawBranch = function() {
		var ox, oy, ot, oa, oc, ocl, ocr, orat;
		var nx, ny, nt, na, nc, ncl, ncr, nrat;
		
		var len = array_length(segments);
		if(len <= 1) return;
		
		var tid = is_surface(texture)? surface_get_texture(texture) : -1;
		draw_set_circle_precision(16);
		draw_primitive_begin_texture(pr_trianglelist, tid);
		
		var ang = array_create(len);
		for( var i = 1; i < len; i += drawStep ) {
			var _s0 = segments[i - 1];
			var _s1 = segments[i];
			
			ang[i] = point_direction(_s0.x, _s0.y, _s1.x, _s1.y) - 90;
		}
		
		ang[0] = ang[1];
		if(rootDirection != undefined)
			ang[0] = rootDirection + (angle_difference(rootDirection, ang[1] + 90) > 0) * 180;
		
		for( var i = 0; i < len; i += drawStep ) {
			var _seg = segments[i];
			
			nx  = _seg.x;
			ny  = _seg.y;
			nt  = _seg.thickness;
			nc  = _seg.color;
			ncl = _seg.colorEdgeL ?? c_white;
			ncr = _seg.colorEdgeR ?? c_white;
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
		if(doDraw && array_length(segments) >= 2) {
			if(drawLine) drawBranchLine();
			else         drawBranch();
		}
		
		array_foreach(leaves,   function(l) /*=>*/ { if(is(l, __MK_Tree_Element)) l.draw(); });
		array_foreach(children, function(c) /*=>*/ { if(is(c, __MK_Tree)) c.draw(); });
		
	}
	
	////- Action
	
	static toString = function() /*=>*/ {return $"[MK Tree]: {array_length(children)} branch, {array_length(leaves)} leaves."};
	
}