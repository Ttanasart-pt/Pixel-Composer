function nodeValue_Bone(_name = "Bone", _toggleFn) { return new __NodeValue_Bone(_name, self, _toggleFn); }
function __NodeValue_Bone(_name, _node, _toggleFn) : __NodeValue_Text(_name, _node, "") constructor {
	
	bSelect = button(_toggleFn).setIcon(THEME.bone, 1, COLORS._main_icon).setTooltip("Select Bone");
	setSideButton(bSelect);
	
	editWidget.autocomplete_context = node;
	editWidget.autocomplete_server  = armature_autocomplete_server;
	
	static setSelecting = function(_sel) {
		bSelect.icon_blend  = _sel? COLORS._main_value_positive : COLORS._main_icon; 
		editWidget.boxColor = _sel? COLORS._main_value_positive : c_white;
	}
	
	/////============== GET =============
	
	static getValue = function(_time = NODE_CURRENT_FRAME, applyUnit = true, arrIndex = 0, useCache = false, log = false) { //// Get value
		getValueRecursive(self.__curr_get_val, _time);
		var val = __curr_get_val[0];
		var nod = __curr_get_val[1]; if(!is(nod, NodeValue)) return val;
		return val;
	}
	
	static __getAnimValue = function(_time = NODE_CURRENT_FRAME) {
		var _anim  = animator;
		var _anims = animators;
		
		if(getAnim()) return _anim.getValue(_time);
		return array_empty(_anim.values)? 0 : _anim.values[0].value;
	}
	
	static arrayLength = arrayLengthSimple;
}