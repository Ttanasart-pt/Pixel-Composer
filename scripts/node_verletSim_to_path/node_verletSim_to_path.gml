function Node_VerletSim_to_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Mesh to Path";
	color = COLORS.node_blend_verlet;
	icon  = THEME.verletSim;
	setDimension(96, 48);
	
	////- =Mesh
	newInput(0, nodeValue_Mesh( "Mesh" )).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	#region ---- path ----
		path_loop    = false;
		anchors		 = [];
		segments     = [];
		lengths		 = [];
		lengthAccs	 = [];
		lengthTotal	 = 0;
		boundary     = new BoundingBox();
	
		cached_pos = ds_map_create();
	#endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _msh = getInputData(0);
		
		if(is(_msh, Mesh)) {
			draw_set_color(COLORS._main_icon);
			_msh.draw(_x, _y, _s);
		}
	}
	
	static updateLength = function() {
		boundary    = new BoundingBox();
		segments    = [];
		lengths     = [];
		lengthAccs  = [];
		lengthTotal = 0;
		
		for( var i = 0, n = array_length(anchors); i < n; i++ ) {
			var _e = anchors[i];
			if(!_e.active) continue;
			
			var _a0 = _e.p0;
			var _a1 = _e.p1;
			var  l  = point_distance(_a0.x, _a0.y, _a1.x, _a1.y);
			
			segments[i]   = [ _a0.x, _a0.y, _a1.x, _a1.y ];
			lengths[i]    = l;
			lengthTotal  += l;
			lengthAccs[i] = lengthTotal;
		}
	}
	
	static getLineCount		= function(   ) /*=>*/ {return 1};
	static getSegmentCount	= function(i=0) /*=>*/ {return array_length(lengths)};
	static getBoundary		= function(i=0) /*=>*/ {return boundary};
	
	static getLength		= function(i=0) /*=>*/ {return lengthTotal};
	static getAccuLength	= function(i=0) /*=>*/ {return lengthAccs};
	
	static getPointRatio    = function(_rat, ind = 0, out = undefined) { return getPointDistance(clamp(_rat, 0, 0.99) * lengthTotal, ind, out); }
	static getPointDistance = function(_dist, ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{ind}, {string_format(_dist, 0, 6)}";
		if(ds_map_exists(cached_pos, _cKey)) {
			var _p = cached_pos[? _cKey];
			out.x = _p.x;
			out.y = _p.y;
			out.weight = _p.weight;
			return out;
		}
		
		for( var i = 0, n = array_length(anchors); i < n; i++ ) {
			var _e = anchors[i];
			if(!_e.active) continue;
			
			if(_dist > lengths[i]) { _dist -= lengths[i]; continue; }
			
			var _a0 = _e.p0;
			var _a1 = _e.p1;
			var _t = _dist / lengths[i];
			
			out.x = lerp(_a0.x, _a1.x, _t);
			out.y = lerp(_a0.y, _a1.y, _t);
			cached_pos[? _cKey] = new __vec2P(out.x, out.y, out.weight);
			return out;
		}
		
		return out;
	}
	
	static update = function() {
		ds_map_clear(cached_pos);
		
		var _msh = getInputData(0);
		if(!is(_msh, Mesh)) return;
		
		anchors = _msh.vedges;
		updateLength();
		
		outputs[0].setValue(self);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_verletsim_to_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}