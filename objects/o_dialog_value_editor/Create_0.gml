/// @description init
event_inherited();

#region data
	dialog_w = ui(240);
	dialog_h = TEXTBOX_HEIGHT + ui(8);
	draggable = false;
	
	destroy_on_click_out = true;
	
	junction   = noone;
	keyframe   = noone;
	editWidget = noone;
	
	wid_h = 0;
	
	function setKey(_key) {
		self.keyframe = _key;
		junction = _key.anim.prop;
		if(!junction.editWidget) {
			instance_destroy();
			return self;
		}
		
		editWidget = junction.editWidget.clone();
		if(editWidget == noone) {
			instance_destroy();
			return self;
		}
		
		editWidget.onModify = function(val, index = noone) { 
			var v = keyframe.value;
			if(is_array(v)) {
				if(index >= 0)
					v[index] = val;
				else if(is_array(val))
					v = val;
			} else
				v = val; 
			
			keyframe.value = v;
			junction.node.triggerRender();
		};
		
		return self;
	}
#endregion