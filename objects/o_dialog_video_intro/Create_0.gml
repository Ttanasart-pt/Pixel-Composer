/// @description init
event_inherited();

#region data
	destroy_on_click_out = true;
	
	dialog_w = ui(720);
	dialog_h = ui(320);
#endregion

function getCoveredNodes() {
	var _nodes = [];
	for( var i = 0, n = array_length(PROJECT.allNodes); i < n; i++ ) {
		var _n = PROJECT.allNodes[i];
		var _t = instanceof(_n);
		
		var _data = ALL_NODES[$ _t];
		if(_data && !_data.show_in_recent || !_data.show_in_global)
			continue;
			
		array_push(_nodes, _t);
	}
	
	PREFERENCES.video_topics = array_unique(_nodes);
	array_sort(PREFERENCES.video_topics, true);
	PREF_SAVE();
}

function addCoveredNodes() {
	var _nodes = [];
	for( var i = 0, n = array_length(PROJECT.allNodes); i < n; i++ ) {
		var _n = PROJECT.allNodes[i];
		var _t = instanceof(_n);
		
		var _data = ALL_NODES[$ _t];
		if(_data && !_data.show_in_recent || !_data.show_in_global)
			continue;
		
		array_push(PREFERENCES.video_topics, _t);
	}
	
	PREFERENCES.video_topics = array_unique(PREFERENCES.video_topics);
	array_sort(PREFERENCES.video_topics, true);
	PREF_SAVE();
}