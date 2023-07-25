#region globals
	global.LOG_LEVEL = 0;
	
	function LOG_BLOCK_START() {
		gml_pragma("forceinline");
		global.LOG_LEVEL++;
	}
	
	function LOG(text) {
		gml_pragma("forceinline");
		var s = "";
		repeat(global.LOG_LEVEL - 1)
			s += "   ";
		s += "├ ";
		
		print(s + string(text));
	}
	
	function LOG_LINE(text) {
		gml_pragma("forceinline");
		LOG_BLOCK_START();
		LOG(text);
		LOG_BLOCK_END();
	}
	
	function LOG_IF(cond, text) {
		gml_pragma("forceinline");
		if(cond) LOG(text);
	}
	
	function LOG_LINE_IF(cond, text) {
		gml_pragma("forceinline");
		if(cond) LOG_LINE(text);
	}
	
	function LOG_BLOCK_END() {
		gml_pragma("forceinline");
		global.LOG_LEVEL--;
	}
	
	function LOG_END() {
		gml_pragma("forceinline");
		global.LOG_LEVEL = 0;
	}
#endregion