function __Node_Cache(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Cache";
	clearCacheOnChange = false;
	update_on_frame    = true;
	
	attributes.cache_group = [];
	cache_group_members    = [];
	group_vertex           = [];
	vertex_hash            = "";
	
	attributes.serialize = true;
	array_push(attributeEditors, "Cache");
	array_push(attributeEditors, [ "Serizalize Data", function() /*=>*/ {return attributes.serialize}, new checkBox(function() /*=>*/ {return toggleAttribute("serialize")}) ]);
	
	insp1button = button(function() /*=>*/ {
		PANEL_GRAPH.cache_group_edit = PANEL_GRAPH.cache_group_edit == self? noone : self;
		PANEL_GRAPH.refreshDraw();
	}).setTooltip(__txt("Edit Group"))
		.setIcon(THEME.sequence_control, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	if(NOT_LOAD) run_in(1, function() /*=>*/ {return generateGroup()});
	
	////- Group
	
	static containNode = function(_node) {
		return array_exists(cache_group_members, _node);
	}
	
	static removeNode = function(_node) {
		if(_node.cache_group != self) return;
		
		array_remove(attributes.cache_group, _node.node_id);
		array_remove(cache_group_members, _node);
		
		_node.cache_group  = noone;
		_node.renderActive = true;
	}
	
	static addNode = function(_node) {
		if(_node.cache_group == self) return;
		if(_node.cache_group != noone)
			_node.cache_group.removeNode(_node);
		
		array_push(attributes.cache_group, _node.node_id);
		array_push(cache_group_members, _node);
		
		_node.cache_group = self;
	}
	
	static enableNodeGroup = function() {
		if(LOADING || APPENDING)  return; 
		if(!attributes.serialize) return; 
		
		for( var i = 0, n = array_length(cache_group_members); i < n; i++ )
			cache_group_members[i].renderActive = true;
		clearCache(true);
	}
	
	static disableNodeGroup = function() {
		if(LOADING || APPENDING)  return;
		if(!attributes.serialize) return; 
		
		if(IS_PLAYING && IS_LAST_FRAME)
		for( var i = 0, n = array_length(cache_group_members); i < n; i++ )
			cache_group_members[i].renderActive = false;
	}
	
	static refreshCacheGroup = function() {
		cache_group_members = [];
		
		for( var i = 0, n = array_length(attributes.cache_group); i < n; i++ ) {
			if(!ds_map_exists(PROJECT.nodeMap, attributes.cache_group[i])) {
				print($"Node not found {attributes.cache_group[i]}");
				continue;
			}
			
			var _node = PROJECT.nodeMap[? attributes.cache_group[i]];
			array_push(cache_group_members, _node);
			_node.cache_group = self;
		}
		
	}
	
	static getCacheGroup = function(node) {
		if(node != self) addNode(node);
		
		for( var i = 0, n = array_length(node.inputs); i < n; i++ ) {
			var _from = node.inputs[i].value_from;
			if(_from == noone || _from.node == self) continue;
			
			if(array_exists(attributes.cache_group, _from.node.node_id)) continue;
			getCacheGroup(_from.node);
		}
	}
	
	static generateGroup = function() {
		attributes.cache_group = [];
		cache_group_members    = [];
		
		getCacheGroup(self);
		refreshCacheGroup();
	}
	
	////- Update
	
	static inspectorStep = function() /*=>*/ {
		insp1button.icon_blend = PANEL_GRAPH.cache_group_edit == self? COLORS._main_value_positive : COLORS._main_icon;
	}
	
	////- Draw
	
	static ccw = function(a, b, c) { return (b[0] - a[0]) * (c[1] - a[1]) - (c[0] - a[0]) * (b[1] - a[1]); }
	
	static getNodeBorder = function(_i, _vertex, _node) {
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
	}
	
	static refreshGroupBG = function(_force = false) {
		var _hash = $"{x},{y},{w},{h}|";
		
		for( var i = 0, n = array_length(cache_group_members); i < n; i++ ) {
			var _node = cache_group_members[i];
			_hash += $"{_node.x},{_node.y},{_node.w},{_node.h}|";
		}
		_hash = md5_string_utf8(_hash);
		
		if(vertex_hash == _hash && !_force) return;
		vertex_hash  = _hash;
		group_vertex = [];
		
		if(array_empty(cache_group_members)) return;
		var _vtrx = array_create((array_length(cache_group_members) + 1) * 4 * 7);
		
		getNodeBorder(0, _vtrx, self);
		
		for( var i = 0, n = array_length(cache_group_members); i < n; i++ )
			getNodeBorder(i + 1, _vtrx, cache_group_members[i]);
		
		__temp_minP = [ x, y ];
		__temp_minI = 0;
		
		for( var i = 0, n = array_length(_vtrx); i < n; i++ ) {
			var _v = _vtrx[i];
			
			if(_v[1] > __temp_minP[1] || (_v[1] == __temp_minP[1] && _v[0] < __temp_minP[0])) {
				__temp_minP = _v;
				__temp_minI = i;
			}
		}
		
		array_map_ext( _vtrx, function(a,i)   /*=>*/ {return [ a[0], a[1], i == __temp_minI? -999 : point_direction(__temp_minP[0], __temp_minP[1], a[0], a[1]) + 360 ]});
		array_sort(    _vtrx, function(a0,a1) /*=>*/ {return a0[2] == a1[2]? sign(a0[0] - a1[0]) : sign(a0[2] - a1[2])});
		
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
	}
	
	static drawNodeBG = function(_x, _y, _mx, _my, _s) {
		if(PANEL_GRAPH.cache_group_edit == self) {
			draw_droppable = true;
			for( var i = 0, n = array_length(cache_group_members); i < n; i++ )
				cache_group_members[i].drawActive(2);
		}
		
		refreshGroupBG();
		if(array_length(group_vertex) < 3) return;
		
		var _color  = getColor();
		draw_set_color(_color);
		draw_set_alpha(0.025);
		draw_primitive_begin(pr_trianglelist);
			var a = group_vertex[0];
			var b = group_vertex[1];
			var c;
			
			for( var i = 2, n = array_length(group_vertex); i < n; i++ ) {
				c = group_vertex[i];
				
				draw_vertex(_x + a[0] * _s, _y + a[1] * _s);
				draw_vertex(_x + b[0] * _s, _y + b[1] * _s);
				draw_vertex(_x + c[0] * _s, _y + c[1] * _s);
				
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
	}
	
	////- Actions
	
	static onDestroy = function() { enableNodeGroup(); }
}