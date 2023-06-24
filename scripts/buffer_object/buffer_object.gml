function Buffer(buff) constructor {
	self.buffer = buff;
	
	static destroy = function() {
		buffer_delete(buffer);
	}
}