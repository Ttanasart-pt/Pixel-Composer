global.loop_nodes = [ "Node_Iterate", "Node_Iterate_Each" ];

function Node(_x, _y, _group = PANEL_GRAPH.getCurrentContext()) : __Node_Base(_x, _y) constructor {
	active  = true;
	renderActive = true;
	
	node_id = generateUUID();
	group   = _group;
	destroy_when_upgroup = false;
	ds_list_add(PANEL_GRAPH.getNodeList(_group), self);
	
	color   = c_white;
	icon    = noone;
	bg_spr  = THEME.node_bg;
	bg_sel_spr	  = THEME.node_active;
	anim_priority = ds_map_size(NODE_MAP);
	
	if(!LOADING && !APPENDING) {
		recordAction(ACTION_TYPE.node_added, self);
		NODE_MAP[? node_id] = self;
		MODIFIED = true;
	
		run_in(1, function() { 
			var str = string_replace_all(name, " ", "_");
			    str = string_replace_all(str,  "/", "");
			    str = string_replace_all(str,  "-", "");
			
			internalName = str + string(irandom_range(10000, 99999)); 
			NODE_NAME_MAP[? internalName] = self;
		});
	}
	
	name = "";
	display_name = "";
	internalName = "";
	
	tooltip = "";
	x = _x;
	y = _y;
	
	w = 128;
	h = 128;
	min_h = 0;
	draw_padding = 8;
	auto_height  = true;
	
	draw_name = true;
	draggable = true;
	
	inputs  = ds_list_create();
	outputs = ds_list_create();
	inputMap  = ds_map_create();
	outputMap = ds_map_create();
	
	input_display_list		= -1;
	output_display_list		= -1;
	inspector_display_list	= -1;
	is_dynamic_output		= false;
	
	attributes		 = ds_map_create();
	attributeEditors = [];
	
	inspectInput1 = nodeValue("Toggle execution", self, JUNCTION_CONNECT.input, VALUE_TYPE.action, false).setVisible(true, true);
	inspectInput2 = nodeValue("Toggle execution", self, JUNCTION_CONNECT.input, VALUE_TYPE.action, false).setVisible(true, true);
	
	updateAction = nodeValue("Update", self, JUNCTION_CONNECT.input, VALUE_TYPE.action, false).setVisible(true, true);
	
	show_input_name  = false;
	show_output_name = false;
	
	inspecting	  = false;
	previewing	  = 0;
	
	preview_surface	= noone;
	preview_amount  = 0;
	previewable		= true;
	preview_speed	= 0;
	preview_index	= 0;
	preview_channel = 0;
	preview_alpha	= 1;
	preview_x		= 0;
	preview_y		= 0;
	
	preview_surface_prev = noone;
	preview_trans  = 1;
	preview_drop_x = 0;
	preview_drop_y = 0;
	
	preview_mx = 0;
	preview_my = 0;
	
	rendered        = false;
	update_on_frame = false;
	render_time		= 0;
	auto_render_time = true;
	updated			= false;
	
	use_cache		= false;
	cached_output	= [];
	cache_result	= [];
	temp_surface    = [];
	
	tools			= -1;
	
	on_dragdrop_file = -1;
	
	anim_show = true;
	dopesheet_y = 0;
	
	value_validation = array_create(3);
	
	error_noti_update	 = noone;
	error_update_enabled = false;
	manual_updated		 = false;
	manual_deletable	 = true;
	
	tool_settings	= [];
	tool_attribute	= {};
	
	static initTooltip = function() {
		if(!struct_has(global.NODE_GUIDE, instanceof(self))) return;
		
		var _n = global.NODE_GUIDE[$ instanceof(self)];
		var _ins = _n.inputs;
		var _ots = _n.outputs;
		
		var amo = min(ds_list_size(inputs), array_length(_ins));
		for( var i = 0; i < amo; i++ ) {
			inputs[| i].name    = _ins[i].name;
			inputs[| i].tooltip = _ins[i].tooltip;
		}
		
		var amo = min(ds_list_size(outputs), array_length(_ots));
		for( var i = 0; i < amo; i++ ) {
			outputs[| i].name    = _ots[i].name;
			outputs[| i].tooltip = _ots[i].tooltip;
		}
	}
	run_in(1, initTooltip);
	
	static resetDefault = function() {
		var folder = instanceof(self);
		if(!ds_map_exists(global.PRESETS_MAP, folder)) return;
		
		var pres = global.PRESETS_MAP[? folder];
		for( var i = 0; i < array_length(pres); i++ ) {
			var preset = pres[i];
			if(preset.name != "_default") continue;
			
			deserialize(preset.content, true, true);
			applyDeserialize(true);
		}
		
		doUpdate();
	}
	run_in(1, method(self, resetDefault));
	
	static getInputJunctionIndex = function(index) {
		if(input_display_list == -1)
			return index;
		
		var jun_list_arr = input_display_list[index];
		if(is_array(jun_list_arr)) return noone;
		if(is_struct(jun_list_arr)) return noone;
		return jun_list_arr;
	}
	
	static getOutputJunctionIndex = function(index) {
		if(output_display_list == -1)
			return index;
		return output_display_list[index];
	}
	
	static setHeight = function() {
		var _hi = ui(32);
		var _ho = ui(32);
		
		for( var i = 0; i < ds_list_size(inputs); i++ )  {
			if(inputs[| i].isVisible()) _hi += 24;
		}
		
		for( var i = 0; i < ds_list_size(outputs); i++ )  {
			if(outputs[| i].isVisible()) _ho += 24;
		}
		
		h = max(min_h, (preview_surface && previewable)? 128 : 0, _hi, _ho);
	}
	
	static setDisplayName = function(_name) {
		display_name = _name;
		internalName = string_replace_all(display_name, " ", "_");
		
		refreshNodeMap();
	}
	
	static getOutput = function(junc = noone) {
		for( var i = 0; i < ds_list_size(outputs); i++ ) {
			if(!outputs[| i].visible) continue;
			if(junc != noone && !junc.isConnectable(outputs[| i], true)) continue;
			
			return outputs[| i];
		}
		return noone;
	}
	
	static getInput = function(junc = noone) {
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(!inputs[| i].visible) continue;
			if(inputs[| i].value_from != noone) continue;
			if(junc != noone && !inputs[| i].isConnectable(junc, true)) continue;
			
			return inputs[| i];
		}
		return noone;
	}
	
	static getFullName = function() {
		return display_name == ""? name : "[" + name + "] " + display_name;
	}
	
	static addInput = function(junctionFrom) {
		var targ = getInput(junctionFrom);
		if(targ == noone) return;
		
		targ.setFrom(junctionFrom);
	}
	
	static isAnimated = function() {
		for(var i = 0; i < ds_list_size(inputs); i++) {
			if(inputs[| i].isAnimated())
				return true;
		}
		return false;
	}
	
	static isInLoop = function() {
		return array_exists(global.loop_nodes, instanceof(group));
	}
	
	static move = function(_x, _y) {
		if(x == _x && y == _y) return;
		
		x = _x;
		y = _y;
		if(!LOADING) MODIFIED = true;
	}
	
	insp1UpdateTooltip  = get_text("panel_inspector_execute", "Execute node");
	insp1UpdateIcon     = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	static inspector1Update = function() {
		if(error_update_enabled && error_noti_update != noone)
			noti_remove(error_noti_update);
		error_noti_update = noone;
		
		onInspector1Update();
	}
	static onInspector1Update = noone;
	static hasInspector1Update = function() { return onInspector1Update != noone; }
	
	insp2UpdateTooltip = get_text("panel_inspector_execute", "Execute node");
	insp2UpdateIcon    = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	static inspector2Update = function() { onInspector2Update(); }
	static onInspector2Update = noone;
	static hasInspector2Update = function() { return onInspector2Update != noone; }
	
	static stepBegin = function() {
		if(use_cache) cacheArrayCheck();
		var willUpdate = false;
		
		if(ANIMATOR.frame_progress) {
			if(update_on_frame) willUpdate = true;
			if(isAnimated()) willUpdate = true;
				
			if(willUpdate) {
				setRenderStatus(false);
				UPDATE |= RENDER_TYPE.partial;
			}
		}
		
		if(auto_height)
			setHeight();
		
		doStepBegin();
		
		if(hasInspector1Update()) inspectInput1.name = insp1UpdateTooltip;
		if(hasInspector2Update()) inspectInput2.name = insp2UpdateTooltip;
	}
	static doStepBegin = function() {}
	
	static step = function() {}
	static focusStep = function() {}
	
	static doUpdate = function() { 
		if(SAFE_MODE) return;
		var sBase = surface_get_target();
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render, "DoUpdate called from " + name);
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(inputs[| i].type != VALUE_TYPE.trigger) continue;
			if(inputs[| i].editWidget == noone) continue;
			
			var trg = inputs[| i].getValue();
			if(trg) inputs[| i].editWidget.onClick();
		}
		
		try {
			var t = get_timer();
			if(!is_instanceof(self, Node_Collection)) 
				setRenderStatus(true);
				
			update();
			
			if(!is_instanceof(self, Node_Collection))
				render_time = get_timer() - t;
		} catch(exception) {
			var sCurr = surface_get_target();
			while(surface_get_target() != sBase)
				surface_reset_target();
			
			log_warning("RENDER", exception_print(exception), self);
		}
		
		if(hasInspector1Update()) {
			var trigger = inspectInput1.getValue();
			if(trigger) onInspector1Update();
		}
		
		if(hasInspector2Update()) {
			var trigger = inspectInput2.getValue();
			if(trigger) onInspector2Update();
		}
		LOG_BLOCK_END();
	}
	
	static valueUpdate = function(index) {
		if(error_update_enabled && error_noti_update == noone)
			error_noti_update = noti_error(getFullName() + " node require manual execution.",, self);
		
		onValueUpdate(index);
	}
	
	static onValueUpdate = function(index = 0) {}
	static onValueFromUpdate = function(index) {}
	
	static triggerRender = function() {
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render, "Trigger render for " + name + " (" + display_name + ")");
		
		setRenderStatus(false);
		UPDATE |= RENDER_TYPE.partial;
		
		var nodes = getNextNodesRaw();
		for(var i = 0; i < array_length(nodes); i++)
			nodes[i].triggerRender();
		LOG_BLOCK_END();
	}

	static isRenderable = function(log = false) { //Check if every input is ready (updated)
		if(!active)	return false;
		if(!renderActive) return false;
		
		if(group && struct_has(group, "iterationStatus") && group.iterationStatus() == ITERATION_STATUS.complete) return false;
		
		for(var j = 0; j < ds_list_size(inputs); j++) {
			var _in = inputs[| j];
			if( _in.type == VALUE_TYPE.node) continue;
			
			var val_from = _in.value_from;
			if( val_from == noone)			continue;
			if(!val_from.node.active)		continue;
			if(!val_from.node.renderActive) continue;
			if(!val_from.node.rendered && !val_from.node.update_on_frame) {
				//LOG_LINE_IF(global.FLAG.render && name == "Tunnel Out", "Non renderable because: " + string(val_from.node.name));
				return false;
			}
		}
		
		return true;
	}
	
	static getNextNodesRaw = function() { return getNextNodes(); }
	
	static getNextNodes = function() {
		var nodes = [];
		
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render, "Call get next node from: " + name);
		LOG_BLOCK_START();
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var _ot = outputs[| i];
			
			for(var j = 0; j < ds_list_size(_ot.value_to); j++) {
				var _to = _ot.value_to[| j];
				if(!_to.node.active || _to.value_from == noone) continue; 
				
				LOG_IF(global.FLAG.render, "Check render " + _to.node.name + " from " + _to.value_from.node.name);
				if(_to.value_from.node != self) continue;
				
				LOG_IF(global.FLAG.render, "Check complete, push " + _to.node.name + " to stack.");
				array_push(nodes, _to.node);
			}
		}	
		
		LOG_BLOCK_END();
		LOG_BLOCK_END();
		return nodes;
	}
	
	static onInspect = function() {}
	
	static setRenderStatus = function(result) {
		LOG_LINE_IF(global.FLAG.render, "Set render status for " + name + " : " + string(result));
		
		rendered = result;
	}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		return point_in_rectangle(_mx, _my, xx, yy, xx + w * _s, yy + h * _s);
	}
	
	static preDraw = function(_x, _y, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		var jun;
		
		var inspCount = hasInspector1Update() + hasInspector2Update();
		var ind = 1;
		if(hasInspector1Update()) {
			inspectInput1.x = xx + w * _s * ind / (inspCount + 1);
			inspectInput1.y = yy;
			ind++;
		}
		
		if(hasInspector2Update()) {
			inspectInput2.x = xx + w * _s * ind / (inspCount + 1);
			inspectInput2.y = yy;
			ind++;
		}
		
		var inamo = input_display_list == -1? ds_list_size(inputs) : array_length(input_display_list);
		var _in = yy + ui(32) * _s;
		
		for(var i = 0; i < inamo; i++) {
			var idx = getInputJunctionIndex(i);
			if(idx == noone) continue;
			
			jun = ds_list_get(inputs, idx, noone);
			if(jun == noone || is_undefined(jun)) continue;
			jun.x = xx;
			jun.y = _in;
			_in += 24 * _s * jun.isVisible();
		}
		
		var outamo = output_display_list == -1? ds_list_size(outputs) : array_length(output_display_list);
		
		 xx = xx + w * _s;
		_in = yy + ui(32) * _s;
		for(var i = 0; i < outamo; i++) {
			var idx = getOutputJunctionIndex(i);
			jun = outputs[| idx];
			
			jun.x = xx;
			jun.y = _in;
			_in += 24 * _s * jun.isVisible();
		}
	}
	
	static drawNodeBase = function(xx, yy, _s) {
		if(!active) return;
		var aa = 0.25 + 0.5 * renderActive;
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w * _s, h * _s, color, aa);
	}
	
	static drawGetBbox = function(xx, yy, _s) {
		var x0 = xx + draw_padding * _s;
		var x1 = xx + (w - draw_padding) * _s;
		var y0 = yy + 20 * draw_name + draw_padding * _s;
		var y1 = yy + (h - draw_padding) * _s;
		
		return new node_bbox(x0, y0, x1, y1);
	}
	
	static drawNodeName = function(xx, yy, _s) {
		if(!active) return;
		
		draw_name = false;
		var _name = display_name == ""? name : display_name;
		if(_name == "") return;
		if(_s < 0.75) return;
		draw_name = true;
		
		var aa = 0.25 + 0.5 * renderActive;
		draw_sprite_stretched_ext(THEME.node_bg_name, 0, xx, yy, w * _s, ui(20), color, aa);
		
		var cc = COLORS._main_text;
		if(PREF_MAP[? "node_show_render_status"] && !rendered)
			cc = isRenderable()? COLORS._main_value_positive : COLORS._main_value_negative;
		
		draw_set_text(f_p1, fa_left, fa_center, cc);
		
		if(hasInspector1Update()) icon = THEME.refresh_s;
		var ts = clamp(power(_s, 0.5), 0.5, 1);
		
		var aa = 0.5 + 0.5 * renderActive;
		draw_set_alpha(aa);
		
		if(icon && _s > 0.75) {
			draw_sprite_ui_uniform(icon, 0, xx + ui(12), yy + ui(10),,, aa);	
			draw_text_cut(xx + ui(24), yy + ui(10), _name, w * _s - ui(24), ts);
		} else
			draw_text_cut(xx + ui(8), yy + ui(10), _name, w * _s - ui(8), ts);
			
		draw_set_alpha(1);
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) {
		if(!active) return;
		var hover = noone;
		var amo = input_display_list == -1? ds_list_size(inputs) : array_length(input_display_list);
		var jun;
		
		for(var i = 0; i < amo; i++) {
			var ind = getInputJunctionIndex(i);
			if(ind == noone) continue;
			jun = ds_list_get(inputs, ind, noone);
			if(jun == noone || is_undefined(jun)) continue;
			
			if(jun.drawJunction(_s, _mx, _my))
				hover = jun;
		}
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			jun = outputs[| i];
			
			if(jun.drawJunction(_s, _mx, _my))
				hover = jun;
		}
		
		if(hasInspector1Update() && inspectInput1.drawJunction(_s, _mx, _my))
			hover = inspectInput1;
			
		if(hasInspector2Update() && inspectInput2.drawJunction(_s, _mx, _my))
			hover = inspectInput2;
		
		return hover;
	}
	
	static drawJunctionNames = function(_x, _y, _mx, _my, _s) {
		if(!active) return;
		var amo = input_display_list == -1? ds_list_size(inputs) : array_length(input_display_list);
		var jun;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		show_input_name  = PANEL_GRAPH.pHOVER && point_in_rectangle(_mx, _my, xx - 8 * _s, yy + 20 * _s, xx + 8 * _s, yy + h * _s);
		show_output_name = PANEL_GRAPH.pHOVER && point_in_rectangle(_mx, _my, xx + (w - 8) * _s, yy + 20 * _s, xx + (w + 8) * _s, yy + h * _s);
		
		if(show_input_name) {
			for(var i = 0; i < amo; i++) {
				var ind = getInputJunctionIndex(i);
				if(ind == noone) continue;
				if(!inputs[| ind]) continue;
				
				inputs[| ind].drawNameBG(_s);
			}
			
			for(var i = 0; i < amo; i++) {
				var ind = getInputJunctionIndex(i);
				if(ind == noone) continue;
				if(!inputs[| ind]) continue;
				
				inputs[| ind].drawName(_s, _mx, _my);
			}
		}
		
		if(show_output_name) {
			for(var i = 0; i < ds_list_size(outputs); i++)
				outputs[| i].drawNameBG(_s);
			
			for(var i = 0; i < ds_list_size(outputs); i++)
				outputs[| i].drawName(_s, _mx, _my);
		}
		
		if(hasInspector1Update() && PANEL_GRAPH.pHOVER && point_in_circle(_mx, _my, inspectInput1.x, inspectInput1.y, 10)) {
			inspectInput1.drawNameBG(_s);
			inspectInput1.drawName(_s, _mx, _my);
		}
		
		if(hasInspector2Update() && PANEL_GRAPH.pHOVER && point_in_circle(_mx, _my, inspectInput2.x, inspectInput2.y, 10)) {
			inspectInput2.drawNameBG(_s);
			inspectInput2.drawName(_s, _mx, _my);
		}
	}
	
	static drawConnections = function(_x, _y, _s, mx, my, _active, aa = 1) { 
		if(!active) return;
		
		var hovering = noone;
		var drawLineIndex = 1;
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var jun       = outputs[| i];
			var connected = false;
			
			for( var j = 0; j < ds_list_size(jun.value_to); j++ ) {
				if(jun.value_to[| j].value_from == jun) 
					connected = true;
			}
			
			if(connected) {
				jun.drawLineIndex = drawLineIndex;
				drawLineIndex += 0.5;
			}
		}
		
		var st = 0;
		if(hasInspector1Update())  st = -1;
		if(hasInspector2Update()) st = -2;
		
		var drawLineIndex = 1;
		for(var i = st; i < ds_list_size(inputs); i++) {
			var jun;
			if(i == -1)			jun = inspectInput1;
			else if(i == -2)	jun = inspectInput2;
			else				jun = inputs[| i];
			
			var jx  = jun.x;
			var jy  = jun.y;	
			
			if(jun.value_from == noone) continue;
			if(!jun.value_from.node.active) continue;
			if(!jun.isVisible()) continue;
			jun.drawLineIndex = drawLineIndex;
			
			var frx = jun.value_from.x;
			var fry = jun.value_from.y;
					
			var c0  = value_color(jun.value_from.type);
			var c1  = value_color(jun.type);
			
			var shx = jun.draw_line_shift_x * _s;
			var shy = jun.draw_line_shift_y * _s;
			
			var cx  = round((frx + jx) / 2 + shx);
			var cy  = round((fry + jy) / 2 + shy);
			
			var hover = false;
			var th = max(1, PREF_MAP[? "connection_line_width"] * _s);
			jun.draw_line_shift_hover = false;
			
			var drawCorner = jun.type == VALUE_TYPE.action || jun.value_from.type == VALUE_TYPE.action;
			
			if(PANEL_GRAPH.pHOVER)
			switch(PREF_MAP[? "curve_connection_line"]) {
				case 0 : 
					hover = distance_to_line(mx, my, jx, jy, frx, fry) < max(th * 2, 6);
					break;
				case 1 : 
					if(drawCorner) 
						hover = distance_to_curve_corner(mx, my, jx, jy, frx, fry, _s) < max(th * 2, 6);
					else 
						hover = distance_to_curve(mx, my, jx, jy, frx, fry, cx, cy, _s) < max(th * 2, 6);
						
					if(PANEL_GRAPH._junction_hovering == noone)
						jun.draw_line_shift_hover = hover;
					break;
				case 2 : 
					if(drawCorner) 
						hover = distance_to_elbow_corner(mx, my, frx, fry, jx, jy) < max(th * 2, 6);
					else
						hover = distance_to_elbow(mx, my, frx, fry, jx, jy, cx, cy, _s, jun.value_from.drawLineIndex, jun.drawLineIndex) < max(th * 2, 6);
					
					if(PANEL_GRAPH._junction_hovering == noone)
						jun.draw_line_shift_hover = hover;
					break;
				case 3 :
					if(drawCorner) 
						hover  = distance_to_elbow_diag_corner(mx, my, frx, fry, jx, jy) < max(th * 2, 6);
					else
						hover  = distance_to_elbow_diag(mx, my, frx, fry, jx, jy, cx, cy, _s, jun.value_from.drawLineIndex, jun.drawLineIndex) < max(th * 2, 6);
					
					if(PANEL_GRAPH._junction_hovering == noone)
						jun.draw_line_shift_hover = hover;
					break;
			}
			
			if(_active && hover)
				hovering = jun;
			
			var thicken = false;
			thicken |= PANEL_GRAPH.nodes_junction_d == jun;
			thicken |= _active && PANEL_GRAPH.junction_hovering == jun && PANEL_GRAPH._junction_hovering == noone;
			thicken |= instance_exists(o_dialog_add_node) && o_dialog_add_node.junction_hovering == jun;
			
			if(PREF_MAP[? "connection_line_transition"]) {
				jun.draw_line_thick.set(thicken? 2 : 1);
				th *= jun.draw_line_thick.get();
			} else 
				th *= thicken? 2 : 1;
			
			var corner = PREF_MAP[? "connection_line_corner"] * _s;
			var ty = LINE_STYLE.solid;
			if(jun.type == VALUE_TYPE.node)
				ty = LINE_STYLE.dashed;
			
			var ss  = _s * aa;
			jx  *= aa;
			jy  *= aa;
			frx *= aa;
			fry *= aa;
			th  *= aa;
			cx  *= aa;
			cy  *= aa;
			corner *= aa;
			th = max(1, th);
			
			switch(PREF_MAP[? "curve_connection_line"]) {
				case 0 : 
					if(ty == LINE_STYLE.solid)
						draw_line_width_color(jx, jy, frx, fry, th, c1, c0);
					else 
						draw_line_dashed_color(jx, jy, frx, fry, th, c1, c0, 12 * ss);
					break;
				case 1 : 
					if(drawCorner) 
						draw_line_curve_corner(jx, jy, frx, fry, ss, th, c0, c1); 
					else 
						draw_line_curve_color(jx, jy, frx, fry, cx, cy, ss, th, c0, c1, ty); 
					break;
				case 2 : 
					if(drawCorner) 
						draw_line_elbow_corner(frx, fry, jx, jy, ss, th, c0, c1, corner, jun.value_from.drawLineIndex, jun.drawLineIndex, ty); 
					else 
						draw_line_elbow_color(frx, fry, jx, jy, cx, cy, ss, th, c0, c1, corner, jun.value_from.drawLineIndex, jun.drawLineIndex, ty); 
					break;
				case 3 : 
					if(drawCorner) 
						draw_line_elbow_diag_corner(frx, fry, jx, jy, ss, th, c0, c1, corner, jun.value_from.drawLineIndex, jun.drawLineIndex, ty); 
					else 
						draw_line_elbow_diag_color(frx, fry, jx, jy, cx, cy, ss, th, c0, c1, corner, jun.value_from.drawLineIndex, jun.drawLineIndex, ty); 
					break;
			}
			
			drawLineIndex += 0.5;
		}
		
		return hovering;
	}
	
	static drawPreview = function(xx, yy, _s) {
		if(!active) return;
		
		var _node = outputs[| preview_channel];
		if(_node.type != VALUE_TYPE.surface) return;
		
		var surf = _node.getValue();
		preview_amount = 0;
		if(is_array(surf)) {
			if(array_length(surf) == 0) return;
			preview_amount = array_length(surf);
			
			if(preview_speed != 0) {
				preview_index += preview_speed;
				if(preview_index <= 0)
					preview_index = array_length(surf) - 1;
			}
			
			if(floor(preview_index) > array_length(surf) - 1) preview_index = 0;
			surf = surf[preview_index];
		}
		
		preview_surface = is_surface(surf)? surf : noone;
		if(preview_surface == noone) return;
		
		var pw = surface_get_width(preview_surface);
		var ph = surface_get_height(preview_surface);
		var ps = min((w * _s - 8) / pw, (h * _s - 8) / ph);
		var px = xx + w * _s / 2 - pw * ps / 2;
		var py = yy + h * _s / 2 - ph * ps / 2;
		var aa = 0.5 + 0.5 * renderActive;
		
		if(preview_trans == 1) {
			draw_surface_ext_safe(preview_surface, px, py, ps, ps, 0, c_white, aa);
			return;
		}
		
		if(preview_trans < 1 && is_surface(preview_surface_prev)) {
			preview_trans = lerp_float(preview_trans, 1, 8);
			var _pw = surface_get_width(preview_surface_prev);
			var _ph = surface_get_height(preview_surface_prev);
			var _ps = min((w * _s - 8) / _pw, (h * _s - 8) / _ph);
			var _px = xx + w * _s / 2 - _pw * _ps / 2;
			var _py = yy + h * _s / 2 - _ph * _ps / 2;
			
			draw_surface_ext_safe(preview_surface_prev, _px, _py, _ps, _ps, 0, c_white, aa);
			
			shader_set(sh_trans_node_prev_drop);
			shader_set_f("dimension", _pw, _ph);
			shader_set_f("position", (preview_drop_x - px) / (_pw * _ps), (preview_drop_y - py) / (_ph * _ps));
			shader_set_f("prog", preview_trans);
			draw_surface_ext_safe(preview_surface, px, py, ps, ps, 0, c_white, aa);
			shader_reset();
		} else if(is_surface(preview_surface_prev))
			surface_free(preview_surface_prev);
	}
	
	static previewDropAnimation = function() {
		preview_surface_prev = surface_clone(preview_surface);
		preview_trans  = 0;
		preview_drop_x = preview_mx;
		preview_drop_y = preview_my;
	}
	
	static getNodeDimension = function(showFormat = true) {
		if(!is_surface(preview_surface)) {	
			if(ds_list_size(outputs))
				return "[" + array_shape(outputs[| 0].getValue()) + "]";
			return "";
		}
		
		var pw = surface_get_width(preview_surface);
		var ph = surface_get_height(preview_surface);
		var format = surface_get_format(preview_surface);
		
		var txt = "[" + string(pw) + " x " + string(ph) + " ";
		if(preview_amount) txt = string(preview_amount) + " x " + txt;
		
		switch(format) {
			case surface_rgba4unorm	 : txt += showFormat? "4RGBA"	: "4R";  break;
			case surface_rgba8unorm	 : txt += showFormat? "8RGBA"	: "8R";  break;
			case surface_rgba16float : txt += showFormat? "16RGBA"	: "16R"; break;
			case surface_rgba32float : txt += showFormat? "32RGBA"	: "32R"; break;
			case surface_r8unorm	 : txt += showFormat? "8BW"		: "8B";  break;
			case surface_r16float	 : txt += showFormat? "16BW"	: "16B"; break;
			case surface_r32float	 : txt += showFormat? "32BW"	: "32B"; break;
		}
		
		txt += "]";
		
		return txt;
	}
	
	static drawDimension = function(xx, yy, _s) {
		if(!active) return;
		if(_s * w < 64) return;
		
		draw_set_text(_s >= 1? f_p1 : f_p2, fa_center, fa_top, COLORS.panel_graph_node_dimension);
		var tx = xx + w * _s / 2;
		var ty = yy + (h + 4) * _s;
		
		if(PANEL_GRAPH.show_dimension) {
			var txt = string(getNodeDimension(_s > 0.65));
			draw_text(round(tx), round(ty), txt);
			ty += string_height(txt) - 4 * _s;
		}
		
		if(PANEL_GRAPH.show_compute) {
			var rt, unit;
			if(render_time < 1000) {
				rt = round(render_time / 10) * 10;
				unit = "us";
				draw_set_color(COLORS.speed[2]);
			} else if(render_time < 1000000) {
				rt = string_format(render_time / 1000, -1, 2);
				unit = "ms";
				draw_set_color(COLORS.speed[1]);
			} else {
				rt = string_format(render_time / 1000000, -1, 2);
				unit = "s";
				draw_set_color(COLORS.speed[0]);
			}
			draw_text(round(tx), round(ty), string(rt) + " " + unit);
		}
	}
	
	static drawNode = function(_x, _y, _mx, _my, _s) {
		if(!active) return;
		//if(group != PANEL_GRAPH.getCurrentContext()) return;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		preview_mx = _mx;
		preview_my = _my;
		
		if(value_validation[VALIDATION.error] || error_noti_update != noone)
			draw_sprite_stretched_ext(THEME.node_glow, 0, xx - 9, yy - 9, w * _s + 18, h * _s + 18, COLORS._main_value_negative, 1);
		
		drawNodeBase(xx, yy, _s);
		if(previewable && ds_list_size(outputs) > 0) {
			if(preview_channel >= ds_list_size(outputs))
				preview_channel = 0;
			drawPreview(xx, yy, _s);
		} 
		drawDimension(xx, yy, _s);
		
		onDrawNode(xx, yy, _mx, _my, _s, PANEL_GRAPH.node_hovering == self, PANEL_GRAPH.node_focus == self);
		drawNodeName(xx, yy, _s);
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_sel_spr, 0, xx, yy, round(w * _s), round(h * _s), active_draw_index > 1? COLORS.node_border_file_drop : COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		
		if(draw_droppable)
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, xx, yy, w * _s, h * _s, COLORS._main_value_positive, 1);
		draw_droppable = false;
		
		return drawJunctions(xx, yy, _mx, _my, _s);
	}
	
	static onDrawNodeBehind = function(_x, _y, _mx, _my, _s) {}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover = false, _focus = false) {}
	
	badgePreview = 0;
	badgeInspect = 0;
	static drawBadge = function(_x, _y, _s) {
		if(!active) return;
		var xx = x * _s + _x + w * _s;
		var yy = y * _s + _y;
		
		badgePreview = lerp_float(badgePreview, !!previewing, 2);
		badgeInspect = lerp_float(badgeInspect,   inspecting, 2);
		
		if(badgePreview > 0) {
			draw_sprite_ext(THEME.node_state, 0, xx, yy, badgePreview, badgePreview, 0, c_white, 1);
			xx -= 28 * badgePreview;
		}
		
		if(badgeInspect > 0) {
			draw_sprite_ext(THEME.node_state, 1, xx, yy, badgeInspect, badgeInspect, 0, c_white, 1);
			xx -= 28 * badgeInspect;
		}
		
		inspecting = false;
		previewing = 0;
	}
	
	active_draw_index = -1;
	static drawActive = function(_x, _y, _s, ind = 0) {
		active_draw_index = ind;
	}
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static drawAnimationTimeline = function(_w, _h, _s) {}
	
	static getPreviewValue = function() {
		if(preview_channel > ds_list_size(outputs)) return noone;
		return outputs[| preview_channel];
	}
	
	static enable = function() { active = true; }
	static disable = function() { active = false; }
			
	static destroy = function(_merge = false) {
		if(!active) return;
		disable();
		
		if(PANEL_GRAPH.node_hover         == self) PANEL_GRAPH.node_hover        = noone;
		if(PANEL_GRAPH.node_focus         == self) PANEL_GRAPH.node_focus        = noone;
		if(PANEL_PREVIEW.preview_node[0]  == self) PANEL_PREVIEW.preview_node[0] = noone;
		if(PANEL_PREVIEW.preview_node[1]  == self) PANEL_PREVIEW.preview_node[1] = noone;
		if(PANEL_INSPECTOR.inspecting     == self) PANEL_INSPECTOR.inspecting    = noone;
		PANEL_ANIMATION.updatePropertyList();
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var jun = outputs[| i];
			
			for(var j = 0; j < ds_list_size(jun.value_to); j++) {
				var _vt = jun.value_to[| j];
				if(_vt.value_from == noone) break;
				if(_vt.value_from.node != self) break;
				
				_vt.removeFrom(false);
				
				if(!_merge) continue;
				
				for( var k = 0; k < ds_list_size(inputs); k++ ) {
					if(inputs[| k].value_from == noone) continue;
					if(_vt.setFrom(inputs[| k].value_from)) break;
				}
			}
			
			ds_list_clear(jun.value_to);
		}
		
		for( var i = 0; i < ds_list_size(inputs); i++ )
			inputs[| i].destroy();
		
		for( var i = 0; i < ds_list_size(outputs); i++ )
			outputs[| i].destroy();
		
		onDestroy();
	}
	
	static restore = function() { 
		if(active) return;
		enable();
		ds_list_add(group == noone? NODES : group.getNodeList(), self);
	}
	
	static onValidate = function() {
		value_validation[VALIDATION.pass]	 = 0;
		value_validation[VALIDATION.warning] = 0;
		value_validation[VALIDATION.error]   = 0;
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			var jun = inputs[| i];
			if(jun.value_validation)
				value_validation[jun.value_validation]++;
		}
	}
	
	static onDestroy = function() {}
	
	static clearInputCache = function() {
		for( var i = 0; i < ds_list_size(inputs); i++ )
			inputs[| i].cache_value[0] = false;
	}
	
	static cacheArrayCheck = function() {
		if(array_length(cached_output) != ANIMATOR.frames_total)
			array_resize(cached_output, ANIMATOR.frames_total);
		if(array_length(cache_result) != ANIMATOR.frames_total)
			array_resize(cache_result, ANIMATOR.frames_total);
	}
	
	static cacheCurrentFrame = function(_frame) {
		cacheArrayCheck();
		if(ANIMATOR.current_frame < 0) return;
		if(ANIMATOR.current_frame >= array_length(cached_output)) return;
		
		surface_array_free(cached_output[ANIMATOR.current_frame]);
		cached_output[ANIMATOR.current_frame] = surface_array_clone(_frame);
		
		array_safe_set(cache_result, ANIMATOR.current_frame, true);
		
		return cached_output[ANIMATOR.current_frame];
	}
	
	static cacheExist = function(frame = ANIMATOR.current_frame) {
		if(frame < 0) return false;
		
		if(frame >= array_length(cached_output)) return false;
		if(frame >= array_length(cache_result)) return false;
		if(!array_safe_get(cache_result, frame, false)) return false;
		
		var s = array_safe_get(cached_output, frame);
		return is_array(s) || surface_exists(s);
	}
	
	static getCacheFrame = function(frame = ANIMATOR.current_frame) {
		if(frame < 0) return false;
		
		if(!cacheExist(frame)) return noone;
		var surf = array_safe_get(cached_output, frame);
		return surf;
	}
	
	static recoverCache = function(frame = ANIMATOR.current_frame) {
		if(!cacheExist(frame)) return false;
		
		var _s = cached_output[ANIMATOR.current_frame];
		outputs[| 0].setValue(_s);
			
		return true;
	}
	static clearCache = function() { 
		if(!use_cache) return;
		if(!renderActive) return;
		
		if(array_length(cached_output) != ANIMATOR.frames_total)
			array_resize(cached_output, ANIMATOR.frames_total);
		for(var i = 0; i < array_length(cached_output); i++) {
			var _s = cached_output[i];
			if(is_surface(_s))
				surface_free(_s);
			cached_output[i] = 0;
			cache_result[i] = false;
		}
	}
	static clearCacheForward = function() {
		if(!renderActive) return;
		
		clearCache();
		for( var i = 0; i < ds_list_size(outputs); i++ )
		for( var j = 0; j < ds_list_size(outputs[| i].value_to); j++ )
			outputs[| i].value_to[| j].node.clearCacheForward();
	}
	
	static checkConnectGroup = function(_type = "group") {
		var _y = y;
		var nodes = [];
				
		for(var i = 0; i < ds_list_size(inputs); i++) {
			var _in = inputs[| i];
			if(_in.value_from == noone) continue;
			if(_in.value_from.node.group == group) continue;
			var input_node = noone;
			
			switch(_type) {
				case "group" :		input_node = new Node_Group_Input(x - w - 64, _y, group);	break;	
				case "loop" :		input_node = new Node_Iterator_Input(x - w - 64, _y, group); break;	
				case "feedback" :	input_node = new Node_Feedback_Input(x - w - 64, _y, group); break;	
			}
				
			if(input_node == noone) continue;
			
			array_push(nodes, input_node);
			input_node.inputs[| 2].setValue(_in.type);
			input_node.inParent.setFrom(_in.value_from);
			input_node.onValueUpdate(0);
			_in.setFrom(input_node.outputs[| 0]);
			
			_y += 64;
		}
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var _ou = outputs[| i];
			for(var j = 0; j < ds_list_size(_ou.value_to); j++) {
				var _to = _ou.value_to[| j];
				if(_to.value_from != _ou) continue;
				if(!_to.node.active) continue;
				if(_to.node.group == group) continue;
				var output_node = noone;
				
				switch(_type) {
					case "group" :		output_node = new Node_Group_Output(x + w + 64, y, group);		break;
					case "loop" :		output_node = new Node_Iterator_Output(x + w + 64, y, group);	break;	
					case "feedback" :	output_node = new Node_Feedback_Output(x + w + 64, y, group);	break;	
				}
					
				if(output_node == noone) continue;
				
				array_push(nodes, output_node);
				_to.setFrom(output_node.outParent);
				output_node.inputs[| 0].setFrom(_ou);
			}
		}
		
		return nodes;
	}
	
	static isNotUsingTool = function() {
		return PANEL_PREVIEW.tool_current == noone;
	}
	
	static isUsingTool = function(index, subtool = noone) {
		if(tools == -1) 
			return false;
		if(PANEL_PREVIEW.tool_current != tools[index])
			return false;
		if(subtool == noone)
			return true;
		return tools[index].selecting == subtool;
	}
	
	static clone = function(target = PANEL_GRAPH.getCurrentContext()) {
		CLONING = true;
		var _type = instanceof(self);
		var _node = nodeBuild(_type, x, y, target);
		CLONING = false;
		
		LOADING_VERSION = SAVEFILE_VERSION;
		
		if(!_node) return;
		
		CLONING = true;
		var _nid = _node.node_id;
		_node.deserialize(serialize());
		_node.postDeserialize();
		_node.applyDeserialize();
		_node.node_id = _nid;
		
		NODE_MAP[? node_id] = self;
		NODE_MAP[? _nid] = _node;
		PANEL_ANIMATION.updatePropertyList();
		CLONING = false;
		
		onClone(_node, target);
		
		return _node;
	}
	
	static onClone = function(_NewNode, target = PANEL_GRAPH.getCurrentContext()) {}
	
	draw_droppable = false;
	static droppable = function(dragObj) {
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(dragObj.type == inputs[| i].drop_key)
				return true;
		}
		return false;
	}
	
	static onDrop = function(dragObj) {
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(dragObj.type == inputs[| i].drop_key) {
				inputs[| i].setValue(dragObj.data);
				previewDropAnimation();
				return;
			}
		}
	}
	
	static serialize = function(scale = false, preset = false) {
		var _map = ds_map_create();
		//print(" > Serializing: " + name);
		
		if(!preset) {
			_map[? "id"]	 = node_id;
			_map[? "render"] = renderActive;
			_map[? "name"]	 = display_name;
			_map[? "iname"]	 = internalName;
			_map[? "x"]		 = x;
			_map[? "y"]		 = y;
			_map[? "type"]   = instanceof(self);
			_map[? "group"]  = group == noone? group : group.node_id;
			_map[? "preview"] = previewable;
		}
		
		ds_map_add_map(_map, "attri", attributeSerialize());
		
		var _inputs = ds_list_create();
		for(var i = 0; i < ds_list_size(inputs); i++)
			ds_list_add_map(_inputs, inputs[| i].serialize(scale, preset));
		ds_map_add_list(_map, "inputs", _inputs);
		
		var _outputs = ds_list_create();
		for(var i = 0; i < ds_list_size(outputs); i++)
			ds_list_add_map(_outputs, outputs[| i].serialize(scale, preset));
		ds_map_add_list(_map, "outputs", _outputs);
		
		var _trigger = ds_list_create();
		ds_list_add_map(_trigger, inspectInput1.serialize(scale, preset));
		ds_list_add_map(_trigger, inspectInput2.serialize(scale, preset));
		ds_map_add_list(_map, "inspectInputs", _trigger);
		
		doSerialize(_map);
		processSerialize(_map);
		return _map;
	}
	
	static attributeSerialize = function() {
		var att = ds_map_create();
		ds_map_override(att, attributes);
		return att;
	}
	static doSerialize = function(_map) {}
	static processSerialize = function(_map) {}
	
	load_scale = false;
	load_map = -1;
	static deserialize = function(_map, scale = false, preset = false) {
		load_map = _map;
		load_scale = scale;
		
		if(!preset) {
			if(APPENDING)
				APPEND_MAP[? load_map[? "id"]] = node_id;
			else
				node_id = ds_map_try_get(load_map, "id");
		
			NODE_MAP[? node_id] = self;
			
			if(ds_map_exists(load_map, "name"))
				setDisplayName(ds_map_try_get(load_map, "name", ""));
			
			internalName = ds_map_try_get(load_map, "iname", internalName);
			_group = ds_map_try_get(load_map, "group", noone);
			if(_group == -1) _group = noone;
			
			x = ds_map_try_get(load_map, "x");
			y = ds_map_try_get(load_map, "y");
			renderActive = ds_map_try_get(load_map, "render", true);
			previewable  = ds_map_try_get(load_map, "preview", previewable);
		}
		
		if(ds_map_exists(load_map, "attri"))
			attributeDeserialize(load_map[? "attri"]);
		
		doDeserialize();
		processDeserialize();
		
		if(preset) {
			postDeserialize();
			applyDeserialize();
			
			triggerRender();
		}
	}
	
	static doDeserialize = function() {}
	
	static attributeDeserialize = function(attr) {
		ds_map_override(attributes, attr);
	}
	
	static postDeserialize = function() {}
	static processDeserialize = function() {}
		
	static applyDeserialize = function(preset = false) {
		var _inputs = load_map[? "inputs"];
		var amo = min(ds_list_size(inputs), ds_list_size(_inputs));
		
		for(var i = 0; i < amo; i++) {
			if(inputs[| i] == noone) continue;
			inputs[| i].applyDeserialize(_inputs[| i], load_scale, preset);
		}
		
		if(ds_map_exists(load_map, "outputs")) {
			var _outputs = load_map[? "outputs"];
			for(var i = 0; i < ds_list_size(outputs); i++) {
				if(outputs[| i] == noone) continue;
				outputs[| i].applyDeserialize(_outputs[| i], load_scale, preset);
			}
		}
		
		if(ds_map_exists(load_map, "inspectInputs")) {
			var insInp = load_map[? "inspectInputs"];
			inspectInput1.applyDeserialize(insInp[| 0], load_scale, preset);
			inspectInput2.applyDeserialize(insInp[| 1], load_scale, preset);
		}
		
		doApplyDeserialize();
	}
	
	static doApplyDeserialize = function() {}
	
	static loadGroup = function(context = PANEL_GRAPH.getCurrentContext()) {
		if(_group == noone) {
			var c = context;
			if(c != noone) c.add(self);
		} else {
			if(APPENDING) _group = GetAppendID(_group);
			
			if(ds_map_exists(NODE_MAP, _group)) {
				NODE_MAP[? _group].add(self);
			} else {
				var txt = "Group load failed. Can't find node ID " + string(_group);
				log_warning("LOAD", txt);
			}
		}
	}
	
	static connect = function(log = false) {
		var connected = true;
		for(var i = 0; i < ds_list_size(inputs); i++)
			connected &= inputs[| i].connect(log);
		
		if(ds_map_exists(load_map, "inspectInputs")) {
			inspectInput1.connect(log);
			inspectInput2.connect(log);
		}
		
		if(!connected) ds_queue_enqueue(CONNECTION_CONFLICT, self);
		
		return connected;
	}
	
	static preConnect = function() {}
	static postConnect = function() {}
	
	static resetAnimation = function() {}
	
	static cleanUp = function() {
		for( var i = 0; i < ds_list_size(inputs); i++ )
			inputs[| i].cleanUp();
		for( var i = 0; i < ds_list_size(outputs); i++ )
			outputs[| i].cleanUp();
		
		ds_list_destroy(inputs);
		ds_list_destroy(outputs);
		
		ds_map_destroy(inputMap);
		ds_map_destroy(outputMap);
		
		ds_map_destroy(attributes);
		
		for( var i = 0; i < array_length(temp_surface); i++ )
			surface_free(temp_surface[i]);
		
		onCleanUp();
	}
	
	static onCleanUp = function() {}
	
	// helper function
	static attrDepth = function() {
		if(ds_map_exists(attributes, "color_depth")) {
			var form = attributes[? "color_depth"];
			if(inputs[| 0].type == VALUE_TYPE.surface) 
				form--;
			if(form >= 0)
				return array_safe_get(global.SURFACE_FORMAT, form, surface_rgba8unorm);
		}
		
		var _s = inputs[| 0].getValue();
		while(is_array(_s) && array_length(_s)) _s = _s[0];
		if(!is_surface(_s)) 
			return surface_rgba8unorm;
		return surface_get_format(_s);
	}
}