function Node_Collection_Inline(_x, _y, _group = noone) : Node(_x, _y, _group) constructor { 	
	attributes.members  = [];
	nodes          = [];
	group_vertex   = [];
	group_dragging = false;
	group_adding   = false;
	vertex_hash    = "";
	
	managedRenderOrder = false;
	group_hovering = false;
	group_hover_al = 0;
	selectable     = false;
	
	input_node_type  = noone;
	output_node_type = noone;
	
	add_point = false;
	point_x   = 0;
	point_y   = 0;
	
	is_root = true;
	
	static topoSortable = function() { #region
		return false;
	} #endregion
	
	static removeNode = function(node) { #region
		array_remove(attributes.members, node.node_id);
		
		array_remove(nodes, node);
		
		if(node.inline_context == self)
			node.inline_context = noone;
		onRemoveNode(node); 
	} #endregion
	
	static onRemoveNode = function(node) {}
	
	static addNode = function(node) { #region
		if(node.inline_context != noone && node.inline_context != self)
			node.inline_context.removeNode(node);
		node.inline_context = self;
		
		array_push_unique(attributes.members, node.node_id);
		array_push_unique(nodes, node);
		
		onAddNode(node);
	} #endregion
	
	static addPoint = function(_x, _y) {
		add_point = true;
		point_x   = _x;
		point_y   = _y;
	}
	
	static onAddNode = function(node) {}
	
	static ccw = function(a, b, c) { return (b[0] - a[0]) * (c[1] - a[1]) - (c[0] - a[0]) * (b[1] - a[1]); }
	
	static getNodeBorder = function(_ind, _vertex, _node) { #region
		var _rad = 6;
		var _stp = 30;
		
		var _nx0 = is_instanceof(_node, input_node_type)?  _node.x + _node.w / 2 : _node.x - 32 + _rad;
		var _ny0 = _node.y - 32 + _rad;
		var _nx1 = is_instanceof(_node, output_node_type)? _node.x + _node.w / 2 : _node.x + _node.w + 32 - _rad;
		var _ny1 = _node.y + _node.h + 32 - _rad;
		
		for( var i =   0; i <=  90; i += _stp ) _vertex[_ind++] = [ _nx1 + lengthdir_x(_rad, i), _ny0 + lengthdir_y(_rad, i) ];
		for( var i =  90; i <= 180; i += _stp ) _vertex[_ind++] = [ _nx0 + lengthdir_x(_rad, i), _ny0 + lengthdir_y(_rad, i) ];
		for( var i = 180; i <= 270; i += _stp ) _vertex[_ind++] = [ _nx0 + lengthdir_x(_rad, i), _ny1 + lengthdir_y(_rad, i) ];
		for( var i = 270; i <= 360; i += _stp ) _vertex[_ind++] = [ _nx1 + lengthdir_x(_rad, i), _ny1 + lengthdir_y(_rad, i) ];
		
		return _ind;
	} #endregion
	
	static refreshMember = function() { #region
		nodes = [];
		
		for( var i = 0, n = array_length(attributes.members); i < n; i++ ) {
			if(!ds_map_exists(PROJECT.nodeMap, attributes.members[i])) {
				print($"Node not found {attributes.members[i]}");
				continue;
			}
			
			addNode(PROJECT.nodeMap[? attributes.members[i]]);
		}
	} #endregion
	
	static refreshGroupBG = function() { #region
		var _hash = "";
		var _ind  = 0;
		
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var _node = nodes[i];
			if(!_node.active) continue;
			_hash += $"{_node.x},{_node.y},{_node.w},{_node.h}|";
			_ind++;
		}
		if(add_point) _hash += $"{point_x},{point_y}|";
		
		if(_hash == "") {
			destroy();
			return;
		}
		_hash = md5_string_utf8(_hash);
		
		if(vertex_hash == _hash) return;
		vertex_hash = _hash;
		
		group_vertex = [];
		
		if(_ind == 0) return;
		var _vtrx = array_create(_ind * 4 * (90 / 30 + 1));
		
		var _ind = 0;
		for( var i = 0, n = array_length(nodes); i < n; i++ ) {
			var _node = nodes[i];
			if(!_node.active) continue;
			_ind = getNodeBorder(_ind, _vtrx, _node);
		}
		
		if(add_point) array_push(_vtrx, [ point_x, point_y ]);
		
		#region create convex shape
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
			}
		#endregion
	} #endregion
	
	static groupCheck = function(_x, _y, _s, _mx, _my) { #region
		if(array_length(group_vertex) < 3) return;
		var _m       = [ _mx / _s - _x, _my / _s - _y ];
		
		group_adding = false;
		
		if(PANEL_GRAPH.node_dragging && PANEL_GRAPH.frame_hovering == self) {
			var _list = PANEL_GRAPH.nodes_selecting;
		
			if(key_mod_press(SHIFT)) {
				if(group_hovering) {
					group_adding = true;
					for( var i = 0, n = array_length(_list); i < n; i++ ) {
						if(_list[i].manual_ungroupable)
							addNode(_list[i]);
					}
				} else {
					for( var i = 0, n = array_length(_list); i < n; i++ ) {
						if(_list[i].manual_ungroupable)
							removeNode(_list[i]);
					}
				}
			}
			
			if(keyboard_check_pressed(vk_shift)) {
				for( var i = 0, n = array_length(_list); i < n; i++ ) {
					if(_list[i].manual_ungroupable)
						removeNode(_list[i]);
				}
				refreshMember();
				refreshGroupBG();
			}
		}
		
		if(group_dragging && mouse_release(mb_left)) {
			refreshMember();
			refreshGroupBG();
			
			group_dragging = false;
		}
	} #endregion
	
	static pointIn = function(_x, _y, _mx, _my, _s) { return false; }
	
	static resetRender = function(_clearCache = false) { #region
		LOG_LINE_IF(global.FLAG.render == 1, $"Reset Render for {INAME}");
		
		setRenderStatus(false);
		if(_clearCache) clearInputCache();
		
		for( var i = 0; i < array_length(nodes); i++ )
			nodes[i].resetRender(_clearCache);
	} #endregion
	
	static drawNodeBG = function(_x, _y, _mx, _my, _s) { #region
		
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
		draw_primitive_begin(pr_linestrip);
			for( var i = 0, n = array_length(group_vertex); i < n; i++ ) {
				var a = group_vertex[i];
				draw_vertex(_x + a[0] * _s, _y + a[1] * _s);
			}
			
			a = group_vertex[0];
			draw_vertex(_x + a[0] * _s, _y + a[1] * _s);
		draw_primitive_end();
		
		draw_set_alpha(1);
		
		//draw_set_color(c_white);
		//for( var i = 0, n = array_length(group_vertex); i < n; i++ ) {
		//	a = group_vertex[i];
		//	var _vx = _x + a[0] * _s;
		//	var _vy = _y + a[1] * _s;
			
		//	draw_circle(_vx, _vy, 1, false);
		//}
		
		add_point = false;
		
		return _hov;
	} #endregion
	
	static drawNode = function(_x, _y, _mx, _my, _s, display_parameter = noone) {}
	
	static drawBadge = function(_x, _y, _s) {}
	
	static postDeserialize = function() { #region
		refreshMember();
	} #endregion
}