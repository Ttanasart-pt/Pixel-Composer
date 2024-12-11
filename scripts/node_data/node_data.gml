#region global
	global.loop_nodes = [ "Node_Iterate", "Node_Iterate_Each" ];
	
	#macro INAME internalName == ""? name : internalName
	#macro SHOW_PARAM (show_parameter && previewable)
	
	enum CACHE_USE {
		none,
		manual,
		auto
	}
	
	enum DYNA_INPUT_COND {
		connection = 1 << 0,
		zero       = 1 << 1,
	}
	
	enum NODE_3D {
		none,
		polygon,
		sdf,
	}
#endregion

function Node(_x, _y, _group = noone) : __Node_Base(_x, _y) constructor {
	
	#region ---- main & active ----
		project      = PROJECT;
		
		active       = true;
		renderActive = true;
		
		node_id              = UUID_generate();
		group                = _group;
		manual_deletable	 = true;
		manual_ungroupable	 = true;
		destroy_when_upgroup = false;
		
		if(NOT_LOAD) array_push(_group == noone? project.nodes : _group.getNodeList(), self);
		
		active_index = -1;
		active_range = [ 0, TOTAL_FRAMES - 1 ];
		
		array_push(PROJECT.allNodes, self);
		
		inline_context = noone;
		inline_parent_object  = "";
		
		search_match  = -9999;
		onDoubleClick = -1;
		is_controller = false;
	#endregion
	
	static resetInternalName = function() {
		var str = string_replace_all(name, " ", "_");
			str = string_replace_all(str,  "/", "");
			str = string_replace_all(str,  "-", "");
		
		ds_map_delete(PROJECT.nodeNameMap, internalName);
		internalName = str + string(irandom_range(10000, 99999)); 
		PROJECT.nodeNameMap[? internalName] = self;
	}
	
	if(!LOADING && !APPENDING) {
		recordAction(ACTION_TYPE.node_added, self);
		PROJECT.nodeMap[? node_id] = self;
		PROJECT.modified = true;
		
		run_in(1, function() /*=>*/ { 
			resetInternalName();
			if(renamed) return;
			
			display_name = __txt_node_name(instanceof(self), name);
			if(!LOCALE_DEF || TESTING) renamed = true;
		});
		
		RENDER_ALL_REORDER
	}
	
	#region ---- display ----
		color          = c_white;
		icon           = noone;
		icon_24        = noone;
		icon_blend     = c_white;
		bg_spr         = THEME.node_bg;
		bg_spr_add     = 0.1;
		bg_spr_add_clr = c_white;
	
		name             = "";
		display_name     = "";
		internalName     = "";
		onSetDisplayName = noone;
		renamed          = false;
		tooltip          = "";
		
		x = _x;
		y = _y;
		w = 128;
		h = 128;
		min_w   = w;
		con_h   = 128;
		h_param = h;
		name_height = ui(16);
		custom_grid = 0;
		
		preserve_height_for_preview = false;
		
		selectable   = true;
		clonable     = true;
		auto_height  = true;
		draw_padding = 4;
		draw_pad_w   = 0;
		draw_pad_h   = 0;
		
		display_parameter = new connectionParameter();
		
		draw_name = true;
		draggable = true;
		
		draw_boundary     = [ 0, 0, 0, 0 ];
		draw_graph_culled = false;
		
		badgePreview = 0;
		badgeInspect = 0;
		
		active_draw_index  = -1;
		active_draw_anchor = false;
		
		draw_droppable = false;
		
		junction_draw_pad_y = 32;
		junction_draw_hei_y = 24;
		
		branch_drawing = false;
	#endregion
	
	#region ---- junctions ----
		inputs           = [];
		outputs          = [];
		input_bypass     = [];
		inputMap         = {};
		outputMap        = {};
		input_value_map  = {};
		
		use_display_list		= true;
		input_display_list		= -1;
		output_display_list		= -1;
		inspector_display_list	= -1;
		is_dynamic_output		= false;
		
		inspectInput1           = nodeValue("Toggle execution", self, CONNECT_TYPE.input, VALUE_TYPE.action, false).setVisible(true, true);
		inspectInput1.index     = -1;
		
		inspectInput2           = nodeValue("Toggle execution", self, CONNECT_TYPE.input, VALUE_TYPE.action, false).setVisible(true, true);
		inspectInput2.index     = -1;
		
		updatedInTrigger        = nodeValue("Update",  self, CONNECT_TYPE.input,  VALUE_TYPE.trigger, false).setVisible(true, true);
		updatedInTrigger.index  = -1;
		updatedInTrigger.tags   = VALUE_TAG.updateInTrigger;
		
		updatedOutTrigger       = nodeValue_Output("Updated", self, VALUE_TYPE.trigger, false).setVisible(true, true);
		updatedOutTrigger.index = -1;
		updatedOutTrigger.tags  = VALUE_TAG.updateOutTrigger;
		
		insp1UpdateActive       = true;
		insp1UpdateTooltip      = __txtx("panel_inspector_execute", "Execute node");
		insp1UpdateIcon         = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
		
		insp2UpdateActive       = true;
		insp2UpdateTooltip      = __txtx("panel_inspector_execute", "Execute node");
		insp2UpdateIcon         = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
		
		is_dynamic_input  = false;
		auto_input		  = false;
		input_display_len = 0;
		input_fix_len	  = 0;
		data_length       = 1;
		inputs_data		  = [];
		input_hash		  = "";
		input_hash_raw	  = "";
		
		inputs_amount    = 0;
		in_cache_len     = 0;
		inputDisplayList = [];
		
		outputs_index  = [];
		out_cache_len  = 0;
		
		input_buttons       = [];
		input_button_length = 0;
		
		toRefreshNodeDisplay = false;
		
		run_in(1, function() {
			input_buttons   = [];
			
			for( var i = 0; i < array_length(inputs); i++ ) {
				var _in = inputs[i];
				if(!is_instanceof(_in, NodeValue)) continue;
				if(_in.type != VALUE_TYPE.trigger) continue;
				
				if(_in.runInUI) array_push(input_buttons, _in);
			}
			
			input_button_length = array_length(input_buttons);
		});
		
		junc_meta = [
			nodeValue_Output("Name",     self, VALUE_TYPE.text,  ""),
			nodeValue_Output("Position", self, VALUE_TYPE.float, [ 0, 0 ])
				.setDisplay(VALUE_DISPLAY.vector),
		];
		
		for( var i = 0, n = array_length(junc_meta); i < n; i++ ) {
			junc_meta[i].index = i;
			junc_meta[i].tags  = VALUE_TAG.matadata;
		}
	#endregion
	
	#region --- attributes ----
		attributes.node_param_width = PREFERENCES.node_param_width;
		attributes.node_width  = 0;
		attributes.node_height = 0;
		attributes.outp_meta   = false;
		
		attributes.annotation       = "";
		attributes.annotation_size  = .4;
		attributes.annotation_color = COLORS._main_text_sub;
		
		attributeEditors = [
			"Display",
			["Annotation",   function() /*=>*/ {return attributes.annotation},       new textArea(TEXTBOX_INPUT.text,  function(val) /*=>*/ { attributes.annotation = val; }) ],
			["Params Width", function() /*=>*/ {return attributes.node_param_width}, new textBox(TEXTBOX_INPUT.number, function(val) /*=>*/ { attributes.node_param_width = val; refreshNodeDisplay(); }) ],
			
			"Node",
			["Auto update",     function() /*=>*/ {return attributes.update_graph},		  new checkBox(function() /*=>*/ { attributes.update_graph        = !attributes.update_graph;           }) ],
			["Update trigger",  function() /*=>*/ {return attributes.show_update_trigger}, new checkBox(function() /*=>*/ { attributes.show_update_trigger = !attributes.show_update_trigger;    }) ],
			["Output metadata", function() /*=>*/ {return attributes.outp_meta},           new checkBox(function() /*=>*/ { attributes.outp_meta           = !attributes.outp_meta; setHeight(); }) ],
		];
	#endregion
	
	#region ---- preview ----
		show_parameter = PREFERENCES.node_param_show;
		
		show_input_name  = false;
		show_output_name = false;
	
		inspecting	     = false;
		previewing	     = 0;
		
		preview_surface	 = noone;
		preview_amount   = 0;
		previewable		 = true;
		preview_draw     = true;
		preview_speed	 = 0;
		preview_index	 = 0;
		preview_channel  = 0;
		preview_alpha	 = 1;
		
		preview_x  = 0;
		preview_y  = 0;
		preview_mx = 0;
		preview_my = 0;
		
		graph_preview_alpha	= 1;
		
		getPreviewingNode = function() /*=>*/ {return self};
		
		preview_value = 0;
		preview_array = "";
	#endregion
	
	#region ---- rendering ----
		rendered         = false;
		update_on_frame  = false;
		render_timer     = 0;
		render_time		 = 0;
		render_cached    = false;
		auto_render_time = true;
		updated			 = false;
		passiveDynamic   = false;
		topoSorted		 = false;
		temp_surface     = [];
		force_requeue    = false;
		
		is_simulation    = false;
		is_group_io      = false;
		in_VFX           = false;
		
		use_trigger      = false;
	#endregion
	
	#region ---- timeline ----
		timeline_item    = new timelineItemNode(self);
		anim_priority    = array_length(PROJECT.allNodes);
		is_anim_timeline = false;
	#endregion
	
	#region ---- notification ----
		value_validation = array_create(3);
		manual_updated   = false;
	#endregion
	
	#region ---- tools ----
		tools			= -1;
		rightTools		= -1;
		isTool			= false;
		tool_settings	= [];
		tool_attribute	= {};
	#endregion
	
	#region ---- 3d ----
		is_3D = NODE_3D.none;
	#endregion
	
	#region ---- cache ----
		use_cache		= CACHE_USE.none;
		cached_manual	= false;
		cached_output	= [];
		cache_result	= [];
		cache_group     = noone;
		
		clearCacheOnChange	= true;
	#endregion
	
	#region ---- log ----
		messages     = [];
		messages_bub = false;
		messages_dbg = [];
		
		static logNode = function(text, noti = 0) { 
			var _time = $"{string_lead_zero(current_hour, 2)}:{string_lead_zero(current_minute, 2)}.{string_lead_zero(current_second, 2)}";
			messages_bub = true;
			array_push(messages, [ _time, text ]); 
			
			switch(noti) {
				case 1 : noti_status(text,,  self); break;
				case 2 : noti_warning(text,, self); break;
			}
		}
		
		static logNodeDebug = function(text, level = 1) { 
			LOG_IF(global.FLAG.render >= level, text);
			if(PROFILER_STAT == 0) return;
			
			_report = {};
			_report.type  = "message";
			_report.node  = self;
			_report.text  = text;
			_report.level = level;
			array_push(PROFILER_DATA, _report); 
		}
	#endregion
	
	#region ---- serialization ----
		load_scale = false;
		load_map   = -1;
		load_group = noone;
	#endregion
	
	////- NAME
	
	static initTooltip = function() { 
		if(IS_CMD) return;
		
		var type_self = instanceof(self);
		if(!struct_has(global.NODE_GUIDE, type_self)) return;
		
		
		var _n = global.NODE_GUIDE[$ type_self];
		var _ins = _n.inputs;
		var _ots = _n.outputs;
		
		var amo = min(array_length(inputs), array_length(_ins));
		for( var i = 0; i < amo; i++ ) {
			inputs[i].name    = _ins[i].name;
			inputs[i].tooltip = _ins[i].tooltip;
		}
		
		var amo = min(array_length(outputs), array_length(_ots));
		for( var i = 0; i < amo; i++ ) {
			outputs[i].name    = _ots[i].name;
			outputs[i].tooltip = _ots[i].tooltip;
		}
	} run_in(1, function() /*=>*/ {return initTooltip});
	
	static setDisplayName = function(_name) {
		renamed = true;
		display_name = _name;
		internalName = string_replace_all(display_name, " ", "_");
		refreshNodeMap();
		
		if(onSetDisplayName != noone)
			onSetDisplayName();
		
		return self;
	}
	
	static getFullName    = function() { return renamed? $"[{name}] " + display_name : name; }
	static getDisplayName = function() { return renamed? display_name : name; }
	
	////- DYNAMIC IO
	
	dummy_input              = noone;
	auto_input               = false;
	dyna_input_check_shift   =  0;
	input_display_dynamic    = -1;
	dynamic_input_inspecting =  0;
	static createNewInput    = -1;
	
	static setDynamicInput = function(_data_length = 1, _auto_input = true, _dummy_type = VALUE_TYPE.any, _dynamic_input_cond = DYNA_INPUT_COND.connection) {
		is_dynamic_input	= true;						
		auto_input			= _auto_input;
		dummy_type	 		= _dummy_type;
		
		input_display_list_raw = array_clone(input_display_list, 1);
		input_display_len	= input_display_list == -1? 0 : array_length(input_display_list);
		input_fix_len		= array_length(inputs);
		data_length			= _data_length;
		
		dynamic_input_cond  = _dynamic_input_cond;
		
		if(auto_input) {
			dummy_input = nodeValue("Add value", self, CONNECT_TYPE.input, dummy_type, 0)
						.setDummy(function() /*=>*/ {return createNewInput()})
						.setVisible(false, true);
		}
		
		attributes.size = 0;
	}
	
	static refreshDynamicInput = function() {
		if(LOADING || APPENDING) return;
		
		var _in = [];
		
		for( var i = 0; i < input_fix_len; i++ )
			array_push(_in, inputs[i]);
		
		input_display_list = array_clone(input_display_list_raw, 1);
		var sep = false;
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _active = false;
			var _inp    = inputs[i + dyna_input_check_shift];
			
			if(dynamic_input_cond & DYNA_INPUT_COND.connection)
				_active |= _inp.hasJunctionFrom();
				
			if(dynamic_input_cond & DYNA_INPUT_COND.zero) {
				var _val = _inp.getValue();
				_active |= _val != 0 || _val != "";
			}
			
			if(_active) {
				if(sep && data_length > 1) array_push(input_display_list, new Inspector_Spacer(20, true));
				sep = true;
			
				for( var j = 0; j < data_length; j++ ) {
					var _ind = i + j;
					
					if(input_display_list != -1)
						array_push(input_display_list, array_length(_in));
					array_push(_in, inputs[_ind]);
				}
			} else {
				for( var j = 0; j < data_length; j++ )
					delete inputs[i + j];
			}
		}
		
		var _ina = array_length(_in);
		for( var i = 0; i < _ina; i++ )
			_in[i].index = i;
		
		if(dummy_input) dummy_input.index = _ina;
		
		inputs = _in;
		
		refreshNodeDisplay();
	}

	static refreshDynamicDisplay = function() {
		if(input_display_dynamic == -1) return;
		array_resize(input_display_list, array_length(input_display_list_raw));
		
		var _amo = getInputAmount();
		if(_amo == 0) {
			dynamic_input_inspecting = 0;
			return;
		}
		
		dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
		var _ind = input_fix_len + dynamic_input_inspecting * data_length;
		
		for( var i = 0, n = array_length(input_display_dynamic); i < n; i++ ) {
			var v = input_display_dynamic[i];
			if(is_real(v)) v += _ind;
			
			array_push(input_display_list, v);
		}
	}
	
	static getInputAmount = function() { return (array_length(inputs) - input_fix_len) / data_length; }
	
	function onInputResize() { refreshDynamicInput(); triggerRender(); }
	
	static getOutput = function(_y, junc = noone) {
		var _targ = noone;
		var _dy   = 9999;
		
		for( var i = 0; i < array_length(outputs); i++ ) {
			if(!outputs[i].isVisible()) continue;
			if(junc != noone && !junc.isConnectable(outputs[i], true)) continue;
			
			var _ddy = abs(outputs[i].y - _y);
			if(_ddy < _dy) {
				_targ = outputs[i];
				_dy   = _ddy;
			}
		}
		return _targ;
	}
	
	static getInput = function(_y = 0, junc = noone, shift = input_fix_len) {
		
		var _targ = noone;
		var _dy   = 9999;
		
		for( var i = shift; i < array_length(inputs); i++ ) {
			var _inp = inputs[i];
			
			if(!_inp.isVisible()) continue;
			if(_inp.value_from != noone) continue;
			if(junc != noone && (value_bit(junc.type) & value_bit(_inp.type)) == 0) continue;
			
			var _ddy = abs(_inp.y - _y);
			
			if(_ddy < _dy) {
				_targ = _inp;
				_dy   = _ddy;
			}
		}
		
		if(dummy_input) {
			var _ddy = abs(dummy_input.y - _y);
			if(_ddy < _dy)
				_targ = dummy_input;
		}
		
		return _targ;
	}
	
	static deleteDynamicInput = function(index) {
		var _ind = input_fix_len + index * data_length;
		
		array_delete(inputs, _ind, data_length);
		dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
		refreshDynamicDisplay();
		triggerRender();
	}
		
	////- INSPECTOR
	
	static onInspector1Update  = noone;
	static inspector1Update    = function() { INLINE onInspector1Update(); }
	static hasInspector1Update = function() { INLINE return onInspector1Update != noone; }
	
	static onInspector2Update  = noone;
	static inspector2Update    = function() { INLINE onInspector2Update(); }
	static hasInspector2Update = function() { INLINE return onInspector2Update != noone; }
	
	////- STEP
	
	static stepBegin = function() {
		
		if(use_cache) cacheArrayCheck();
		
		doStepBegin();
		
		if(attributes.show_update_trigger) {
			if(updatedInTrigger.getValue()) { 
				
				getInputs();
				update();
				
				updatedInTrigger.setValue(false);
			}
			updatedOutTrigger.setValue(false);
		}
		
		if(is_3D == NODE_3D.polygon) USE_DEPTH = true;
		if(is_simulation) PROJECT.animator.is_simulating = true;
		
		if(attributes.outp_meta) {
			junc_meta[0].setValue(getDisplayName());
			junc_meta[1].setValue([ x, y ]);
		}
		
		if(toRefreshNodeDisplay) {
			refreshNodeDisplay();
			toRefreshNodeDisplay = false;
		}
	}
	
	static doStepBegin = function() {}
	
	static setTrigger = function(index, tooltip = __txtx("panel_inspector_execute", "Execute"), icon = [ THEME.sequence_control, 1, COLORS._main_value_positive ], _function = undefined) {
		use_trigger         = true;
		
		if(index == 1) {
			insp1UpdateTooltip  = tooltip;
			insp1UpdateIcon     = icon;
			if(!is_undefined(_function)) onInspector1Update  = _function;
			
		} else if(index == 2) {
			insp2UpdateTooltip  = tooltip;
			insp2UpdateIcon     = icon;
			if(!is_undefined(_function)) onInspector2Update  = _function;
		} 
	}
	
	static triggerCheck = function() {
		if(input_button_length) {
			var i = 0;
			repeat( input_button_length ) {
				var _in = input_buttons[i++];
				
				if(_in.getStaticValue()) {
					_in.editWidget.onClick();
					_in.setValue(false);
				}
			}
		}
		
		if(!use_trigger) return;
		
		if(hasInspector1Update()) {
			inspectInput1.name = insp1UpdateTooltip;
			
			if(inspectInput1.getStaticValue()) {
				onInspector1Update();
				inspectInput1.setValue(false);
			}
		}
		
		if(hasInspector2Update()) {
			inspectInput2.name = insp2UpdateTooltip;
			
			if(inspectInput2.getStaticValue()) {
				onInspector2Update();
				inspectInput2.setValue(false);
			}
		}
	}
	
	static step = function() {}
	static focusStep = function() {}
	static inspectorStep = function() {}
	
	////- JUNCTIONS
	
	static newInput  = function(index, junction) { inputs[index]  = junction; return junction;  }
	static newOutput = function(index, junction) { outputs[index] = junction; return junction;  }
	
	static getInputJunctionAmount = function() { return (input_display_list == -1 || !use_display_list)? array_length(inputs) : array_length(input_display_list); }
	static getInputJunctionIndex  = function(index) {
		INLINE 
		
		if(input_display_list == -1 || !use_display_list)
			return index;
		
		var jun_list_arr = input_display_list[index];
		if(is_array(jun_list_arr))  return noone;
		if(is_struct(jun_list_arr)) return noone;
		
		return jun_list_arr;
	}
	
	static getOutputJunctionAmount = function()      { return output_display_list == -1? array_length(outputs) : array_length(output_display_list); }
	static getOutputJunctionIndex  = function(index) { return output_display_list == -1? index : output_display_list[index]; }
	
	static updateIO = function() {
		
		for( var i = 0, n = array_length(inputs); i < n; i++ )
			inputs[i].visible_in_list = false;
		
		inputs_amount = getInputJunctionAmount();
		
		for( var i = 0; i < inputs_amount; i++ ) {
			var _input = getInputJunctionIndex(i);
			if(_input == noone) continue;
			
			var _inp = inputs[_input];
			if(!is_struct(_inp) || !is_instanceof(_inp, NodeValue)) continue;
			
			_inp.visible_in_list = true;
		}
		
		outputs_index  = array_create_ext(getOutputJunctionAmount(), function(index) { return getOutputJunctionIndex(index); });
	}
	
	static setHeight = function() {
		
		w = SHOW_PARAM? attributes.node_param_width : min_w;
		if(!auto_height) return;
		
		var _ps = is_surface(getGraphPreviewSurface()) || preserve_height_for_preview;
		var _ou = preview_channel >= 0 && preview_channel < array_length(outputs) && outputs[preview_channel].type == VALUE_TYPE.surface;
		var _prev_surf = previewable && preview_draw && (_ps || _ou);
		
		junction_draw_hei_y = SHOW_PARAM?  32 : 16;
		junction_draw_pad_y = SHOW_PARAM? 128 : 24;
		
		var _hi, _ho;
		
		if(previewable) {
			_hi = junction_draw_pad_y;
			_ho = junction_draw_pad_y;
			
			if(SHOW_PARAM) {
				_hi = con_h;
				_ho = con_h;
			}
			
		} else {
			junction_draw_hei_y = 16;
			junction_draw_pad_y = name_height / 2;
			
			_hi = name_height;
			_ho = name_height;
		}
		
		var _p = previewable;
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _inp = inputs[i];
			if(is_instanceof(_inp, NodeValue) && _inp.isVisible()) {
				if(_p) _hi += junction_draw_hei_y;
				_p = true;
			}
		}
		
		if(auto_input && dummy_input) _hi += junction_draw_hei_y;
		var _p = previewable;
		
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			if(!outputs[i].isVisible()) continue;
			if(_p) _ho += junction_draw_hei_y;
			_p = true;
		}
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _inp = inputs[i];
			var _byp = _inp.bypass_junc;
			if(_byp == noone) continue;
			
			_ho += junction_draw_hei_y * _byp.visible;
		}
		
		if(attributes.outp_meta) {
			for( var i = 0, n = array_length(junc_meta); i < n; i++ ) {
				if(!junc_meta[i].isVisible()) continue;
				_ho += junction_draw_hei_y;
			}
		}
		
		h = max(previewable? con_h : name_height, _prev_surf * 128, _hi, _ho);
		if(attributes.node_height) h = max(h, attributes.node_height);
	}
	
	static getJunctionList = function() { ////getJunctionList
		inputDisplayList = [];
		
		var iamo = getInputAmount();
		if(iamo && input_display_dynamic != -1) {
			
			for(var i = 0; i < array_length(input_display_list_raw); i++) {
				var ind = input_display_list_raw[i];
				if(!is_real(ind)) continue;
				
				var jun = array_safe_get(inputs, ind, noone);
				if(jun == noone || is_undefined(jun)) continue;
				if(!jun.isVisible()) continue;
				
				array_push(inputDisplayList, jun);
			}
			
			for( var i = 0; i < iamo; i++ ) {
				var ind = input_fix_len + i * data_length;
				
				for( var j = 0, n = array_length(input_display_dynamic); j < n; j++ ) {
					if(!is_real(input_display_dynamic[j])) continue;
					
					var _in_ind = ind + input_display_dynamic[j];
					
					var jun = array_safe_get(inputs, _in_ind, noone);
					if(jun == noone || is_undefined(jun)) continue;
					if(!jun.isVisible()) continue;
					
					array_push(inputDisplayList, jun);
				}
			}
			
		} else {
			var amo = input_display_list == -1? array_length(inputs) : array_length(input_display_list);
			// print($"Amo = {amo}");
			
			for(var i = 0; i < amo; i++) {
				var ind = getInputJunctionIndex(i);
				if(ind == noone) continue;
				
				var jun = array_safe_get(inputs, ind, noone);
				if(jun == noone || is_undefined(jun)) continue;
				
				// print($"{i}: {jun.isVisible()}");
				// print($"    {jun.visible_manual}, {jun.visible}, {jun.index}, {jun.visible_in_list}");
				
				if(!jun.isVisible()) continue;
				
				array_push(inputDisplayList, jun);
			}
			
			// print($"{inputDisplayList}\n");
		}
		
		if(auto_input && dummy_input) array_push(inputDisplayList, dummy_input);
		
		// print(inputDisplayList);
	}
	
	static onValidate = function() {
		value_validation[VALIDATION.pass]	 = 0;
		value_validation[VALIDATION.warning] = 0;
		value_validation[VALIDATION.error]   = 0;
		
		for( var i = 0; i < array_length(inputs); i++ ) {
			var jun = inputs[i];
			if(jun.value_validation)
				value_validation[jun.value_validation]++;
		}
	}
	
	static onIOValidate = function() {
		var _inline_input = noone;
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _j = inputs[i];
			if(_j.value_from == noone) continue;
			
			var _n = _j.value_from.node;
			if(_n.inline_context == noone) continue;
			
			if(_inline_input != noone && _inline_input != _n.inline_context)
				logNode($"Node {getDisplayName()} connected to multiple inline loop inputs, this can cause render error.", 2);
				
			_inline_input = _n.inline_context;
		}
		
		var _inline_output = noone;
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			var _j = outputs[i];
			var _t = _j.getJunctionTo();
			
			for( var j = 0, m = array_length(_t); j < m; j++ ) {
				var _n = _t[j].node;
				if(_n.inline_context == noone) continue;
			
				if(_inline_output != noone && _inline_output != _n.inline_context)
					logNode($"Node {getDisplayName()} connected to multiple inline loop outputs, this can cause render error.", 2);
					
				_inline_output = _n.inline_context;
			}
		}
		
		if(_inline_input != noone && _inline_output != noone && _inline_input != inline_context) {
			logNode($"Node {getDisplayName()} connected between two inline nodes, but the node itself is not part of the group. The program has automatically add the node back to inline group.", 1);
			_inline_input.addNode(self);
		}
	}
	
	static getJunctionTos = function() {
		var _vto = array_create(array_length(outputs));
		for (var j = 0; j < array_length(outputs); j++)
			_vto[j] = array_clone(outputs[j].value_to);
			
		return _vto;
	}
	
	static checkConnectGroup = function(_io) {
		
		var _y  = y;
		var _n  = noone;
		
		for(var i = 0; i < array_length(inputs); i++) {
			var _in = inputs[i];
			if(_in.value_from == noone)				continue;
			if(_in.value_from.node.group == group)	continue;
			
			var _ind = string(_in.value_from);
			_io.map[$ _ind] = _in.value_from;
			
			if(struct_has(_io.inputs, _ind))
				array_push(_io.inputs[$ _ind ], _in);
			else 
				_io.inputs[$ _ind ] = [ _in ];
		}
		
		for(var i = 0; i < array_length(outputs); i++) {
			var _ou = outputs[i];
			
			for(var j = 0; j < array_length(_ou.value_to); j++) {
				var _to = _ou.value_to[j];
				if(_to.value_from != _ou)   continue;
				if(!_to.node.active)        continue;
				if(_to.node.group == group) continue;
				
				var _ind = string(_ou);
				_io.map[$ _ind] = _ou;
				
				if(struct_has(_io.outputs, _ind))
					array_push(_io.outputs[$ _ind ], _to);
				else 
					_io.outputs[$ _ind ] = [ _to ];
			}
		}
	}
	
	////- INPUTS
	
	set_default = true;
	
	static skipDefault = function() /*=>*/ { set_default = false; return self; }
	
	static resetDefault = function() { 
		var folder = instanceof(self);
		
		if(!ds_map_exists(global.PRESETS_MAP, folder)) {
			for( var i = 0, n = array_length(inputs); i < n; i++ )
				inputs[i].resetValue();
			return;
		}
		
		var pres = global.PRESETS_MAP[? folder];
		for( var i = 0, n = array_length(pres); i < n; i++ ) {
			var preset = pres[i];
			if(preset.name != "_default") continue;
			
			deserialize(loadPreset(preset), true, true);
			applyDeserialize(true);
			return;
		}
		
		for( var i = 0, n = array_length(inputs); i < n; i++ )
			inputs[i].resetValue();
			
	} if(!APPENDING && !LOADING) run_in(1, function() /*=>*/ { if(set_default) resetDefault() });
	
	static addInput = function(junctionFrom, shift = input_fix_len) {
		var targ = getInput(y, junctionFrom, shift);
		if(targ == noone) return;
		
		targ.setFrom(junctionFrom);
	}
	
	static getInputData      = function(index, def = 0) { return inputs[index].getValue(); }//array_safe_get_fast(inputs_data, index, def); }
	static getInputDataForce = function(index, def = 0) { return inputs[index].getValue(); }
	
	// static setInputData = function(index, value) {
	// 	var _inp = inputs[index];
	// 	inputs_data[index] = value;
	// 	if(is_struct(_inp)) input_value_map[$ _inp.internalName] = value;
	// }
	
	static getInputs = function(frame = CURRENT_FRAME) {
		
		inputs_data	= array_verify(inputs_data, array_length(inputs));
		__frame     = frame;
		
		array_foreach(inputs, function(_inp, i) /*=>*/ {
			if(!is_instanceof(_inp, NodeValue)) return;
			if(!_inp.isDynamic())               return;
			
			var val = _inp.getValue(__frame);
			
			if(_inp.bypass_junc.visible) _inp.bypass_junc.setValue(val);
			inputs_data[i] = val;								// setInputData(i, val);
			input_value_map[$ _inp.internalName] = val;
		});
	}
	
	////- UPDATE
	
	static forceUpdate = function() {
		input_hash = "";
		doUpdate();
	}
	
	static postUpdate = function(frame = CURRENT_FRAME) {}
	
	static doUpdateLite = function(frame = CURRENT_FRAME) {
		render_timer = get_timer();
		setRenderStatus(true);
		
		if(attributes.update_graph) {
			try      { update(frame); } 
			catch(e) { log_warning("RENDER", exception_print(e), self); }
		}
		
		render_time = get_timer() - render_timer;
	}
	
	static doUpdateFull = function(frame = CURRENT_FRAME) {
		
		if(PROJECT.safeMode) return;
		if(NODE_EXTRACT)     return;
		
		render_timer  = get_timer();
		var _updateRender = !is_instanceof(self, Node_Collection) || !managedRenderOrder;
		if(_updateRender) setRenderStatus(true);
		
		if(cached_manual || (use_cache == CACHE_USE.auto && recoverCache())) {
			render_cached = true;
			
		} else {
			render_cached = false;
			getInputs(frame);
			
			LOG_BLOCK_START();
			LOG_IF(global.FLAG.render == 1, $">>>>>>>>>> DoUpdate called from {INAME} <<<<<<<<<<");
			
			var sBase = surface_get_target();	
			
			try {
				if(attributes.update_graph) update(frame);
			} catch(exception) {
				var sCurr = surface_get_target();
				while(surface_get_target() != sBase)
					surface_reset_target();
			
				log_warning("RENDER", exception_print(exception), self);
			}
		}
		
		if(!IS_PLAYING) {
			array_foreach(inputs,  function(in, i) /*=>*/ { in.updateColor(getInputData(i)); });
			array_foreach(outputs, function(in, i) /*=>*/ { in.updateColor(in.getValue());   });
		}
		
		postUpdate(frame);
		cached_manual = false;
		
		if(!use_cache && PROJECT.onion_skin.enabled) {
			for( var i = 0; i < array_length(outputs); i++ ) {
				if(outputs[i].type != VALUE_TYPE.surface) continue;
				cacheCurrentFrame(outputs[i].getValue());
				break;
			}
		}
		
		if(hasInspector1Update() && inspectInput1.getValue()) onInspector1Update(true);
		if(hasInspector2Update() && inspectInput2.getValue()) onInspector2Update(true);
		
		updatedOutTrigger.setValue(true);
		
		if(!is(self, Node_Collection)) render_time = get_timer() - render_timer;
		
		LOG_BLOCK_END();
	}
	
	doUpdate = doUpdateFull;
	
	static valueUpdate = function(index) {
		onValueUpdate(index);
		
		cacheCheck();
	}
	
	static valueFromUpdate = function(index) {
		onValueFromUpdate(index);
		onValueUpdate(index);
		
		if(auto_input && !LOADING && !APPENDING) 
			refreshDynamicInput();
			
		cacheCheck();
	}
	
	static onValueUpdate = function(index = 0) {}
	static onValueFromUpdate = function(index) {}
	
	////- RENDER
	
	static isAnimated = function(frame = CURRENT_FRAME) {
		if(update_on_frame) return true;
		return array_any(inputs, function(inp) /*=>*/ {return inp.is_anim});
	}
	
	static isActiveDynamic = function(frame = CURRENT_FRAME) {
		if(update_on_frame) return true;
		if(!rendered)       return true;
		
		force_requeue = false;
		__temp_frame  = frame;
		return array_any(inputs, function(inp) /*=>*/ {return inp.isActiveDynamic(__temp_frame)});
	}
	
	static triggerRender = function(resetSelf = true) {
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"Trigger render for {self}");
		
		if(resetSelf) resetRender(false);
		RENDER_PARTIAL
		
		if(is_instanceof(group, Node_Collection)) {
			group.triggerRender();
		} else {
			
			var nodes = getNextNodesRaw();
			for(var i = 0; i < array_length(nodes); i++)
				nodes[i].triggerRender();
		}
		
		LOG_BLOCK_END();
	}
	
	static clearTopoSorted = function() { INLINE topoSorted = false; }
	
	static forwardPassiveDynamic = function() {
		rendered = false;
		
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			var _outp = outputs[i];
			
			for(var j = 0; j < array_length(_outp.value_to); j++) {
				var _to = _outp.value_to[j];
				if(!_to.node.active || _to.value_from != _outp) continue; 
				
				//LOG_IF(global.FLAG.render == 1, $"|| Forwarding dynamic to {_to.node.name} ||");
				_to.node.passiveDynamic = true;
				_to.node.rendered = false;
			}
		}
	}
	
	static resetRender = function(_clearCache = false) { 
		setRenderStatus(false); 
		if(_clearCache) clearInputCache();
	}
	
	static isLeaf = function() {
		INLINE 
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _inp = inputs[i];
			if(!_inp.value_from == noone) return false;
		}
		
		return true;
	}
	
	static isLeafList = function(list = noone) {
		INLINE 
		
		if(list == noone) return isLeaf();
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _inp = inputs[i].value_from;
			
			if(_inp != noone && array_exists(list, _inp.node)) 
				return false;
		}
		
		return true;
	}
	
	static isRenderActive = function() { return renderActive || (PREFERENCES.render_all_export && IS_RENDERING); }
	
	static isRenderable = function(log = false) { //Check if every input is ready (updated)
		if(!active || !isRenderActive()) return false;
		
		for(var j = 0; j < array_length(inputs); j++) {
			if(!inputs[j].isRendered()) {
				LOG_IF(global.FLAG.render == 1, $"→→ x Node {internalName} {inputs[j]} not rendered.");
				return false;
			}
		}
		
		return true;
	}
	
	static setRenderStatus = function(result) {
		INLINE
		
		if(rendered == result) return;
		logNodeDebug($"Set render status for {getFullName()} : {result}", 3);
		
		rendered = result;
	}
	
	static getPreviousNodes = function() {
		var prev = [];
		var prMp = {};
		var _n;
		
		if(attributes.show_update_trigger && updatedInTrigger.value_from) {
			_n = updatedInTrigger.value_from.node;
			
			if(!struct_has(prMp, _n.node_id)) {
				array_push(prev, _n);
				prMp[$ _n.node_id] = 1;
			}
		}
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _in = inputs[i];
			
			if(_in.value_from != noone) {
				if(in_VFX && !_in.value_from.node.in_VFX) {
					array_push(in_VFX.prev_nodes, _in.value_from.node);
					
					if(!struct_has(prMp, in_VFX.node_id)) {
						array_push(prev, in_VFX);
						prMp[$ in_VFX.node_id] = 1;
					}
					
					continue;
				}
				
				_n = _in.value_from.node;
				if(!struct_has(prMp, _n.node_id)) {
					array_push(prev, _n);
					prMp[$ _n.node_id] = 1;
				}
				
			}
				
			if(_in.value_from_loop != noone) {
				_n = _in.value_from_loop;
				if(!struct_has(prMp, _n.node_id)) {
					array_push(prev, _n);
					prMp[$ _n.node_id] = 1;
				}
			}
		}
		
		onGetPreviousNodes(prev);
		return prev;
	}
	
	static onGetPreviousNodes = function(arr) {}
	
	__nextNodes       = noone;
	__nextNodesToLoop = noone;
	
	static getNextNodes = function(checkLoop = false) {
		if(checkLoop) {
			if(__nextNodesToLoop != noone && __nextNodesToLoop.bypassNextNode())
				__nextNodesToLoop.getNextNodes();
			return;
		}
		
		__nextNodesToLoop = noone;
		for(var i = 0; i < array_length(outputs); i++) {
			var _ot = outputs[i];
			if(!_ot.forward) continue;
			
			for( var j = 0, n = array_length(_ot.value_to_loop); j < n; j++ ) {
				var _to = _ot.value_to_loop[j];
				if(!_to.active) continue;
				
				__nextNodesToLoop = _to;
				if(!_to.bypassNextNode()) continue;
				return _to.getNextNodes();
			}
		}
		
		if(__nextNodes != noone) return __nextNodes;
		var nodes = [];
		
		for(var i = 0; i < array_length(outputs); i++) {
			var _ot = outputs[i];
			if(!_ot.forward) continue;
			
			var _tos = _ot.getJunctionTo();
			for( var j = 0; j < array_length(_tos); j++ ) {
				var _to = _tos[j];
				array_push(nodes, _to.node);
			}
		}	
		
		for(var i = 0; i < array_length(junc_meta); i++) {
			var _ot  = junc_meta[i];
			var _tos = _ot.getJunctionTo();
			
			for( var j = 0; j < array_length(_tos); j++ ) {
				var _to = _tos[j];
				array_push(nodes, _to.node);
			}
		}
		
		for(var i = 0; i < array_length(inputs); i++) {
			var _in = inputs[i];
			if(_in.bypass_junc == noone) continue;
			
			var _tos = _in.bypass_junc.getJunctionTo();
			for( var j = 0; j < array_length(_tos); j++ ) {
				var _to = _tos[j];
				array_push(nodes, _to.node);
			}
		}
		
		__nextNodes = nodes;
		return nodes;
	}
	
	static getNextNodesRaw = function() {
		var nodes = [];
		
		for(var i = 0; i < array_length(outputs); i++) {
			var _ot = outputs[i];
			if(!_ot.forward) continue;
			if(_ot.type == VALUE_TYPE.node) continue;
			
			for( var j = 0, n = array_length(_ot.value_to_loop); j < n; j++ ) {
				var _to = _ot.value_to_loop[j];
				if(!_to.active) continue; 
				if(!_to.bypassNextNode()) continue;
			
				return _to.getNextNodes();
			}
		
			var _tos = _ot.getJunctionTo();
			for( var j = 0; j < array_length(_tos); j++ )
				array_push(nodes, _tos[j].node);
		}	
		
		for(var i = 0; i < array_length(inputs); i++) {
			var _in = inputs[i];
			if(_in.bypass_junc == noone) continue;
			
			var _tos = _in.bypass_junc.getJunctionTo();
			for( var j = 0; j < array_length(_tos); j++ )
				array_push(nodes, _tos[j].node);
		}
		
		return nodes;
	}
	
	////- DRAW
	
	static setShowParameter = function(showParam) {
		show_parameter = showParam;
		refreshNodeDisplay();
		return self;
	}
	
	static setPreviewable = function(prev) {
		if(previewable == prev) return;
		
		previewable = prev;
		y += previewable? -16 : 16;
	}
	
	static onInspect = function() {}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		return point_in_rectangle(_mx, _my, xx, yy, xx + w * _s, yy + h * _s);
	}
	
	static cullCheck = function(_x, _y, _s, minx, miny, maxx, maxy) {
		var x0 = x * _s + _x;
		var y0 = y * _s + _y;
		var x1 = (x + w) * _s + _x;
		var y1 = (y + h) * _s + _y;
		
		draw_boundary[0] = minx;
		draw_boundary[1] = miny;
		draw_boundary[2] = maxx;
		draw_boundary[3] = maxy;
		
		draw_graph_culled = !rectangle_in_rectangle(minx, miny, maxx, maxy, x0, y0, x1, y1);
		return !draw_graph_culled;
	}
	
	static refreshNodeDisplay = function() {
		// print("refreshNodeDisplay"); printCallStack();
		// if(IS_PLAYING) return;
		updateIO();
		setHeight();
		getJunctionList();
		setJunctionIndex();
		
		__preDraw_data.force = true;
		
	} run_in(1, function() /*=>*/ { refreshNodeDisplay(); });
	
	__preDraw_data = { _x: undefined, _y: undefined, _w: undefined, _h: undefined, _s: undefined, _p: undefined, sp: undefined, force: false };
	
	static preDraw = function(_x, _y, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		var _d   = __preDraw_data;
		var _upd = _d._x != xx || _d._y != yy || _d._s != _s || _d.force || _d._w != w || _d._h != h || _d._p != previewable || _d.sp != show_parameter 
		
		_d._x = xx;
		_d._y = yy;
		_d._w = w;
		_d._h = h;
		_d._s = _s;
		_d._p = previewable;
		_d.sp = show_parameter;
		
		_d.force = false;
		
		if(!_upd) {
			if(SHOW_PARAM) h = h_param;
			onPreDraw(_x, _y, _s, _iy, _oy);
			return;
		}
		
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
		
		updatedInTrigger.x = xx;
		updatedInTrigger.y = yy + 10;
		
		updatedOutTrigger.x = xx + w * _s;
		updatedOutTrigger.y = yy + 10;
		
		if(in_cache_len != array_length(inputDisplayList) || out_cache_len != array_length(outputs)) {
			refreshNodeDisplay();
			
			in_cache_len  = array_length(inputDisplayList);
			out_cache_len = array_length(outputs);
		}
		
		var _junRy = junction_draw_pad_y;
		var _junSy = yy + _junRy * _s;
		
		if(SHOW_PARAM) {
			_junRy = con_h + junction_draw_hei_y / 2;
			_junSy = yy + _junRy * _s;
		}
		
		__s = _s;
		_ix = xx;           _rix = x;
		_iy = _junSy;       _riy = y + _junRy;
		
		_ox = xx + w * _s;  _rox = x + w;
		_oy = _junSy;       _roy = y + _junRy;
		
		array_foreach(inputs,           function(jun) /*=>*/ { jun.x = _ix; jun.y = _iy; });
		
		array_foreach(inputDisplayList, function(jun) /*=>*/ { 
			jun.x = _ix; jun.rx = _rix; 
			jun.y = _iy; jun.ry = _riy; 
			
			_riy += junction_draw_hei_y;
			_iy  += junction_draw_hei_y * __s;
		});
		
		array_foreach(outputs_index,    function(jun) /*=>*/ { 
			jun = outputs[jun]; 
			jun.x = _ox; jun.rx = _rox; 
			jun.y = _oy; jun.ry = _roy; 
			
			var __vis = jun.isVisible();
			_roy += junction_draw_hei_y * __vis 
			_oy  += junction_draw_hei_y * __vis * __s; 
		});
		
		array_foreach(inputs,           function(jun) /*=>*/ { jun   = jun.bypass_junc; if(!jun.visible) return; 
		                                           jun.x = _ox; jun.y = _oy; _oy += junction_draw_hei_y * jun.visible * __s; });
		array_foreach(junc_meta,        function(jun) /*=>*/ { jun.x = _ox; jun.y = _oy; _oy += junction_draw_hei_y * jun.isVisible() * __s; });
		
		if(SHOW_PARAM) h = h_param;
		onPreDraw(_x, _y, _s, _iy, _oy);
	}
	
	static onPreDraw = function(_x, _y, _s, _iny, _outy) {}
	
	static isHighlightingInGraph = function() {
		var  high = display_parameter.highlight;
		var _selc = active_draw_index == 0 || branch_drawing;
		return !high || _selc;
	}
	
	static getColor = function() { INLINE return attributes.color == -1? color : attributes.color; }
	
	static drawNodeBase = function(xx, yy, _s) { 
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w * _s, h * _s, getColor(), .75 * (.25 + .75 * isHighlightingInGraph())); 
	}
	
	static drawNodeOverlay = function(xx, yy, _mx, _my, _s) {}
	
	__draw_bbox = BBOX();
	static drawGetBbox = function(xx, yy, _s, label = true) {
		var pad_label = ((display_parameter.avoid_label || label) && draw_name) || label == 2;
		
		var x0 = xx;
		var x1 = xx + w * _s;
		var y0 = yy;
		var y1 = yy + h * _s;
		
		if(pad_label)  y0 += name_height * _s;
		if(SHOW_PARAM) y1  = yy + con_h  * _s;
		
		x0 += max(draw_padding, draw_pad_w) * _s; 
		x1 -= max(draw_padding, draw_pad_w) * _s;
		y0 += max(draw_padding, draw_pad_h) * _s; 
		y1 -= max(draw_padding, draw_pad_h) * _s;
		
		var _w = x1 - x0;
		var _h = y1 - y0;
		
		var _xc = (x0 + x1) / 2;
		var _yc = (y0 + y1) / 2;
		
		_w *= display_parameter.preview_scale / 100;
		_h *= display_parameter.preview_scale / 100;
		
		x0 = _xc - _w / 2;
		x1 = _xc + _w / 2;
		y0 = _yc - _h / 2;
		y1 = _yc + _h / 2;
		
		return __draw_bbox.fromPoints(x0, y0, x1, y1);
	}
	
	static drawNodeName = function(xx, yy, _s, _panel = noone) {
		var _name = renamed? display_name : name;
		if(_name == "") return;
		
		draw_name = true;
		
		var aa = (.25 + .5 * renderActive) * (.25 + .75 * isHighlightingInGraph());
		var cc = getColor();
		var nh = previewable? name_height * _s : h * _s;
		var ba = aa;
		
		if(_panel && _panel.node_hovering == self) ba = .1;
		draw_sprite_stretched_ext(THEME.node_bg, 2, xx, yy, w * _s, nh, cc, ba);
		
		var cc = renderActive? COLORS._main_text : COLORS._main_text_sub;
		if(PREFERENCES.node_show_render_status && !rendered)
			cc = isRenderable()? COLORS._main_value_positive : COLORS._main_value_negative;
		
		aa += 0.25;
		
		var tx = xx     + 6 * _s;
		var tw = w * _s - 8 * _s;
		
		if(_panel && _panel.is_searching && _panel.search_string != "" && search_match == -9999)
			aa *= .15;
				
		if(icon) {
			tx += _s * 6;
			draw_sprite_ui_uniform(icon, 0, round(tx) + 1, round(yy + nh / 2) + 1, _s, c_black,    1);
			draw_sprite_ui_uniform(icon, 0, round(tx),     round(yy + nh / 2),     _s, icon_blend, 1);
			tx += _s *  12;
			tw -= _s * (12 + 6);
		}
		
		var _ts  = _s * 0.275;
		var _tx  = round(tx);
		var _ty  = round(yy + nh / 2 + 1);
		
		draw_set_text(f_sdf, fa_left, fa_center, cc, aa);
			var _txt = string_cut(_name, tw, "...", _ts);
			BLEND_ALPHA_MULP
			
			draw_set_color(0);  draw_set_alpha(1); draw_text_transformed(_tx + 1, _ty + 1, _txt, _ts, _ts, 0);
			draw_set_color(cc); draw_set_alpha(1); draw_text_transformed(_tx, _ty, _txt, _ts, _ts, 0);
			
			BLEND_NORMAL
		draw_set_alpha(1);
	}
	
	static drawJunctionWidget = function(_x, _y, _mx, _my, _s, _hover, _focus) {
		
		var hover = noone;
		
		var _m = [ _mx, _my ];
		var pd = junction_draw_pad_y * _s;
		var wh = junction_draw_hei_y * _s;
		
		var ww = w * _s * 0.5;
		var wt = w * _s * 0.25;
		var wx = _x + w * _s - ww - 8;
		var lx = _x + 12 * _s;
		
		var jy = _y + con_h * _s + wh / 2;
		
		var rx = PANEL_GRAPH.x;
		var ry = PANEL_GRAPH.y;
		
		var extY = 0;
		var drwT = _s > 0.5;
		
		for(var i = 0, n = array_length(inputDisplayList); i < n; i++) {
			var jun = inputDisplayList[i];
			var wd  = jun.graphWidget;
			
			jun.y = jy;
			
			if(drwT) {
				draw_set_text(f_sdf, fa_left, fa_center, jun.color_display);
				draw_text_add(lx, jun.y, jun.getName(), _s * 0.25);
				
			} else {
				draw_set_color(jun.color_display);
				draw_rectangle(lx, jun.y - 1 * _s, lx + wt, jun.y + 4 * _s, false);
			}
			
			if(jun.value_from || wd == noone) {
				extY += junction_draw_hei_y;
				jy   += wh;
				continue;
			}
			
			var _param = jun.graphWidgetP;
			
			_param.w    = ww;
			_param.h    = wh - 4 * _s;
			_param.x    = wx;
			_param.y    = jy - _param.h / 2;
			
			_param.data = jun.showValue();
			_param.m	= _m;
			_param.rx	= rx;
			_param.ry	= ry;
			_param.s    = wh;
			_param.font = f_p2;
			_param.color = getColor();
			
			if(is_instanceof(jun, checkBox))
				_param.halign = fa_center;
			
			wd.setInteract(wh > line_get_height(f_p2));
			wd.setFocusHover(_focus, _hover);
			var _h = wd.drawParam(_param);
			jun.graphWidgetH = _h / _s;
					
			extY += max(0, jun.graphWidgetH + 4);
			jy   += (jun.graphWidgetH + 4) * _s;
			
			if(wd.isHovering()) draggable = false;
		}
		
		h = con_h + extY + 4;
		h_param = h;
	}
	
	static drawJunctions = function(_draw, _x, _y, _mx, _my, _s) {
		var hover = noone;
		gpu_set_texfilter(true);
		
		for(var i = 0, n = array_length(inputDisplayList); i < n; i++) { //inputs
			var jun = inputDisplayList[i];
			
			if(jun.drawJunction(_draw, _s, _mx, _my)) hover = jun;
		}
		
		for(var i = 0; i < array_length(outputs); i++) { // outputs
			var jun = outputs[i];
			
			if(!jun.isVisible()) continue;
			if(jun.drawJunction(_draw, _s, _mx, _my)) hover = jun;
		}
		
		for( var i = 0; i < array_length(inputs); i++ ) { // bypass
			var _inp = inputs[i];
			var  jun = _inp.bypass_junc;
			
			if(jun == noone || !jun.visible) continue;
			if(jun.drawJunction(_draw, _s, _mx, _my)) hover = jun;
		}
		
		if(hasInspector1Update() && inspectInput1.drawJunction(_draw, _s, _mx, _my)) hover = inspectInput1;
		if(hasInspector2Update() && inspectInput2.drawJunction(_draw, _s, _mx, _my)) hover = inspectInput2;
		
		if(attributes.show_update_trigger) {
			if(updatedInTrigger.drawJunction(_draw, _s, _mx, _my))  hover = updatedInTrigger;
			if(updatedOutTrigger.drawJunction(_draw, _s, _mx, _my)) hover = updatedOutTrigger;
		}
		
		if(attributes.outp_meta) {
			for(var i = 0; i < array_length(junc_meta); i++) { // outputs
				var jun = junc_meta[i];
				
				if(!jun.isVisible()) continue;
				if(jun.drawJunction(_draw, _s, _mx, _my)) hover = jun;
			}
		}
		
		onDrawJunctions(_x, _y, _mx, _my, _s);
		
		gpu_set_texfilter(false);
		return hover;
	}
	
	static drawJunctions_fast = function(_draw, _x, _y, _mx, _my, _s) {
		var hover = noone;
		
		draw_set_circle_precision(4);
		
		for(var i = 0, n = array_length(inputDisplayList); i < n; i++) {
			var jun = inputDisplayList[i];
			
			if(jun.drawJunction_fast(_draw, _s, _mx, _my)) hover = jun;
		}
		
		for(var i = 0; i < array_length(outputs); i++) {
			var jun = outputs[i];
			
			if(!jun.isVisible()) continue;
			if(jun.drawJunction_fast(_draw, _s, _mx, _my)) hover = jun;
		}
		
		for( var i = 0; i < array_length(inputs); i++ ) {
			var _inp = inputs[i];
			var jun = _inp.bypass_junc;
			
			if(jun == noone || !jun.visible) continue;
			if(jun.drawJunction_fast(_draw, _s, _mx, _my)) hover = jun;
		}
		
		if(hasInspector1Update() && inspectInput1.drawJunction_fast(_draw, _s, _mx, _my)) hover = inspectInput1;
		if(hasInspector2Update() && inspectInput2.drawJunction_fast(_draw, _s, _mx, _my)) hover = inspectInput2;
		
		if(attributes.show_update_trigger) {
			if(updatedInTrigger.drawJunction_fast(_draw, _s, _mx, _my))  hover = updatedInTrigger;
			if(updatedOutTrigger.drawJunction_fast(_draw, _s, _mx, _my)) hover = updatedOutTrigger;
		}
		
		if(attributes.outp_meta) {
			for(var i = 0; i < array_length(junc_meta); i++) { // outputs
				var jun = junc_meta[i];
				
				if(!jun.isVisible()) continue;
				if(jun.drawJunction_fast(_draw, _s, _mx, _my)) hover = jun;
			}
		}
		
		onDrawJunctions(_x, _y, _mx, _my, _s);
		
		return hover;
	}
	
	static onDrawJunctions = function(_x, _y, _mx, _my, _s) {}
	
	static drawJunctionNames = function(_x, _y, _mx, _my, _s) {
		var amo = input_display_list == -1? array_length(inputs) : array_length(input_display_list);
		var jun;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		var _hov = PANEL_GRAPH.pHOVER && (PANEL_GRAPH.node_hovering == noone || PANEL_GRAPH.node_hovering == self);
		
		show_input_name  = _hov;
		show_output_name = _hov;
		
		var _y0 = previewable? yy + name_height * _s : yy;
		var _y1 = yy + h * _s;
		
		show_input_name  &= point_in_rectangle(_mx, _my, xx - (    12) * _s, _y0, xx + (    12) * _s, _y1);
		show_output_name &= point_in_rectangle(_mx, _my, xx + (w - 12) * _s, _y0, xx + (w + 12) * _s, _y1);
		
		if(PANEL_GRAPH.value_dragging && PANEL_GRAPH.node_hovering == self) {
			if(PANEL_GRAPH.value_dragging.connect_type == CONNECT_TYPE.input)  show_output_name = true;
			if(PANEL_GRAPH.value_dragging.connect_type == CONNECT_TYPE.output) show_input_name = true;
		}
		
		if(show_input_name) {
			for(var i = 0, n = array_length(inputDisplayList); i < n; i++) {
				var jun = inputDisplayList[i];
				jun.drawNameBG(_s);
			}
			
			for(var i = 0, n = array_length(inputDisplayList); i < n; i++) {
				var jun = inputDisplayList[i];
				jun.drawName(_s, _mx, _my);
			}
		}
		
		if(show_output_name) {
			for(var i = 0; i < array_length(outputs); i++)
				if(outputs[i].isVisible()) outputs[i].drawNameBG(_s);
			
			for( var i = 0; i < array_length(inputs); i++ ) {
				var jun = inputs[i].bypass_junc;
				if(jun == noone || !jun.visible) continue;
				jun.drawNameBG(_s);
			}
			
			for(var i = 0; i < array_length(outputs); i++)
				if(outputs[i].isVisible()) outputs[i].drawName(_s, _mx, _my);
			
			for( var i = 0; i < array_length(inputs); i++ ) {
				var jun = inputs[i].bypass_junc;
				if(jun == noone || !jun.visible) continue;
				jun.drawName(_s, _mx, _my);
			}
			
			if(attributes.outp_meta) {
				for(var i = 0; i < array_length(junc_meta); i++) {
					var jun = junc_meta[i];
					
					if(!jun.isVisible()) continue;
					jun.drawNameBG(_s);
					jun.drawName(_s, _mx, _my);
				}
			}
			
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
	
	__draw_inputs     = [];
	__draw_inputs_len = 0;
	
	static setJunctionIndex = function() {
		var drawLineIndex  = 1;
		__draw_outputs_len = 0;
		
		for(var i = 0, n = array_length(outputs); i < n; i++) {
			var _jun      = outputs[i];
			var connected = !array_empty(_jun.value_to);
			
			if(connected) __draw_outputs_len++;
		}
		
		var _ind = 0;
		for(var i = 0, n = array_length(outputs); i < n; i++) {
			var _jun      = outputs[i];
			var connected = !array_empty(_jun.value_to);
			
			if(connected) {
				_jun.drawLineIndex = 1 + (_ind > __draw_outputs_len / 2? (__draw_outputs_len - 1 - _ind) : _ind) * 0.5;
				_ind++;
			}
		}
		
		__draw_inputs = array_verify(__draw_inputs, array_length(inputs));
		var drawLineIndex = 1;
		__draw_inputs_len = 0;
		
		for(var i = 0, n = array_length(inputs); i < n; i++) {
			_jun = inputs[i];
			
			if( _jun.value_from == noone || !_jun.value_from.node.active || !_jun.isVisible()) continue;
			__draw_inputs[__draw_inputs_len++] = _jun;
		}
		
		for( var i = 0; i < __draw_inputs_len; i++ ) {
			_jun = __draw_inputs[i];
			_jun.drawLineIndex = 1 + (i > __draw_inputs_len / 2? (__draw_inputs_len - 1 - i) : i) * 0.5;
		}
	}
	
	static drawConnections = function(params = {}, _draw = true) { 
		if(!active) return noone;
		
		var _hov, hovering = noone;
		if(hasInspector1Update()) { _hov = inspectInput1.drawConnections(params, _draw); if(_hov) hovering = _hov; }
		if(hasInspector2Update()) { _hov = inspectInput2.drawConnections(params, _draw); if(_hov) hovering = _hov; }
		
		for( var i = 0; i < __draw_inputs_len; i++ ) {
			var _jun = __draw_inputs[i];
			
			if(_jun.bypass_junc.visible) _jun.bypass_junc.drawBypass(params);
			_hov = _jun.drawConnections(params, _draw); if(_hov) hovering = _hov;
		}
		
		if(attributes.show_update_trigger) {
			if(updatedInTrigger.drawConnections(params, _draw))  hovering = updatedInTrigger;
			if(updatedOutTrigger.drawConnections(params, _draw)) hovering = updatedOutTrigger;
		}
		
		return hovering;
	}
	
	static getGraphPreviewSurface = function() { 
		var _node = array_safe_get(outputs, preview_channel);
		if(!is_instanceof(_node, NodeValue)) return noone;
		
		switch(_node.type) {
			case VALUE_TYPE.surface :
			case VALUE_TYPE.dynaSurface :
				return _node.showValue();
		}
		
		return noone;
	}
	
	__preview_surf = false;
	__preview_sw   = noone;
	__preview_sh   = noone;
	
	static setPreview = function(_surf) {
		preview_surface = _surf;
		__preview_surf  = is_surface(_surf);
	}
	
	static drawPreview = function(xx, yy, _s) {
		var surf = getGraphPreviewSurface();
		if(surf == noone) return;
		
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
		
		setPreview(surf);
		if(!__preview_surf) return;
		
		__preview_sw   = surface_get_width_safe(preview_surface);
		__preview_sh   = surface_get_height_safe(preview_surface);
		
		var bbox = drawGetBbox(xx, yy, _s, false);
		var aa   = 0.5 + 0.5 * renderActive;
		if(!isHighlightingInGraph()) aa *= 0.25;
		
		var _sw = __preview_sw;
		var _sh = __preview_sh;
		var _ss = min(bbox.w / _sw, bbox.h / _sh);
		
		var _ps = preview_surface;
		if(is_struct(_ps) && is_instanceof(_ps, dynaSurf))
			_ps = array_safe_get_fast(_ps.surfaces, 0, noone);
			
		draw_surface_ext_safe(_ps, bbox.xc - _sw * _ss / 2, bbox.yc - _sh * _ss / 2, _ss, _ss);
	}
	
	static getNodeDimension = function(showFormat = true) {
		if(!__preview_surf) return preview_array;
		
		var pw = surface_get_width_safe(preview_surface);
		var ph = surface_get_height_safe(preview_surface);
		var format = surface_get_format_safe(preview_surface);
		
		var txt = $"[{pw} x {ph}";
		if(preview_amount) txt = $"{preview_amount} x {txt}";
		
		switch(format) {
			case surface_rgba8unorm	 : break;
			case surface_rgba4unorm	 : txt += showFormat? " 4RGBA"	: " 4R";  break;
			case surface_rgba16float : txt += showFormat? " 16RGBA"	: " 16R"; break;
			case surface_rgba32float : txt += showFormat? " 32RGBA"	: " 32R"; break;
			case surface_r8unorm	 : txt += showFormat? " 8BW"	: " 8B";  break;
			case surface_r16float	 : txt += showFormat? " 16BW"	: " 16B"; break;
			case surface_r32float	 : txt += showFormat? " 32BW"	: " 32B"; break;
		}
		
		txt += "]";
		
		return txt;
	}
	
	static drawDimension = function(xx, yy, _s) {
		if(draw_graph_culled) return;
		if(!active)           return;
		if(_s * w < 64)       return;
		if(!previewable)      return;
		
		draw_set_text(f_p3, fa_center, fa_top, COLORS.panel_graph_node_dimension);
		var tx = xx + w * _s / 2;
		var ty = yy + (h + 4) * _s - 2;
		
		if(struct_get(display_parameter, "show_dimension")) {
			var txt = string(getNodeDimension(_s > 0.65));
			draw_text(round(tx), round(ty), txt);
			ty += string_height(txt) - 2;
		}
		
		if(struct_get(display_parameter, "show_compute")) {
			var rt = 0, unit = "";
			
			if(render_time == 0) {
				draw_set_color(COLORS._main_text_sub);
				unit = "us";
				
			} else if(render_time < 1000) {
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
			
			if(render_cached) draw_set_color(COLORS._main_text_sub);
			
			draw_text(round(tx), round(ty), $"{rt} {unit}");
		}
	}
	
	static groupCheck = function(_x, _y, _s, _mx, _my) {}
	
	static drawNodeBG = function(_x, _y, _mx, _my, _s, display_parameter = noone, _panel = noone) { 
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		drawDimension(xx, yy, _s);
		return false; 
	}
	
	static drawNodeFG = function(_x, _y, _mx, _my, _s, display_parameter = noone, _panel = noone) { }
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s, display_parameter = noone, _panel = noone) { 
		if(display_parameter != noone) self.display_parameter = display_parameter;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		if(!_draw) return _s > 0.5? drawJunctions(_draw, xx, yy, _mx, _my, _s) : drawJunctions_fast(_draw, xx, yy, _mx, _my, _s);
		
		preview_mx = _mx;
		preview_my = _my;
		
		if(value_validation[VALIDATION.error])
			draw_sprite_stretched_ext(THEME.node_glow_border, 0, xx - 9, yy - 9, w * _s + 18, h * _s + 18, COLORS._main_value_negative, 1);
		
		drawNodeBase(xx, yy, _s);
		draggable = true;
		
		if(previewable) {
			if(preview_draw) drawPreview(xx, yy, _s);
			
			try { 
				var _hover = PANEL_GRAPH.node_hovering == self;
				var _focus = PANEL_GRAPH.getFocusingNode() == self;
				
				onDrawNode(xx, yy, _mx, _my, _s, _hover, _focus); 
			}
			catch(e) { log_warning("NODE onDrawNode", exception_print(e)); }
		} 
		
		if(SHOW_PARAM) drawJunctionWidget(xx, yy, _mx, _my, _s, _hover, _focus);
		
		draw_name = false;
		if((previewable && _s >= 0.5) || (!previewable && h * _s >= name_height * .5)) drawNodeName(xx, yy, _s, _panel);
		
		if(attributes.annotation != "") {
			draw_set_text(f_sdf_medium, fa_left, fa_bottom, attributes.annotation_color);
			var _ts = _s * attributes.annotation_size;
			
			BLEND_ADD
			draw_text_ext_transformed(xx, yy - 4  * _s, attributes.annotation, -1, (w + 8) * _s / _ts, _ts, _ts, 0);
			BLEND_NORMAL
		}
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_spr, 1, xx, yy, round(w * _s), round(h * _s), active_draw_index > 1? COLORS.node_border_file_drop : COLORS._main_accent, 1);
			
			if(active_draw_anchor) draw_sprite_stretched_add(bg_spr, 1, xx, yy, round(w * _s), round(h * _s), COLORS._main_accent, 0.5);
			
			active_draw_anchor = false;
			active_draw_index  = -1;
		}
		
		if(draw_droppable) {
			draw_sprite_stretched_ext(THEME.color_picker_box, 0, xx - 2 * _s, yy - 2 * _s, w * _s + 4 * _s, h * _s + 4 * _s, COLORS._main_value_positive, 1);
			
			draw_droppable = false;
		}
		
		if(bg_spr_add > 0) draw_sprite_stretched_add(bg_spr, 1, xx, yy, w * _s, h * _s, bg_spr_add_clr, bg_spr_add);
		
		drawNodeOverlay(xx, yy, _mx, _my, _s);
		
		if(!previewable) return drawJunctions_fast(_draw, xx, yy, _mx, _my, _s);
		return _s > 0.5? drawJunctions(_draw, xx, yy, _mx, _my, _s) : drawJunctions_fast(_draw, xx, yy, _mx, _my, _s);
	}
	
	static drawNodeBehind = function(_x, _y, _mx, _my, _s) {
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		onDrawNodeBehind(_x, _y, _mx, _my, _s);
	}
	
	static onDrawNodeBehind = function(_x, _y, _mx, _my, _s) {}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover = false, _focus = false) {}
	
	static onDrawHover = function(_x, _y, _mx, _my, _s) {}
	
	static drawPreviewBackground = function(_x, _y, _mx, _my, _s) { return false; }
	
	static drawBadge = function(_x, _y, _s) {
		badgePreview = lerp_float(badgePreview, !!previewing, 2);
		badgeInspect = lerp_float(badgeInspect,   inspecting, 2);
		
		if(previewable) {
			var xx = x * _s + _x + w * _s;
			var yy = y * _s + _y;
			
			if(badgePreview > 0) { draw_sprite_ext(THEME.node_state, is_3D? 3 : 0, xx, yy, badgePreview, badgePreview, 0, c_white, 1); 	xx -= 28 * badgePreview;	}
			if(badgeInspect > 0) { draw_sprite_ext(THEME.node_state, 1, xx, yy, badgeInspect, badgeInspect, 0, c_white, 1);				xx -= 28 * badgeInspect;	}
			if(isTool)           { draw_sprite_ext(THEME.node_state, 2, xx, yy, 1, 1, 0, c_white, 1);									xx -= 28 * 2;				}
			
		} else {
			var xx = _x + _s * (x + w - 10);
			var yy = _y + _s *  y;
			
			if(badgePreview > 0) { draw_sprite_ext(THEME.circle_16, 0, xx, yy, .5 * _s, .5 * _s, 0, CDEF.orange); xx -= 12 * _s; }
			if(badgeInspect > 0) { draw_sprite_ext(THEME.circle_16, 0, xx, yy, .5 * _s, .5 * _s, 0, CDEF.lime);   xx -= 12 * _s; }
			if(isTool)           { draw_sprite_ext(THEME.circle_16, 0, xx, yy, .5 * _s, .5 * _s, 0, CDEF.blue);   xx -= 12 * _s; }
		}
		
		inspecting = false;
		previewing = 0;
	}
	
	static drawBranch = function(_depth = 0) {
		if(branch_drawing) return;
		branch_drawing = true;
		
		if(!PREFERENCES.connection_line_highlight_all && _depth == 1) return;
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			if(inputs[i].value_from == noone) continue;
			inputs[i].value_from.node.drawBranch(_depth + 1);
		}
	}
	
	static drawActive = function(_x, _y, _s, ind = 0) {
		active_draw_index = ind; 
		if(display_parameter.highlight) drawBranch();
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static drawPreviewToolOverlay = function(hover, active, _mx, _my, _panel) { return false; }
	
	static drawAnimationTimeline = function(_w, _h, _s) {}
	
	////- PREVIEW
	
	static getPreviewValues = function() {
		if(preview_channel >= array_length(outputs)) return noone;
		
		var _type = outputs[preview_channel].type;
		if(_type != VALUE_TYPE.surface && _type != VALUE_TYPE.dynaSurface)
			return noone;
		
		var val = outputs[preview_channel].getValue();
		if(is_struct(val) && is_instanceof(val, dynaSurf))
			val = array_safe_get_fast(val.surfaces, 0, noone);
		
		return val;
	}
	
	static getPreviewBoundingBox = function() {
		var _surf = getPreviewValues();
		if(is_array(_surf)) 
			_surf = array_safe_get_fast(_surf, preview_index, noone);
		if(!is_surface(_surf)) return noone;
		
		return BBOX().fromWH(preview_x, preview_y, surface_get_width_safe(_surf), surface_get_height_safe(_surf));
	}
	
	////- CACHE
	
	static cacheCheck = function() {
		INLINE
		
		if(cache_group) cache_group.enableNodeGroup();
		if(group != noone) group.cacheCheck();
	}
	
	static getAnimationCacheExist = function(frame) { return cacheExist(frame); }
	
	static clearInputCache = function() {
		for( var i = 0; i < array_length(inputs); i++ )
			inputs[i].cache_value[0] = false;
	}
	
	static cacheArrayCheck = function() {
		cached_output = array_verify(cached_output, TOTAL_FRAMES);
		cache_result  = array_verify(cache_result,  TOTAL_FRAMES);
	}
	
	static cacheCurrentFrame = function(_surface) {
		cacheArrayCheck();
		var _frame = CURRENT_FRAME;
		if(_frame < 0) return;
		if(_frame >= array_length(cached_output)) return;
		
		if(is_array(_surface)) {
			surface_array_free(cached_output[_frame]);
			cached_output[_frame] = surface_array_clone(_surface);
			
		} else if(surface_exists(_surface)) {
			var _sw = surface_get_width(_surface);
			var _sh = surface_get_height(_surface);
			
			cached_output[_frame] = surface_verify(cached_output[_frame], _sw, _sh);
			surface_set_target(cached_output[_frame]);
				DRAW_CLEAR BLEND_OVERRIDE
				draw_surface(_surface, 0, 0);
			surface_reset_target();
		}
		
		array_safe_set(cache_result, _frame, true);
		
		return cached_output[_frame];
	}
	
	static cacheExist = function(frame = CURRENT_FRAME) {
		if(frame < 0) return false;
		
		if(frame >= array_length(cached_output)) return false;
		if(frame >= array_length(cache_result)) return false;
		if(!array_safe_get_fast(cache_result, frame, false)) return false;
		
		var s = array_safe_get_fast(cached_output, frame);
		return is_array(s) || surface_exists(s);
	}
	
	static getCacheFrame = function(frame = CURRENT_FRAME) {
		if(frame < 0) return false;
		
		if(!cacheExist(frame)) return noone;
		var surf = array_safe_get_fast(cached_output, frame);
		return surf;
	}
	
	static recoverCache = function(frame = CURRENT_FRAME) {
		if(!cacheExist(frame)) return false;
		
		var _s = cached_output[CURRENT_FRAME];
		outputs[0].setValue(_s);
			
		return true;
	}
	
	static clearCache = function(_force = false) {
		clearInputCache();
		
		if(!_force) {
			if(!use_cache)          return;
			if(!clearCacheOnChange) return;
			if(!isRenderActive())   return;
		}
		
		if(array_length(cached_output) != TOTAL_FRAMES)
			array_resize(cached_output, TOTAL_FRAMES);
		for(var i = 0; i < array_length(cached_output); i++) {
			var _s = cached_output[i];
			if(is_surface(_s))
				surface_free(_s);
			cached_output[i] = 0;
			cache_result[i] = false;
		}
	}
	
	static clearCacheForward = function() {
		_clearCacheForward(); 
	}
	
	static _clearCacheForward = function() {
		if(!isRenderActive()) return;
		
		clearCache();
		var arr = getNextNodesRaw();
		for( var i = 0, n = array_length(arr); i < n; i++ )
			arr[i]._clearCacheForward();
	}
	
	static cachedPropagate = function(_group = group) {
		if(group != _group) return;
		setRenderStatus(true);
		
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _input = inputs[i];
			if(_input.value_from == noone) continue;
			
			_input.value_from.node.cachedPropagate(_group);
		}
	}
	
	static clearInputCache = function() {
		for( var i = 0; i < array_length(inputs); i++ ) {
			if(!is_instanceof(inputs[i], NodeValue)) continue;
			inputs[i].resetCache();
		}
	}
	
	////- TOOLS
	
	static isUsingTool = function(index = undefined, subtool = noone) {
		if(tools == -1) 
			return false;
		
		var _tool = PANEL_PREVIEW.tool_current;
		if(_tool == noone) //not using any tool
			return false;
		
		if(index == undefined) //using any tool
			return true;
		
		if(is_real(index) && _tool != tools[index])
			return false;
			
		if(is_string(index) && _tool.getName(_tool.selecting) != index)
			return false;
			
		if(subtool == noone)
			return true;
			
		return _tool.selecting == subtool;
	}
	
	static isNotUsingTool = function() { return PANEL_PREVIEW.tool_current == noone; }
	
	static getTool = function() { return self; }
	
	static getToolSettings = function() { return tool_settings; }
	
	static setTool = function(tool) {
		if(!tool) {
			isTool = false;
			return;
		}
		
		for( var i = 0; i < array_length(group.nodes); i++ )
			group.nodes[i].isTool = false;
		
		isTool = true;
	}
	
	static drawTools = noone;
	
	////- SERIALIZE
	
	static serialize = function(scale = false, preset = false) {
		if(!active) return;
		
		var _map = {};
		//print(" > Serializing: " + name);
		
		if(!preset) {
			_map.id	     = node_id;
			_map.name	 = display_name;
			_map.iname	 = internalName;
			_map.x		 = x;
			_map.y		 = y;
			_map.type    = instanceof(self);
			if(isTool)         _map.tool  = isTool;
			if(group != noone) _map.group = group.node_id;
			
			if(!renderActive)  _map.render         = renderActive;
			if(!previewable)   _map.previewable    = previewable;
			if(show_parameter) _map.show_parameter = show_parameter;
		}
		
		var _attr = attributeSerialize();
		var attri = struct_append(variable_clone(attributes), _attr); 
		
		#region attribute stripping // TODO : make it an array
			if(struct_try_get(attri, "color_depth")         == 3)     struct_remove(attri, "color_depth");
			if(struct_try_get(attri, "interpolate")         == 1)     struct_remove(attri, "interpolate");
			if(struct_try_get(attri, "oversample")          == 1)     struct_remove(attri, "oversample");
			if(struct_try_get(attri, "node_width")          == 0)     struct_remove(attri, "node_width");
			if(struct_try_get(attri, "node_height")         == 0)     struct_remove(attri, "node_height");
			if(struct_try_get(attri, "node_param_width")    == 192)   struct_remove(attri, "node_param_width");
			if(struct_try_get(attri, "outp_meta")           == false) struct_remove(attri, "outp_meta");
			
			if(struct_try_get(attri, "annotation")          == "")                       struct_remove(attri, "annotation");
			if(struct_try_get(attri, "annotation_size")     == .4)                       struct_remove(attri, "annotation_size");
			if(struct_try_get(attri, "annotation_color")    == COLORS._main_text_sub)    struct_remove(attri, "annotation_color");
			
			if(struct_try_get(attri, "color")               == -1)    struct_remove(attri, "color");
			if(struct_try_get(attri, "update_graph")        == true)  struct_remove(attri, "update_graph");
			if(struct_try_get(attri, "show_update_trigger") == false) struct_remove(attri, "show_update_trigger");
			if(struct_try_get(attri, "array_process")       == 0)     struct_remove(attri, "array_process");
			
			if(struct_has(attri, "use_project_dimension"))			  struct_remove(attri, "use_project_dimension");
			
			if(struct_names_count(attri)) _map.attri = attri;
		#endregion	
		
		if(is_dynamic_input) {
			_map.input_fix_len  = input_fix_len;
			_map.data_length    = data_length;
		}
		
		var _inputs = [];
		for(var i = 0; i < array_length(inputs); i++)
			array_push(_inputs, inputs[i].serialize(scale, preset));
		_map.inputs = _inputs;
		
		var _outputs = [];
		for(var i = 0; i < array_length(outputs); i++)
			array_push(_outputs, outputs[i].serialize(scale, preset));
		_map.outputs = _outputs;
		
		var _trigger = [];
		array_push(_trigger, inspectInput1.serialize(scale, preset));
		array_push(_trigger, inspectInput2.serialize(scale, preset));
		array_push(_trigger, updatedInTrigger.serialize(scale, preset));
		array_push(_trigger, updatedOutTrigger.serialize(scale, preset));
		
		var _outMeta = [];
		for(var i = 0; i < array_length(junc_meta); i++)
			_outData[i] = junc_meta[i].serialize(scale, preset);
		
		_map.inspectInputs = _trigger;
		if(!array_empty(_outMeta)) _map.outputMeta = _outMeta;
		if(renamed)                _map.renamed    = renamed;
		
		doSerialize(_map);
		processSerialize(_map);
		return _map;
	}
	
	static attributeSerialize = function() { return {}; }
	static doSerialize		  = function(_map) {}
	static processSerialize   = function(_map) {}
	
	////- DESERIALIZE
	
	static deserialize = function(_map, scale = false, preset = false) {
		
		load_map   = _map;
		load_scale = scale;
		renamed    = struct_try_get(load_map, "renamed", false);
		
		preDeserialize();
		
		if(!preset) {
			if(APPENDING) APPEND_MAP[? load_map.id] = node_id;
			else		  node_id = load_map.id;
			
			PROJECT.nodeMap[? node_id] = self;
			
			if(struct_has(load_map, "name"))
				setDisplayName(load_map.name);
			
			internalName = struct_try_get(load_map, "iname", internalName);
			if(internalName == "")
				resetInternalName();
			
			load_group = struct_try_get(load_map, "group", noone);
			if(load_group == -1) load_group = noone;
			
			x = struct_try_get(load_map, "x");
			y = struct_try_get(load_map, "y");
			renderActive   = struct_try_get(load_map, "render", true);
			previewable    = struct_try_get(load_map, "previewable", true);
			isTool         = struct_try_get(load_map, "tool", false);
			show_parameter = struct_try_get(load_map, "show_parameter", false);
		}
		
		if(struct_has(load_map, "attri")) {
			var _lattr = load_map.attri;
			_lattr.color_depth         = struct_try_get(_lattr, "color_depth",             3);
			_lattr.interpolate         = struct_try_get(_lattr, "interpolate",             1);
			_lattr.oversample          = struct_try_get(_lattr, "oversample",              1);
			_lattr.node_width          = struct_try_get(_lattr, "node_width",              0);
			_lattr.node_height         = struct_try_get(_lattr, "node_height",             0);
			_lattr.node_param_width    = struct_try_get(_lattr, "node_param_width",      192);
			_lattr.outp_meta           = struct_try_get(_lattr, "outp_meta",           false);
		
			_lattr.color               = struct_try_get(_lattr, "color",                  -1);
			_lattr.update_graph        = struct_try_get(_lattr, "update_graph",         true);
			_lattr.show_update_trigger = struct_try_get(_lattr, "show_update_trigger", false);
			_lattr.array_process       = struct_try_get(_lattr, "array_process",           0);
			
			attributeDeserialize(CLONING? variable_clone(_lattr) : _lattr);
		}
		
		if(is_dynamic_input) {
			inputBalance();
			inputGenerate();
		}
		
		processDeserialize();
		
		if(preset) {
			postDeserialize();
			applyDeserialize();
			
			triggerRender();
			postLoad();
		}
		
		anim_timeline = struct_try_get(attributes, "show_timeline", false);
		if(anim_timeline) refreshTimeline();
	}
	
	static inputBalance = function() { // Cross-version compatibility for dynamic input nodes
		if(!struct_has(load_map, "data_length")) 
			return;
		
		var _input_fix_len  = load_map.input_fix_len;
		var _data_length    = load_map.data_length;
		var _dynamic_inputs = (array_length(load_map.inputs) - _input_fix_len) / _data_length;
		if(frac(_dynamic_inputs) != 0) {
			var _txt = "LOAD: Uneven dynamic input.";
			logNode(_txt); noti_warning(_txt);
			
			_dynamic_inputs = ceil(_dynamic_inputs);
		}
		
		if(_input_fix_len == input_fix_len && _data_length == data_length) 
			return;
		
		var _pad_dyna = data_length - _data_length;
		
		for( var i = _dynamic_inputs; i >= 1; i-- ) {
			var _ind = _input_fix_len + i * _data_length;
			
			if(_pad_dyna > 0)
				repeat(_pad_dyna) array_insert(load_map.inputs, _ind, noone);
			else
				array_delete(load_map.inputs, _ind + _pad_dyna, -_pad_dyna);
		}
		
		var _pad_fix = input_fix_len - _input_fix_len;
		repeat(_pad_fix) 
			array_insert(load_map.inputs, _input_fix_len, noone);
	}
	
	static inputGenerate = function() { // Generate inputs for dynamic input nodes
		if(createNewInput == noone) 
			return;
		
		var _dynamic_inputs = ceil((array_length(load_map.inputs) - input_fix_len) / data_length);
		repeat(_dynamic_inputs)
			createNewInput();
	}
	
	static attributeDeserialize = function(attr) {
		struct_override(attributes, attr); 
		
		if(!CLONING && LOADING_VERSION < 1_18_02_0) {
			if(struct_has(attributes, "color_depth")) attributes.color_depth += (!array_empty(inputs) && inputs[0].type == VALUE_TYPE.surface)? 1 : 2;
			if(struct_has(attributes, "interpolate")) attributes.interpolate++;
			if(struct_has(attributes, "oversample"))  attributes.oversample++;
		}
	}
	
	static processDeserialize = function() {}
	static preDeserialize     = function() {}
	static postDeserialize    = function() {}
	
	static applyDeserialize = function(preset = false) {
		preApplyDeserialize();
		
		var _inputs = load_map.inputs;
		var amo = min(array_length(inputs), array_length(_inputs));
		
		//print($"Applying deserialzie for {name}");
		
		for(var i = 0; i < amo; i++) {
			if(inputs[i] == noone || _inputs[i] == noone) continue;
			
			//print($"      Apply {i} : {inputs[i].name}");
			inputs[i].applyDeserialize(_inputs[i], load_scale, preset);
		}
		
		if(struct_has(load_map, "outputs")) {
			var _outputs = load_map.outputs;
			var amo = min(array_length(outputs), array_length(_outputs));
			
			for(var i = 0; i < amo; i++) {
				if(outputs[i] == noone) continue;
				
				outputs[i].applyDeserialize(_outputs[i], load_scale, preset);
			}
		}
		
		if(struct_has(load_map, "inspectInputs")) {
			var insInp = load_map.inspectInputs;
			inspectInput1.applyDeserialize(insInp[0], load_scale, preset);
			inspectInput2.applyDeserialize(insInp[1], load_scale, preset);
			
			if(array_length(insInp) > 2) updatedInTrigger.applyDeserialize(insInp[2], load_scale, preset);
			if(array_length(insInp) > 3) updatedOutTrigger.applyDeserialize(insInp[3], load_scale, preset);
		}
		
		if(struct_has(load_map, "outputMeta")) {
			var _outMeta = load_map.outputMeta;
			
			for(var i = 0; i < min(array_length(_outMeta), array_length(junc_meta)); i++)
				junc_meta[i].applyDeserialize(_outMeta[i], load_scale, preset);
		}
		
		//print($"Applying deserialzie for {name} complete");
		
		postApplyDeserialize();
	}
	
	static preApplyDeserialize = function() {}
	static postApplyDeserialize  = function() {}
	
	static loadGroup = function(ctx = noone) { 
		if(load_group == noone) {
			if(ctx) ctx.add(self);
			else    array_push(project.nodes, self);
			onLoadGroup();
			return;
		}
		
		if(APPENDING) load_group = GetAppendID(load_group);
		
		if(ds_map_exists(PROJECT.nodeMap, load_group)) {
			var _grp = PROJECT.nodeMap[? load_group];
			
			if(struct_has(_grp, "add"))
				_grp.add(self);
			else
				throw($"Group load failed. Node ID {load_group} is not a group.");
			
		} else 
			throw($"Group load failed. Can't find node ID {load_group}");
		
		onLoadGroup();
	}
	
	static onLoadGroup = function() {}
	
	static connect = function(log = false) {
		var connected = true;
		for(var i = 0; i < array_length(inputs); i++)
			connected &= inputs[i].connect(log);
		
		inspectInput1.connect(log);
		inspectInput2.connect(log);
		updatedInTrigger.connect(log);
		
		if(!connected) ds_queue_enqueue(CONNECTION_CONFLICT, self);
		refreshTimeline();
		
		return connected;
	}
	
	static preConnect = function() {}
	static postConnect = function() {}
	
	static postLoad = function() {}
	
	////- CLEAN UP
	
	static cleanUp = function() {
		for( var i = 0; i < array_length(inputs);  i++ ) { inputs[i].cleanUp();  delete inputs[i];  }
		for( var i = 0; i < array_length(outputs); i++ ) { outputs[i].cleanUp(); delete outputs[i]; }
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ )
			surface_free(temp_surface[i]);
		
		onCleanUp();
	}
	
	static onCleanUp = function() {}
	
	////- ACTION
	
	static setDimension = function(_w = 128, _h = 128, _apply = true) {
		INLINE
		
		var _oh = con_h;
		min_w = _w; 
		con_h = _h;
		
		if(!_apply) return;
		
		w = max(w, min_w);
		if(_oh != _h) refreshNodeDisplay();
	}
	
	static move = function(_x, _y, _s) {
		if(x == _x && y == _y) return;
		
		x = _x;
		y = _y; 
		if(!LOADING) PROJECT.modified = true;
	}
	
	static enable  = function() { INLINE active = true;  timeline_item.active = true;  }
	static disable = function() { INLINE active = false; timeline_item.active = false; }
	
	static onDestroy = function() {}
	
	static destroy = function(_merge = false, record = true) {
		if(!active) return;
		disable();
		
		array_remove(group == noone? PROJECT.nodes : group.getNodeList(), self);
		
		if(PANEL_GRAPH.node_hover     == self) PANEL_GRAPH.node_hover     = noone;
		array_remove(PANEL_GRAPH.nodes_selecting, self);
		
		if(PANEL_INSPECTOR.inspecting == self) PANEL_INSPECTOR.inspecting = noone;
		
		PANEL_PREVIEW.removeNodePreview(self);
		
		var val_from_map = {};
		for( var i = 0; i < array_length(inputs); i++ ) {
			var _i = inputs[i];
			if(_i.value_from == noone) continue;
			
			val_from_map[$ _i.type] = _i.value_from;
		}
		
		for(var i = 0; i < array_length(outputs); i++) {
			var jun = outputs[i];
			
			for(var j = array_length(jun.value_to) - 1; j >= 0; j--) {
				var _vt = jun.value_to[j];
				
				if(_vt.value_from == noone || _vt.value_from.node != self) 
					continue;
				
				if(_merge && struct_has(val_from_map, _vt.type))
					_vt.setFrom(val_from_map[$ _vt.type]);
				else
					_vt.removeFrom(false);
			}
			
			jun.value_to = [];
		}
		
		for( var i = 0; i < array_length( inputs); i++ )  inputs[i].destroy();
		for( var i = 0; i < array_length(outputs); i++ ) outputs[i].destroy();
		
		onDestroy();
		if(group)  group.refreshNodes();
		if(record) recordAction(ACTION_TYPE.node_delete, self);
		
		RENDER_ALL_REORDER
	}
	
	static onRestore = function() {}
	
	static restore = function() {
		if(active) return;
		enable();
		
		array_push(group == noone? PROJECT.nodes : group.getNodeList(), self);
		
		onRestore();
		if(group) group.refreshNodes();
		
		RENDER_ALL_REORDER
	}
	
	static droppable = function(dragObj) {
		for( var i = 0; i < array_length(inputs); i++ ) {
			if(dragObj.type == inputs[i].drop_key)
				return true;
		}
		return false;
	}
	
	on_drop_file = noone;
	static onDrop = function(dragObj) {
		if(dragObj.type == "Asset" && is_callable(on_drop_file)) {
			on_drop_file(dragObj.data.path);
			return;
		}
		
		for( var i = 0; i < array_length(inputs); i++ ) {
			if(dragObj.type == inputs[i].drop_key) {
				inputs[i].setValue(dragObj.data);
				return;
			}
		}
	}
	
	static dropPath = noone;  
	 
	static clone = function(target = PANEL_GRAPH.getCurrentContext()) {
		CLONING = true;
		var _type = instanceof(self);
		var _node = nodeBuild(_type, x, y, target);
		CLONING = false;
		
		LOADING_VERSION = SAVE_VERSION;
		
		if(!_node) return;
		
		CLONING = true;
		var _nid = _node.node_id;
		_node.deserialize(serialize());
		_node.postDeserialize();
		_node.applyDeserialize();
		_node.node_id = _nid;
		
		PROJECT.nodeMap[? node_id] = self;
		PROJECT.nodeMap[? _nid] = _node;
		CLONING = false;
		refreshTimeline();
		
		onClone(_node, target);
		
		return _node;
	}
	
	static onClone = function(_NewNode, target = PANEL_GRAPH.getCurrentContext()) {}
	
	////- MISC
	
	static isInLoop = function() {
		return array_exists(global.loop_nodes, instanceof(group));
	}
	
	static isTerminal = function() {
		for( var i = 0; i < array_length(outputs); i++ ) {
			var _to = outputs[i].getJunctionTo();
			if(array_length(_to)) return false;
		}
		
		return true;
	}
	
	static resetAnimation = function() {}
	
	static getAttribute = function(_key) {
		var _val = struct_try_get(attributes, _key, 0);
		
		switch(_key) {
			case "interpolate" :
			case "oversample" :
				if(_val == 0 && group != noone) return group.getAttribute(_key);
				return _val;
		}
		
		return _val;
	}
	
	static attrDepth = function() {
		var form = -1;
		
		if(struct_has(attributes, "color_depth")) {
			form = global.SURFACE_FORMAT[attributes.color_depth];
			if(form >= 0) return form;
		}
		
		if(form == -1) { // input
			var _s = getInputData(0);
			while(is_array(_s) && array_length(_s)) _s = _s[0];
			if(is_surface(_s)) return surface_get_format(_s);
		}
		
		if(form == -2 && group != noone) // group
			return group.attrDepth();
		
		return surface_rgba8unorm;
	}
	
	static checkGroup = function() {
		
		for( var i = 0, n = array_length(attributeEditors); i < n; i++ ) {
			var _att = attributeEditors[i];
			if(!is_array(_att)) continue;
			
			var _wid = _att[2];
			if(!is(_wid, scrollBox)) continue;
			
			var _key = array_safe_get(_att, 3, "");
			var _l   = _wid.data_list;
			
			for( var j = 0, m = array_length(_l); j < m; j++ ) {
				var _scl = _l[j];
				if(!is(_scl, scrollItem)) continue;
				if(_scl.name != "Group")  continue;
				
				_scl.active = group != noone;
				if(!_scl.active && attributes[$ _key] == j) attributes[$ _key] = _att[0] == "Color depth"? 3 : 1;
				break;
			}
		}
		
	} run_in(1, function() /*=>*/ { checkGroup(); });
	
	nextn = [];
	static generateNodeRenderReport = function() {
		var _report = {};
		
		_report.search_res = true;
		_report.type = "render";
		_report.node = self;
		_report.inputs  = array_create(array_length(inputs));
		for( var i = 0, n = array_length(inputs); i < n; i++ ) {
			var _j = inputs[i];
			_report.inputs[i] = _j.getValue();
			
			if(_j.type == VALUE_TYPE.surface)
				_report.inputs[i] = surface_array_clone(_report.inputs[i]);
		}
		
		_report.outputs = array_create(array_length(outputs));
		for( var i = 0, n = array_length(outputs); i < n; i++ ) {
			var _j = outputs[i];
			_report.outputs[i] = _j.getValue();
			
			if(_j.type == VALUE_TYPE.surface)
				_report.outputs[i] = surface_array_clone(_report.outputs[i]);
		}
		
		_report.logs  = array_clone(messages_dbg);
		
		_report.nextn = nextn;
		_report.queue = array_clone(RENDER_QUEUE.data, 1);
		
		nextn = [];
		
		return _report;
	}
	
	static summarizeReport = function(_startTime) {
		var _srcstr = $"{getFullName()}";
		var _report = generateNodeRenderReport();
		
		for( var i = 0, n = array_length(_report.nextn); i < n; i++ ) _srcstr += $"{_report.nextn[i].getFullName()}";
		for( var i = 0, n = array_length(_report.queue); i < n; i++ ) _srcstr += $"{_report.queue[i].getFullName()}";
		
		_report.time          = get_timer() - _startTime;
		_report.renderTime    = render_time;
		_report.search_string = _srcstr;
		array_push(PROFILER_DATA, _report);
	}
	
	static toString = function() { return $"Node [{internalName}] [{instanceof(self)}]: {node_id}"; }
}