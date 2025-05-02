function Node_VFX_Triangulate(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name      = "VFX Triangulate";
	color     = COLORS.node_blend_vfx;
	icon      = THEME.vfx;
	use_cache = CACHE_USE.auto;
	
	manual_ungroupable = false;
	
	inputs = array_create(9);
	
	newInput( 0, nodeValue_Vec2("Output dimension",     self, DEF_SURF ));
	newInput( 1, nodeValue_Particle("Particles",        self, -1       ))
		.setVisible(true, true);
		
	newInput( 2, nodeValue_f(  "Thickness",             self, 1            ));
	newInput( 4, nodeValue_b(  "Inherit Thickness",     self, false        ));
	newInput( 7, nodeValue_cu( "Thickness over Length", self, CURVE_DEF_11 ));
		
	newInput( 3, nodeValue_c(  "Color",                 self, ca_white ));
	newInput( 5, nodeValue_b(  "Inherit Color",         self, false         ));
	newInput( 8, nodeValue_gr( "Color over Length",     self, new gradientObject(ca_white)));
	
	newInput( 6, nodeValue_i("Segments",                self, 1 ));
		
	newOutput(0, nodeValue_Output("Surface Out",   self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 1, 
		[ "Geometry",  false], 6, 
		[ "Thickness", false], 2, 4, 7, 
		[ "Rendering", false], 3, 5, 8, 
	]
	
	setTrigger(2, "Clear cache", [ THEME.cache, 0, COLORS._main_icon ]);
	
	static onInspector2Update = function() /*=>*/ {return clearCache()};
	
	function _Point(p) constructor {
		part = p;
		x    = p.x;
		y    = p.y;
		
		static equal = function(_p) /*=>*/ {return x == _p.x && y == _p.y};
	}
	
	static update = function() {
		var _dim = inline_context.dimension;
		var _par = getInputData(1);
		
		var _seg = getInputData(6);
		
		var _ith = getInputData(4);
		var _th  = getInputData(2);
		var _thc = getInputData(7);
		
		var _icl = getInputData(5);
		var _cl  = getInputData(3);
		var _clc = getInputData(8);
		
		#region surface
			var _surf = outputs[0].getValue();
			    _surf = surface_verify(_surf, _dim[0], _dim[1]);
				outputs[0].setValue(_surf);
		#endregion
		
		#region VFX
			var _vrx = array_create(array_length(_par));
			var _ind = 0;
			for( var i = 0, n = array_length(_par); i < n; i++ ) {
				var p = _par[i];
				
				if(!p.active) continue;
				_vrx[_ind++] = new _Point(p);
			}
		
			array_resize(_vrx, _ind);
		#endregion
		
		var tri = delaunay_triangulation(_vrx);
		var p0, p1, p2;
		var t0, t1, t2;
		var c0, c1, c2;
		var t;
		
		var st = 1 / _seg, _l;
		var ox, oy, ot, oc; 
		var nx, ny, nt, nc;
		
		var _thcMap = array_create(_seg + 1);
		var _clcMap = array_create(_seg + 1);
		
		for( var j = 0; j <= _seg; j++ ) {
			_l = j * st;
			
			_thcMap[j] = eval_curve_x(_thc, _l);
			_clcMap[j] = _clc.eval(_l);
		}
		
		surface_set_shader(_surf, noone);
			draw_set_color(c_white);
			
			for( var i = 0, n = array_length(tri); i < n; i++ ) {
				t = tri[i];
				
				           p0 = t[0].part;              p1 = t[1].part;              p2 = t[2].part;
				
				           t0 = 1;                      t1 = 1;                      t2 = 1;
				if(_ith) { t0 = min(p0.scx, p0.scy);    t1 = min(p1.scx, p1.scy);    t2 = min(p2.scx, p2.scy); }
				           t0 *= _th;                   t1 *= _th;                   t2 *= _th;
				           
				           c0 = c_white;                c1 = c_white;                c2 = c_white;
				if(_icl) { c0 = p0.currColor;           c1 = p1.currColor;           c2 = p2.currColor;        }
				           c0 = colorMultiply(c0, _cl); c1 = colorMultiply(c1, _cl); c2 = colorMultiply(c2, _cl);
				
				for( var j = 0; j <= _seg; j++ ) {
					_l = j * st;
					
					nx = lerp(p0.x, p1.x,   _l);
					ny = lerp(p0.y, p1.y,   _l);
					nt = lerp(t0,   t1,     _l);
					nc = lerp_color(c0, c1, _l);
					
					nt = max(1, nt * _thcMap[j]);
					nc = colorMultiply(nc, _clcMap[j]);
					
					if(j) draw_line_width2(ox, oy, nx, ny, ot, nt, false, oc, nc);
					
					ox = nx;
					oy = ny;
					ot = nt;
					oc = nc;
				}
				
				for( var j = 0; j <= _seg; j++ ) {
					_l = j * st;
					
					nx = lerp(p0.x, p2.x,   _l);
					ny = lerp(p0.y, p2.y,   _l);
					nt = lerp(t0,   t2,     _l);
					nc = lerp_color(c0, c2, _l);
					
					nt = max(1, nt * _thcMap[j]);
					nc = colorMultiply(nc, _clcMap[j]);
					
					if(j) draw_line_width2(ox, oy, nx, ny, ot, nt, false, oc, nc);
					
					ox = nx;
					oy = ny;
					ot = nt;
					oc = nc;
				}
				
				for( var j = 0; j <= _seg; j++ ) {
					_l = j * st;
					
					nx = lerp(p1.x, p2.x,   _l);
					ny = lerp(p1.y, p2.y,   _l);
					nt = lerp(t1,   t2,     _l);
					nc = lerp_color(c1, c2, _l);
					
					nt = max(1, nt * _thcMap[j]);
					nc = colorMultiply(nc, _clcMap[j]);
					
					if(j) draw_line_width2(ox, oy, nx, ny, ot, nt, false, oc, nc);
					
					ox = nx;
					oy = ny;
					ot = nt;
					oc = nc;
				}
				
			}
		surface_reset_shader();
		
		cacheCurrentFrame(_surf);
	}
	
}