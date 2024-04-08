global.loop_nodes = [ "Node_Iterate", "Node_Iterate_Each" ];

#macro INAME internalName == ""? name : internalName
#macro NODE_HAS_INSP1 (onInspector1Update != noone)
#macro NODE_HAS_INSP2 (onInspector2Update != noone)

enum CACHE_USE {
	none,
	manual,
	auto
}

enum DYNA_INPUT_COND {
	connection = 1 << 0,
	zero       = 1 << 1,
}

function Node(_x, _y, _group = noone) : __Node_Base(_x, _y) constructor {
	
	#region ---- main & active ----
		active       = true;
		renderActive = true;
	
		node_id = UUID_generate();
		group   = _group;
		manual_deletable	 = true;
		manual_ungroupable	 = true;
		destroy_when_upgroup = false;
		
		var l = _group == noone? PROJECT.nodes : _group.getNodeList();
		ds_list_add(l, self);
		
		active_index = -1;
		active_range = [ 0, TOTAL_FRAMES - 1 ];
		
		array_push(PROJECT.nodeArray, self);
		
		inline_context = noone;
	#endregion
	
	static resetInternalName = function() { #region
		var str = string_replace_all(name, " ", "_");
			str = string_replace_all(str,  "/", "");
			str = string_replace_all(str,  "-", "");
		
		ds_map_delete(PROJECT.nodeNameMap, internalName);
		internalName = str + string(irandom_range(10000, 99999)); 
		PROJECT.nodeNameMap[? internalName] = self;
	} #endregion
	
	if(!LOADING && !APPENDING) { #region
		recordAction(ACTION_TYPE.node_added, self);
		PROJECT.nodeMap[? node_id] = self;
		PROJECT.modified = true;
		
		run_in(1, function() { 
			resetInternalName();
			
			if(renamed) return;
			display_name = __txt_node_name(instanceof(self), name);
			if(!LOCALE_DEF || TESTING) renamed = true;
		});
		
		RENDER_ALL_REORDER
	} #endregion
	
	#region ---- display ----
		color   = c_white;
		icon    = noone;
		icon_24 = noone;
		bg_spr  = THEME.node_bg;
		bg_sel_spr	  = THEME.node_active;
	
		name = "";
		display_name = "";
		internalName = "";
		onSetDisplayName = noone;
		renamed = false;
		
		tooltip = "";
		x = _x;
		y = _y;
	
		w = 128;
		h = 128;
		min_w = w;
		min_h = h;
		fix_h = h;
		will_setHeight = false;
		
		selectable   = true;
		draw_padding = 4;
		auto_height  = true;
		
		display_parameter = new connectionParameter();
		
		draw_name = true;
		draggable = true;
		
		draw_boundary     = [ 0, 0, 0, 0 ];
		draw_graph_culled = false;
		
		badgePreview = 0;
		badgeInspect = 0;
		
		active_draw_index = -1;
		
		draw_droppable = false;
		
		junction_draw_pad_y = 32;
		junction_draw_hei_y = 24;
		
		branch_drawing = false;
	#endregion
	
	#region ---- junctions ----
		inputs    = ds_list_create();
		outputs   = ds_list_create();
		inputMap  = ds_map_create();
		outputMap = ds_map_create();
		input_value_map = {};
		
		use_display_list		= true;
		input_display_list		= -1;
		output_display_list		= -1;
		inspector_display_list	= -1;
		is_dynamic_output		= false;
		
		inspectInput1 = nodeValue("Toggle execution", self, JUNCTION_CONNECT.input, VALUE_TYPE.action, false).setVisible(true, true);
		inspectInput2 = nodeValue("Toggle execution", self, JUNCTION_CONNECT.input, VALUE_TYPE.action, false).setVisible(true, true);
		
		inspectInput1.index = -1;
		inspectInput2.index = -1;
		
		autoUpdatedTrigger = true;
		updatedInTrigger   = nodeValue("Update",  self, JUNCTION_CONNECT.input,  VALUE_TYPE.trigger, false).setVisible(true, true);
		updatedOutTrigger  = nodeValue("Updated", self, JUNCTION_CONNECT.output, VALUE_TYPE.trigger, false).setVisible(true, true);
		
		updatedInTrigger.index  = -1;
		updatedOutTrigger.index = -1;
		
		updatedInTrigger.tags  = VALUE_TAG.updateInTrigger;
		updatedOutTrigger.tags = VALUE_TAG.updateOutTrigger;
		
		insp1UpdateActive   = true;
		insp1UpdateTooltip  = __txtx("panel_inspector_execute", "Execute node");
		insp1UpdateIcon     = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
		
		insp2UpdateActive   = true;
		insp2UpdateTooltip = __txtx("panel_inspector_execute", "Execute node");
		insp2UpdateIcon    = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
		
		is_dynamic_input  = false;
		auto_input		  = false;
		input_display_len = 0;
		input_fix_len	  = 0;
		data_length       = 1;
		inputs_data		  = [];
		input_hash		  = "";
		input_hash_raw	  = "";
		
		inputs_amount    = 0;
		inputs_index     = [];
		in_cache_len     = 0;
		inputDisplayList = [];
		
		outputs_amount = 0;
		outputs_index  = [];
		out_cache_len  = 0;
		
		input_buttons       = [];
		input_button_length = 0;
		
		run_in(1, function() {
			input_buttons = [];
			
			for( var i = 0; i < ds_list_size(inputs); i++ ) {
				var _in = inputs[| i];
				if(!is_instanceof(_in, NodeValue)) continue;
				if(_in.type != VALUE_TYPE.trigger) continue;
				
				if(_in.runInUI) array_push(input_buttons, _in);
			}
			
			input_button_length = array_length(input_buttons);
		});
	#endregion
	
	#region --- attributes ----
		attributes.node_param_width = PREFERENCES.node_param_width;
		attributes.node_width  = 0;
		attributes.node_height = 0;
		
		attributeEditors = [
			"Display",
			["Params Width", function() { return attributes.node_param_width; }, new textBox(TEXTBOX_INPUT.number, function(val) { attributes.node_param_width = val; refreshNodeDisplay(); }) ],
			
			"Node update",
			["Auto update", function() { return attributes.update_graph; }, new checkBox(function() { attributes.update_graph = !attributes.update_graph; }) ],
			["Update trigger", function() { return attributes.show_update_trigger; }, new checkBox(function() { attributes.show_update_trigger = !attributes.show_update_trigger; }) ],
		];
		
		bufferStore = {};
	#endregion
	
	#region ---- preview ----
		show_parameter = PREFERENCES.node_param_show;
		
		show_input_name  = false;
		show_output_name = false;
	
		inspecting	  = false;
		previewing	  = 0;
		
		preview_surface	= noone;
		preview_amount  = 0;
		previewable		= true;
		preview_draw    = true;
		preview_speed	= 0;
		preview_index	= 0;
		preview_channel = 0;
		preview_alpha	= 1;
		preview_x		= 0;
		preview_y		= 0;
		
		preview_mx = 0;
		preview_my = 0;
		
		graph_preview_alpha	= 1;
		
		getPreviewingNode = noone;
		
		preview_value = 0;
		preview_array = "";
	#endregion
	
	#region ---- rendering ----
		rendered         = false;
		update_on_frame  = false;
		render_time		 = 0;
		render_cached    = false;
		auto_render_time = true;
		updated			 = false;
		passiveDynamic   = false;
		topoSorted		 = false;
		temp_surface     = [];
		force_requeue    = false;
		is_simulation    = false;
		
		in_VFX = false;
		
		is_group_io = false;
	#endregion
	
	#region ---- timeline ----
		timeline_item    = new timelineItemNode(self);
		anim_priority    = ds_map_size(PROJECT.nodeMap);
		is_anim_timeline = false;
	#endregion
	
	#region ---- notification ----
		value_validation = array_create(3);
	
		manual_updated		 = false;
	#endregion
	
	#region ---- tools ----
		tools			= -1;
		isTool			= false;
		tool_settings	= [];
		tool_attribute	= {};
	#endregion
	
	#region ---- 3d ----
		is_3D = false;
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
		messages = [];
	#endregion
	
	static createNewInput = noone;
	
	static initTooltip = function() { #region
		if(IS_CMD) return;
		
		var type_self = instanceof(self);
		if(!struct_has(global.NODE_GUIDE, type_self)) return;
		
		var _n = global.NODE_GUIDE[$ type_self];
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
	} #endregion
	run_in(1, initTooltip);
	
	static resetDefault = function() { #region
		var folder = instanceof(self);
		if(!ds_map_exists(global.PRESETS_MAP, folder)) return;
		
		var pres = global.PRESETS_MAP[? folder];
		for( var i = 0, n = array_length(pres); i < n; i++ ) {
			var preset = pres[i];
			if(preset.name != "_default") continue;
			
			deserialize(preset.content, true, true);
			applyDeserialize(true);
		}
		
		doUpdate();
	} #endregion
	if(!APPENDING && !LOADING)
		run_in(1, method(self, resetDefault));
	
	static getInputJunctionIndex = function(index) { #region
		INLINE 
		
		if(input_display_list == -1 || !use_display_list)
			return index;
		
		var jun_list_arr = input_display_list[index];
		if(is_array(jun_list_arr))  return noone;
		if(is_struct(jun_list_arr)) return noone;
		
		return jun_list_arr;
	} #endregion
	
	static getOutputJunctionIndex = function(index) { #region
		if(output_display_list == -1)
			return index;
		return output_display_list[index];
	} #endregion
	
	static updateIO = function() { #region
		for( var i = 0, n = ds_list_size(inputs); i < n; i++ )
			inputs[| i].visible_in_list = false;
		
		inputs_amount = (input_display_list == -1 || !use_display_list)? ds_list_size(inputs) : array_length(input_display_list);
		inputs_index  = [];
		
		for( var i = 0; i < inputs_amount; i++ ) {
			var _input = getInputJunctionIndex(i);
			if(_input == noone) continue;
			
			var _inp = inputs[| _input];
			if(!is_struct(_inp) || !is_instanceof(_inp, NodeValue)) continue;
			
			array_push(inputs_index, _input);
			_inp.visible_in_list = true;
		}
		inputs_amount = array_length(inputs_index);
		
		outputs_amount = output_display_list == -1? ds_list_size(outputs) : array_length(output_display_list);
		outputs_index  = array_create_ext(outputs_amount, function(index) { return getOutputJunctionIndex(index); });
	} #endregion
	
	static setDimension = function(_w = 128, _h = 128, _apply = true) { #region
		INLINE
		
		min_w = _w; 
		min_h = _h; 
		
		if(_apply) {
			w = _w;
			h = _h;
		}
	} #endregion
	
	static setHeight = function() { #region
		w = show_parameter? attributes.node_param_width : min_w;
		
		if(!auto_height) return;
		junction_draw_hei_y = show_parameter? 32 : 24;
		junction_draw_pad_y = show_parameter? min_h : 32;
		
		var _hi = junction_draw_pad_y + show_parameter * 4;
		var _ho = junction_draw_pad_y + show_parameter * 4;
		
		var _prev_surf = previewable && preview_draw && 
			(	is_surface(getGraphPreviewSurface()) || 
				(preview_channel >= 0 && preview_channel < ds_list_size(outputs) && outputs[| preview_channel].type == VALUE_TYPE.surface)
			);
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			var _inp = inputs[| i];
			if(is_instanceof(_inp, NodeValue) && _inp.isVisible()) 
				_hi += junction_draw_hei_y;
		}
		
		for( var i = 0; i < ds_list_size(outputs); i++ )
			if(outputs[| i].isVisible()) _ho += junction_draw_hei_y;
		
		h     = max(min_h, _prev_surf * 128, _hi, _ho, attributes.node_height);
		fix_h = h;
		
	} #endregion
	
	static setDisplayName = function(_name) { #region
		renamed = true;
		display_name = _name;
		internalName = string_replace_all(display_name, " ", "_");
		refreshNodeMap();
		
		if(onSetDisplayName != noone)
			onSetDisplayName();
		
		return self;
	} #endregion
	
	static setIsDynamicInput = function(_data_length = 1, _auto_input = true, _dynamic_input_cond = DYNA_INPUT_COND.connection) { #region
		is_dynamic_input	= true;						
		auto_input			= _auto_input;
		input_display_len	= input_display_list == -1? 0 : array_length(input_display_list);
		input_fix_len		= ds_list_size(inputs);
		data_length			= _data_length;
		
		dynamic_input_cond  = _dynamic_input_cond;
	} #endregion
	
	static createNewInput = -1;
	
	static refreshDynamicInput = function() { #region
		var _in = ds_list_create();
		
		for( var i = 0; i < input_fix_len; i++ )
			ds_list_add(_in, inputs[| i]);
		
		array_resize(input_display_list, input_display_len);
		
		for( var i = input_fix_len; i < ds_list_size(inputs); i += data_length ) {
			var _active = false;
			if(dynamic_input_cond & DYNA_INPUT_COND.connection)
				_active |= inputs[| i].value_from != noone;
			if(dynamic_input_cond & DYNA_INPUT_COND.zero) {
				var _val = inputs[| i].getValue();
				_active |= _val != 0 || _val != "";
			}
			
			if(_active) {
				for( var j = 0; j < data_length; j++ ) {
					ds_list_add(_in, inputs[| i + j]);
					array_push(input_display_list, i + j);
				}
			} else {
				for( var j = 0; j < data_length; j++ )
					delete inputs[| i + j];
			}
		}
		
		for( var i = 0; i < ds_list_size(_in); i++ )
			_in[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _in;
		
		createNewInput();
	} #endregion
	
	static getOutput = function(junc = noone) { #region
		for( var i = 0; i < ds_list_size(outputs); i++ ) {
			if(!outputs[| i].visible) continue;
			if(junc != noone && !junc.isConnectable(outputs[| i], true)) continue;
			
			return outputs[| i];
		}
		return noone;
	} #endregion
	
	static getInput = function(junc = noone, shift = input_fix_len) { #region
		for( var i = shift; i < ds_list_size(inputs); i++ ) {
			if(!inputs[| i].visible) continue;
			if(inputs[| i].value_from != noone) continue;
			if(junc != noone && !inputs[| i].isConnectable(junc, true)) continue;
			
			return inputs[| i];
		}
		return noone;
	} #endregion
	
	static getFullName = function() { #region
		INLINE
		return renamed? "[" + name + "] " + display_name : name;
	} #endregion
	
	static getDisplayName = function() { #region
		INLINE
		return renamed? display_name : name;
	} #endregion
	
	static addInput = function(junctionFrom, shift = input_fix_len) { #region
		var targ = getInput(junctionFrom, shift);
		if(targ == noone) return;
		
		targ.setFrom(junctionFrom);
	} #endregion
	
	static isActiveDynamic = function(frame = CURRENT_FRAME) { #region
		if(update_on_frame) return true;
		if(!rendered)       return true;
		
		force_requeue = false;
		for(var i = 0; i < ds_list_size(inputs); i++)
			if(inputs[| i].isActiveDynamic(frame)) return true;
		
		return false;
	} #endregion
	
	static isInLoop = function() { #region
		return array_exists(global.loop_nodes, instanceof(group));
	} #endregion
	
	static move = function(_x, _y, _s) { #region
		if(x == _x && y == _y) return;
		
		x = _x;
		y = _y; 
		if(!LOADING) PROJECT.modified = true;
	} #endregion
	
	#region ++++ inspector update ++++
		static onInspector1Update  = noone;
		static inspector1Update    = function() { INLINE onInspector1Update(); }
		static hasInspector1Update = function() { INLINE return NODE_HAS_INSP1; }
	
		static onInspector2Update  = noone;
		static inspector2Update    = function() { INLINE onInspector2Update(); }
		static hasInspector2Update = function() { INLINE return NODE_HAS_INSP2; }
	#endregion
	
	static stepBegin = function() { #region
		if(use_cache) cacheArrayCheck();
		
		doStepBegin();
		
		if(NODE_HAS_INSP1) inspectInput1.name = insp1UpdateTooltip;
		if(NODE_HAS_INSP2) inspectInput2.name = insp2UpdateTooltip;
		
		if(attributes.show_update_trigger) {
			if(updatedInTrigger.getValue()) { 
				getInputs();
				update();
			
				updatedInTrigger.setValue(false);
			}
			updatedOutTrigger.setValue(false);
		}
		
		if(will_setHeight) {
			setHeight();
			will_setHeight = false;
		}
		
		if(is_3D) USE_DEPTH = true;
		if(is_simulation) PROJECT.animator.is_simulating = true;
	} #endregion
	
	static doStepBegin = function() {}
	
	static triggerCheck = function() { #region
		var i = 0;
		
		repeat( input_button_length ) {
			var _in = input_buttons[i++];
			
			if(_in.getStaticValue()) {
				_in.editWidget.onClick();
				_in.setValue(false);
			}
		}
		
		if(NODE_HAS_INSP1 && inspectInput1.getStaticValue()) {
			onInspector1Update();
			inspectInput1.setValue(false);
		}
		
		if(NODE_HAS_INSP2 && inspectInput2.getStaticValue()) {
			onInspector2Update();
			inspectInput2.setValue(false);
		}
	} #endregion
	
	static step = function() {}
	static focusStep = function() {}
	static inspectorStep = function() {}
	
	static getInputData = function(index, def = 0) { #region
		INLINE
		
		return array_safe_get_fast(inputs_data, index, def);
	} #endregion
	
	static setInputData = function(index, value) { #region
		INLINE
		
		inputs_data[index] = value;
		input_value_map[$ inputs[| index].internalName] = value;
	} #endregion
	
	static getInputs = function(frame = CURRENT_FRAME) { #region
		inputs_data	= array_verify(inputs_data, ds_list_size(inputs));
		
		for(var i = 0; i < ds_list_size(inputs); i++) {
			if(!is_instanceof(inputs[| i], NodeValue)) continue;
			
			var val = inputs[| i].getValue(frame);
			setInputData(i, val);
		}
	} #endregion
	
	static forceUpdate = function() { #region
		input_hash = "";
		doUpdate();
	} #endregion
	
	static postUpdate = function(frame = CURRENT_FRAME) {}
	
	static doUpdate = function(frame = CURRENT_FRAME) { #region
		if(PROJECT.safeMode) return;
		if(NODE_EXTRACT)     return;
		
		var render_timer = get_timer();
		
		if(cached_manual || (use_cache == CACHE_USE.auto && recoverCache())) {
			render_cached = true;
			
			if(!is_instanceof(self, Node_Collection)) setRenderStatus(true);
		} else {
			render_cached = false;
			getInputs(frame);
			
			LOG_BLOCK_START();
			LOG_IF(global.FLAG.render == 1, $">>>>>>>>>> DoUpdate called from {INAME} <<<<<<<<<<");
			
			if(!is_instanceof(self, Node_Collection)) setRenderStatus(true);
			var sBase = surface_get_target();	
			
			try {
				update(frame);
			} catch(exception) {
				var sCurr = surface_get_target();
				while(surface_get_target() != sBase)
					surface_reset_target();
			
				log_warning("RENDER", exception_print(exception), self);
			}
		}
		
		postUpdate(frame);
		cached_manual = false;
		
		if(!use_cache && PROJECT.onion_skin.enabled) {
			for( var i = 0; i < ds_list_size(outputs); i++ ) {
				if(outputs[| i].type != VALUE_TYPE.surface) continue;
				cacheCurrentFrame(outputs[| i].getValue());
				break;
			}
		}
		
		if(NODE_HAS_INSP1 && inspectInput1.getValue()) onInspector1Update();
		if(NODE_HAS_INSP2 && inspectInput2.getValue()) onInspector2Update();
		
		updatedOutTrigger.setValue(true);
		
		if(!is_instanceof(self, Node_Collection)) 
			render_time = get_timer() - render_timer;
		
		refreshNodeDisplay();
		LOG_BLOCK_END();
	} #endregion
	
	static cacheCheck = function() { #region
		INLINE
		
		if(cache_group) cache_group.enableNodeGroup();
		if(group != noone) group.cacheCheck();
	} #endregion
	
	static valueUpdate = function(index) { #region
		
		onValueUpdate(index);
		
		if(is_dynamic_input) will_setHeight = true;
		cacheCheck();
	} #endregion
	
	static valueFromUpdate = function(index) { #region
		onValueFromUpdate(index);
		
		if(is_dynamic_input) will_setHeight = true;
		cacheCheck();
	} #endregion
	
	static onValueUpdate = function(index = 0) {}
	static onValueFromUpdate = function(index) {}
	
	static triggerRender = function() { #region
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"Trigger render for {self}");
		
		resetRender(false);
		RENDER_PARTIAL
		
		if(is_instanceof(group, Node_Collection)) {
			group.triggerRender();
		} else {
			
			var nodes = getNextNodesRaw();
			for(var i = 0; i < array_length(nodes); i++)
				nodes[i].triggerRender();
		}
		
		LOG_BLOCK_END();
	} #endregion
	
	static clearTopoSorted = function() { INLINE topoSorted = false; }
	
	static forwardPassiveDynamic = function() { #region
		rendered = false;
		
		for( var i = 0, n = ds_list_size(outputs); i < n; i++ ) {
			var _outp = outputs[| i];
			
			for(var j = 0; j < array_length(_outp.value_to); j++) {
				var _to = _outp.value_to[j];
				if(!_to.node.active || _to.value_from != _outp) continue; 
				
				//LOG_IF(global.FLAG.render == 1, $"|| Forwarding dynamic to {_to.node.name} ||");
				_to.node.passiveDynamic = true;
				_to.node.rendered = false;
			}
		}
	} #endregion
	
	static resetRender = function(_clearCache = false) {  #region
		setRenderStatus(false); 
		if(_clearCache) clearInputCache();
	} #endregion
	
	static isLeaf = function() { #region
		INLINE 
		
		for( var i = 0, n = ds_list_size(inputs); i < n; i++ ) {
			var _inp = inputs[| i];
			if(!_inp.isLeaf()) return false;
		}
		
		return true;
	} #endregion
	
	static isLeafList = function(list = noone) { #region
		INLINE 
		
		if(list == noone) return isLeaf();
		
		for( var i = 0, n = ds_list_size(inputs); i < n; i++ ) {
			var _inp = inputs[| i];
			if(!_inp.isLeafList(list)) return false;
		}
		
		return true;
	} #endregion
	
	static isRenderActive = function() { return renderActive || (PREFERENCES.render_all_export && IS_RENDERING); }
	
	static isRenderable = function(log = false) { #region //Check if every input is ready (updated)
		if(!active)	return false;
		if(!isRenderActive()) return false;
		
		for(var j = 0; j < ds_list_size(inputs); j++)
			if(!inputs[| j].isRendered()) return false;
		
		return true;
	} #endregion
	
	static setRenderStatus = function(result) { #region
		INLINE
		
		if(rendered == result) return;
		LOG_LINE_IF(global.FLAG.render == 1, $"Set render status for {self} : {result}");
		
		rendered = result;
	} #endregion
	
	static getPreviousNodes = function() { #region
		var prev = [];
		
		for( var i = 0, n = ds_list_size(inputs); i < n; i++ ) {
			var _in = inputs[| i];
			
			if(_in.value_from != noone) {
				if(in_VFX && !_in.value_from.node.in_VFX) {
					array_push(in_VFX.prev_nodes, _in.value_from.node);
					array_push(prev, in_VFX);
					continue;
				}
				
				array_push_unique(prev, _in.value_from.node);
			}
				
			if(_in.value_from_loop != noone)
				array_push_unique(prev, _in.value_from_loop);
		}
		
		onGetPreviousNodes(prev);
		return prev;
	} #endregion
	
	static onGetPreviousNodes = function(arr) {}
	
	static getNextNodes = function() { #region
		var nodes = [];
		var nodeNames = [];
		
		LOG_BLOCK_START();
		LOG_IF(global.FLAG.render == 1, $"→→→→→ Call get next node from: {INAME}");
		LOG_BLOCK_START();
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var _ot = outputs[| i];
			if(!_ot.forward)				continue;
			
			for( var j = 0, n = array_length(_ot.value_to_loop); j < n; j++ ) {
				var _to = _ot.value_to_loop[j];
				if(!_to.active) continue; 
				if(!_to.bypassNextNode()) continue;
				
				LOG_BLOCK_END();
				LOG_BLOCK_END();
		
				return _to.getNextNodes();
			}
		
			var _tos = _ot.getJunctionTo();
			for( var j = 0; j < array_length(_tos); j++ ) {
				var _to = _tos[j];
				
				array_push(nodes, _to.node);
				array_push(nodeNames, _to.node.internalName);
				
				//LOG_IF(global.FLAG.render == 1, $"→→ Check output: {_ot.name} connect to node {_to.node.internalName}");
			}
		}	
		
		LOG_IF(global.FLAG.render == 1, $"→→ Push {nodeNames} to queue.");
		
		LOG_BLOCK_END();
		LOG_BLOCK_END();
		return nodes;
	} #endregion
	
	static getNextNodesRaw = function() { #region
		var nodes = [];
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var _ot = outputs[| i];
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
		
		return nodes;
	} #endregion
	
	static isTerminal = function() { #region
		for( var i = 0; i < ds_list_size(outputs); i++ ) {
			var _to = outputs[| i].getJunctionTo();
			if(array_length(_to)) return false;
		}
		
		return true;
	} #endregion
	
	static onInspect = function() {}
	
	static pointIn = function(_x, _y, _mx, _my, _s) { #region
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		return point_in_rectangle(_mx, _my, xx, yy, xx + w * _s, yy + h * _s);
	} #endregion
	
	static cullCheck = function(_x, _y, _s, minx, miny, maxx, maxy) { #region
		var x0 = x * _s + _x;
		var y0 = y * _s + _y;
		var x1 = (x + w) * _s + _x;
		var y1 = (y + h) * _s + _y;
		
		draw_boundary[0] = minx;
		draw_boundary[1] = miny;
		draw_boundary[2] = maxx;
		draw_boundary[3] = maxy;
		
		draw_graph_culled = !rectangle_in_rectangle(minx, miny, maxx, maxy, x0, y0, x1, y1);
	} #endregion
	
	static refreshNodeDisplay = function() { #region
		INLINE
		
		updateIO();
		setHeight();
		getJunctionList();
	} run_in(1, function() { refreshNodeDisplay(); }); #endregion
	
	static getJunctionList = function() { #region
		var amo = input_display_list == -1? ds_list_size(inputs) : array_length(input_display_list);
		inputDisplayList = [];
		
		for(var i = 0; i < amo; i++) {
			var ind = getInputJunctionIndex(i);
			if(ind == noone) continue;
			
			var jun = ds_list_get(inputs, ind, noone);
			if(jun == noone || is_undefined(jun)) continue;
			if(!jun.isVisible()) continue;
			
			array_push(inputDisplayList, jun);
		}
	}#endregion
	
	static preDraw = function(_x, _y, _s) { #region
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		var jun;
		
		var inspCount = NODE_HAS_INSP1 + NODE_HAS_INSP2;
		var ind = 1;
		if(NODE_HAS_INSP1) {
			inspectInput1.x = xx + w * _s * ind / (inspCount + 1);
			inspectInput1.y = yy;
			ind++;
		}
		
		if(NODE_HAS_INSP2) {
			inspectInput2.x = xx + w * _s * ind / (inspCount + 1);
			inspectInput2.y = yy;
			ind++;
		}
		
		updatedInTrigger.x = xx;
		updatedInTrigger.y = yy + 10;
		
		updatedOutTrigger.x = xx + w * _s;
		updatedOutTrigger.y = yy + 10;
		
		if(in_cache_len != array_length(inputDisplayList) || out_cache_len != ds_list_size(outputs)) {
			refreshNodeDisplay();
			
			in_cache_len  = array_length(inputDisplayList);
			out_cache_len = ds_list_size(outputs);
		}
			
		var _iny = yy + (junction_draw_pad_y + junction_draw_hei_y * 0.5 * show_parameter) * _s;
		
		for( var i = 0, n = ds_list_size(inputs); i < n; i++ ) {
			jun = inputs[| i];
			jun.x = xx;
			jun.y = _iny;
		}
		
		for(var i = 0; i < in_cache_len; i++) {
			jun = inputDisplayList[i];
			
			jun.x = xx;
			jun.y = _iny;
			_iny += junction_draw_hei_y * _s;
		}
		
		xx = xx + w * _s;
		var _outy = yy + (junction_draw_pad_y + junction_draw_hei_y * 0.5 * show_parameter) * _s;
		
		for(var i = 0; i < outputs_amount; i++) {
			var idx = outputs_index[i];
			jun = outputs[| idx];
			
			jun.x = xx;
			jun.y = _outy;
			_outy += junction_draw_hei_y * _s * jun.isVisible();
		}
		
		onPreDraw(_x, _y, _s, _iny, _outy);
	} #endregion
	
	static onPreDraw = function(_x, _y, _s, _iny, _outy) {}
	
	static isHighlightingInGraph = function() { #region
		var  high = display_parameter.highlight;
		var _selc = active_draw_index == 0 || branch_drawing;
		return !high || _selc;
	} #endregion
	
	static getColor = function() { #region
		INLINE
		return attributes.color == -1? color : attributes.color;
	} #endregion
	
	static drawNodeBase = function(xx, yy, _s) { #region
		if(draw_graph_culled) return;
		if(!active) return;
		
		var aa = 0.25 + 0.5 * renderActive;
		if(!isHighlightingInGraph()) aa *= 0.25;
		var cc = getColor();
		
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w * _s, h * _s, cc, aa);
	} #endregion 
	
	__draw_bbox = BBOX();
	static drawGetBbox = function(xx, yy, _s) { #region
		var pad_label = draw_name && display_parameter.avoid_label;
		
		var _w = w;
		var _h = show_parameter? min_h : h;
		
		_w *= _s;
		_h *= _s;
		
		_w -= draw_padding * 2;
		_h -= draw_padding * 2 + 20 * pad_label;
		
		var _xc = xx +  w * _s / 2;
		var _yc = yy + _h / 2 + pad_label * 20 + draw_padding;
		
		_w *= display_parameter.preview_scale / 100;
		_h *= display_parameter.preview_scale / 100;
		
		var x0 = _xc - _w / 2;
		var x1 = _xc + _w / 2;
		var y0 = _yc - _h / 2;
		var y1 = _yc + _h / 2;
		
		return __draw_bbox.fromPoints(x0, y0, x1, y1);
	} #endregion
	
	static drawNodeName = function(xx, yy, _s) { #region
		
		var _name = renamed? display_name : name;
		if(_name == "") return;
		
		draw_name = true;
		
		var aa = 0.25 + 0.5 * renderActive;
		if(!isHighlightingInGraph()) aa *= 0.25;
		var cc = getColor();
		
		draw_sprite_stretched_ext(THEME.node_bg_name, 0, xx, yy, w * _s, ui(20), cc, aa);
		
		var cc = COLORS._main_text;
		if(PREFERENCES.node_show_render_status && !rendered)
			cc = isRenderable()? COLORS._main_value_positive : COLORS._main_value_negative;
		
		draw_set_text(f_p1, fa_left, fa_center, cc);
		
		if(NODE_HAS_INSP1) icon = THEME.refresh_16;
		var ts = clamp(power(_s, 0.5), 0.5, 1);
		
		var aa = 0.5 + 0.5 * renderActive;
		if(!isHighlightingInGraph()) aa *= 0.25;
		
		draw_set_alpha(aa);
		
		if(icon && _s > 0.75) {
			draw_sprite_ui_uniform(icon, 0, xx + ui(12), yy + ui(10),,, aa);	
			draw_text_cut(round(xx + ui(24)), round(yy + ui(10)), _name, w * _s - ui(24), ts);
		} else
			draw_text_cut(round(xx + ui(8)), round(yy + ui(10)), _name, w * _s - ui(8), ts);
			
		draw_set_alpha(1);
	} #endregion
	
	static drawJunctionWidget = function(_x, _y, _mx, _my, _s, _hover, _focus) { #region
		
		var hover = noone;
		
		var wh = junction_draw_hei_y * _s;
		var ww = w * _s * 0.5;
		var wt = w * _s * 0.25;
		var wx = _x + w * _s - ww - 8;
		var lx = _x + 12 * _s;
		
		var _m = [ _mx, _my ];
		var rx = PANEL_GRAPH.x;
		var ry = PANEL_GRAPH.y;
		
		var jy = _y + junction_draw_pad_y * _s + wh / 2;
		
		var boundH = _x > draw_boundary[0] - w * _s && _x < draw_boundary[2];
		var boundV = 1;//_y > draw_boundary[1] - h * _s && _y < draw_boundary[3];
		var extY   = 0;
		var drawText = _s > 0.5;
		
		for(var i = 0, n = array_length(inputDisplayList); i < n; i++) {
			var jun = inputDisplayList[i];
			var wd  = jun.graphWidget;
			
			jun.y = jy;
			
			if(drawText) {
				draw_set_text(f_sdf, fa_left, fa_center, jun.color_display);
				draw_text_add(lx, jun.y, jun.getName(), _s * 0.25);
				
			} else {
				draw_set_color(jun.color_display);
				draw_rectangle(lx, jun.y - 1 * _s, lx + wt, jun.y + 4 * _s, false);
			}
			
			if(jun.value_from || wd == noone) {
				jy += wh;
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
			
			if(is_instanceof(jun, checkBox))
				_param.halign = fa_center;
			
			wd.setInteract(wh > line_get_height(f_p2));
			wd.setFocusHover(_focus, _hover);
			var _h = wd.drawParam(_param);
			jun.graphWidgetH = _h / _s;
					
			extY += max(0, (jun.graphWidgetH + 4) - junction_draw_hei_y);
					
			if(wd.isHovering()) draggable = false;
			
			jy += (jun.graphWidgetH + 4) * _s;
		}
		
		h = fix_h + extY;
	} #endregion
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) { #region
		if(!active) return;
		var hover = noone;
		
		for(var i = 0, n = array_length(inputDisplayList); i < n; i++) {
			var jun = inputDisplayList[i];
			
			if(jun.drawJunction(_s, _mx, _my))
				hover = jun;
		}
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var jun = outputs[| i];
			if(!jun.isVisible()) continue;
			
			if(jun.drawJunction(_s, _mx, _my))
				hover = jun;
		}
		
		if(NODE_HAS_INSP1 && inspectInput1.drawJunction(_s, _mx, _my))
			hover = inspectInput1;
			
		if(NODE_HAS_INSP2 && inspectInput2.drawJunction(_s, _mx, _my))
			hover = inspectInput2;
		
		if(attributes.show_update_trigger) {
			if(updatedInTrigger.drawJunction(_s, _mx, _my))  hover = updatedInTrigger;
			if(updatedOutTrigger.drawJunction(_s, _mx, _my)) hover = updatedOutTrigger;
		}
		
		onDrawJunctions(_x, _y, _mx, _my, _s);
		
		return hover;
	} #endregion
	
	static drawJunctions_fast = function(_x, _y, _mx, _my, _s) { #region
		if(!active) return;
		var hover = noone;
		
		_s = _s * 6;
		
		draw_set_circle_precision(4);
		
		for(var i = 0, n = array_length(inputDisplayList); i < n; i++) {
			var jun = inputDisplayList[i];
			
			if(jun.drawJunction_fast(_s, _mx, _my))
				hover = jun;
		}
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var jun = outputs[| i];
			
			if(jun.drawJunction_fast(_s, _mx, _my))
				hover = jun;
		}
		
		if(NODE_HAS_INSP1 && inspectInput1.drawJunction_fast(_s, _mx, _my))
			hover = inspectInput1;
			
		if(NODE_HAS_INSP2 && inspectInput2.drawJunction_fast(_s, _mx, _my))
			hover = inspectInput2;
		
		if(attributes.show_update_trigger) {
			if(updatedInTrigger.drawJunction_fast(_s, _mx, _my))  hover = updatedInTrigger;
			if(updatedOutTrigger.drawJunction_fast(_s, _mx, _my)) hover = updatedOutTrigger;
		}
		
		onDrawJunctions(_x, _y, _mx, _my, _s / 6);
		
		return hover;
	} #endregion
	
	static onDrawJunctions = function(_x, _y, _mx, _my, _s) {}
	
	static drawJunctionNames = function(_x, _y, _mx, _my, _s) { #region
		if(draw_graph_culled) return;
		if(!active) return;
		
		var amo = input_display_list == -1? ds_list_size(inputs) : array_length(input_display_list);
		var jun;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		var _hov = PANEL_GRAPH.pHOVER && (PANEL_GRAPH.node_hovering == noone || PANEL_GRAPH.node_hovering == self);
		show_input_name  = _hov && point_in_rectangle(_mx, _my, xx - 8 * _s, yy + 20 * _s, xx + 8 * _s, yy + h * _s);
		show_output_name = _hov && point_in_rectangle(_mx, _my, xx + (w - 8) * _s, yy + 20 * _s, xx + (w + 8) * _s, yy + h * _s);
		
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
			for(var i = 0; i < ds_list_size(outputs); i++)
				if(outputs[| i].visible) outputs[| i].drawNameBG(_s);
			
			for(var i = 0; i < ds_list_size(outputs); i++)
				if(outputs[| i].visible) outputs[| i].drawName(_s, _mx, _my);
		}
		
		if(NODE_HAS_INSP1 && PANEL_GRAPH.pHOVER && point_in_circle(_mx, _my, inspectInput1.x, inspectInput1.y, 10)) {
			inspectInput1.drawNameBG(_s);
			inspectInput1.drawName(_s, _mx, _my);
		}
		
		if(NODE_HAS_INSP2 && PANEL_GRAPH.pHOVER && point_in_circle(_mx, _my, inspectInput2.x, inspectInput2.y, 10)) {
			inspectInput2.drawNameBG(_s);
			inspectInput2.drawName(_s, _mx, _my);
		}
	} #endregion
	
	static drawConnections = function(params = {}) { #region
		if(!active) return;
		
		var hovering = noone;
		var drawLineIndex = 1;
		
		var high = params.highlight; // 0
		var bg   = params.bg;        // 0
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var jun       = outputs[| i];
			var connected = false;
			
			for( var j = 0; j < array_length(jun.value_to); j++ ) {
				if(jun.value_to[j].value_from == jun) 
					connected = true;
			}
			
			if(connected) {
				jun.drawLineIndex = drawLineIndex;
				drawLineIndex += 0.5;
			}
			
			if(high) {
				jun.draw_blend_color = bg;
				jun.draw_blend       = PREFERENCES.connection_line_highlight_fade;
			} else {
				jun.draw_blend_color = bg;
				jun.draw_blend       = -1;
			}
		
		}
		
		var st = 0;
		if(NODE_HAS_INSP1) st = -1;
		if(NODE_HAS_INSP2) st = -2;
		
		var _inputs = array_create(ds_list_size(inputs));
		var _len    = 0;
		
		var drawLineIndex = 1;
		for(var i = st; i < ds_list_size(inputs); i++) {
			var jun;
			if(i == -1)			jun = inspectInput1;
			else if(i == -2)	jun = inspectInput2;
			else				jun = inputs[| i];
			
			if(high) {
				jun.draw_blend_color = bg;
				jun.draw_blend       = PREFERENCES.connection_line_highlight_fade;
			} else {
				jun.draw_blend_color = bg;
				jun.draw_blend       = -1;
			}
			
			if(jun.isLeaf()) continue;
			if(!jun.value_from.node.active) continue;
			if(!jun.isVisible()) continue;
			
			if(i >= 0) _inputs[_len++] = jun;
		}
		
		for( var i = 0; i < _len; i++ ) {
			var jun = _inputs[i];
			
			jun.drawLineIndex = 1 + (i > _len / 2? (_len - 1 - i) : i) * 0.5;
			var hov = jun.drawConnections(params);
			if(hov) hovering = hov;
		}
		
		if(attributes.show_update_trigger) {
			if(updatedInTrigger.drawConnections(params))  hovering = updatedInTrigger;
			if(updatedOutTrigger.drawConnections(params)) hovering = updatedOutTrigger;
		}
		
		return hovering;
	} #endregion
	
	static getGraphPreviewSurface = function() { #region
		var _node = outputs[| preview_channel];
		if(!is_instanceof(_node, NodeValue)) return noone;
		
		switch(_node.type) {
			case VALUE_TYPE.surface :
			case VALUE_TYPE.dynaSurface :
				var val = _node.showValue();
				return val;
		}
		
		return noone;
	} #endregion
	
	__preview_surf = false;
	__preview_sw   = noone;
	__preview_sh   = noone;
	
	static setPreview = function(_surf) { #region
		preview_surface = _surf;
		__preview_surf  = is_surface(_surf);
	} #endregion
	
	static drawPreview = function(xx, yy, _s) { #region
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
		
		var bbox = drawGetBbox(xx, yy, _s);
		var aa   = 0.5 + 0.5 * renderActive;
		if(!isHighlightingInGraph()) aa *= 0.25;
		
		var _sw = __preview_sw;
		var _sh = __preview_sh;
		var _ss = min(bbox.w / _sw, bbox.h / _sh);
		draw_surface_ext_safe(preview_surface, bbox.xc - _sw * _ss / 2, bbox.yc - _sh * _ss / 2, _ss, _ss);
	} #endregion
	
	static getNodeDimension = function(showFormat = true) { #region
		if(!__preview_surf) return preview_array;
		
		var pw = surface_get_width_safe(preview_surface);
		var ph = surface_get_height_safe(preview_surface);
		var format = surface_get_format_safe(preview_surface);
		
		var txt = $"[{pw} x {ph} ";
		if(preview_amount) txt = $"{preview_amount} x {txt}";
		
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
	} #endregion
	
	static drawDimension = function(xx, yy, _s) { #region
		if(draw_graph_culled) return;
		if(!active) return;
		if(_s * w < 64) return;
		
		draw_set_text(f_p2, fa_center, fa_top, COLORS.panel_graph_node_dimension);
		var tx = xx + w * _s / 2;
		var ty = yy + (h + 4) * _s - 2;
		
		if(struct_get(display_parameter, "show_dimension")) {
			var txt = string(getNodeDimension(_s > 0.65));
			draw_text(round(tx), round(ty), txt);
			ty += line_get_height(f_p2) - 2;
		}
		
		draw_set_font(f_p3);
		
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
			
			draw_text(round(tx), round(ty), string(rt) + " " + unit);
		}
	} #endregion
	
	static groupCheck = function(_x, _y, _s, _mx, _my) {}
	
	static drawNodeBG = function(_x, _y, _mx, _my, _s, display_parameter = noone) { return false; }
	
	static drawNode = function(_x, _y, _mx, _my, _s, display_parameter = noone) { #region
		if(draw_graph_culled) return;
		if(!active) return;
		
		if(display_parameter != noone)
			self.display_parameter = display_parameter;
		
		var xx = x * _s + _x;
		var yy = y * _s + _y;
		
		preview_mx = _mx;
		preview_my = _my;
		
		if(value_validation[VALIDATION.error])
			draw_sprite_stretched_ext(THEME.node_glow_border, 0, xx - 9, yy - 9, w * _s + 18, h * _s + 18, COLORS._main_value_negative, 1);
		
		drawNodeBase(xx, yy, _s);
		drawDimension(xx, yy, _s);
		
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
		
		if(show_parameter)
			drawJunctionWidget(xx, yy, _mx, _my, _s, _hover, _focus);
		
		draw_name = false;
		if(_s >= 0.75) drawNodeName(xx, yy, _s);
		
		if(active_draw_index > -1) {
			draw_sprite_stretched_ext(bg_sel_spr, 0, xx, yy, round(w * _s), round(h * _s), active_draw_index > 1? COLORS.node_border_file_drop : COLORS._main_accent, 1);
			active_draw_index = -1;
		}
		
		if(draw_droppable) {
			draw_sprite_stretched_ext(THEME.ui_panel_active, 0, xx, yy, w * _s, h * _s, COLORS._main_value_positive, 1);
			draw_droppable = false;
		}
		
		return _s > 0.5? drawJunctions(xx, yy, _mx, _my, _s) : drawJunctions_fast(xx, yy, _mx, _my, _s);
	} #endregion
	
	static onDrawNodeBehind = function(_x, _y, _mx, _my, _s) {}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover = false, _focus = false) {}
	
	static onDrawHover = function(_x, _y, _mx, _my, _s) {}
	
	static drawPreviewBackground = function(_x, _y, _mx, _my, _s) { return false; }
	
	static drawBadge = function(_x, _y, _s) { #region
		if(!active) return;
		var xx = x * _s + _x + w * _s;
		var yy = y * _s + _y;
		
		badgePreview = lerp_float(badgePreview, !!previewing, 2);
		badgeInspect = lerp_float(badgeInspect,   inspecting, 2);
		
		if(badgePreview > 0) {
			draw_sprite_ext(THEME.node_state, is_3D? 3 : 0, xx, yy, badgePreview, badgePreview, 0, c_white, 1);
			xx -= 28 * badgePreview;
		}
		
		if(badgeInspect > 0) {
			draw_sprite_ext(THEME.node_state, 1, xx, yy, badgeInspect, badgeInspect, 0, c_white, 1);
			xx -= 28 * badgeInspect;
		}
		
		if(isTool) {
			draw_sprite_ext(THEME.node_state, 2, xx, yy, 1, 1, 0, c_white, 1);
			xx -= 28 * 2;
		}
		
		inspecting = false;
		previewing = 0;
	} #endregion
	
	static drawBranch = function(_depth = 0) { #region
		if(branch_drawing) return;
		branch_drawing = true;
		
		if(!PREFERENCES.connection_line_highlight_all && _depth == 1) return;
		
		for( var i = 0, n = ds_list_size(inputs); i < n; i++ ) {
			if(inputs[| i].isLeaf()) continue;
			inputs[| i].value_from.node.drawBranch(_depth + 1);
		}
	} #endregion
	
	static drawActive = function(_x, _y, _s, ind = 0) { #region
		active_draw_index = ind; 
		if(display_parameter.highlight) drawBranch();
	} #endregion
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static drawPreviewToolOverlay = function(hover, active, _mx, _my, _panel) { return false; }
	
	static drawAnimationTimeline = function(_w, _h, _s) {}
	
	static getAnimationCacheExist = function(frame) { return cacheExist(frame); }
	
	static enable  = function() { INLINE active = true;  timeline_item.active = true;  }
	static disable = function() { INLINE active = false; timeline_item.active = false; }
	
	static onDestroy = function() {}
	
	static destroy = function(_merge = false, record = true) { #region
		if(!active) return;
		disable();
		
		ds_list_remove(group == noone? PROJECT.nodes : group.getNodeList(), self);
		
		if(PANEL_GRAPH.node_hover     == self) PANEL_GRAPH.node_hover     = noone;
		PANEL_GRAPH.nodes_selecting = [];
		
		if(PANEL_INSPECTOR.inspecting == self) PANEL_INSPECTOR.inspecting = noone;
		
		PANEL_PREVIEW.removeNodePreview(self);
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var jun = outputs[| i];
			
			for(var j = 0; j < array_length(jun.value_to); j++) {
				var _vt = jun.value_to[j];
				if(_vt.isLeaf()) break;
				if(_vt.value_from.node != self) break;
				
				_vt.removeFrom(false);
				
				if(!_merge) continue;
				
				for( var k = 0; k < ds_list_size(inputs); k++ ) {
					if(inputs[| k].isLeaf()) continue;
					if(_vt.setFrom(inputs[| k].value_from)) break;
				}
			}
			
			jun.value_to = [];
		}
		
		for( var i = 0; i < ds_list_size(inputs); i++ )
			inputs[| i].destroy();
		
		for( var i = 0; i < ds_list_size(outputs); i++ )
			outputs[| i].destroy();
		
		onDestroy();
		if(group) group.refreshNodes();
		
		if(record) recordAction(ACTION_TYPE.node_delete, self);
		
		RENDER_ALL_REORDER
	} #endregion
	
	static onRestore = function() {}
	
	static restore = function() { #region
		if(active) return;
		enable();
		
		ds_list_add(group == noone? PROJECT.nodes : group.getNodeList(), self);
		
		onRestore();
		if(group) group.refreshNodes();
		
		RENDER_ALL_REORDER
	} #endregion
	
	static onValidate = function() { #region
		value_validation[VALIDATION.pass]	 = 0;
		value_validation[VALIDATION.warning] = 0;
		value_validation[VALIDATION.error]   = 0;
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			var jun = inputs[| i];
			if(jun.value_validation)
				value_validation[jun.value_validation]++;
		}
	} #endregion
	
	static clearInputCache = function() { #region
		for( var i = 0; i < ds_list_size(inputs); i++ )
			inputs[| i].cache_value[0] = false;
	} #endregion
	
	static cacheArrayCheck = function() { #region
		cached_output = array_verify(cached_output, TOTAL_FRAMES);
		cache_result  = array_verify(cache_result,  TOTAL_FRAMES);
	} #endregion
	
	static cacheCurrentFrame = function(_frame) { #region
		cacheArrayCheck();
		if(CURRENT_FRAME < 0) return;
		if(CURRENT_FRAME >= array_length(cached_output)) return;
		
		surface_array_free(cached_output[CURRENT_FRAME]);
		cached_output[CURRENT_FRAME] = surface_array_clone(_frame);
		
		array_safe_set(cache_result, CURRENT_FRAME, true);
		
		return cached_output[CURRENT_FRAME];
	} #endregion
	
	static cacheExist = function(frame = CURRENT_FRAME) { #region
		if(frame < 0) return false;
		
		if(frame >= array_length(cached_output)) return false;
		if(frame >= array_length(cache_result)) return false;
		if(!array_safe_get_fast(cache_result, frame, false)) return false;
		
		var s = array_safe_get_fast(cached_output, frame);
		return is_array(s) || surface_exists(s);
	} #endregion
	
	static getCacheFrame = function(frame = CURRENT_FRAME) { #region
		if(frame < 0) return false;
		
		if(!cacheExist(frame)) return noone;
		var surf = array_safe_get_fast(cached_output, frame);
		return surf;
	} #endregion
	
	static recoverCache = function(frame = CURRENT_FRAME) { #region
		if(!cacheExist(frame)) return false;
		
		var _s = cached_output[CURRENT_FRAME];
		outputs[| 0].setValue(_s);
			
		return true;
	} #endregion
	
	static clearCache = function(_force = false) { #region
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
	} #endregion
	
	static clearCacheForward = function() { #region
		_clearCacheForward(); 
	} #endregion
	
	static _clearCacheForward = function() { #region
		if(!isRenderActive()) return;
		
		clearCache();
		var arr = getNextNodesRaw();
		for( var i = 0, n = array_length(arr); i < n; i++ )
			arr[i]._clearCacheForward();
	} #endregion
	
	static cachedPropagate = function(_group = group) { #region
		if(group != _group) return;
		setRenderStatus(true);
		
		for( var i = 0, n = ds_list_size(inputs); i < n; i++ ) {
			var _input = inputs[| i];
			if(_input.isLeaf()) continue;
			
			_input.value_from.node.cachedPropagate(_group);
		}
	} #endregion
	
	static clearInputCache = function() { #region
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(!is_instanceof(inputs[| i], NodeValue)) continue;
			inputs[| i].resetCache();
		}
	} #endregion
	
	static checkConnectGroup = function(_io) { #region
		var _y  = y;
		var _n  = noone;
		
		for(var i = 0; i < ds_list_size(inputs); i++) {
			var _in = inputs[| i];
			if(_in.isLeaf())						continue;
			if(_in.value_from.node.group == group)	continue;
			
			var _ind = string(_in.value_from);
			_io.map[$ _ind] = _in.value_from;
			
			if(struct_has(_io.inputs, _ind))
				array_push(_io.inputs[$ _ind ], _in);
			else 
				_io.inputs[$ _ind ] = [ _in ];
		}
		
		for(var i = 0; i < ds_list_size(outputs); i++) {
			var _ou = outputs[| i];
			
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
	} #endregion
	
	static isNotUsingTool = function() { return PANEL_PREVIEW.tool_current == noone; }
	
	static isUsingTool = function(index = undefined, subtool = noone) { #region
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
	} #endregion
	
	static clone = function(target = PANEL_GRAPH.getCurrentContext()) { #region
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
	} #endregion
	
	static onClone = function(_NewNode, target = PANEL_GRAPH.getCurrentContext()) {}
	
	static droppable = function(dragObj) { #region
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(dragObj.type == inputs[| i].drop_key)
				return true;
		}
		return false;
	} #endregion
	
	on_drop_file = noone;
	static onDrop = function(dragObj) { #region
		if(dragObj.type == "Asset" && is_callable(on_drop_file)) {
			on_drop_file(dragObj.data.path);
			return;
		}
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(dragObj.type == inputs[| i].drop_key) {
				inputs[| i].setValue(dragObj.data);
				return;
			}
		}
	} #endregion
	
	static getPreviewValues = function() { #region
		if(preview_channel >= ds_list_size(outputs)) return noone;
		
		switch(outputs[| preview_channel].type) {
			case VALUE_TYPE.surface :
			case VALUE_TYPE.dynaSurface :
				break;
			default :
				return noone;
		}
		
		return outputs[| preview_channel].getValue();
	} #endregion
	
	static getPreviewBoundingBox = function() { #region
		var _surf = getPreviewValues();
		if(is_array(_surf)) 
			_surf = array_safe_get_fast(_surf, preview_index, noone);
		if(!is_surface(_surf)) return noone;
		
		return BBOX().fromWH(preview_x, preview_y, surface_get_width_safe(_surf), surface_get_height_safe(_surf));
	} #endregion
	
	static getTool = function() { return self; }
	
	static getToolSettings = function() { return tool_settings; }
	
	static setTool = function(tool) { #region
		if(!tool) {
			isTool = false;
			return;
		}
		
		for( var i = 0; i < ds_list_size(group.nodes); i++ )
			group.nodes[| i].isTool = false;
		
		isTool = true;
	} #endregion
	
	static drawTools = function(_mx, _my, xx, yy, tool_size, hover, focus) { return 0; }
	
	static serialize = function(scale = false, preset = false) { #region							>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SERIALIZE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		if(!active) return;
		
		var _map = {};
		//print(" > Serializing: " + name);
		
		if(!preset) {
			_map.id	     = node_id;
			_map.render  = renderActive;
			_map.name	 = display_name;
			_map.iname	 = internalName;
			_map.x		 = x;
			_map.y		 = y;
			_map.type    = instanceof(self);
			_map.group   = group == noone? group : group.node_id;
			_map.tool    = isTool;
			
			_map.previewable    = previewable;
			_map.show_parameter = show_parameter;
		}
		
		_map.attri = attributeSerialize();
		
		if(is_dynamic_input) {
			_map.input_fix_len  = input_fix_len;
			_map.data_length    = data_length;
		}
		
		var _inputs = [];
		for(var i = 0; i < ds_list_size(inputs); i++)
			array_push(_inputs, inputs[| i].serialize(scale, preset));
		_map.inputs = _inputs;
		
		var _outputs = [];
		for(var i = 0; i < ds_list_size(outputs); i++)
			array_push(_outputs, outputs[| i].serialize(scale, preset));
		_map.outputs = _outputs;
		
		var _trigger = [];
		array_push(_trigger, inspectInput1.serialize(scale, preset));
		array_push(_trigger, inspectInput2.serialize(scale, preset));
		array_push(_trigger, updatedInTrigger.serialize(scale, preset));
		array_push(_trigger, updatedOutTrigger.serialize(scale, preset));
		
		_map.inspectInputs = _trigger;
		_map.renamed       = renamed;
		
		_map.buffer = {};
		var _bufferKey = struct_key(bufferStore);
		for( var i = 0, n = array_length(_bufferKey); i < n; i++ ) {
			var _key = _bufferKey[i];
			_map.buffer[$ _key] = buffer_serialize(bufferStore[$ _key]);
		}
		
		doSerialize(_map);
		processSerialize(_map);
		return _map;
	} #endregion
	
	static attributeSerialize = function() { return attributes; }
	static doSerialize = function(_map) {}
	static processSerialize = function(_map) {}
	
	load_scale = false;
	load_map = -1;
	static deserialize = function(_map, scale = false, preset = false) { #region					>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> DESERIALIZE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		load_map   = _map;
		load_scale = scale;
		renamed    = struct_try_get(load_map, "renamed", false);
		
		if(!preset) {
			if(APPENDING) APPEND_MAP[? load_map.id] = node_id;
			else		  node_id = load_map.id;
			
			PROJECT.nodeMap[? node_id] = self;
			//print($"Adding node {node_id} to {PROJECT.path} [{ds_map_size(PROJECT.nodeMap)}]");
			
			if(struct_has(load_map, "name"))
				setDisplayName(load_map.name);
			
			internalName = struct_try_get(load_map, "iname", internalName);
			if(internalName == "")
				resetInternalName();
			
			_group = struct_try_get(load_map, "group", noone);
			if(_group == -1) _group = noone;
			
			x = struct_try_get(load_map, "x");
			y = struct_try_get(load_map, "y");
			renderActive   = struct_try_get(load_map, "render", true);
			previewable    = struct_try_get(load_map, "previewable", previewable);
			isTool         = struct_try_get(load_map, "tool");
			show_parameter = struct_try_get(load_map, "show_parameter");
		}
		
		if(struct_has(load_map, "attri"))
			attributeDeserialize(load_map.attri);
		
		if(struct_has(load_map, "buffer")) {
			var _bufferKey = struct_key(bufferStore);
			for( var i = 0, n = array_length(_bufferKey); i < n; i++ ) {
				var _key = _bufferKey[i];
				if(!struct_has(bufferStore, _key)) continue;
				
				bufferStore[$ _key] = buffer_deserialize(load_map.buffer[$ _key]);
			}
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
		}
	} #endregion
	
	static inputBalance = function() { #region //Cross version compatibility for dynamic input nodes
		if(!struct_has(load_map, "data_length")) 
			return;
		
		var _input_fix_len  = load_map.input_fix_len;
		var _data_length    = load_map.data_length;
		
		//print($"Balancing IO: {input_fix_len} => {load_map.input_fix_len} : {data_length} => {load_map.data_length}");
		//print($"IO size before: {array_length(load_map.inputs)}");
		//for( var i = 0, n = array_length(load_map.inputs); i < n; i++ ) 
		//	print($"{i}: {load_map.inputs[i].name}");
		
		var _dynamic_inputs = (array_length(load_map.inputs) - _input_fix_len) / _data_length;
		if(frac(_dynamic_inputs) != 0) {
			noti_warning("LOAD: Uneven dynamic input.");
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
			
		//print($"IO size after: {array_length(load_map.inputs)}");
		//for( var i = 0, n = array_length(load_map.inputs); i < n; i++ ) 
		//	print($"{i}: {load_map.inputs[i] == noone? "noone" : load_map.inputs[i].name}");
	} #endregion
	
	static inputGenerate = function() { #region //Generate input for dynamic input nodes
		if(createNewInput == noone) 
			return;
		
		var _dynamic_inputs = (array_length(load_map.inputs) - input_fix_len) / data_length;
		//print($"Node {name} create {_dynamic_inputs} inputs for data length {data_length}");
		repeat(_dynamic_inputs)
			createNewInput();
	} #endregion
	
	static attributeDeserialize = function(attr) { #region
		if(struct_has(attributes, "use_project_dimension") && !struct_has(attr, "use_project_dimension"))
			attributes.use_project_dimension = false;
		
		struct_append(attributes, attr); 
	} #endregion
	
	static processDeserialize = function() {}
	static postDeserialize = function() {}
		
	static applyDeserialize = function(preset = false) { #region
		preApplyDeserialize();
		
		var _inputs = load_map.inputs;
		var amo = min(ds_list_size(inputs), array_length(_inputs));
		
		//print($"Applying deserialzie for {name}");
		
		for(var i = 0; i < amo; i++) {
			if(inputs[| i] == noone || _inputs[i] == noone) continue;
			
			//print($"      Apply {i} : {inputs[| i].name}");
			inputs[| i].applyDeserialize(_inputs[i], load_scale, preset);
		}
		
		if(struct_has(load_map, "outputs")) {
			var _outputs = load_map.outputs;
			var amo = min(ds_list_size(outputs), array_length(_outputs));
			
			for(var i = 0; i < amo; i++) {
				if(outputs[| i] == noone) continue;
				
				outputs[| i].applyDeserialize(_outputs[i], load_scale, preset);
			}
		}
		
		if(struct_has(load_map, "inspectInputs")) {
			var insInp = load_map.inspectInputs;
			inspectInput1.applyDeserialize(insInp[0], load_scale, preset);
			inspectInput2.applyDeserialize(insInp[1], load_scale, preset);
			
			if(array_length(insInp) > 2) updatedInTrigger.applyDeserialize(insInp[2], load_scale, preset);
			if(array_length(insInp) > 3) updatedOutTrigger.applyDeserialize(insInp[3], load_scale, preset);
		}
		
		//print($"Applying deserialzie for {name} complete");
		
		doApplyDeserialize();
	} #endregion
	
	static preApplyDeserialize = function() {}
	static doApplyDeserialize  = function() {}
	
	static loadGroup = function(context = noone) { #region
		if(_group == noone) {
			if(context != noone) context.add(self);
		} else {
			if(APPENDING) _group = GetAppendID(_group);
			
			if(ds_map_exists(PROJECT.nodeMap, _group)) {
				if(struct_has(PROJECT.nodeMap[? _group], "add"))
					PROJECT.nodeMap[? _group].add(self);
				else {
					var txt = $"Group load failed. Node ID {_group} is not a group.";
					throw(txt);
				}
			} else {
				var txt = $"Group load failed. Can't find node ID {_group}";
				throw(txt);
			}
		}
		
		onLoadGroup();
	} #endregion
	
	static onLoadGroup = function() {}
	
	static connect = function(log = false) { #region
		var connected = true;
		for(var i = 0; i < ds_list_size(inputs); i++)
			connected &= inputs[| i].connect(log);
		
		inspectInput1.connect(log);
		inspectInput2.connect(log);
		updatedInTrigger.connect(log);
		
		if(!connected) ds_queue_enqueue(CONNECTION_CONFLICT, self);
		refreshTimeline();
		
		return connected;
	} #endregion
	
	static preConnect = function() {}
	static postConnect = function() {}
	
	static postLoad = function() {}
	
	static resetAnimation = function() {}
	
	static cleanUp = function() { #region
		for( var i = 0; i < ds_list_size(inputs); i++ )
			inputs[| i].cleanUp();
		for( var i = 0; i < ds_list_size(outputs); i++ )
			outputs[| i].cleanUp();
		
		ds_list_destroy(inputs);
		ds_list_destroy(outputs);
		
		ds_map_destroy(inputMap);
		ds_map_destroy(outputMap);
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ )
			surface_free(temp_surface[i]);
		
		onCleanUp();
	} #endregion
	
	static onCleanUp = function() {}
	
	// helper function
	static attrDepth = function() { #region
		if(struct_has(attributes, "color_depth")) {
			var form = attributes.color_depth;
			if(inputs[| 0].type == VALUE_TYPE.surface) 
				form--;
			if(form >= 0)
				return array_safe_get_fast(global.SURFACE_FORMAT, form, surface_rgba8unorm);
		}
		
		var _s = getInputData(0);
		while(is_array(_s) && array_length(_s)) _s = _s[0];
		if(!is_surface(_s)) 
			return surface_rgba8unorm;
		return surface_get_format(_s);
	} #endregion
	
	static toString = function() { return $"Node [{internalName}]: {node_id}"; }
}