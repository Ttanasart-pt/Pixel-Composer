#region globals
	global.LOG_LEVEL = 0;
	
	function LOG_BLOCK_START() {
		INLINE
		global.LOG_LEVEL++;
	}
	
	function LOG(text) {
		INLINE
		var s = "";
		repeat(global.LOG_LEVEL - 1)
			s += "   ";
		s += "├ ";
		
		print(s + string(text));
	}
	
	function LOG_LINE(text) {
		INLINE
		LOG_BLOCK_START();
		LOG(text);
		LOG_BLOCK_END();
	}
	
	function LOG_IF(cond, text) {
		INLINE
		if(cond) LOG(text);
	}
	
	function LOG_LINE_IF(cond, text) {
		INLINE
		if(cond) LOG_LINE(text);
	}
	
	function LOG_BLOCK_END() {
		INLINE
		global.LOG_LEVEL--;
	}
	
	function LOG_END() {
		INLINE
		global.LOG_LEVEL = 0;
	}
#endregion