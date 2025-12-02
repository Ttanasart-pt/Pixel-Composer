function   nodeValue_Bool(_name, _value, _tooltip = "") { return new __NodeValue_Bool(_name, self, _value, _tooltip); }
function __NodeValue_Bool(_name, _node, _value, _tooltip = "") : NodeValue(_name, _node, CONNECT_TYPE.input, VALUE_TYPE.boolean, _value, _tooltip) constructor {
	
	/////============== GET =============
	
	function toBool(a) { return is_array(a)? array_map(a, function(v) /*=>*/ {return toBool(v)}) : bool(a) };
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { 
		if(__tempValue != undefined) return __tempValue;
		
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		return toBool(val);
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		var _anim  = animator;
		var _anims = animators;
		
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}

function   nodeValue_Bool_single(_name, _value, _tooltip = "") { return new __NodeValue_Bool_single(_name, self, _value, _tooltip); }
function __NodeValue_Bool_single(_name, _node, _value, _tooltip = "") : __NodeValue_Bool(_name, _node, _value, _tooltip) constructor {
	rejectArray();
	
	/////============== GET =============
	
	function toBool(a) { return bool(a) };
}

function   nodeValue_Active() { return new __NodeValue_Active(self); }
function __NodeValue_Active(_node) : __NodeValue_Bool_single("Active", _node, true) constructor {
	
	static setAnim = function(anim, record = false) {
		if(is_anim == anim) return;
		is_modified = true;
		
		if(record) recordAction_variable_change(self, "is_anim", is_anim, $"{name} animation status").setRef(node);
		is_anim = anim;
		
		if(is_anim) {
			animator.values = [ new valueKey(0, true, animator), new valueKey(NODE_TOTAL_FRAMES - 1, false, animator) ];
			
		} else {
			var _val = animator.getValue();
			animator.values = [ new valueKey(0, _val, animator) ];
		}
		
		animator.updateKeyMap();
		node.refreshTimeline();
		if(NOT_LOAD && node.group) node.group.checkPureFunction();
		
	}
}