function Node_MK_Tree_Branch_To_Path(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Branch to Path";
	color = COLORS.node_blend_mktree;
	icon  = THEME.mkTree;
	update_on_frame = true;
	setDrawIcon(s_node_mk_tree_branch_to_path);
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Struct("Branch", noone)).setVisible(true, true).setCustomData(global.MKTREE_JUNC);
	
	newOutput(0, nodeValue_Output("Path", VALUE_TYPE.pathnode, self));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
		// [ "Branches", false ], 
	];
	
	////- Nodes
	
	#region ---- path ----
		path_loop    = false;
		path_amo     = 1;
		anchors		 = [];
		lengths		 = [];
		lengthAccs	 = [];
		lengthTotal	 = 0;
		boundary     = [];
	
		cached_pos   = {};
	#endregion
	
	static getDimension = function() /*=>*/ {return is(inline_context, Node_MK_Tree_Inline)? inline_context.getDimension() : [1,1]};
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _resT = inputs[0].getValue();
		if(is_array(_resT)) 
		for( var i = 0, n = array_length(_resT); i < n; i++ ) {
			var _t = _resT[i];
			if(is(_t, __MK_Tree)) _t.drawOverlay(_x, _y, _s);
		}
	}
	
	static updateLength = function(ind) {
		var _ancs = anchors[ind];
		if(array_empty(_ancs)) return;
		
		var _boundary    = new BoundingBox();
		var _lengths     = [];
		var _lengthAccs  = [];
		var _lengthTotal = 0;
		
		var nx, ny;
		var ox = _ancs[0][0];
		var oy = _ancs[0][1];
		
		for( var i = 1, n = array_length(_ancs); i < n; i++ ) {
			var _anc = _ancs[i];
			
			var nx = _ancs[i][0];
			var ny = _ancs[i][1];
			var  l  = point_distance(ox, oy, nx, ny);
			
			_boundary.addPoint(nx, ny);
			
			_lengths[i]    = l;
			_lengthTotal  += l;
			_lengthAccs[i] = _lengthTotal;
			
			ox = nx;
			oy = ny;
		}
		
		boundary[ind]    = _boundary;
		lengths[ind]     = _lengths;
		lengthAccs[ind]  = _lengthAccs;
		lengthTotal[ind] = _lengthTotal;
	}
	
	static updateLengths = function() {
		path_amo    = array_length(anchors);
		
		boundary    = array_create(path_amo);
		lengths     = array_create(path_amo);
		lengthAccs  = array_create(path_amo);
		lengthTotal = array_create(path_amo);
		
		for( var i = 0; i < path_amo; i++ ) updateLength(i)
	}
	
	static getLineCount		= function(   ) /*=>*/ {return path_amo};
	static getSegmentCount	= function(i=0) /*=>*/ {return array_length(lengths[i])};
	static getBoundary		= function(i=0) /*=>*/ {return boundary[i]};
	
	static getLength		= function(i=0) /*=>*/ {return lengthTotal[i]};
	static getAccuLength	= function(i=0) /*=>*/ {return lengthAccs[i]};
	
	static getPointRatio    = function(_rat, ind = 0, out = undefined) { return getPointDistance(clamp(_rat, 0, 0.99) * lengthTotal[ind], ind, out); }
	static getPointDistance = function(_dist, ind = 0, out = undefined) {
		if(out == undefined) out = new __vec2P(); else { out.x = 0; out.y = 0; }
		
		var _cKey = $"{ind}, {string_format(_dist, 0, 6)}";
		if(has(cached_pos, _cKey)) {
			var _p = cached_pos[$ _cKey];
			out.x = _p.x;
			out.y = _p.y;
			out.weight = _p.weight;
			return out;
		}
		
		var _ancs = anchors[ind];
		if(array_empty(_ancs)) return out;
		
		var nx, ny, nt;
		var ox = _ancs[0][0];
		var oy = _ancs[0][1];
		var ot = _ancs[0][2];
		var _lens = lengths[ind];
		
		for( var i = 1, n = array_length(_ancs); i < n; i++ ) {
			if(_dist > _lens[i]) { _dist -= _lens[i]; continue; }
			
			var nx = _ancs[i][0];
			var ny = _ancs[i][1];
			var nt = _ancs[i][2];
			var _t = _dist / _lens[i];
			
			out.x = lerp(ox, nx, _t);
			out.y = lerp(oy, ny, _t);
			out.weight = lerp(ot, nt, _t);
			cached_pos[$ _cKey] = new __vec2P(out.x, out.y, out.weight);
			
			ox = nx;
			oy = ny;
			ot = nt;
			return out;
		}
		
		return out;
	}
	
	static update = function() {
		if(!is(inline_context, Node_MK_Tree_Inline)) return;
		
		outputs[0].setValue(self);
		var _tree = getInputData(0);
		anchors   = [];
		
		if(!is_array(_tree)) return;
		
		for( var i = 0, n = array_length(_tree); i < n; i++ ) {
			var _bran = _tree[i];
			var _segs = _bran.segments;
			var _ancs = [];
			
			for( var j = 0, m = array_length(_segs); j < m; j++ ) {
				var _s = _segs[j];
				_ancs[j] = [ _s.x, _s.y, _s.thickness ];
			}
			
			anchors[i] = _ancs;
		}
		
		updateLengths();
		
	}
	
}