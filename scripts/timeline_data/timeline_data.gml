function timelineItem() constructor {
	color  = c_white;
	parent = noone;
	
	static removeSelf = function() {
		if(parent == noone) return;
		array_remove(parent.contents, self);
		
		return self;
	}
	
	static serialize = function() {}
	
	static deserialize = function(_map) {
		switch(_map.type) {
			case "Node"   : return new timelineItemNode(noone).deserialize(_map);
			case "Folder" : return new timelineItemGroup(noone).deserialize(_map);
		}
		
		return self;
	}
}

function timelineItemNode(node) : timelineItem() constructor {
	self.node = node;
	
	static serialize = function() {
		var _map = {};
		
		_map.type    = "Node";
		_map.color   = color;
		_map.node_id = node.node_id;
		
		return _map;
	}
	
	static deserialize = function(_map) {
		color = _map.color;
		var _node_id = _map.node_id;
		
		node = PROJECT.nodeMap[? _node_id];
		node.timeline_item = self;
		
		return self;
	}
}

function timelineItemGroup() : timelineItem() constructor {
	contents = [];
	
	static addItem = function(_item) {
		array_push(contents, _item);
		_item.parent = self;
		
		return self;
	}
	
	static serialize = function() {
		var _map = {};
		
		_map.type    = "Folder";
		_map.color   = color;
		
		var _content = array_create(array_length(contents));
		for( var i = 0, n = array_length(contents); i < n; i++ )
			_content[i] = contents[i].serialize();
		_map.contents = _content;
		
		return _map;
	}
	
	static deserialize = function(_map) {
		color = _map.color;
		
		contents = array_create(array_length(_map.contents));
		for( var i = 0, n = array_length(_map.contents); i < n; i++ ) {
			contents[i] = new timelineItem().deserialize(_map.contents[i]);
			contents[i].parent = self;
		}
			
		return self;
	}
}