function cbuffer_write_f(_buffer, _val) { d3d11_cbuffer_add_float(1); buffer_write(_buffer, buffer_f32, _val); return 1; }
function cbuffer_write_i(_buffer, _val) { d3d11_cbuffer_add_int(1);   buffer_write(_buffer, buffer_s32, _val); return 1; }
function cbuffer_write_u(_buffer, _val) { d3d11_cbuffer_add_uint(1);  buffer_write(_buffer, buffer_u32, _val); return 1; }

function cbuffer_write_fs(_buffer, _arr) {
	var _amo = array_length(_arr);
	d3d11_cbuffer_add_float(_amo); 
	for( var i = 0, n = _amo; i < n; i++ ) 
		buffer_write(_buffer, buffer_f32, _arr[i]);
	return _amo;
}

function cbuffer_write_c(_buffer, _col) {
	d3d11_cbuffer_add_float(4); 
	
	buffer_write(_buffer, buffer_f32, _color_get_r(_col));
	buffer_write(_buffer, buffer_f32, _color_get_g(_col));
	buffer_write(_buffer, buffer_f32, _color_get_b(_col));
	buffer_write(_buffer, buffer_f32, _color_get_a(_col));
	
	return 4;
}
