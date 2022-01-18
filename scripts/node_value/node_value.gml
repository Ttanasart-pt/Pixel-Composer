enum JUNCTION_CONNECT {
	input,
	output
}

enum VALUE_TYPE {
	integer   = 0,
	float     = 1,
	boolean   = 2,
	color     = 3,
	surface   = 4,
	
	path      = 5,
	curve     = 6,
	text      = 7,
	object    = 8,
	any       = -1,
}

enum VALUE_MODIFIER {
	none    = 0,
	linked  = 1,
}

enum VALUE_DISPLAY {
	_default,
	range,
	
	//Int
	enum_scroll,
	enum_button,
	rotation,
	rotation_range,
	slider,
	slider_range,
	
	//Color
	gradient,
	palette,
	
	//Int array
	padding,
	vector,
	vector_range,
	area,
	
	//Curve
	curve,
	
	//Misc
	puppet_control,
	button,
	label,
	
	//Array
	path_array,
	
	//Text
	export_format,
	
	//path
	path_save,
	path_load
}

enum VALUE_TAG {
	_default = 0,
	dimension_2d = 1
}

function value_color(i) {
	static JUNCTION_COLORS = [ $6691ff, $78e4ff, $5d3f8c, $5dde8f, $976bff, $4b00eb, $d1c2c2, $e3ff66, $b5b5ff, $ffa64d ];
	return JUNCTION_COLORS[safe_mod(max(0, i), array_length(JUNCTION_COLORS))];
}

function value_bit(i) {
	switch(i) {
		case VALUE_TYPE.integer		: return 1 << 0 | 1 << 1;
		case VALUE_TYPE.float		: return 1 << 1 | 1 << 2;
		case VALUE_TYPE.color		: return 1 << 3;
		case VALUE_TYPE.surface		: return 1 << 4;
									
		case VALUE_TYPE.path		: return 1 << 10;
		case VALUE_TYPE.text		: return 1 << 0 | 1 << 1 | 1 << 10 | 1 << 11;
									
		case VALUE_TYPE.object		: return 1 << 20;
		
		case VALUE_TYPE.any			: return 1 << 0 | 1 << 1 | 1 << 2 | 1 << 3 | 1 << 4 | 1 << 10 | 1 << 11 | 1 << 20;
	}
	return 0;
}

function value_type_directional(f, t) {
	if((t.tag & VALUE_TAG.dimension_2d) && f.type == VALUE_TYPE.surface && t.type == VALUE_TYPE.integer) return true;
	return false;
}

function typeArray(_type) {
	switch(_type) {
		case VALUE_DISPLAY.range :
		case VALUE_DISPLAY.vector_range :
		case VALUE_DISPLAY.rotation_range :
		case VALUE_DISPLAY.slider_range :
		
		case VALUE_DISPLAY.vector :
		case VALUE_DISPLAY.padding :
		case VALUE_DISPLAY.area :
		case VALUE_DISPLAY.puppet_control :
			
		case VALUE_DISPLAY.curve :
			return 1;
			
		case VALUE_DISPLAY.path_array :
		case VALUE_DISPLAY.palette :
			return 2;
	}
	return 0;
}

enum KEYFRAME_END {
	hold,
	loop,
	ping
}

function isGraphable(type) {
	switch(type) {
		case VALUE_TYPE.integer :
		case VALUE_TYPE.float   : return true;
	}
	return false;
}

function nodeValue(_index, _name, _node, _connect, _type, _value, _tag = VALUE_TAG._default) {
	return new NodeValue(_index, _name, _node, _connect, _type, _value, _tag);
}

function NodeValue(_index, _name, _node, _connect, _type, _value, _tag = VALUE_TAG._default) constructor {
	name  = _name;
	node  = _node;
	y     = node.y;
	index = _index;
	type  = _type;
	
	tag = _tag;
	
	connect_type = _connect;
	value_from   = noone;
	value_to     = ds_list_create();
	modifier     = VALUE_MODIFIER.none;
	accept_array = true;
	
	def_val = _value;
	value	= new animValue(_value, self);
	on_end	= KEYFRAME_END.hold;
	extra_data = ds_list_create();
	
	visible = true;
	show_in_inspector = true;
	
	display_type = VALUE_DISPLAY._default;
	display_data = -1;
	
	static setVisible = function(vis, inspector = true) {
		visible = vis;	
		show_in_inspector = inspector;
		
		return self;
	}
	
	static setDisplay = function(_type, _data = -1) {
		display_type = _type;
		display_data = _data;
		resetDisplay();
		
		return self;
	}
	
	static setAcceptArray = function(_accept_array) {
		accept_array = _accept_array;
		
		return self;
	}
	
	static resetDisplay = function() {
		editWidget = noone;
		switch(display_type) {
			case VALUE_DISPLAY.button :
				editWidget = button(display_data[0]);
				editWidget.text = display_data[1];
				visible = false;
				return;
		}
		
		switch(type) {
			case VALUE_TYPE.float :
			case VALUE_TYPE.integer :
				var _txt = type == VALUE_TYPE.float? TEXTBOX_INPUT.float : TEXTBOX_INPUT.number;
				switch(display_type) {
					case VALUE_DISPLAY._default :
						editWidget = new textBox(_txt, function(str) { 
							if(str != "") setValue(toNumber(str)); 
						} );
						editWidget.slidable = true;
						if(display_data != -1) editWidget.slide_speed = display_data;
						break;
					case VALUE_DISPLAY.range :
						editWidget = new rangeBox(_txt, function(index, val) { 
							var _val = value.getValue();
							_val[index] = val;
							setValue(_val);
						} );
						if(display_data != -1) editWidget.extras = display_data;
						break;
					case VALUE_DISPLAY.vector :
						if(array_length(value.getValue()) <= 4) {
							editWidget = new vectorBox(array_length(value.getValue()), _txt, function(index, val) { 
								var _val = value.getValue();
								if(modifier & VALUE_MODIFIER.linked) {
									for(var i = 0; i < array_length(_val); i++) 
										_val[i] = val;
								}
							
								_val[index] = val;
								setValue(_val);
							} );
							if(display_data != -1) editWidget.extras = display_data;
						}
						break;
					case VALUE_DISPLAY.vector_range :
						editWidget = new vectorRangeBox(array_length(value.getValue()), _txt, function(index, val) { 
							var _val = value.getValue();
							_val[index] = val;
							setValue(_val);
						} );
						if(display_data != -1) editWidget.extras = display_data;
						break;
					case VALUE_DISPLAY.rotation :
						editWidget = new rotator(function(val, save) {
							setValue(val, save);
						} );
						break;
					case VALUE_DISPLAY.rotation_range :
						editWidget = new rotatorRange(function(index, val) { 
							var _val = value.getValue();
							_val[index] = round(val);
							setValue(_val);
						} );
						break;
					case VALUE_DISPLAY.slider :
						editWidget = new slider(display_data[0], display_data[1], display_data[2], function(val) { 
							setValue(toNumber(val));
						} );
						break;
					case VALUE_DISPLAY.slider_range :
						editWidget = new sliderRange(display_data[0], display_data[1], display_data[2], function(index, val) { 
							var _val = value.getValue();
							_val[index] = val;
							setValue(_val);
						} );
						break;
					case VALUE_DISPLAY.area :
						editWidget = new areaBox(function(index, val) { 
							var _val = value.getValue();
							_val[index] = val;
							setValue(_val);
						});
						if(display_data != -1) editWidget.onSurfaceSize = display_data;
						break;
					case VALUE_DISPLAY.padding :
						editWidget = new paddingBox(function(index, val) { 
							var _val = value.getValue();
							if(modifier & VALUE_MODIFIER.linked) {
								for(var i = 0; i < array_length(_val); i++) 
									_val[i] = val;
							}
							
							_val[index] = val;
							setValue(_val);
						} , function() { 
							if(modifier & VALUE_MODIFIER.linked) 
								modifier = modifier & ~VALUE_MODIFIER.linked;
							else 
								modifier |= VALUE_MODIFIER.linked;
						});
						break;
					case VALUE_DISPLAY.puppet_control :
						editWidget = new textBox(_txt, function(str) { 
							if(str != "") {
								var _val = value.getValue();
								_val[4] = toNumber(str);
								setValue(_val);
							}
						} );
						editWidget.slidable = true;
						break;
					case VALUE_DISPLAY.enum_scroll :
						editWidget = new scrollBox(display_data, function(val) {
							if(val == -1) return;
							setValue(toNumber(val)); 
						} );
						break;
					case VALUE_DISPLAY.enum_button :
						editWidget = buttonGroup(display_data, function(val) { 
							setValue(val);
						} );
						break;
				}
				break;
			case VALUE_TYPE.boolean :
				editWidget = new checkBox(function() {
					setValue(!value.getValue()); 
				} );
				break;
			case VALUE_TYPE.color :
				switch(display_type) {
					case VALUE_DISPLAY._default :
						editWidget = buttonColor(function(color) { 
							setValue(color);
						} );
					break;
					case VALUE_DISPLAY.gradient :
						editWidget = buttonGradient(function() { 
							node.updateForward();
						} );
						extra_data[| 0] = GRADIENT_INTER.smooth;
					break;
					case VALUE_DISPLAY.palette :
						editWidget = buttonPalette(function(color) { 
							setValue(color);
						} );
					break;
				}
				break;
			case VALUE_TYPE.path :
				visible = false;
				switch(display_type) {
					case VALUE_DISPLAY.path_load :
					case VALUE_DISPLAY.path_array :
						editWidget = button(function() { 
							var path = get_open_filename(display_data[0], display_data[1]);
							if(path == "") return noone;
							setValue(path);
						} );
						break;
					case VALUE_DISPLAY.path_save :
						editWidget = button(function() { 
							var path = get_save_filename(display_data[0], display_data[1]);
							if(path == "") return noone;
							setValue(path);
						} );
						break;
				}
				break;
			case VALUE_TYPE.curve :
				visible = false;
				display_type = VALUE_DISPLAY.curve;
				editWidget = new curveBox(
					function(_modified) { setValue(_modified); });
				break;
			case VALUE_TYPE.text :
				editWidget = new textBox(TEXTBOX_INPUT.text, function(str) { 
					setValue(str);
				} );
				break;
		}
	}
	resetDisplay();
	
	static getValue = function() {
		var _val = getValueRecursive();
		var val = _val[0];
		var typ = _val[1];
		
		var _base = value.getValue();
		
		if((tag & VALUE_TAG.dimension_2d) && typ == VALUE_TYPE.surface) {
			if(is_array(val)) {
				if(array_length(val) > 0 && is_surface(val[0])) {
					var _v = array_create(array_length(val));
					for( var i = 0; i < array_length(val); i++ )
						_v[i] = [ surface_get_width(val[i]), surface_get_height(val[i]) ];
					return _v;
				}
			} else if (is_surface(val)) {
				return [ surface_get_width(val), surface_get_height(val) ];
			}
		}
		
		if(is_array(_base)) {
			if(!is_array(val))
				return array_create(array_length(_base), val);	
			else if(array_length(val) < array_length(_base)) {
				for( var i = array_length(val); i < array_length(_base); i++ ) {
					val[i] = 0;
				}
			}
		}
		
		return val;
	}
	
	static getValueRecursive = function() {
		var val = [ -1, VALUE_TYPE.any ];
		
		if(value_from == noone)
			val = [value.getValue(), type];
		else if(value_from != self) {
			val = value_from.getValueRecursive(); 
		}
		
		return val;
	}
	
	static getExtraData = function() {
		var data = extra_data;
		
		if(value_from != noone && value_from != self)					
			data = value_from.getExtraData();
		
		return data;
	}
	
	static __anim = function() {
		return value.is_anim || node.update_on_frame;
	}
	static isAnim = function() {
		if(value_from == noone) return __anim();
		else					return value_from.isAnim() || value_from.__anim();
	}
	
	static showValue = function() {
		var val = getValue();
		if(isArray()) {
			if(array_length(val) == 0) return 0;
			return val[safe_mod(node.preview_index, array_length(val))];
		}
		return val;
	}
	
	static isArray = function() {
		var val = getValue();
		
		if(is_array(val)) {
			if(typeArray(display_type))
				return is_array(val[0]);
			else
				return true;
		}
		
		return false;
	}
	
	static setValue = function(val = 0, record = true, time = -999) {
		var _o = value.getValue();
		value.setValue(val, record, time);
		var _n = value.getValue();
		var updated = false;
		
		if(is_array(_o)) {
			if(array_length(_o) != array_length(_n)) {
				updated = true;
			} else {
				for(var i = 0; i < array_length(_o); i++) {
					updated = updated || (_o[i] != _n[i]);
				}
			}
		} else
			updated = _o != _n;
		
		if(updated) {
			if(connect_type == JUNCTION_CONNECT.input && node.auto_update) 
				node.updateForward();
			
			node.onValueUpdate(index);
		}
		
		return updated;
	}
	
	static removeKeyframe = function(index) {
		if(ds_list_size(value.values) > 1)
			ds_list_delete(value.values, index);
		else
			value.is_anim = false;
	}
	
	static setFrom = function(_valueFrom, _update = true, checkRecur = true) {
		if(_valueFrom == -1 || _valueFrom == undefined) {
			show_debug_message("LOAD : Value from error " + string(_valueFrom))
			return false;
		}
		
		if(_valueFrom == noone) {
			removeFrom();
			return false;
		}
		
		if(_valueFrom == self) {
			show_debug_message("setFrom : Connect to self");
			return false;
		}
		
		if(value_bit(type) & value_bit(_valueFrom.type) == 0 && !value_type_directional(_valueFrom, self)) {
			show_debug_message("setFrom : Type mismatch");
			return false;
		}
		
		if(connect_type == _valueFrom.connect_type) {
			show_debug_message("setFrom : Connect type mismatch");
			return false;
		}
		
		if(checkRecur && _valueFrom.searchNodeBackward(node)) {
			show_debug_message("setFrom : Recursive");
			return false;
		}
			
		if(!accept_array && _valueFrom.isArray()) {
			show_debug_message("setFrom : Array mismatch");
			return false;
		}
		
		recordAction(ACTION_TYPE.junction_connect, self, value_from);
		value_from = _valueFrom;
		ds_list_add(_valueFrom.value_to, self);
		//show_debug_message("connected " + name + " to " + _valueFrom.name)
		
		if(_update) node.updateValueFrom(index);
		if(_update && node.auto_update) _valueFrom.node.updateForward();
		
		return true;
	}
	
	static removeFrom = function() {
		recordAction(ACTION_TYPE.junction_connect, self, value_from);
		if(value_from)
			ds_list_delete(value_from.value_to, ds_list_find_index(value_from.value_to, self));	
		value_from = noone;
		
		node.updateValueFrom(index);
	}
	
	static getShowString = function() {
		var val = showValue();
		return string(val);
	}
	
	static setString = function(str) {
		var _o = value.getValue();
		
		if(string_pos(",", str) > 0) {
			string_replace(str, "[", "");
			string_replace(str, "]", "");
			
			var ss  = str, pos, val = [], ind = 0;
			
			while(string_length(ss) > 0) {
				pos = string_pos(",", ss);
				
				if(pos == 0) {
					val[ind++] = toNumber(ss);
					ss = "";
				} else {
					val[ind++] = toNumber(string_copy(ss, 1, pos - 1));
					ss  = string_copy(ss, pos + 1, string_length(ss) - pos);
				}
			}
			
			var _t = typeArray(display_type);
			if(_t) {
				if(array_length(_o) == array_length(val) || _t == 2) {
					setValue(val);
				}
			} else if(array_length(val) > 0) {
				setValue(val[0]);	
			}
		} else {
			if(is_array(_o)) {
				setValue(array_create(array_length(_o), toNumber(str)));
			} else {
				setValue(toNumber(str));
			}
		}
	}
	
	static checkConnection = function() {
		if(value_from && !value_from.node.active) 
			removeFrom();
	}
	
	static searchNodeBackward = function(_node) {
		if(node == _node) return true;
		for(var i = 0; i < ds_list_size(node.inputs); i++) {
			var _in = node.inputs[| i].value_from;
			if(_in && _in.searchNodeBackward(_node))
				return true;
		}
		return false;
	}
	
	drag_type = 0;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sx   = 0;
	drag_sy   = 0;
	static drawOverlay = function(_active, _x, _y, _s, _mx, _my) {
		var _val = getValue();
		var hover = -1;
		
		switch(type) {
			case VALUE_TYPE.integer :
			case VALUE_TYPE.float :
				switch(display_type) {
					case VALUE_DISPLAY._default : #region
						var _angle = argument_count > 6? argument[6] : 0;
						var _scale = argument_count > 7? argument[7] : 1;
						var spr = argument_count > 8? argument[8] : s_anchor_selector;
						var index = 0;
						
						var __ax = lengthdir_x(_val * _scale, _angle);
						var __ay = lengthdir_y(_val * _scale, _angle);
						
						var _ax = _x + __ax * _s;
						var _ay = _y + __ay * _s;
						
						if(drag_type) {
							index = 1;
							var dist = point_distance(_mx, _my, _x, _y) / _s / _scale;
							if(keyboard_check(vk_control))
								dist = round(dist);
							
							if(setValue( dist ))
								UNDO_HOLDING = true;
							
							if(mouse_check_button_released(mb_left)) {
								drag_type = 0;
								UNDO_HOLDING = false;
							}
						}
						
						if(point_in_circle(_mx, _my, _ax, _ay, 8)) {
							hover = 1;
							index = 1;
							if(_active && mouse_check_button_pressed(mb_left)) {
								drag_type = 1;
								drag_mx   = _mx;
								drag_my   = _my;
								drag_sx   = _ax;
								drag_sy   = _ay;
							}
						} 
						
						draw_sprite(spr, index, _ax, _ay);
						break;
					#endregion
					case VALUE_DISPLAY.rotation : #region
						var _rad = argument_count > 6? argument[6] : 64;
						
						var _ax = _x + lengthdir_x(_rad, _val);
						var _ay = _y + lengthdir_y(_rad, _val);
						draw_sprite_ext(s_anchor_rotate, 0, _ax, _ay, 1, 1, _val - 90, c_white, 1);
						
						if(drag_type) {
							draw_set_color(c_ui_orange);
							draw_set_alpha(0.5);
							draw_circle(_x, _y, _rad, true);
							draw_set_alpha(1);
							
							draw_sprite_ext(s_anchor_rotate, 1, _ax, _ay, 1, 1, _val - 90, c_white, 1);
							var angle = point_direction(_x, _y, _mx, _my);
							if(keyboard_check(vk_control))
								angle = round(angle / 15) * 15;
								
							if(setValue( angle ))
								UNDO_HOLDING = true;
							
							if(mouse_check_button_released(mb_left)) {
								drag_type = 0;
								UNDO_HOLDING = false;
							}
						}
						
						if(point_in_circle(_mx, _my, _ax, _ay, 8)) {
							draw_set_color(c_ui_orange);
							draw_set_alpha(0.5);
							draw_circle(_x, _y, _rad, true);
							draw_set_alpha(1);
							hover = 1;
							
							draw_sprite_ext(s_anchor_rotate, 1, _ax, _ay, 1, 1, _val - 90, c_white, 1);
							if(_active && mouse_check_button_pressed(mb_left)) {
								drag_type = 1;
								drag_mx   = _mx;
								drag_my   = _my;
								drag_sx   = _ax;
								drag_sy   = _ay;
							}
						} 
						break;
					#endregion
					case VALUE_DISPLAY.vector : #region
						var _psx = argument_count > 6? argument[6] : 1;
						var _psy = argument_count > 7? argument[7] : 1;
						
						var __ax = _val[0] * _psx;
						var __ay = _val[1] * _psy;
						
						var _ax = __ax * _s + _x;
						var _ay = __ay * _s + _y;
						
						draw_sprite(s_anchor_selector, 0, _ax, _ay);
						
						if(drag_type) {
							draw_sprite(s_anchor_selector, 1, _ax, _ay);
							var _nx = (drag_sx + (_mx - drag_mx) - _x) / _s / _psx;
							var _ny = (drag_sy + (_my - drag_my) - _y) / _s / _psy;
							if(keyboard_check(vk_control)) {
								_val[0] = round(_nx);
								_val[1] = round(_ny);
							} else {
								_val[0] = _nx;
								_val[1] = _ny;
							}
							
							if(setValue( _val )) 
								UNDO_HOLDING = true;
							
							if(mouse_check_button_released(mb_left)) {
								drag_type = 0;
								UNDO_HOLDING = false;
							}
						}
						
						if(point_in_circle(_mx, _my, _ax, _ay, 8)) {
							hover = 1;
							draw_sprite(s_anchor_selector, 1, _ax, _ay);
							if(_active && mouse_check_button_pressed(mb_left)) {
								drag_type = 1;
								drag_mx   = _mx;
								drag_my   = _my;
								drag_sx   = _ax;
								drag_sy   = _ay;
							}
						} 
						break;
					#endregion
					case VALUE_DISPLAY.area : #region
						var __ax = array_safe_get(_val, 0);
						var __ay = array_safe_get(_val, 1);
						var __aw = array_safe_get(_val, 2);
						var __ah = array_safe_get(_val, 3);
						var __at = array_safe_get(_val, 4);
						
						var _ax = __ax * _s + _x;
						var _ay = __ay * _s + _y;
						var _aw = __aw * _s;
						var _ah = __ah * _s;
						
						draw_set_color(c_ui_orange);
						switch(__at) {
							case AREA_SHAPE.rectangle :
								draw_rectangle(_ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah, true);
								break;
							case AREA_SHAPE.elipse :
								draw_ellipse(_ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah, true);
								break;
						}
						
						draw_sprite_ext(s_anchor, 0, _ax, _ay, 1, 1, 0, c_white, 1);
						draw_sprite(s_anchor_selector, 0, _ax + _aw, _ay + _ah);
						
						if(point_in_circle(_mx, _my, _ax + _aw, _ay + _ah, 8))
							draw_sprite(s_anchor_selector, 1, _ax + _aw, _ay + _ah);
						else if(point_in_rectangle(_mx, _my, _ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah))
							draw_sprite_ext(s_anchor, 0, _ax, _ay, 1.25, 1.25, 0, c_white, 1);
						
						if(drag_type == 1) {
							var _xx = drag_sx + (_mx - drag_mx) / _s;
							var _yy = drag_sy + (_my - drag_my) / _s;
							
							if(keyboard_check(vk_control)) {
								_val[0] = round(_xx);
								_val[1] = round(_yy);
							} else {
								_val[0] = _xx;
								_val[1] = _yy;
							}
							
							if(setValue(_val))
								UNDO_HOLDING = true;
							
							if(mouse_check_button_released(mb_left)) {
								drag_type = 0;
								UNDO_HOLDING = false;
							}
						} else if(drag_type == 2) {
							var _dx = (_mx - drag_mx) / _s;
							var _dy = (_my - drag_my) / _s;
							
							if(keyboard_check(vk_control)) {
								_val[2] = round(_dx);
								_val[3] = round(_dy);
							} else {
								_val[2] = _dx;
								_val[3] = _dy;
							}
							
							if(setValue(_val))
								UNDO_HOLDING = true;
			
							if(mouse_check_button_released(mb_left)) {
								drag_type = 0;
								UNDO_HOLDING = false;
							}
						}
						
						if(_active) {
							if(point_in_circle(_mx, _my, _ax + _aw, _ay + _ah, 8)) {
								hover = 2;
								if(mouse_check_button_pressed(mb_left)) {
									drag_type = 2;
									drag_mx   = _ax;
									drag_my   = _ay;
								}
							} else if(point_in_rectangle(_mx, _my, _ax - _aw, _ay - _ah, _ax + _aw, _ay + _ah)) {
								hover = 1;
								if(mouse_check_button_pressed(mb_left)) {
									drag_type = 1;	
									drag_sx   = __ax;
									drag_sy   = __ay;
									drag_mx   = _mx;
									drag_my   = _my;
								}
							}
						}
						break;
					#endregion
					case VALUE_DISPLAY.puppet_control : #region
						var __ax  = _val[0];
						var __ay  = _val[1];
						var __ax1 = _val[2];
						var __ay1 = _val[3];
						
						var _ax = __ax * _s + _x;
						var _ay = __ay * _s + _y;
						
						var _ax1 = (__ax + __ax1) * _s + _x;
						var _ay1 = (__ay + __ay1) * _s + _y;
						
						draw_set_color(c_ui_orange);
						
						draw_line_width2(_ax, _ay, _ax1, _ay1, 6, 1);
						
						draw_sprite(s_anchor_selector, 0, _ax, _ay);
						draw_sprite(s_anchor_selector, 2, _ax1, _ay1);
						
						if(drag_type == 1) {
							draw_sprite(s_anchor_selector, 1, _ax, _ay);
							var _nx = drag_sx + (_mx - drag_mx) / _s;
							var _ny = drag_sy + (_my - drag_my) / _s;
							
							if(keyboard_check(vk_control)) {
								_val[0] = round(_nx);
								_val[1] = round(_ny);
							} else {
								_val[0] = _nx;
								_val[1] = _ny;
							}
							
							if(setValue( _val ))
								UNDO_HOLDING = true;
							
							if(mouse_check_button_released(mb_left)) {
								drag_type = 0;
								UNDO_HOLDING = false;
							}
						} else if(drag_type == 2) {
							draw_sprite(s_anchor_selector, 0, _ax1, _ay1);
							var _nx = drag_sx + (_mx - drag_mx) / _s;
							var _ny = drag_sy + (_my - drag_my) / _s;
							
							if(keyboard_check(vk_control)) {
								_val[2] = round(_nx);
								_val[3] = round(_ny);
							} else {
								_val[2] = _nx;
								_val[3] = _ny;
							}
							
							if(setValue( _val ))
								UNDO_HOLDING = true;
							
							if(mouse_check_button_released(mb_left)) {
								drag_type = 0;
								UNDO_HOLDING = false;
							}
						}
						
						if(point_in_circle(_mx, _my, _ax, _ay, 8)) {
							draw_set_color(c_ui_orange);
							draw_circle(_ax, _ay, _val[4] * _s, true);
							
							hover = 1;
							draw_sprite(s_anchor_selector, 1, _ax, _ay);
							if(_active && mouse_check_button_pressed(mb_left)) {
								drag_type = 1;
								drag_mx   = _mx;
								drag_my   = _my;
								drag_sx   = __ax;
								drag_sy   = __ay;
							}
						} else if(point_in_circle(_mx, _my, _ax1, _ay1, 8)) {
							hover = 2;
							draw_sprite(s_anchor_selector, 0, _ax1, _ay1);
							if(_active && mouse_check_button_pressed(mb_left)) {
								drag_type = 2;
								drag_mx   = _mx;
								drag_my   = _my;
								drag_sx   = __ax1;
								drag_sy   = __ay1;
							}
						} 
						break;
					#endregion
				}
				break;
		}
		return hover;
	}
	
	static isVisible = function() {
		if(!node.active) return false;
		return visible && show_in_inspector;
	}
	
	static serialize = function(scale = false) {
		var _map = ds_map_create();
		
		ds_map_add_list(_map, "raw value", value.serialize(scale));
		
		_map[? "on end"] = on_end;
		_map[? "visible"] = visible;
		_map[? "anim"] = value.is_anim;
		_map[? "from node"] = value_from? value_from.node.node_id	: -1;
		_map[? "from index"] = value_from? value_from.index			: -1;
		
		ds_map_add_list(_map, "data", ds_list_clone(extra_data));
		
		return _map;
	}
	
	con_node  = -1;
	con_index = -1;
	static deserialize = function(_map, scale = false) {
		on_end = ds_map_try_get(_map, "on end", on_end);
		visible	= ds_map_try_get(_map, "visible", visible);
		value.deserialize(_map[? "raw value"], scale);
		value.is_anim = _map[? "anim"];
		con_node = _map[? "from node"];
		con_index = _map[? "from index"];
		
		if(ds_map_exists(_map, "data")) 
			ds_list_copy(extra_data, _map[? "data"]);
	}
	
	static connect = function() {
		if(con_node == -1) return true;
		if(con_index == -1) return true;
		
		if(ds_map_exists(NODE_MAP, con_node + APPEND_ID)) {
			var _nd = NODE_MAP[? con_node + APPEND_ID];
			var _ol = ds_list_size(_nd.outputs);
			if(con_index < _ol) {
				if(setFrom(_nd.outputs[| con_index], false)) 
					return true;
				else
					log_warning("LOAD", "[Connect] Connection conflict " + string(node.name) + " to " + string(_nd.name) + " : Connection failed.");
				return false;
			} else {
				log_warning("LOAD", "[Connect] Connection conflict " + string(node.name) + " to " + string(_nd.name) + " : Node not exist.");
				return false;
			}
		} else {
			log_warning("LOAD", "[Connect] Connection error, node does not exist.");
		}
		
		var txt = "Node connect error : Node ID " + string(con_node + APPEND_ID) + " not found.";
		log_warning("LOAD", "[Connect] " + txt);
		PANEL_MENU.addNotiExtra(txt);
		return true;
	}
}