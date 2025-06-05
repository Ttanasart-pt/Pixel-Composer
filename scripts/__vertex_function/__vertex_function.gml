globalvar MATRIX_IDENTITY;

MATRIX_IDENTITY = matrix_build_identity();

#region format
	vertex_format_begin();
	vertex_format_add_position();
	vertex_format_add_color();
	global.format_pc = vertex_format_end();
#endregion

function vertex_add_pt(buffer, position, texture) {
	vertex_position_3d(buffer, position[0], position[1], position[2]);
	vertex_texcoord(buffer, texture[0], texture[1]);
}

function vertex_add_pnt(buffer, position, normal, texture) {
	vertex_position_3d(buffer, position[0], position[1], position[2]);
	vertex_normal(buffer, normal[0], normal[1], normal[2]);
	vertex_texcoord(buffer, texture[0], texture[1]);
}

function vertex_add_pntc(buffer, position, normal, texture, color = c_white, alpha = 1) {
	vertex_position_3d(buffer, position[0], position[1], position[2]);
	vertex_normal(buffer, normal[0], normal[1], normal[2]);
	vertex_texcoord(buffer, texture[0], texture[1]);
	vertex_color(buffer, color, alpha);
}

function vertex_add_pntcb(buffer, position, normal, texture, color = c_white, alpha = 1, bx = 1, by = 0, bz = 0) {
	vertex_position_3d(buffer, position[0], position[1], position[2]);
	vertex_normal(buffer, normal[0], normal[1], normal[2]);
	vertex_texcoord(buffer, texture[0], texture[1]);
	vertex_color(buffer, color, alpha);
	vertex_float3(buffer, bx, by, bz);
}

function __vertex_add_pntc(buffer, _px, _py, _pz, _nx, _ny, _nz, _u, _v, color = c_white, alpha = 1, bx = 1, by = 0, bz = 0) {
	vertex_position_3d(buffer, _px, _py, _pz);
	vertex_normal(buffer, _nx, _ny, _nz);
	vertex_texcoord(buffer, _u, _v);
	vertex_color(buffer, color, alpha);
	vertex_float3(buffer, bx, by, bz);
}

function vertex_add_2pc(buffer, _x, _y, color, alpha = 1) {
	vertex_position(buffer, _x, _y);
	vertex_color(buffer, color, alpha);
}

function vertex_add_2pct(buffer, _x, _y, _u, _v, color, alpha = 1) {
	vertex_position(buffer, _x, _y);
	vertex_color(buffer, color, alpha);
	vertex_texcoord(buffer, _u, _v);
}

function vertex_add_v(buffer, vertex) {
	vertex_position_3d(buffer, vertex.x, vertex.y, vertex.z);
}

function vertex_add_vc(buffer, vertex) {
	vertex_position_3d(buffer, vertex.x, vertex.y, vertex.z);
	vertex_color(buffer, vertex.color, vertex.alpha);
}

function vertex_add_vnt(buffer, vertex) {
	vertex_position_3d(buffer, vertex.x, vertex.y, vertex.z);
	vertex_normal(buffer, vertex.nx, vertex.ny, vertex.nz);
	vertex_texcoord(buffer, vertex.u, vertex.v);
}

function vertex_add_vntc(buffer, vertex) {
	vertex_position_3d(buffer, vertex.x, vertex.y, vertex.z);
	vertex_normal(buffer, vertex.nx, vertex.ny, vertex.nz);
	vertex_texcoord(buffer, vertex.u, vertex.v);
	vertex_color(buffer, vertex.color, vertex.alpha);
}

//////////////////////////////////////////////////////////////

function __vertex_buffer_add_pntc(buffer, _px, _py, _pz, _nx, _ny, _nz, _u, _v, color = c_white, alpha = 1, bx = 1, by = 0, bz = 0) {
	buffer_write(buffer, buffer_f32, _px);
	buffer_write(buffer, buffer_f32, _py);
	buffer_write(buffer, buffer_f32, _pz);
	
	buffer_write(buffer, buffer_f32, _nx);
	buffer_write(buffer, buffer_f32, _ny);
	buffer_write(buffer, buffer_f32, _nz);
	
	buffer_write(buffer, buffer_f32, _u);
	buffer_write(buffer, buffer_f32, _v);
	
	buffer_write(buffer, buffer_u32, cola(color, alpha));
	
	buffer_write(buffer, buffer_f32, bx);
	buffer_write(buffer, buffer_f32, by);
	buffer_write(buffer, buffer_f32, bz);
}
