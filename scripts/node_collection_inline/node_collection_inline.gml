function Node_Collection_Inline(_x, _y, _group = noone) : Node(_x, _y, _group) constructor { 	
	attributes.members  = [];
	members        = [];
	group_vertex   = [];
	group_dragging = false;
	group_adding   = false;
	vertex_hash    = "";
	
	group_hovering = false;
	group_hover_al = 0;
	
	static removeNode = function(node) { #region
		array_remove(attributes.members, node.node_id);
		array_remove(members, node);
		
		array_remove(node.context_data, self);
	} #endregion
	
	static addNode = function(node) { #region
		array_push(attributes.members, node.node_id);
		array_push(members, node);
		
		array_push_unique(node.context_data, self);
	} #endregion
	
	static ccw = function(a, b, c) { return (b[0] - a[0]) * (c[1] - a[1]) - (c[0] - a[0]) * (b[1] - a[1]); }
	
	static getNodeBorder = function(_i, _vertex, _node) { #region
		var _rad = 4;
		var _stp = 15;
		
		var _nx0 = _node.x - 32 + _rad;
		var _ny0 = _node.y - 32 + _rad;
		var _nx1 = _node.x + (_node == self? _node.w / 2 : _node.w + 32 - _rad);
		var _ny1 = _node.y + _node.h + 32 - _rad;
		
		var _ind = 0;
		for( var i =   0; i <=  90; i += _stp ) _vertex[_i * 7 * 4 + _ind++] = [ _nx1 + lengthdir_x(_rad, i), _ny0 + lengthdir_y(_rad, i) ];
		for( var i =  90; i <= 180; i += _stp ) _vertex[_i * 7 * 4 + _ind++] = [ _nx0 + lengthdir_x(_rad, i), _ny0 + lengthdir_y(_rad, i) ];
		for( var i = 180; i <= 270; i += _stp ) _vertex[_i * 7 * 4 + _ind++] = [ _nx0 + lengthdir_x(_rad, i), _ny1 + lengthdir_y(_rad, i) ];
		for( var i = 270; i <= 360; i += _stp ) _vertex[_i * 7 * 4 + _ind++] = [ _nx1 + lengthdir_x(_rad, i), _ny1 + lengthdir_y(_rad, i) ];
	} #endregion
	
	static refreshMember = function() { #region
		members = [];
		
		for( var i = 0, n = array_length(attributes.members); i < n; i++ ) {
			if(!ds_map_exists(PROJECT.nodeMap, attributes.members[i])) {
				print($"Node not found {attributes.members[i]}");
				continue;
			}
			
			var _node = PROJECT.nodeMap[? attributes.members[i]];
			array_push_unique(_node.context_data, self);
			array_push(members, _node);
		}
	} #endregion
	
	static refreshGroupBG = function() { #region
		var _hash = "";
		var _ind  = 0;
		
		for( var i = 0, n = array_length(members); i < n; i++ ) {
			var _node = members[i];
			if(!_node.active) continue;
			_hash += $"{_node.x},{_node.y},{_node.w},{_node.h}|";
			_ind++;
		}
		if(_hash == "") {
			nodeDelete(self);
			return;
		}
		_hash = md5_string_utf8(_hash);
		
		if(vertex_hash == _hash) return;
		vertex_hash = _hash;
		
		group_vertex = [];
		
		if(_ind == 0) return;
		var _vtrx = array_create(_ind * 4 * 7);
		
		var _ind = 0;
		for( var i = 0, n = array_length(members); i < n; i++ ) {
			var _node = members[i];
			if(!_node.active) continue;
			getNodeBorder(_ind, _vtrx, _node);
			_ind++;
		}
		
		__temp_minP = [ x, y ];
		__temp_minI = 0;
		
		for( var i = 0, n = array_length(_vtrx); i < n; i++ ) {
			var _v = _vtrx[i];
			
			if(_v[1] > __temp_minP[1] || (_v[1] == __temp_minP[1] && _v[0] < __temp_minP[0])) {
				__temp_minP = _v;
				__temp_minI = i;
			}
		}
		
		_vtrx = array_map( _vtrx, function(a, i) { return [ a[0], a[1], i == __temp_minI? -999 : point_direction(__temp_minP[0], __temp_minP[1], a[0], a[1]) + 360 ] });
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
	} #endregion
	
	static groupCheck = function(_x, _y, _s, _mx, _my) { #region
		if(array_length(group_vertex) < 3) return;
		var _m       = [ _mx / _s - _x, _my / _s - _y ];
		
		group_adding = false;
		
		if(PANEL_GRAPH.node_dragging && key_mod_press(SHIFT)) {
			var side = undefined;
			
			var _list = PANEL_GRAPH.nodes_selecting;
		
			if(group_hovering) {
				group_adding = true;
				for( var i = 0, n = array_length(_list); i < n; i++ )
					array_push_unique(attributes.members, _list[i].node_id);
			} else {
				for( var i = 0, n = array_length(_list); i < n; i++ )
					array_remove(attributes.members, _list[i].node_id);
			}
			
			if(!group_dragging) {
				for( var i = 0, n = array_length(_list); i < n; i++ )
					array_remove(attributes.members, _list[i].node_id);
				refreshMember();
				refreshGroupBG();
			}
			group_dragging = true;
		}
		
		if(group_dragging && mouse_release(mb_left)) {
			refreshMember();
			refreshGroupBG();
			
			group_dragging = false;
		}
	} #endregion
	
	static drawNodeBG = function(_x, _y, _mx, _my, _s) { #region
		refreshGroupBG();
		if(array_length(group_vertex) < 3) return false;
		
		var _hov    = false;
		var _color  = getColor();
		
		draw_set_color(_color);
		group_hover_al = lerp_float(group_hover_al, group_hovering, 4);
		draw_set_alpha(0.025 + 0.050 * group_hover_al);
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
				
				draw_vertex(v0x, v0y);
				draw_vertex(v1x, v1y);
				draw_vertex(v2x, v2y);
				
				if(!_hov && point_in_triangle(_mx, _my, v0x, v0y, v1x, v1y, v2x, v2y)) 
					_hov = true;
				
				b = group_vertex[i];
			}
		draw_primitive_end();
		
		draw_set_alpha(0.3);
		draw_primitive_begin(pr_linestrip);
			for( var i = 0, n = array_length(group_vertex); i < n; i++ ) {
				var a = group_vertex[i];
				draw_vertex(_x + a[0] * _s, _y + a[1] * _s);
			}
			
			a = group_vertex[0];
			draw_vertex(_x + a[0] * _s, _y + a[1] * _s);
		draw_primitive_end();
		
		draw_set_alpha(1);
		
		group_hovering = _hov;
		return _hov;
	} #endregion
	
	static drawNode = function(_x, _y, _mx, _my, _s, display_parameter = noone) {}
	
	static postDeserialize = function() { #region
		refreshMember();
	} #endregion
}