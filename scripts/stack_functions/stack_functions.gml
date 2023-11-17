function ds_stack_to_array(stack) {
	var len = ds_stack_size(stack);
	var _st = array_create(len);
	
	for( var i = 0; i < len; i++ )
		_st[len - i - 1] = ds_stack_pop(stack);
	
	for( var i = 0; i < len; i++ )
		ds_stack_push(stack, _st[i]);
		
	return _st;
}