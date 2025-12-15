function Node_VFX_Boids(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name   = "Boids";
	color  = COLORS.node_blend_vfx;
	icon   = THEME.vfx;
	reloop = true;
	manual_ungroupable	 = false;
	setDrawIcon(s_node_vfx_boids);
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Particle()).setVisible(true, true);
	newInput(7, nodeValue_Float("Speed amplification", 1   ));
	
	////- =Separation
	newInput(11, nodeValue_Bool(   "Separate",  true ));
	newInput( 1, nodeValue_Float(  "Radius",    4    )).setInternalName("sep_radius");
	newInput( 2, nodeValue_Slider( "Influence", 0.2  )).setInternalName("sep_influence");
	
	////- =Alignment
	newInput(12, nodeValue_Bool(   "Align",     true ));
	newInput( 3, nodeValue_Float(  "Radius",    32   )).setInternalName("ali_radius");
	newInput( 4, nodeValue_Slider( "Influence", 0.2  )).setInternalName("ali_influence");
	
	////- =Grouping
	newInput(13, nodeValue_Bool(   "Group",     true ));
	newInput( 5, nodeValue_Float(  "Radius",    32   )).setInternalName("grp_radius");
	newInput( 6, nodeValue_Slider( "Influence", 0.2  )).setInternalName("grp_influence");
	
	////- =Follow
	newInput( 8, nodeValue_Bool(   "Follow point", false ));
	newInput( 9, nodeValue_Vec2(   "Point",        [0,0] )).setUnitSimple();
	newInput(10, nodeValue_Slider( "Influence",    .1    )).setInternalName("fol_influence");
	
	input_display_list = [ 0, 7, 
		["Separation",	 false, 11],  1,  2, 
		["Alignment",	 false, 12],  3,  4, 
		["Grouping",	 false, 13],  5,  6, 
		["Follow point", false,  8],  9, 10, 
	];
	
	newOutput(0, nodeValue_Output("Particles", VALUE_TYPE.particle, noone ));
	
	UPDATE_PART_FORWARD
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _fol_pnt = getInputData(8);
		
		if(_fol_pnt) InputDrawOverlay(inputs[9].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		return w_hovering;
	}
	
	static getDimension = function() { return inline_context.dimension; }
	
	static update = function(frame = CURRENT_FRAME) {
		var parts = getInputData(0);
		
		outputs[0].setValue(parts);
		if(parts == noone) return;
		
		if(array_empty(parts)) return;
		var _allparts = [];
		
		if(!is_array(parts[0])) parts = [ parts ];
		
		for( var i = 0, n = array_length(parts); i < n; i++ ) {
			var _parts = parts[i];
			for( var j = 0, m = array_length(_parts); j < m; j++ ) {
				var p = _parts[j];
				if(p.active) array_append(_allparts, p);
			}
		}
		
		var _use_sep = getInputData(11);
		var _sep_rad = getInputData( 1), _sep_rad2 = _sep_rad * _sep_rad;
		var _sep_amo = getInputData( 2);
		
		var _use_ali = getInputData(12);
		var _ali_rad = getInputData( 3), _ali_rad2 = _ali_rad * _ali_rad;
		var _ali_amo = getInputData( 4);
		
		var _use_grp = getInputData(13);
		var _grp_rad = getInputData( 5), _grp_rad2 = _grp_rad * _grp_rad;
		var _grp_amo = getInputData( 6);
		var _spd_amp = getInputData( 7);
		
		var _fol_pnt = getInputData( 8);
		var _pnt_tar = getInputData( 9);
		var _fol_inf = getInputData(10);
		
		var amo = array_length(_allparts);
		var p0, p0x, p0y, p0vx, p0vy;
		var p1, p1x, p1y, p1vx, p1vy;
		var avx, avy, avc;
		var ax, ay, ac;
		
		var tarx = _pnt_tar[0];
		var tary = _pnt_tar[1];
		
		var max_rad2 = max(_sep_rad2, _ali_rad2, _grp_rad2);
		
		for( var i = 0; i < amo; i++ ) {
			p0 = _allparts[i];
			
			p0x  = p0.x;
			p0y  = p0.y;
			p0vx = p0.speedx;
			p0vy = p0.speedy;
			
			avx = 0;
			avy = 0;
			avc = 0;
			
			ax  = 0;
			ay  = 0;
			ac  = 0;
			
			var dis = sqrt(p0vx * p0vx + p0vy * p0vy) * _spd_amp;
			
			for( var j = 0; j < amo; j++ ) {
				if(j == i) continue;
				
				p1 = _allparts[j];
				
				p1x  = p1.x;
				p1y  = p1.y;
				p1vx = p1.speedx;
				p1vy = p1.speedy;
				
				var _dx = p0x - p1x;
				var _dy = p0y - p1y;
				
				var _dist = _dx * _dx + _dy * _dy;
				if(_dist >= max_rad2) continue;
				
				if(_use_sep && _dist < _sep_rad2) {
					p0x += (p0x - p1x) * _sep_amo;
					p0y += (p0y - p1y) * _sep_amo;
				}
				
				if(_use_ali && _dist < _ali_rad2) {
					avx += p1vx;
					avy += p1vy;
					avc++;
				}
				
				if(_use_grp && _dist < _grp_rad2) {
					ax += p1x;
					ay += p1y;
					ac++;
				}
			}
			
			if(_use_ali && avc) {
				avx /= avc;
				avy /= avc;
				
				p0vx += (avx - p0vx) * _ali_amo;
				p0vy += (avy - p0vy) * _ali_amo;
			}
			
			if(_use_grp && ac) {
				ax /= ac;
				ay /= ac;
				
				p0x += (ax - p0x) * _grp_amo;
				p0y += (ay - p0y) * _grp_amo;
			}
			
			if(_fol_pnt) {
				p0x += (tarx - p0x) * _fol_inf;
				p0y += (tary - p0y) * _fol_inf;
			}
			
			var dir   = point_direction(p0.x, p0.y, p0x, p0y);
			var _disn = point_distance( p0.x, p0.y, p0x, p0y);
			
			p0.speedx = lengthdir_x(min(dis, _disn), dir);
			p0.speedy = lengthdir_y(min(dis, _disn), dir);
			
			p0.x += p0.speedx;
			p0.y += p0.speedy;
			
			// p0.x   += lengthdir_x(min(dis, _disn), dir);
			// p0.y   += lengthdir_y(min(dis, _disn), dir);
			
			// p0.speedx  = p0vx;
			// p0.speedy  = p0vy;
			
		}
	}
	
	getPreviewingNode = VFX_PREVIEW_NODE;
}