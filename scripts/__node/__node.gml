function __Node_Base(x, y) constructor {
	self.x = x;
	self.y = y;
	
	node_id = 0;
	
	display_name    = "";
	inputs          = [];
	outputs         = [];
	input_value_map = {};
	
	is_selecting    = false;
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
		anim_timeline    = false;
		is_anim_timeline = false;
		
		static refreshTimeline = function() {
			var _pre_anim = is_anim_timeline;
			var _cur_anim = anim_timeline;
		
			for( var i = 0, n = array_length(inputs); i < n; i++ ) {
				var _inp = inputs[i];
				if(_inp.is_anim && _inp.value_from == noone) {
					_cur_anim = true;
					break;
				}
			}
			is_anim_timeline = _cur_anim;
			if(_pre_anim == _cur_anim) return;
			
			if(_cur_anim) PROJECT.timelines.addItem(timeline_item);
			else          timeline_item.removeSelf();
		}
		
		static setAlwaysTimeline = function(item = timeline_item) {
			attributes.show_timeline = true;
			array_push(attributeEditors, [ "Show In Timeline", function() /*=>*/ {return attributes.show_timeline}, 
				new checkBox(function() /*=>*/ { 
					attributes.show_timeline = !attributes.show_timeline; 
					anim_timeline = attributes.show_timeline;
					refreshTimeline();
					
					PROJECT.modified = true;
				})
			]);
			
			timeline_item   = item;
			anim_timeline   = true; 
			refreshTimeline();
		}
	#endregion
	
	static step   = function() {}
	static update = function(frame = CURRENT_FRAME) {}
	
	static valueUpdate   = function(index) {}
	static triggerRender = function() {}
	
	static onValidate = function() {}
	static onDestroy  = function() {}
	
	static clearCache = function() {}
	static clearCacheForward = function() {}
	
	static serialize   = function() {}
	static deserialize = function(_map) {}
}