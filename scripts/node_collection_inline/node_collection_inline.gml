function Node_Collection_Inline(_x, _y, _group = noone) : Node(_x, _y, _group) constructor { 	
	attributes.members = [];
	nodes              = [];
	group_vertex       = [];
	group_dragging     = false;
	group_adding       = false;
	vertex_hash        = "";
	modifiable         = true;
	draggable          = false;
	manual_deletable   = false;
	bbox               = [ 0, 0, 0, 0 ];
	
	managedRenderOrder = false;
	group_hovering     = false;
	group_hover_al     = 0;
	selectable         = false;
	
	input_node_types   = [];
	output_node_types  = [];
	
	add_point = false;
	point_x   = 0;
	point_y   = 0;
	
	junction_x = 0;
	junction_y = 0;
	
	is_root = true;
	
	static topoSortable = function() /*=>*/ {return false};
	
	////- Nodes
	
	static removeNode = function(node) {
		array_remove(attributes.members, node.node_id);
		
		array_remove(nodes, node);
		
		if(node.inline_context == self)
			node.inline_context = noone;
		onRemoveNode(node); 
		
		// print($"Pose remove node : {array_length(nodes)}");
	}
	
	static onRemoveNode = function(node) {}
	
	static addNode = function(node) {
		if(node.inline_context != noone && node.inline_context != self)
			node.inline_context.removeNode(node);
		node.inline_context = self;
		
		array_push_unique(attributes.members, node.node_id);
		array_push_unique(nodes, node);
		refreshGroupBG();
		
		onAddNode(node);
		
		// print($"Post add node : {array_length(nodes)}");
	}
	
	static addPoint = function(_x, _y) {
		add_point = true;
		point_x   = _x;
		point_y   = _y;
	}
	
	static onAddNode = function(node) {}
	
	////- Render
	
	static resetNodeRender = function(_node, _clearCache = false) {
		_node.resetRender(_clearCache);
		
		if(is(_node, Node_Collection))
		for(var i = 0, n = array_length(_node.nodes); i < n; i++)
			resetNodeRender(_node.nodes[i], _clearCache);
	}
	
	static resetRender = function(_clearCache = false) {
		LOG_LINE_IF(global.FLAG.render == 1, $"Reset Render for {getInternalName()}");
		
		setRenderStatus(false);
		if(_clearCache) clearInputCache();
		
		for( var i = 0; i < array_length(nodes); i++ )
			resetNodeRender(nodes[i], _clearCache);
	}
	
	////- Draw
	
	static ccw = function(a, b, c) { return (b[0] - a[0]) * (c[1] - a[1]) - (c[0] - a[0]) * (b[1] - a[1]); }
	
	static getNodeBorder = function(_ind, _vertex, _node) {
		var _rad = 6;
		var _stp = 30;
		var _nx0, _ny0, _nx1, _ny1;
		
		__temp_node = _node;
		
		if(is(_node, Node_Pin)) {
			_nx0 = _node.x - 32;
			_ny0 = _node.y - 32;
			_nx1 = _node.x + 32;
			_ny1 = _node.y + 32;

		} else {
			_nx0 = array_any(input_node_types,  function(n) /*=>*/ {return is(__temp_node, n)})? _node.x + _node.w / 2 : _node.x - 32 + _rad;
			_ny0 = _node.y - 32 + _rad;
			_nx1 = array_any(output_node_types, function(n) /*=>*/ {return is(__temp_node, n)})? _node.x + _node.w / 2 : _node.x + _node.w + 32 - _rad;
			_ny1 = _node.y + _node.h + 32 - _rad;
		}
		
		for( var i =   0; i <=  90; i += _stp ) _vertex[_ind++] = [ _nx1 + lengthdir_x(_rad, i), _ny0 + lengthdir_y(_rad, i) ];
		for( var i =  90; i <= 180; i += _stp ) _vertex[_ind++] = [ _nx0 + lengthdir_x(_rad, i), _ny0 + lengthdir_y(_rad, i) ];
		for( var i = 180; i <= 270; i += _stp ) _vertex[_ind++] = [ _nx0 + lengthdir_x(_rad, i), _ny1 + lengthdir_y(_rad, i) ];
		for( var i = 270; i <= 360; i += _stp ) _vertex[_ind++] = [ _nx1 + lengthdir_x(_rad, i), _ny1 + lengthdir_y(_rad, i) ];
		
		return _ind;
	}
	
	static refreshMember = function() {
		nodes = [];
		array_foreach(attributes.members, function(m) /*=>*/ { if(ds_map_exists(PROJECT.nodeMap, m)) addNode(PROJECT.nodeMap[? m]); })
	}
	
	static refreshGroupBG = function() {
		var _hash = "";
		var _ind  = 0;
		
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var _node = nodes[i];
			if(!_node.active || _node.group != group) continue;
			_hash += $"{_node.x},{_node.y},{_node.w},{_node.h}|";
			_ind++;
		}
		if(add_point) _hash += $"{point_x},{point_y}|";
		
		if(_hash == "") {
			group_vertex = [];
			destroy();
			return;
		}
		_hash = md5_string_utf8(_hash);
		
		if(vertex_hash == _hash) return;
		
		vertex_hash  = _hash;
		group_vertex = [];
		
		if(_ind == 0) return;
		var _vtrx = array_create(_ind * 4 * (90 / 30 + 1));
		
		var _ind = 0;
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var _node = nodes[i];
			if(!_node.active || _node.group != group) continue;
			_ind = getNodeBorder(_ind, _vtrx, _node);
		}
		
		if(add_point) array_push(_vtrx, [ point_x, point_y ]);
		
		__temp_minP = _vtrx[0];
		__temp_minI = 0;
		
		for( var i = 0, n = array_length(_vtrx); i < n; i++ ) {
			var _v  = _vtrx[i];
			var _vx = _v[0];
			var _vy = _v[1];
		
			if(_vy > __temp_minP[1] || (_vy == __temp_minP[1] && _vx < __temp_minP[0])) {
				__temp_minP = _v;
				__temp_minI = i;
			}
		}
		
		_vtrx = array_map( _vtrx, function(a, i)   { return [ a[0], a[1], i == __temp_minI? -999 : point_direction(__temp_minP[0], __temp_minP[1], a[0], a[1]) + 360 ] });
		        array_sort(_vtrx, function(a0, a1) { return a0[2] == a1[2]? sign(a0[0] - a1[0]) : sign(a0[2] - a1[2]); });
	
		var _linS = 0;
		for( var i = 1, n = array_length(_vtrx); i < n; i++ ) {
			if(_vtrx[i][1] != _vtrx[0][1]) break;
			_linS = i;
		}
	
		array_delete(_vtrx, 1, _linS - 1);
	
		group_vertex = [ _vtrx[0], _vtrx[1] ];
		
		var minx   = _vtrx[0][0];
		var miny   = _vtrx[0][1];
		var maxx   = _vtrx[0][0];
		var maxy   = _vtrx[0][1];
		
		for( var i = 2, n = array_length(_vtrx); i < n; i++ ) {
			var _v = _vtrx[i];
		
			while( array_length(group_vertex) >= 2 && ccw( group_vertex[array_length(group_vertex) - 2], group_vertex[array_length(group_vertex) - 1], _v ) >= 0 )
				array_pop(group_vertex);
			array_push(group_vertex, _v);
		}
		
		for( var i = array_length(group_vertex) - 1; i >= 0; i-- ) {
			var n  = array_length(group_vertex);
			if(n < 4) break;
			
			var v0 = group_vertex[(i - 1 + n) % n];
			var v1 = group_vertex[i];
			var v2 = group_vertex[(i + 1) % n];
			
			var a0 = point_direction(v1[0], v1[1], v0[0], v0[1]);
			var a1 = point_direction(v1[0], v1[1], v2[0], v2[1]);
			var d  = angle_difference(a0, a1);
			
			if(min(abs(d), abs(d - 180)) <= 2) 
				array_delete(group_vertex, i, 1);
			
			minx = min(minx, v1[0]);
			miny = min(miny, v1[1]);
			maxx = max(maxx, v1[0]);
			maxy = max(maxy, v1[1]);
		}
		
		junction_x = group_vertex[0][0]; 
		junction_y = group_vertex[0][1];
		for( var i = 1, n = array_length(group_vertex); i < n; i++ ) {
			var v1 = group_vertex[i];
			if(v1[0] <= junction_x && v1[1] <= junction_y) {
				junction_x = v1[0];
				junction_y = v1[1] + 8;
			}
		}
		
		bbox = [ minx, miny, maxx, maxy ];
		
		x = (minx + maxx) / 2;
		y = (miny + maxy) / 2;
		
		junction_x -= x;
		junction_y -= y;
	}
	
	static groupCheck = function(_x, _y, _s, _mx, _my) {
		if(array_length(group_vertex) < 3) return;
		if(!modifiable) return;
		
		var _m = [ _mx / _s - _x, _my / _s - _y ];
		
		group_adding = false;
		
		if(PANEL_GRAPH.node_dragging && PANEL_GRAPH.frame_hovering == self) {
			var _list = PANEL_GRAPH.nodes_selecting;
			
			PANEL_GRAPH.addKeyOverlay("Inline group", [[ "Shift", "Add/remove" ]]);
			
			if(!array_empty(_list) && key_mod_down(SHIFT)) {
				var _remove = _list[0].inline_context == self;
				
				if(_remove) {
					for( var i = 0, n = array_length(_list); i < n; i++ )
						if(_list[i].manual_ungroupable) removeNode(_list[i]);
				} else {
					group_adding = true;
					for( var i = 0, n = array_length(_list); i < n; i++ )
						if(_list[i].manual_ungroupable) addNode(_list[i]);
					
				} 
			}
		}
		
		if(group_dragging && mouse_release(mb_left)) {
			refreshMember();
			refreshGroupBG();
			
			group_dragging = false;
		}
	}
	
	static pointIn = function(_x, _y, _mx, _my, _s) { return false; }
	
	static cullCheck = function(_x, _y, _s, minx, miny, maxx, maxy) { return true; }
	
	static drawNodeBG = function(_x, _y, _mx, _my, _s) {
		refreshGroupBG();
		if(array_length(group_vertex) < 3) return false;
		
		var _hov   = false;
		var _color = getColor();
		var _sel   = inspecting || add_point;
		inspecting = false;
		
		draw_set_color(_color);
		group_hover_al = lerp_float(group_hover_al, group_hovering, 4);
		group_hovering = 0;
		draw_set_alpha(_sel? 0.1 : lerp(0.025, 0.05, group_hover_al));
		
		draw_primitive_begin(pr_trianglelist);
			var a = group_vertex[0];
			var b = group_vertex[1];
			var c;
			
			for( var i = 2, n = array_length(group_vertex); i < n; i++ ) {
				c = group_vertex[i];
				
				var v0x = _x + a[0] * _s;
				var v0y = _y + a[1] * _s;
				var v1x = _x + b[0] * _s;
				var v1y = _y + b[1] * _s;
				var v2x = _x + c[0] * _s;
				var v2y = _y + c[1] * _s;
				
				draw_vertex(round(v0x), round(v0y));
				draw_vertex(round(v1x), round(v1y));
				draw_vertex(round(v2x), round(v2y));
				
				if(!_hov && point_in_triangle(_mx, _my, v0x, v0y, v1x, v1y, v2x, v2y)) {
					group_hovering = 1 + (PANEL_GRAPH._frame_hovering == self && key_mod_press(SHIFT)) * 2;
					_hov = true;
				}
				
				b = group_vertex[i];
			}
		draw_primitive_end();
		
		draw_set_alpha(_sel? 1 : lerp(0.4, 0.65, group_hover_al));
		BLEND_ADD
		draw_primitive_begin(pr_linestrip);
			for( var i = 0, n = array_length(group_vertex); i < n; i++ ) {
				var a = group_vertex[i];
				draw_vertex(_x + a[0] * _s, _y + a[1] * _s);
			}
			
			a = group_vertex[0];
			draw_vertex(_x + a[0] * _s, _y + a[1] * _s);
		draw_primitive_end();
		BLEND_NORMAL
		
		draw_set_alpha(1);
		
		add_point = false;
		
		return _hov;
	}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s, display_parameter = noone) {
		// return drawJunctions(_x, _y, _mx, _my, _s)
	}
	
	static drawBadge = function(_x, _y, _s) {}
	
	static checkJunctions = function(_x, _y, _mx, _my, _s, _fast = false) {
		var hover = noone;
		var _dy = junction_draw_hei_y * _s / 2;
		var _dx = _fast? 6  * _s : _dy;
		
		var jx = junction_x;
		var jy = junction_y;
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var jun = inputs[i];
			if(!jun.isVisible()) continue;
			
		    jun.rx = jx;
		    jun.ry = jy;
		    jun.x  = _x + jx * _s;
		    jun.y  = _y + jy * _s;
			
			if(jun.isHovering(_s, _dx, _dy, _mx, _my)) hover = jun;
			jy += junction_draw_hei_y;
		}
		
		return hover;
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) {
		var jx = junction_x;
		var jy = junction_y;
		
		gpu_set_tex_filter(true);
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var jun = inputs[i];
			if(!jun.isVisible()) continue;
			
		    jun.rx = jx;
		    jun.ry = jy;
		    jun.x  = _x + jx * _s;
		    jun.y  = _y + jy * _s;
			
			jun.drawJunction(_s, _mx, _my);
			jy += junction_draw_hei_y;
		}
		gpu_set_tex_filter(false);
	}
	
	////- Serialize
	
	static postDeserialize = function() {
		if(APPENDING)
		for( var i = 0, n = array_length(attributes.members); i < n; i++ )
			attributes.members[i] = GetAppendID(attributes.members[i]);
			
		refreshMember();
	}
	
	////- Actions
	
	static junctionIsInside = function(junc) {
        if(!modifiable) return false;
		
        __temp_node = junc.node;
        
        if(array_any(input_node_types,   function(n) /*=>*/ {return is(__temp_node, n)}) && junc.connect_type == CONNECT_TYPE.input)  return false;
        if(array_any(output_node_types, function(n) /*=>*/ {return is(__temp_node, n)}) && junc.connect_type == CONNECT_TYPE.output) return false;
		
		return true;
	}
}