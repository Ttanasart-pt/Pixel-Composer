enum PUPPET_CONTROL {
	mode,
	cx,
	cy,
	fx,
	fy,
	width,
	height
}

enum PUPPET_FORCE_MODE {
	move,
	pinch,
	inflate,
	wind,
}

function controlPointBox(_onModify) : widget() constructor {
	onModify = _onModify;
	onSurfaceSize = -1;
	
	tbCx = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(PUPPET_CONTROL.cx,     toNumber(val)); });
	tbCy = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(PUPPET_CONTROL.cy,     toNumber(val)); });
	tbFx = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(PUPPET_CONTROL.fx,     toNumber(val)); });
	tbFy = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(PUPPET_CONTROL.fy,     toNumber(val)); });
	tbW  = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(PUPPET_CONTROL.width,  max(0, toNumber(val))); });
	tbH  = new textBox(TEXTBOX_INPUT.number, function(val) { return onModify(PUPPET_CONTROL.height, max(0, toNumber(val))); });
	rot  = new rotator(function(val) { return onModify(PUPPET_CONTROL.fy, toNumber(val)); });
	tbFx.slidable = true;
	tbFy.slidable = true;
	tbW.slidable = true;
	tbH.slidable = true;
	
	sW   = new slider(0, 32, 0.1, function(val) { onModify(PUPPET_CONTROL.width,  toNumber(val)); });
	
	sMode = ["Move", "Pinch", "Inflate", "Wind"];
	scMode = new scrollBox(
		sMode, 
		function(val) { onModify(PUPPET_CONTROL.mode, toNumber(val)); }
	);
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		scMode.interactable = interactable;
		tbCx.interactable = interactable;
		tbCy.interactable = interactable;
		tbFx.interactable = interactable;
		tbFy.interactable = interactable;
		tbW.interactable = interactable;
		tbH.interactable = interactable;
		rot.interactable = interactable;
	}
	
	static register = function(parent = noone) {
		scMode.register(parent); 
		tbCx.register(parent);
		tbCy.register(parent);
		tbFx.register(parent);
		tbFy.register(parent);
		tbW.register(parent); 
		tbH.register(parent); 
		rot.register(parent); 
	}
	
	static draw = function(_x, _y, _w, _data, _m, _rx, _ry) {
		x = _x;
		y = _y;
		
		tbCx.hover   = hover; tbCx.active   = active;
		tbCy.hover   = hover; tbCy.active   = active;
		tbFx.hover   = hover; tbFx.active   = active;
		tbFy.hover   = hover; tbFy.active   = active;
		tbW.hover    = hover; tbW.active    = active;
		sW.hover     = hover; sW.active     = active;
		tbH.hover    = hover; tbH.active    = active;
		scMode.hover = hover; scMode.active = active;
		rot.hover    = hover; rot.active    = active;
		
		var yy = _y;
		
		scMode.draw(_x, yy, _w, TEXTBOX_HEIGHT, sMode[_data[PUPPET_CONTROL.mode]], _m, _rx, _ry);
		yy += TEXTBOX_HEIGHT + ui(8);
		
		var lw = ui(80);
		var w  = _w / 2 - lw;
		
		draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
		draw_text(_x,					yy + ui(17), "cx");
		draw_text(_x + _w / 2 + ui(10), yy + ui(17), "cy");
		tbCx.draw(_x + lw,				yy, w, TEXTBOX_HEIGHT, _data[PUPPET_CONTROL.cx], _m);
		tbCy.draw(_x + _w / 2 + lw,		yy, w, TEXTBOX_HEIGHT, _data[PUPPET_CONTROL.cy], _m);
		yy += TEXTBOX_HEIGHT + ui(8);
		
		switch(_data[PUPPET_CONTROL.mode]) {
			case PUPPET_FORCE_MODE.move: 
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
				draw_text(_x,					yy + ui(17), "fx");
				draw_text(_x + _w / 2 + ui(10), yy + ui(17), "fy");
				tbFx.draw(_x + lw,				yy, w, TEXTBOX_HEIGHT, _data[PUPPET_CONTROL.fx],  _m);
				tbFy.draw(_x + _w / 2 + lw,		yy, w, TEXTBOX_HEIGHT, _data[PUPPET_CONTROL.fy], _m);
				yy += TEXTBOX_HEIGHT + ui(8);
		
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
				draw_text(_x, yy + ui(17), "radius");
				sW.draw(_x + lw, yy, _w - lw, TEXTBOX_HEIGHT, _data[PUPPET_CONTROL.width],  _m);
				yy += TEXTBOX_HEIGHT + ui(8);
				break;
			case PUPPET_FORCE_MODE.pinch: 
			case PUPPET_FORCE_MODE.inflate: 
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
				draw_text(_x, yy + ui(17), "radius");
				sW.draw(_x + lw, yy, _w - lw, TEXTBOX_HEIGHT, _data[PUPPET_CONTROL.width],  _m);
				yy += TEXTBOX_HEIGHT + ui(8);
				
				draw_text(_x, yy + ui(17), "strength");
				tbH.draw(_x + lw, yy, _w - lw, TEXTBOX_HEIGHT, _data[PUPPET_CONTROL.height], _m);
				yy += TEXTBOX_HEIGHT + ui(8);
				break;
			case PUPPET_FORCE_MODE.wind: 
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
				draw_text(_x, yy + ui(17), "stength");
				tbFx.draw(_x + lw, yy, _w - lw, TEXTBOX_HEIGHT, _data[PUPPET_CONTROL.fx],  _m);
				yy += TEXTBOX_HEIGHT + ui(8);
				
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
				draw_text(_x, yy + ui(17), "width");
				tbW.draw(_x + lw, yy, _w - lw, TEXTBOX_HEIGHT, _data[PUPPET_CONTROL.width], _m);
				yy += TEXTBOX_HEIGHT + ui(8);
				
				rot.draw(_x + _w / 2, yy, _data[PUPPET_CONTROL.fy], _m);
				yy += ui(94 + 8);
				break;
		}
		
		resetFocus();
		
		return yy - _y;
	}
}