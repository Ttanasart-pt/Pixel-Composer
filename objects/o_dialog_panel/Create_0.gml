/// @description 
event_inherited();

#region panel
	dialog_w             = 640;
	dialog_h             = 480;
	padding              = ui(2);
	title_height         = ui(24);
	dialog_resizable     = true;
	destroy_on_click_out = true;
	destroy_on_escape    = true;
	
	panel        = surface_create(dialog_w, dialog_h);
	mask_surface = noone;
	content		 = noone;
	
	function setContent(content) {
		self.content = content;
		context_str  = content.context_str;
		
		if(struct_has(content, "title_height"))
			title_height = content.title_height;
		
		dialog_w         = content.w + content.showHeader * padding * 2;
		dialog_h         = content.h + content.showHeader * (padding * 2 + title_height);
		dialog_w_min     = content.min_w;
		dialog_h_min     = content.min_h;
		dialog_resizable = content.resizable;
		
		content.panel     = self;
		content.in_dialog = true;
		
		if(content.auto_pin) {
			destroy_on_click_out = false;
			destroy_on_escape    = false;
		}
	}
	
	function contentResize() {
		dialog_w = content.w + content.showHeader * padding * 2;
		dialog_h = content.h + content.showHeader * (padding * 2 + title_height);
	}
	
	function resetMask() {
		if(!content) return;
		mask_surface = surface_verify(mask_surface, dialog_w - content.showHeader * padding * 2, 
											        dialog_h - content.showHeader * (padding * 2 + title_height));
		
		surface_set_target(mask_surface);
		draw_clear(c_black);
		gpu_set_blendmode(bm_subtract);
		draw_sprite_stretched(THEME.ui_panel_bg, 0, 0, 0, dialog_w - content.showHeader * padding * 2, 
														  dialog_h - content.showHeader * (padding * 2 + title_height));
		gpu_set_blendmode(bm_normal);
		surface_reset_target();
	} resetMask();
	
	onResize = function() {
		panel = surface_verify(panel, dialog_w, dialog_h);
		resetMask();
		
		if(content) {
			content.w = dialog_w - content.showHeader * padding * 2;
			content.h = dialog_h - content.showHeader * (padding * 2 + title_height);
		
			content.onResize();
		}
	}
	
	function checkClosable() {
		if(!content) return true;
		return content.checkClosable();
	}
	
	function onDestroy() {
		if(content == noone) return;
		content.onClose();
	}
	
	function remove() {
		instance_destroy();
	}
		
	function onFocusBegin() { if(content) content.onFocusBegin(); }
	function onFocusEnd()   { if(content) content.onFocusEnd();   }
#endregion