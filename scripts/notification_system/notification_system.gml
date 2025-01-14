#region notification
	globalvar STATUSES, WARNING, ERRORS, STATS_PROGRESS;
	
	STATUSES = ds_list_create();
	WARNING  = ds_list_create();
	ERRORS   = ds_list_create();
	STATS_PROGRESS = [];
#endregion

#region classes
	enum NOTI_TYPE {
		log		 = 1 << 0,
		warning  = 1 << 1,
		error    = 1 << 2,
		internal = 1 << 3,
	}
	
	function notification(type, str, icon = noone, color = c_ui_blue_dkgrey, life = -1) constructor {
		self.type   = type;
		self.txt    = str;
		self.txtclr = COLORS._main_text_sub;
		self.icon   = icon;
		self.color  = color;
		
		self.life_max = life;
		self.life     = life;
		
		self.onClick  = noone;
		self.tooltip  = "";
		self.icon_end = noone;
		
		self.progress = noone;
		
		self.amount = 1;
		self.time   = $"{string_lead_zero(current_hour, 2)}:{string_lead_zero(current_minute, 2)}.{string_lead_zero(current_second, 2)}";
		
		static setOnClick = function(onClick, tooltip = "", icon_end = noone) {
			self.onClick  = method(self, onClick);
			self.tooltip  = tooltip;
			self.icon_end = icon_end;
			
			return self;
		}
		
		if(type != NOTI_TYPE.internal) array_push(CMD, self);
	}
	
	function noti_status(str, icon = noone, flash = false, ref = noone) {
		str = string(str);
		show_debug_message($"STATUS: {str}🠂");
		if(TEST_ERROR) return {};
		
		var noti;
		
		if(!ds_list_empty(STATUSES) && STATUSES[| ds_list_size(STATUSES) - 1].txt == str) {
			STATUSES[| ds_list_size(STATUSES) - 1].amount++;
			noti = STATUSES[| ds_list_size(STATUSES) - 1];
			
		} else {
			noti = new notification(NOTI_TYPE.log, str, icon);
			ds_list_add(STATUSES, noti);
		}
		
		if(flash && PANEL_MENU) {
			PANEL_MENU.noti_flash = 1;
			PANEL_MENU.noti_flash_color = flash;
			
			dialogCall(o_dialog_warning, mouse_mx + ui(16), mouse_my + ui(16)).setText(str);
		}
		
		if(ref) {
			var onClick = function() /*=>*/ { PANEL_GRAPH.focusNode(self.ref); };
			noti.ref = ref;
			noti.onClick = method(noti, onClick);
		}
		
		return noti;
	}
	
	function noti_warning(str, icon = noone, ref = noone) {
		if(TEST_ERROR) return {};
		
		if(PANEL_MENU) {
			PANEL_MENU.noti_flash = 1;
			PANEL_MENU.noti_flash_color = COLORS._main_accent;
		}
		
		if(!ds_list_empty(STATUSES) && STATUSES[| ds_list_size(STATUSES) - 1].txt == str) {
			var noti = STATUSES[| ds_list_size(STATUSES) - 1];
			
			noti.amount++;
			noti.life = noti.life_max;
			return noti;
		}
		
		show_debug_message($"WARNING: {str}🠂");
		var noti = new notification(NOTI_TYPE.warning, str, icon, c_ui_orange, PREFERENCES.notification_time);
		noti.txtclr = c_ui_orange;
		
		ds_list_add(STATUSES, noti);
		ds_list_add(WARNING, noti);
		
		if(!instance_exists(o_dialog_warning))
			dialogCall(o_dialog_warning, mouse_mx + ui(16), mouse_my + ui(16)).setText(str);
		
		if(ref) {
			var onClick = function() /*=>*/ { PANEL_GRAPH.focusNode(self.ref); };
			noti.ref = ref;
			noti.onClick = method(noti, onClick);
		}
		return noti;
	}
	
	function noti_error(str, icon = noone, ref = noone) {
		if(TEST_ERROR) return {};
		show_debug_message($"ERROR: {str}🠂");
		
		var noti = new notification(NOTI_TYPE.error, str, icon, c_ui_red);
		noti.txtclr = c_ui_red;
		
		ds_list_add(STATUSES, noti);
		ds_list_add(ERRORS, noti);
		
		if(ref) {
			var onClick = function() /*=>*/ { PANEL_GRAPH.focusNode(self.ref); };
			noti.ref = ref;
			noti.onClick = method(noti, onClick);
		}
		return noti;
	}
	
	function noti_remove(noti) {
		ds_list_remove(STATUSES, noti);
		ds_list_remove(ERRORS, noti);
	}
#endregion