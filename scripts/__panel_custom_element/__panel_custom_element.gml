function Panel_Custom_Element(_data) constructor {
	data = _data;
	type = "element";
	name = "Element";
	icon = THEME.panel_icon_element_frame;
	active = true;
	
	contents       = [];
	is_container   = false;
	modifyContent  = true;
	outline_expand = true;
	mouseEvent     = true;
	
	outline_h = ui(24);
	
	#region position
		pbBox = new __pbBox();
		pbBox.anchor_x_type = PB_AXIS_ANCHOR.minimum;
		pbBox.anchor_y_type = PB_AXIS_ANCHOR.minimum;
		pbBox.anchor_w = 64; pbBox.anchor_w_fract = false;
		pbBox.anchor_h = 64; pbBox.anchor_h_fract = false;
		bbox = [0,0,1,1];
		
		x = 0;
		y = 0;
		w = 1;
		h = 1;
		
		rx = 0;
		ry = 0;
	#endregion
	
	parent    = undefined;
	hover     = false;
	focus     = false;
	draggable = true;
	elementHover = false;
	
	editors = [
		[ "Main", false ], 
		Simple_Editor("Name",        textBox_Text( function(t) /*=>*/ { name = t; } ), function() /*=>*/ {return name}, function(t) /*=>*/ { name = t; }), 
		Simple_Editor("Position",    new pbBoxBox(), function() /*=>*/ {return pbBox}, function(v) /*=>*/ { pbBox = v; }), 
		Simple_Editor("Mouse Event", new checkBox(function() /*=>*/ { mouseEvent = !mouseEvent; }), function() /*=>*/ {return mouseEvent}, function(v) /*=>*/ { mouseEvent = v; }), 
	];
	
	////- Contents
	
	static addContent = function(cont) {
		array_push(contents, cont);
		cont.parent = self;
	}
	
	////- BBOX
	
	static setSize = function(_pBbox, _rx, _ry) {
		rx = _rx;
		ry = _ry;
		
		bbox = pbBox.setBase(_pBbox).getBBOX(bbox);
		x  = bbox[0];
		y  = bbox[1];
		w  = bbox[2] - bbox[0];
		h  = bbox[3] - bbox[1];
		
		for( var i = 0, n = array_length(contents); i < n; i++ )
			contents[i].setSize(bbox, _rx, _ry);
	}
	
	static checkMouse = function(panel, _m) {
		elementHover = panel._hovering_element == self;
		
		var _hov = hover && point_in_rectangle(_m[0], _m[1], x, y, x + w, y + h);
		if(_hov) {
			if(mouseEvent) panel.hovering_element = self;
			
			if(is_container || key_mod_press(CTRL)) 
				panel.hovering_frame = self;
		}
		
		for( var i = 0, n = array_length(contents); i < n; i++ )
			contents[i].checkMouse(panel, _m);
	}
	
	////- Draw
	
	static setFocusHover = function(_focus, _hover) {
		focus = _focus;
		hover = _hover;
		for( var i = 0, n = array_length(contents); i < n; i++ ) 
			contents[i].setFocusHover(_focus, _hover);
		return self;
	}
	
	static draw   = function(panel, _m) {}
	static doDraw = function(panel, _m) {
		draw(panel, _m);
		
		for( var i = 0, n = array_length(contents); i < n; i++ )
			contents[i].doDraw(panel, _m);
	}
	
	static drawBox = function(panel) {
		var aa = .25 + .5 * (panel._hovering_element == self);
		draw_sprite_stretched_add(THEME.ui_panel, 1, x, y, w, h, COLORS._main_icon, aa);
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) 
			contents[i].drawBox(panel);
	}
	
	static drawOutlineContent = function(_depth, _panel, _x, _y, _w, _m, hov) { 
		var lh = outline_h;
		
		if(modifyContent) {
			if(_panel.element_adding) {
				if(_panel._hovering_frame == self)
					draw_sprite_stretched_ext(THEME.box_r2, 1, _x, _y - lh, _w, lh, COLORS._main_accent);
					
				if(hov) _panel.hovering_frame = self;
			}
			
			if(_panel.outline_drag && _panel.outline_drag != _panel._hovering_element) {
				var hovIn = point_in_rectangle(_m[0], _m[1], _x + _w - ui(32), _y - lh, _x + _w, _y);
				draw_sprite_ui_uniform(THEME.icon_default, 0, _x + _w - ui(16), _y - lh / 2, .75, 
					hovIn? COLORS._main_accent : COLORS._main_icon, .5 + .5 * hovIn);
				
				if(hovIn) _panel.outline_drag_frame = self;
			}
		}
		
		if(!outline_expand) return 0;
		
		var _h  = 0;
		var _y0 = _y;
		var _y1 = _y;
		
		for( var i = 0, n = array_length(contents); i < n; i++ ) {
			var con = contents[i];
			
			var hh = con.drawOutline(_depth + 1, _panel, _x + ui(16), _y, _w - ui(16), _m);
			_h += hh;
			_y += hh;
			if(i < n - 1) _y1 = _y;
		}
		
		if(n) {
			draw_set_color(CDEF.main_dark);
			draw_line(_x + ui(12), _y0, _x + ui(12), _y1 + lh / 2);
		}
		
		return _h;
	}
		
	static drawOutline = function(_depth, _panel, _x, _y, _w, _m) {
		var lh = outline_h;
		var _h = lh;
		var yc = _y + lh / 2;
		
		if(_depth) {
			draw_set_color(CDEF.main_dark);
			draw_line(_x - ui(4), yc, _x, yc);
		}
		
		draw_sprite_ui_uniform(icon, 0, _x + ui(12), yc, .25, c_white);
		var ttx = _x + ui(24);
		if(is_container || !array_empty(contents)) {
			var hov = _panel.pHOVER && point_in_circle(_m[0], _m[1], _x + ui(24+8), yc, lh / 2);
			draw_sprite_ui_uniform(THEME.arrow, outline_expand * 3, _x + ui(24+8), yc + outline_expand * ui(1), .75, c_white, .5 + hov * .5);
			if(hov && mouse_lpress(_panel.pFOCUS))
				outline_expand = !outline_expand;
			ttx += ui(16);
		}
		
		draw_set_text(f_p4, fa_left, fa_center, active? COLORS._main_text : COLORS._main_text_sub);
		draw_text_add(ttx, yc, name);
		
		if(_panel.element_adding == undefined && _panel.element_selecting == self)
			draw_sprite_stretched_ext(THEME.box_r2, 1, _x, _y, _w, lh, COLORS._main_accent);
		
		var hov = _panel.pHOVER && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + lh - 1);
		if(hov) {
			draw_sprite_stretched_add(THEME.box_r2, 1, _x, _y, _w, lh, COLORS._main_icon, .3);
			_panel.hovering_element  = self;
			_panel.outline_hover     = self;
			_panel.outline_drag_side = _m[1] > yc? 1 : 0;
			
			if(_panel.outline_drag && _panel.outline_drag != self) {
				var ly = _panel.outline_drag_side? _y + lh : _y;
				draw_set_color(COLORS._main_accent);
				draw_line_round(_x, ly, _x + _w, ly, 2);
			}
			
			if(_panel.element_adding && hov)
				_panel.hovering_frame = parent;
			
			if(mouse_lpress(_panel.pFOCUS)) {
				_panel.element_selecting = self;
				if(draggable) _panel.outline_drag = self;
			}
		}
		
		_y += lh;
		_h += drawOutlineContent(_depth, _panel, _x, _y, _w, _m, hov);
		
		return _h;
	}
	
	////- Actions
	
	static postBuild = function() {}
	
	static remove = function() {
		if(parent == undefined) return;
		
		array_remove(parent.contents, self);
	}
	
	////- Serialize
	
	static doSerialize = function(_m) {}
	static serialize   = function() {
		var _m = {};
		
		_m.box  = pbBox.serialize().uiScale(true);
		_m.name = name;
		_m.type = type;
		_m.draggable  = draggable;
		_m.mouseEvent = mouseEvent;
		
		_m.contents = array_map(contents, function(c) /*=>*/ {return c.serialize()});
		
		doSerialize(_m);
		return _m;
	}
	
	static doDeserialize = function(_m) {}
	static deserialize   = function(_m) { 
		if(!has(PANEL_ELEMENT_MAP, _m.type)) return self;
		
		var edata = PANEL_ELEMENT_MAP[$ _m.type];
		var _ele  = new edata.fn(data).doDeserialize(_m);
		
		_ele.pbBox.deserialize(_m.box).uiScale(false);
		_ele.name       = _m[$ "name"]       ?? name;
		_ele.draggable  = _m[$ "draggable"]  ?? draggable;
		_ele.mouseEvent = _m[$ "mouseEvent"] ?? mouseEvent;
		
		if(has(_m, "contents"))
		for( var i = 0, n = array_length(_m.contents); i < n; i++ )
			_ele.addContent(new Panel_Custom_Element(data).deserialize(_m.contents[i]));
		
		return _ele;
	}
	
	static toString = function() { return $"[Custom Element {instanceof(self)}] {name}"; }
}

function   Simple_Editor(_name, _widget, _getter, _setter) { return new __Simple_Editor(_name, _widget, _getter, _setter); }
function __Simple_Editor(_name, _widget, _getter, _setter) constructor {
	name       = _name;   static setName = function(n) /*=>*/ { name = n; return self; }
	editWidget = _widget;
	getter     = _getter;
	setter     = _setter;
}

#region elements
	globalvar PANEL_ELEMENT, PANEL_ELEMENT_MAP;
	
	PANEL_ELEMENT = [
		[ "Frames", false ], 
		{ name: "Frame",       key: "frame",      fn: Panel_Custom_Frame,       spr: function() /*=>*/ {return THEME.panel_icon_element_frame},       prevsize: [ 64, 64] }, 
		{ name: "Grid Frame",  key: "framegrid",  fn: Panel_Custom_Frame_Grid,  spr: function() /*=>*/ {return THEME.panel_icon_element_frame_grid},  prevsize: [ 64, 64] }, 
		{ name: "Scroll Frame",key: "framescroll",fn: Panel_Custom_Frame_Scroll,spr: function() /*=>*/ {return THEME.panel_icon_element_frame_scroll},prevsize: [ 64, 64] }, 
		{ name: "Split Frame", key: "framesplit", fn: Panel_Custom_Frame_Split, spr: function() /*=>*/ {return THEME.panel_icon_element_frame_split}, prevsize: [ 64, 64] }, 
		{ name: "Tab Frame",   key: "frametab",   fn: Panel_Custom_Frame_Tab,   spr: function() /*=>*/ {return THEME.panel_icon_element_frame_tab},   prevsize: [ 64, 64] }, 
		
		[ "Nodes", false ], 
		{ name: "Node Input",  key: "input",      fn: Panel_Custom_Node_Input,  spr: function() /*=>*/ {return THEME.panel_icon_element_node_input},  prevsize: [ 80, 32] }, 
		{ name: "Node Output", key: "output",     fn: Panel_Custom_Node_Output, spr: function() /*=>*/ {return THEME.panel_icon_element_node_output}, prevsize: [ 64, 64] }, 
		
		[ "Widgets", false ], 
		{ name: "Button",      key: "button",     fn: Panel_Custom_Button,      spr: function() /*=>*/ {return THEME.panel_icon_element_button},      prevsize: [ 64, 64] }, 
	//  { name: "Choices",     key: "choices",    fn: Panel_Custom_Choices,     spr: () => THEME.panel_icon_element_choices,     prevsize: [120, 64] }, 
		{ name: "Color",       key: "color",      fn: Panel_Custom_Color,       spr: function() /*=>*/ {return THEME.panel_icon_element_color},       prevsize: [160,160] }, 
		{ name: "Knob",        key: "knob",       fn: Panel_Custom_Knob,        spr: function() /*=>*/ {return THEME.panel_icon_element_knob},        prevsize: [ 64, 64] }, 
		{ name: "Slider",      key: "slider",     fn: Panel_Custom_Slider,      spr: function() /*=>*/ {return THEME.panel_icon_element_slider},      prevsize: [120, 32] }, 
		{ name: "Text",        key: "text",       fn: Panel_Custom_Text,        spr: function() /*=>*/ {return THEME.panel_icon_element_text},        prevsize: [ 80, 32] }, 
		{ name: "Textbox",     key: "textbox",    fn: Panel_Custom_Textbox,     spr: function() /*=>*/ {return THEME.panel_icon_element_textbox},     prevsize: [ 80, 32] }, 
	];
	
	PANEL_ELEMENT_MAP = {};
	for( var i = 0, n = array_length(PANEL_ELEMENT); i < n; i++ ) {
		var e = PANEL_ELEMENT[i];
		if(!is_struct(e)) continue;
		
		PANEL_ELEMENT_MAP[$ e.key] = e;
	}
#endregion