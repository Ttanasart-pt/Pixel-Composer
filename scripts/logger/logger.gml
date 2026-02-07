#region globals
	global.LOG_LEVEL = 0;
	
	#macro LOG_BLOCK_START global.LOG_LEVEL++;
	#macro LOG_BLOCK_END   global.LOG_LEVEL--;
	#macro LOG_END         global.LOG_LEVEL = 0;
	
	function LOG(text) {
		INLINE
		var s = "";
		repeat(global.LOG_LEVEL - 1)
			s += "   ";
		s += "├ ";
		print($"{s}{text}");
	}
	
	function LOG_LINE(text) {
		INLINE
		LOG_BLOCK_START
		LOG(text);
		LOG_BLOCK_END
	}
	
#endregion