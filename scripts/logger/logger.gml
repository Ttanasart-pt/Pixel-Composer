#region globals
	global.LOG_LEVEL = 0;
	
	function LOG_BLOCK_START() {
		global.LOG_LEVEL++;
	}
	
	function LOG(text) {
		var s = "";
		repeat(global.LOG_LEVEL - 1)
			s += "   ";
		s += "├ ";
		
		print(s + string(text));
	}
	
	function LOG_LINE(text) {
		LOG_BLOCK_START();
		LOG(text);
		LOG_BLOCK_END();
	}
	
	function LOG_IF(cond, text) {
		if(!cond) return;
		LOG(text);
	}
	
	function LOG_LINE_IF(cond, text) {
		if(!cond) return;
		LOG_LINE(text);
	}
	
	function LOG_BLOCK_END() {
		global.LOG_LEVEL--;
	}
	
	function LOG_END() {
		global.LOG_LEVEL = 0;
	}
#endregion