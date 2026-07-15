function __Node_Base(_x, _y) constructor {
	x = _x;
	y = _y;
	
	node_id = 0;
	project = PROJECT;   static setProject = function(p) /*=>*/ { project = p; return self; }
	active  = true;
	
	display_name    = "";
	inputs          = [];
	outputs         = [];
	input_value_map = {};
	
	update_on_frame = false;
	
	instanceBase    = undefined;
	instanceChild   = [];
	
	is_selecting    = false;
	active_index	= -1;
	preview_index	= 0;
	anim_priority	= -999;
	
	#region ---- Inspector ----
		inspector_draw_height = 0;
		inspector_pad_label   = undefined;
	#endregion
	
	#region ---- Attributes ----
		parameters = {};
		attributes = {
			update_graph :         true,
			show_update_trigger : false,
			show_timeline :       false,
			timeline_hide :       false, 
			timeline_override :   false, 
			
			color : -1,
		};
		
		attributes_properties = [["Attributes", true]];
		attributeEditors      = [];
	#endregion
	
	#region ---- Timeline ----
		timeline_item    = new timelineItemNode(self);
		anim_priority    = 0;
		anim_timeline    = false;
		is_anim_timeline = false;
		
		static refreshTimeline = function() {
			refreshAnimationRange();
			
			var _pre_anim = is_anim_timeline;
			var _cur_anim = anim_timeline || attributes.show_timeline;
			
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
			timeline_item   = item;
			anim_timeline   = true; 
			refreshTimeline();
		}
		
		static refreshAnimationRange = function() {
			animation_range_start =  infinity;
			animation_range_end   = -infinity;
			
			for( var i = 0, n = array_length(inputs); i < n; i++ ) {
				var _input = inputs[i];
				if(!_input.is_anim) continue;
				
		        if(_input.on_end != KEYFRAME_END.hold) {
		        	animation_range_start = min(animation_range_start, 0);
					animation_range_end   = max(animation_range_end, TOTAL_FRAMES);
					continue;
		        }
		        
				var _anims = _input.sep_axis? _input.getAnimators() : [_input.animator];
			    for( var j = 0, m = array_length(_anims); j < m; j++ ) {
			        var _anim  = _anims[j];
			        
			        for(var k = 0, p = array_length(_anim.values); k < p; k++) {
			            animation_range_start = min(animation_range_start, _anim.values[k].time);
			    		animation_range_end   = max(animation_range_end,   _anim.values[k].time);
			    		
			    		if(k == p - 1 && _anim.values[k].driverObject != undefined)
			    			animation_range_end = max(animation_range_end, TOTAL_FRAMES);
			        }
			    }
			}
			
		}
		
		static isAnimated = function(frame = CURRENT_FRAME) {
			if(update_on_frame) return true;
			if(instanceBase)    return instanceBase.isAnimated();
			return array_any(inputs, function(inp,i) /*=>*/ {return inp.getAnim()});
		}
	#endregion
	
	static step   = function() {}
	static update = function(frame = CURRENT_FRAME) {}
	
	static valueUpdate   = function(index) {} 
	static triggerRender = function() {}
	
	static onDestroy  = function() {}
	
	static clearCache = function() {}
	static clearCacheForward = function() {}
	
	static serialize   = function() {}
	static deserialize = function(_map) {}
}