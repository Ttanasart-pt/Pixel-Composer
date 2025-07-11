function __node_dynamic_io() {
	dummy_input      = noone;
	dummy_insert     = noone;
	dummy_add_index  = noone;
	_dummy_add_index = noone;
	_dummy_start     = 0;
	
	auto_input                 = false;
	dyna_input_check_shift     =  0;
	input_display_dynamic      = -1;
	input_display_dynamic_full = undefined;
	dynamic_input_inspecting   =  0;
	
	createNewInput      = -1;
	dynamic_visibility  = -1;
	
	////- Method
	
    static setDynamicInput = function(_data_length = 1, _auto_input = true, _dummy_type = VALUE_TYPE.any, _dynamic_input_cond = DYNA_INPUT_COND.connection) {
		is_dynamic_input	= true;						
		auto_input			= _auto_input;
		dummy_type	 		= _dummy_type;
		data_length			= _data_length;
		dynamic_input_cond  = _dynamic_input_cond;
		
		if(auto_input) {
			dummy_input = nodeValue("Add value", self, CONNECT_TYPE.input, dummy_type, 0)
				.setDummy(function() /*=>*/ {
					var index = array_length(inputs);
					if(dummy_insert != noone) 
						index = input_fix_len + dummy_insert * data_length;
					
					repeat(data_length) array_insert(inputs, index, 0);
					return createNewInput(index);
				})
				.setVisible(false, true);
		}
		
		attributes.size = 0;
		resetDynamicInput();
	}
	
	static resetDynamicInput = function() {
		input_display_list_raw = array_clone(input_display_list, 1);
		input_display_len	   = input_display_list == -1? 0 : array_length(input_display_list);
		input_fix_len		   = array_length(inputs);
	}
	
	static refreshDynamicInput = function() {
		if(LOADING || APPENDING) return;
		
		var _in = [];
		
		for( var i = 0; i < input_fix_len; i++ )
			array_push(_in, inputs[i]);
		
		var _input_display_list = array_clone(input_display_list_raw, 1);
		var sep = false;
		
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _active = false;
			var _inp    = inputs[i + dyna_input_check_shift];
			
			if(dynamic_input_cond & DYNA_INPUT_COND.connection)
				_active = _active || _inp.hasJunctionFrom();
				
			if(dynamic_input_cond & DYNA_INPUT_COND.zero) {
				var _val = _inp.getValue();
				_active = _active || _val != 0 || _val != "";
			}
			
			if(_active) {
				if(sep && data_length > 1) array_push(_input_display_list, new Inspector_Spacer(20, true));
				sep = true;
				
				for( var j = 0; j < data_length; j++ ) {
					var _ind = i + j;
					
					if(_input_display_list != -1)
						array_push(_input_display_list, array_length(_in));
					array_push(_in, inputs[_ind]);
				}
			} else {
				for( var j = 0; j < data_length; j++ )
					delete inputs[i + j];
			}
		}
		
		array_foreach(_in, function(inp, i) /*=>*/ { inp.index = i });
		
		if(dummy_input) dummy_input.index = array_length(_in);
		inputs = _in;
		setHeight();
		
		if(input_display_dynamic == -1) input_display_list = _input_display_list;
	}

	static refreshDynamicDisplay = function() {
		if(input_display_dynamic == -1) return;
		array_resize(input_display_list, array_length(input_display_list_raw));
		
		var _amo = getInputAmount();
		if(_amo == 0) { dynamic_input_inspecting = 0; return; }
		
		dynamic_input_inspecting = min(dynamic_input_inspecting, _amo - 1);
		
		if(dynamic_input_inspecting == noone) {
			for( var i = 0; i < _amo; i++ ) {
				var _ind = input_fix_len + i * data_length;
				var _list = input_display_dynamic;
				
				if(!is_undefined(input_display_dynamic_full))
					_list = input_display_dynamic_full(i);
					
				for( var j = 0, n = array_length(_list); j < n; j++ ) {
					var v = _list[j]; 
					if(is_real(v)) v += _ind;
					
					array_push(input_display_list, v);
				}
			}
			return;
		} 
		
		var _ind = input_fix_len + dynamic_input_inspecting * data_length;
		for( var i = 0, n = array_length(input_display_dynamic); i < n; i++ ) {
			var v = input_display_dynamic[i]; if(is_real(v)) v += _ind;
			array_push(input_display_list, v);
		}
		
		if(dynamic_visibility != -1) dynamic_visibility();
	}
	
	static getInputAmount = function() { return (array_length(inputs) - input_fix_len) / data_length; }
	
	static onInputResize = function() { refreshDynamicInput(); triggerRender(); }
	
	static getOutput = function(_y = 0, junc = noone) {
		var _targ = noone;
		var _dy   = 9999;
		
		for( var i = 0; i < array_length(outputs); i++ ) {
			var _outp = outputs[i];
			
			if(!is(_outp, NodeValue)) continue;
			if(!_outp.isVisible())    continue;
			if(junc != noone && !junc.isConnectable(_outp, true)) continue;
			
			var _ddy = abs(_outp.y - _y);
			if(_ddy < _dy) {
				_targ = _outp;
				_dy   = _ddy;
			}
		}
		return _targ;
	}
	
	static getInput = function(_y = 0, _junc = noone, _shft = input_fix_len, _over = false) {
		
		var _targ = noone;
		var _dy   = 9999;
		
		for( var i = _shft; i < array_length(inputs); i++ ) {
			var _inp = inputs[i];
			
			if(!_inp.isVisible()) continue;
			if(_inp.value_from != noone) continue;
			if(_junc != noone && (value_bit(_junc.type) & value_bit(_inp.type)) == 0) continue;
			
			var _ddy = abs(_inp.y - _y);
			
			if(_ddy < _dy) {
				_targ = _inp;
				_dy   = _ddy;
			}
		}
		
		if(dummy_input) {
			var _ddy = abs(dummy_input.y - _y);
			if(_ddy < _dy) _targ = dummy_input;
		}
		
		if(_targ == noone && _over) {
			var _dy   = 9999;
			
			for( var i = _shft; i < array_length(inputs); i++ ) {
				var _inp = inputs[i];
				
				if(!_inp.isVisible()) continue;
				if(_junc != noone && (value_bit(_junc.type) & value_bit(_inp.type)) == 0) continue;
				
				var _ddy = abs(_inp.y - _y);
				
				if(_ddy < _dy) {
					_targ = _inp;
					_dy   = _ddy;
				}
			}
		}
		
		return _targ;
	}
	
	static deleteDynamicInput = function(index) {
		var _ind = input_fix_len + index * data_length;
		
		array_delete(inputs, _ind, data_length);
		dynamic_input_inspecting = min(dynamic_input_inspecting, getInputAmount() - 1);
		refreshDynamicDisplay();
		triggerRender();
	}
		
}