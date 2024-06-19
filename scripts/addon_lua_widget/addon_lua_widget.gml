// feather ignore all
#region setup
	function __addon_lua_setup(lua, context) {
		__addon_lua_setup_functions(lua);
		__addon_lua_setup_constants(lua, context);
		__addon_lua_setup_widget(lua, context);
		
		context.ready = true;
	}
#endregion

#region widget manager
	global.__lua_widget_functions = [
		[ "__widget_wake",   function(wd, hover, focus) { 
			if(!ds_map_exists(global.ADDON_WIDGET, wd)) return;
			
			global.ADDON_WIDGET[? wd].setFocusHover(focus, hover);
		} ],
		
		[ "__textBox",   function(ID, type, onModify) { 
			var _addon = noone;
			with(_addon_custom) if(self.ID == ID) _addon = self;
			if(_addon == noone) return noone;
			
			var wd  = new textBox(type, noone);
			wd.setLua(_addon.thread, onModify, function(txt) { 
				return lua_call(lua_thread, lua_thread_key, txt); 
			});
			
			var key = UUID_generate();
			global.ADDON_WIDGET[? key] = wd;
			
			return key;
		} ],
		
		[ "__textBox_draw",   function(wd, _x, _y, _w, _h, _text, _m) { 
			if(!ds_map_exists(global.ADDON_WIDGET, wd)) return;
			
			var _param = new widgetParam(_x, _y, _w, _h, _text, {}, _m)
			global.ADDON_WIDGET[? wd].drawParam(_param);
		} ],
@"
TextBox = {}
TextBox.new = function(type, onModify) 
	local self = {}
	
	self.id = __textBox(ID, type, onModify)
	
	function self.draw(self, _x, _y, _w, _h, _text) 
		__widget_wake(self.id, Panel.hoverable, Panel.clickable)
		__textBox_draw(self.id, _x, _y, _w, _h, _text, Panel.mouse)
	end
	
	return self
end",
		
		[ "__vectorBox",   function(ID, size, onModify) { 
			var _addon = noone;
			with(_addon_custom) if(self.ID == ID) _addon = self;
			if(_addon == noone) return noone;
			
			var wd  = new vectorBox(size, noone);
			wd.setLua(_addon.thread, onModify, function(v, i) { 
				return lua_call(lua_thread, lua_thread_key, i + 1, v); 
			});
			
			var key = UUID_generate();
			global.ADDON_WIDGET[? key] = wd;
			
			return key;
		} ],
		
		[ "__vectorBox_draw",   function(wd, _x, _y, _w, _h, _vector, _m) { 
			if(!ds_map_exists(global.ADDON_WIDGET, wd)) return;
			
			var _param = new widgetParam(_x, _y, _w, _h, _vector, {}, _m)
			global.ADDON_WIDGET[? wd].drawParam(_param);
		} ],

@"
VectorBox = {}
VectorBox.new = function(size, onModify) 
	local self = {}
	
	self.id = __vectorBox(ID, size, onModify)
	
	function self.draw(self, _x, _y, _w, _h, _vector) 
		__widget_wake(self.id, Panel.hoverable, Panel.clickable)
		__vectorBox_draw(self.id, _x, _y, _w, _h, _vector, Panel.mouse)
	end
	
	return self
end",

		[ "__checkBox",   function(ID, onModify) { 
			var _addon = noone;
			with(_addon_custom) if(self.ID == ID) _addon = self;
			if(_addon == noone) return noone;
			
			var wd  = new checkBox(onModify);
			wd.setLua(_addon.thread, onModify, function() { 
				return lua_call(lua_thread, lua_thread_key); 
			});
			
			var key = UUID_generate();
			global.ADDON_WIDGET[? key] = wd;
			
			return key;
		} ],
		
		[ "__checkBox_draw",   function(wd, _x, _y, _value, _m) { 
			if(!ds_map_exists(global.ADDON_WIDGET, wd)) return;
			
			var _param = new widgetParam(_x, _y, ui(24), ui(24), _value, {}, _m)
			global.ADDON_WIDGET[? wd].drawParam(_param);
		} ],

@"
CheckBox = {}
CheckBox.new = function(onModify) 
	local self = {}
	
	self.id = __checkBox(ID, onModify)
	
	function self.draw(self, _x, _y, _value) 
		__widget_wake(self.id, Panel.hoverable, Panel.clickable)
		__checkBox_draw(self.id, _x, _y, _value, Panel.mouse)
	end
	
	return self
end",

		[ "__button",   function(ID, onModify, txt = "") { 
			var _addon = noone;
			with(_addon_custom) if(self.ID == ID) _addon = self;
			if(_addon == noone) return noone;
			
			var wd  = button(onModify).setText(txt);
			wd.setLua(_addon.thread, onModify, function() { 
				return lua_call(lua_thread, lua_thread_key); 
			});
			
			var key = UUID_generate();
			global.ADDON_WIDGET[? key] = wd;
			
			return key;
		} ],

		[ "__button_draw",   function(wd, _x, _y, _w, _h, _m) { 
			if(!ds_map_exists(global.ADDON_WIDGET, wd)) return;
			
			var _button = global.ADDON_WIDGET[? wd];
			var _param = new widgetParam(_x, _y, _w, _h, 0, {}, _m)
			_button.drawParam(_param);
		} ],

@"
Button = {}
Button.new = function(onModify, txt) 
	local self = {}
	
	self.id = __button(ID, onModify, txt)
	
	function self.draw(self, _x, _y, _w, _h) 
		__widget_wake(self.id, Panel.hoverable, Panel.clickable)
		__button_draw(self.id, _x, _y, _w, _h, Panel.mouse)
	end
	
	return self
end",
	];
	
	function __addon_lua_setup_widget(lua, context) {
		for( var i = 0, n = array_length(global.__lua_widget_functions); i < n; i++ ) {
			var _func = global.__lua_widget_functions[i];
			
			if(is_string(_func))     lua_add_code(lua, _func);
			else if(is_array(_func)) lua_add_function(lua, _func[0], _func[1]);
		}
	}
#endregion