#region notification
	globalvar STATUSES, WARNING, ERRORS;
	
	STATUSES = ds_list_create();
	WARNING = ds_list_create();
	ERRORS = ds_list_create();
#endregion

#region classes
	enum NOTI_TYPE {
		log		 = 1 << 0,
		warning  = 1 << 1,
		error    = 1 << 2,
	}
	
	function notification(type, str, icon = noone, color = c_ui_blue_dkgrey, life = -1) constructor {
		self.type = type;
		self.txt = str;
		self.icon = icon;
		self.color = color;
		
		self.life_max = life;
		self.life = life;
		
		self.onClick = noone;
		
		self.time = string_lead_zero(current_hour, 2) + ":" + string_lead_zero(current_minute, 2);
	}
	
	function noti_status(str, icon = noone) {
		ds_list_add(STATUSES, new notification(NOTI_TYPE.log, str, icon));
	}
	
	function noti_warning(str, icon = noone) {
		var noti = new notification(NOTI_TYPE.warning, str, icon, c_ui_orange, 180);
		ds_list_add(STATUSES, noti);
		ds_list_add(WARNING, noti);
		
		if(PANEL_MENU)
			PANEL_MENU.noti_flash = 1;
		return noti;
	}
	
	function noti_error(str, icon = noone) {
		var noti = new notification(NOTI_TYPE.error, str, icon, c_ui_red);
		ds_list_add(STATUSES, noti);
		ds_list_add(ERRORS, noti);
		
		return noti;
	}
	
	function noti_remove(noti) {
		ds_list_remove(STATUSES, noti);
		ds_list_remove(ERRORS, noti);
	}
#endregion