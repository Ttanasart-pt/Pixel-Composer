function Panel_Custom_Element() constructor {
	type = "element";
	name = "Element";
	icon = THEME.panel_icon_element_frame;
	
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
	
	editors = [
		[ "Main", false ], 
		new Panel_Custom_Element_Editor("Name",     textBox_Text( function(t) /*=>*/ { name = t; } ), function() /*=>*/ {return name}, function(t) /*=>*/ { name = t; }), 
		new Panel_Custom_Element_Editor("Position", new pbBoxBox(), function() /*=>*/ {return pbBox}, function(v) /*=>*/ { pbBox = v; }), 
	];
	
	////- BBOX
	
	static setSize = function(_pBbox, _rx, _ry) {
		pbBox.base_bbox = _pBbox.getBBOX();
		bbox = pbBox.getBBOX(bbox);
		x  = bbox[0];
		y  = bbox[1];
		w  = bbox[2] - bbox[0];
		h  = bbox[3] - bbox[1];
		
		rx = _rx;
		ry = _ry;
	}
	
	////- Draw
	
	static setFocusHover = function(_focus, _hover) {
		focus = _focus;
		hover = _hover;
		return self;
	}
	
	static draw = function(panel, _m) {}
	
	static drawBox = function(panel) {
		draw_sprite_stretched_add(THEME.ui_panel, 1, x, y, w, h, COLORS._main_icon, .1 + .5 * (panel._hovering_element == self));
	}
	
	static doDrawOutline = function(_depth, _panel, _x, _y, _w, _m, hov) { return 0; }
	static drawOutline   = function(_depth, _panel, _x, _y, _w, _m) {
		var lh = ui(24);
		var _h = lh;
		
		if(_depth) {
			draw_set_color(CDEF.main_dark);
			draw_line(_x - ui(4), _y + lh / 2, _x, _y + lh / 2);
		}
		
		var hov = _panel.pHOVER && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + lh - 1);
		draw_sprite_ui_uniform(icon, 0, _x + ui(12), _y + lh / 2, .5, c_white);
		draw_set_text(f_p4, fa_left, fa_center, COLORS._main_text);
		draw_text_add(_x + ui(24), _y + lh / 2, name);
		
		if(_panel.element_adding == undefined && _panel.element_selecting == self)
			draw_sprite_stretched_ext(THEME.box_r2, 1, _x, _y, _w, lh, COLORS._main_accent);
		
		if(hov) {
			draw_sprite_stretched_add(THEME.box_r2, 1, _x, _y, _w, lh, COLORS._main_icon, .3);
			_panel.hovering_element  = self;
			_panel.outline_drag_side = _m[1] > _y + lh / 2? 1 : 0;
			
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
		_h += doDrawOutline(_depth, _panel, _x, _y, _w, _m, hov);
		
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
		
		_m.type = type;
		_m.draggable = draggable;
		
		#region pbbox scale
			_m.box  = pbBox.serialize();
			
			if(!_m.box.anchor_l_fract) _m.box.anchor_l /= UI_SCALE;
			if(!_m.box.anchor_t_fract) _m.box.anchor_t /= UI_SCALE;
			
			if(!_m.box.anchor_r_fract) _m.box.anchor_r /= UI_SCALE;
			if(!_m.box.anchor_b_fract) _m.box.anchor_b /= UI_SCALE;
			
			if(!_m.box.anchor_w_fract) {
				_m.box.anchor_w     /= UI_SCALE;
				_m.box.anchor_w_min /= UI_SCALE;
				_m.box.anchor_w_max /= UI_SCALE;
			}
				
			if(!_m.box.anchor_h_fract) {
				_m.box.anchor_h     /= UI_SCALE;
				_m.box.anchor_h_min /= UI_SCALE;
				_m.box.anchor_h_max /= UI_SCALE;
			}
		#endregion
		
		doSerialize(_m);
		return _m;
	}
	
	static doDeserialize = function(_m) {}
	static deserialize   = function(_m) { 
		var _ele = undefined;
		switch(_m.type) {
			case "frame":      _ele = new Panel_Custom_Frame().doDeserialize(_m);       break;
			case "framesplit": _ele = new Panel_Custom_Frame_Split().doDeserialize(_m); break;
			
			case "text":   _ele = new Panel_Custom_Text().doDeserialize(_m);           break;
			
			case "input":  _ele = new Panel_Custom_Node_Input().doDeserialize(_m);  break;
			case "output": _ele = new Panel_Custom_Node_Output().doDeserialize(_m); break;
		}
		
		if(_ele == undefined) return self;
		_ele.draggable  = _m.draggable;
		
		#region pbbox scale
			var p = _ele.pbBox;
			p.deserialize(_m.box);
			
			if(!p.anchor_l_fract) p.anchor_l *= UI_SCALE;
			if(!p.anchor_t_fract) p.anchor_t *= UI_SCALE;
			
			if(!p.anchor_r_fract) p.anchor_r *= UI_SCALE;
			if(!p.anchor_b_fract) p.anchor_b *= UI_SCALE;
			
			if(!p.anchor_w_fract) {
				p.anchor_w     *= UI_SCALE;
				p.anchor_w_min *= UI_SCALE;
				p.anchor_w_max *= UI_SCALE;
			}
				
			if(!p.anchor_h_fract) {
				p.anchor_h     *= UI_SCALE;
				p.anchor_h_min *= UI_SCALE;
				p.anchor_h_max *= UI_SCALE;
			}
		#endregion
		
		return _ele;
	}
	
	static toString = function() { return $"[Custom Element {instanceof(self)}] {name}"; }
}

function Panel_Custom_Element_Editor(_name, _widget, _getter, _setter) constructor {
	name       = _name;
	editWidget = _widget;
	getter     = _getter;
	setter     = _setter;
}