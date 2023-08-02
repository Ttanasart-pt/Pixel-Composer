function actionStep() constructor {
	type = "";
	data = {};
	
	static trigger = function() {
		
	}
	
	static serialize = function() {
		var map = {};
		
		map.type = type;
		map.data = data;
		
		return map;
	}
	
	static deserialize = function(map) {
		type = map.type;
		data = map.data;
		
		return self;
	}
}

function actionObject() constructor {
	name	= "";
	spr		= noone;
	
	isPlaying = false;
	playStep  = 0;
	
	actions   = [];
	
	static step = function() {
		actions[playStep].trigger();
		playStep++;
		
		if(playStep == array_length(actions)) {
			isPlaying = false;
			return true;
		}
		
		return false;
	}
	
	static play = function() {
		if(isPlaying) return;
		
		isPlaying = true;
		playStep  = 0;
	}
	
	static serialize = function() {
		var map = {};
		
		map.name    = name;
		map.actions = [];
		
		for( var i = 0, n = array_length(actions); i < n; i++ ) 
			map.actions[i] = actions[i].serialize();
		
		return map;
	}
	
	static deserialize = function(map) {
		name    = map.name;
		actions = [];
		
		for( var i = 0, n = array_length(map.actions); i < n; i++ )
			actions[i] = new actionStep().deserialize(map.actions[i]);
		
		return self;
	}
}