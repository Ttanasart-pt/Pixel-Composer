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
	
	sMode = ["Move", "Wind"];
	scMode = new scrollBox(
		sMode, 
		function(val) { onModify(PUPPET_CONTROL.mode, toNumber(val)); }
	);
	
	widgets = [ scMode, tbCx, tbCy, tbFx, tbFy, tbW, tbH, rot ];
	
	static setInteract = function(interactable = noone) { 
		self.interactable = interactable;
		
		for( var i = 0, n = array_length(widgets); i < n; i++ ) 
			widgets[i].setInteract(interactable);
	}
	
	static register = function(parent = noone) {
		for( var i = 0, n = array_length(widgets); i < n; i++ ) 
			widgets[i].register(parent); 
	}
	
	static drawParam = function(params) {
		return draw(params.x, params.y, params.w, params.data, params.m, params.rx, params.ry);
	}
	
	static draw = function(_x, _y, _w, _data, _m, _rx, _ry) {
		x = _x;
		y = _y;
		
		for( var i = 0, n = array_length(widgets); i < n; i++ )
			widgets[i].setFocusHover(active, hover);
		
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
			case PUPPET_FORCE_MODE.wind: 
				draw_set_text(f_p0, fa_left, fa_center, COLORS._main_text);
				draw_text(_x, yy + ui(17), "strength");
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