function __Node_Base(x, y) constructor {
	self.x = x;
	self.y = y;
	
	node_id = 0;
	
	display_name = "";
	inputs  = ds_list_create();
	outputs = ds_list_create();
	input_value_map = {};
	
	active_index	= -1;
	preview_index	= 0;
	anim_priority	= -999;
	
	#region --- attributes ----
		attributes = {
			update_graph: true,
			show_update_trigger: false,
			color: -1,
		};
	#endregion
	
	#region ---- timeline ----
		timeline_item    = new timelineItemNode(self);
		anim_priority    = 0;
		is_anim_timeline = false;
		
		static refreshTimeline = function() { #region
			var _pre_anim = is_anim_timeline;
			var _cur_anim = false;
		
			for( var i = 0, n = ds_list_size(inputs); i < n; i++ ) {
				var _inp = inputs[| i];
				if(_inp.is_anim && _inp.value_from == noone) {
					_cur_anim = true;
					break;
				}
			}
			
			if(_pre_anim && !_cur_anim)
				timeline_item.removeSelf();
			else if(!_pre_anim && _cur_anim)
				PROJECT.timelines.addItem(timeline_item);
			
			is_anim_timeline = _cur_anim;
		} #endregion
	
	#endregion
	
	static step   = function() {}
	static update = function(frame = CURRENT_FRAME) {}
	
	static valueUpdate = function(index) {}
	static triggerRender = function() {}
	
	static onValidate = function() {}
	static onDestroy = function() {}
	
	static clearCache = function() {}
	static clearCacheForward = function() {}
	
	static serialize = function() {}
	static deserialize = function(_map) {}
}