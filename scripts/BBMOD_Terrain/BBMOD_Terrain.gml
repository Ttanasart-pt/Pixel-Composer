/// @func BBMOD_Terrain([_heightmap[, _subimage]])
///
/// @extends BBMOD_Class
///
/// @desc A heightmap based terrain with five material layers controlled through
/// a splatmap.
///
/// @param {Asset.GMSprite} [_heightmap] The heightmap to make the terrain
/// from. If `undefined`, then you will need to build the terrain mesh yourself
/// later using the terrain's methods.
/// @param {Real} [_subimage] The sprite subimage to use for the heightmap.
/// Defaults to 0.
function BBMOD_Terrain(_heightmap=undefined, _subimage=0)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

	/// @var {Struct.BBMOD_RenderQueue} Render queue for terrain layers.
	/// @readonly
	static RenderQueue = new BBMOD_RenderQueue("Terrain", -$FFFFFFFE);

	/// @var {Array<Struct.BBMOD_Material>} Array of five material layers. Use
	/// `undefined` instead of a material to disable certain layer.
	Layer = array_create(5, undefined);

	/// @var {Pointer.Texture} A texture that controls visibility of individual
	/// layers. The first layer is always visible (if the material is not
	/// `undefined`), the red channel of the splatmap controls visibility of the
	/// second layer, the green channel controls the third layer etc.
	Splatmap = pointer_null;

	/// @var {Id.DsGrid}
	/// @private
	__splatmapGrid = ds_grid_create(1, 1);
	ds_grid_clear(__splatmapGrid, 0);

	/// @var {Struct.BBMOD_Vec2} Controls material texture repeat over the
	/// terrain mesh.
	TextureRepeat = new BBMOD_Vec2(1.0);

	/// @var {Struct.BBMOD_Vec3} The position of the terrain in the world.
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec2} The width and height of the terrain in world
	/// units.
	/// @readonly
	Size = new BBMOD_Vec2();

	/// @var {Struct.BBMOD_Vec3} The scale of the terrain.
	Scale = new BBMOD_Vec3(1.0, 1.0, 1.0);

	/// @var {Id.DsGrid} __height of individual vertices (on the z axis).
	/// @private
	__height = ds_grid_create(1, 1);

	/// @var {Id.DsGrid} Normal vector's X component of vertices.
	/// @private
	__normalX = ds_grid_create(1, 1);
	ds_grid_clear(__normalX, 0);

	/// @var {Id.DsGrid} Normal vector's Y component of vertices.
	/// @private
	__normalY = ds_grid_create(1, 1);
	ds_grid_clear(__normalY, 0);

	/// @var {Id.DsGrid} Normal vector's Z component of vertices.
	/// @private
	__normalZ = ds_grid_create(1, 1);
	ds_grid_clear(__normalZ, 1);

	/// @var {Id.DsGrid} Smooth normal vector's X component of vertices.
	/// @private
	__normalSmoothX = ds_grid_create(1, 1);
	ds_grid_clear(__normalSmoothX, 0);

	/// @var {Id.DsGrid} Smooth normal vector's Y component of vertices.
	/// @private
	__normalSmoothY = ds_grid_create(1, 1);
	ds_grid_clear(__normalSmoothY, 0);

	/// @var {Id.DsGrid} Smooth normal vector's Z component of vertices.
	/// @private
	__normalSmoothZ = ds_grid_create(1, 1);
	ds_grid_clear(__normalSmoothZ, 1);

	/// @var {Struct.BBMOD_VertexFormat} The vertex format used by the terrain
	/// mesh.
	/// @readonly
	VertexFormat = BBMOD_VFORMAT_DEFAULT;

	/// @var {Id.VertexBuffer} The vertex buffer or `undefined` if the terrain
	/// was not built yet.
	/// @readonly
	/// @see BBMOD_Terrain.build_mesh
	VertexBuffer = undefined;

	/// @func in_bounds(_x, _y)
	///
	/// @desc Checks whether the coordinate is within the terrain's bounds.
	///
	/// @param {Real} _x The x coordinate to check.
	/// @param {Real} _y The y coordinate to check.
	///
	/// @return {Bool} Returns `true` if the coordinate is within the terrain's
	/// bounds.
	static in_bounds = function (_x, _y) {
		gml_pragma("forceinline");
		return (_x >= Position.X && _x <= Position.X + (Size.X * Scale.X)
			&& _y >= Position.Y && _y <= Position.Y + (Size.Y * Scale.Y));
	};

	/// @func get_random_position()
	///
	/// @desc Retrieves a random position on the terrain.
	///
	/// @return {Struct.BBMOD_Vec3} A random position on the terrain.
	static get_random_position = function () {
		gml_pragma("forceinline");
		var _x = Position.X + (random(Size.X) * Scale.X);
		var _y = Position.Y + (random(Size.Y) * Scale.Y);
		var _z = get_height(_x, _y);
		return new BBMOD_Vec3(_x, _y, _z);
	};

	/// @func from_heightmap(_sprite[, _subimage])
	///
	/// @desc Initializes terrain height from a sprite.
	///
	/// @param {Asset.GMSprite} _sprite The heightmap sprite.
	/// @param {Real} [_subimage] The subimage to use for the heightmap.
	/// Defaults to 0.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static from_heightmap = function (_sprite, _subimage=0) {
		var _spriteWidth = sprite_get_width(_sprite);
		var _spriteHeight = sprite_get_height(_sprite);

		Size.X = _spriteWidth;
		Size.Y = _spriteHeight;

		ds_grid_resize(__height, _spriteWidth, _spriteHeight);
		ds_grid_clear(__height, 0);

		ds_grid_resize(__normalX, _spriteWidth, _spriteHeight);
		ds_grid_clear(__normalX, 0);

		ds_grid_resize(__normalY, _spriteWidth, _spriteHeight);
		ds_grid_clear(__normalY, 0);

		ds_grid_resize(__normalZ, _spriteWidth, _spriteHeight);
		ds_grid_clear(__normalZ, 1);

		ds_grid_resize(__normalSmoothX, _spriteWidth, _spriteHeight);
		ds_grid_clear(__normalSmoothX, 0);

		ds_grid_resize(__normalSmoothY, _spriteWidth, _spriteHeight);
		ds_grid_clear(__normalSmoothY, 0);

		ds_grid_resize(__normalSmoothZ, _spriteWidth, _spriteHeight);
		ds_grid_clear(__normalSmoothZ, 1);

		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());

		var _surface = surface_create(_spriteWidth, _spriteHeight);
		surface_set_target(_surface);
		draw_sprite(_sprite, _subimage, 0, 0);
		surface_reset_target();

		gpu_pop_state();

		var _buffer = buffer_create(_spriteWidth * _spriteHeight * 4, buffer_fast, 1);
		buffer_get_surface(_buffer, _surface, 0);
		surface_free(_surface);
		// Offset to the second byte, just in case the format was ARGB for example.
		buffer_seek(_buffer, buffer_seek_start, 1);

		var _j = 0;
		repeat (_spriteHeight)
		{
			var _i = 0;
			repeat (_spriteWidth)
			{
				__height[# _i++, _j] = buffer_read(_buffer, buffer_u8);
				buffer_seek(_buffer, buffer_seek_relative, 3);
			}
			++_j;
		}

		buffer_delete(_buffer);

		return self;
	};

	/// @func smooth_height()
	///
	/// @desc Smoothens out the terrain's height.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static smooth_height = function () {
		var _width = ds_grid_width(__height);
		var _height = ds_grid_height(__height);
		var _heightSmooth = ds_grid_create(_width, _height);

		for (var x1 = 0; x1 < _width; ++x1)
		{
			for (var y1 = 0; y1 < _height; ++y1)
			{
				_heightSmooth[# x1, y1] = ds_grid_get_mean(__height, x1 - 1, y1 - 1, x1 + 1, y1 + 1);
			}
		}

		ds_grid_copy(__height, _heightSmooth);
		ds_grid_destroy(_heightSmooth);

		return self;
	};

	/// @func get_height_index(_i, _j)
	///
	/// @desc Retrieves terrain's height at given index.
	///
	/// @param {Real} _i The X coordinate in the terrain's height grid.
	/// @param {Real} _j The Y coordinate in the terrain's height grid.
	///
	/// @return {Real} The terrain's height at given index.
	///
	/// @see BBMOD_Terrain.__height
	static get_height_index = function (_i, _j) {
		gml_pragma("forceinline");
		return __height[#
			clamp(_i, 0, ds_grid_width(__height) - 1),
			clamp(_j, 0, ds_grid_height(__height) - 1)
		];
	};

	/// @func get_height(_x, _y)
	///
	/// @desc Retrieves terrain's height at given coordinate.
	///
	/// @param {Real} _x The x position to get the height at.
	/// @param {Real} _y The y position to get the height at.
	///
	/// @return {Real} The terrain's height at given coordinate or `undefined`
	/// if the coordinate is outside of the terrain.
	static get_height = function (_x, _y) {
		gml_pragma("forceinline");
		var _xScaled = (_x - Position.X) / Scale.X;
		var _yScaled = (_y - Position.Y) / Scale.Y;
		if (_xScaled < 0.0 || _xScaled > Size.X
			|| _yScaled < 0.0 || _yScaled > Size.Y)
		{
			return undefined;
		}
		var _imax = ds_grid_width(__height) - 1;
		var _jmax = ds_grid_height(__height) - 1;
		var _i1 = floor(_xScaled);
		var _j1 = floor(_yScaled);
		var _h1 = __height[# clamp(_i1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h2 = __height[# clamp(_i1 + 1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h3 = __height[# clamp(_i1 + 1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		var _h4 = __height[# clamp(_i1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		var _offsetX = frac(_xScaled);
		var _offsetY = frac(_yScaled);
		// TODO: Optimize retrieving terrain height
		if (_offsetX <= _offsetY)
		{
			return Position.Z + (_h4 + (_h1-_h4)*(1.0-_offsetY) + (_h3-_h4)*(_offsetX)) * Scale.Z;
		}
		return Position.Z + (_h2 + (_h1-_h2)*(1.0-_offsetX) + (_h3-_h2)*(_offsetY)) * Scale.Z;
	};

	/// @func get_normal(_x, _y)
	///
	/// @desc Retrieves terrain's normal at given coordinate.
	///
	/// @param {Real} _x The x position to get the normal at.
	/// @param {Real} _y The y position to get the normal at.
	///
	/// @return {Struct.BBMOD_Vec3} The terrain's normal at given coordinate or
	/// `undefined` if the coordinate is outside of the terrain.
	static get_normal = function (_x, _y) {
		gml_pragma("forceinline");
		var _xScaled = (_x - Position.X) / Scale.X;
		var _yScaled = (_y - Position.Y) / Scale.Y;
		if (_xScaled < 0.0 || _xScaled > Size.X
			|| _yScaled < 0.0 || _yScaled > Size.Y)
		{
			return undefined;
		}
		var _imax = ds_grid_width(__height) - 1;
		var _jmax = ds_grid_height(__height) - 1;
		var _i1 = floor(_xScaled);
		var _j1 = floor(_yScaled);
		var _h1 = __height[# clamp(_i1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h2 = __height[# clamp(_i1 + 1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h3 = __height[# clamp(_i1 + 1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		var _h4 = __height[# clamp(_i1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		// TODO: Optimize retrieving terrain normal
		if (frac(_xScaled) <= frac(_yScaled))
		{
			return (new BBMOD_Vec3(0.0, -Scale.Y, (_h1 - _h4) * Scale.Z))
				.Cross(new BBMOD_Vec3(Scale.X, 0.0, (_h3 - _h4) * Scale.Z))
				.Normalize();
		}
		return (new BBMOD_Vec3(0.0, Scale.Y, (_h3 - _h2) * Scale.Z))
			.Cross(new BBMOD_Vec3(-Scale.X, 0.0, (_h1 - _h2) * Scale.Z))
			.Normalize();
	};

	/// @func get_layer(_x, _y[, _threshold])
	///
	/// @desc Retrieves the topmost splatmap layer at given coordinate.
	///
	/// @param {Real} _x The x coordinate to retrieve the layer at.
	/// @param {Real} _y The y coordinate to retrieve the layer at.
	/// @param {Real} [_threshold] The minimum required opacity. Defaults to 0.5.
	///
	/// @return {Real} The topmost splatmap layer at given coordinate. Returns
	/// `undefined` if the coordinate is outside of the terrain or if no layer
	/// was found!
	///
	/// @note Method {@link BBMOD_Terrain.build_layer_index} needs to be called
	/// first!
	static get_layer = function (_x, _y, _threshold=0.5) {
		gml_pragma("forceinline");
		var _xScaled = (_x - Position.X) / Scale.X;
		var _yScaled = (_y - Position.Y) / Scale.Y;
		if (_xScaled < 0.0 || _xScaled > Size.X
			|| _yScaled < 0.0 || _yScaled > Size.Y)
		{
			return undefined;
		}
		var _i = floor((_xScaled / Size.X) * ds_grid_width(__splatmapGrid));
		var _j = floor((_yScaled / Size.Y) * ds_grid_height(__splatmapGrid));
		var _rgba = __splatmapGrid[# _i, _j];
		// TODO: Could be a loop
		if (Layer[4] != undefined && (((_rgba & $FF) >> 0) / 255.0) >= _threshold)
		{
			return 4;
		}
		if (Layer[3] != undefined && (((_rgba & $FF00) >> 8) / 255.0) >= _threshold)
		{
			return 3;
		}
		if (Layer[2] != undefined && (((_rgba & $FF0000) >> 16) / 255.0) >= _threshold)
		{
			return 2;
		}
		if (Layer[1] != undefined && (((_rgba & $FF000000) >> 24) / 255.0) >= _threshold)
		{
			return 1;
		}
		return ((Layer[0] != undefined) ? 0 : undefined);
	};

	/// @func build_normals()
	///
	/// @desc Rebuilds normal vectors.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static build_normals = function () {
		var _i = 0;
		repeat (ds_grid_width(__height))
		{
			var _j = 0;
			repeat (ds_grid_height(__height))
			{
				var _nx = get_height_index(_i - 1, _j) - get_height_index(_i + 1, _j);
				var _ny = get_height_index(_i, _j - 1) - get_height_index(_i, _j + 1);
				var _nz = 2.0;
				var _r = sqrt((_nx * _nx) + (_ny * _ny) + (_nz * _nz));
				_nx /= _r;
				_ny /= _r;
				_nz /= _r;
				__normalX[# _i, _j] = _nx;
				__normalY[# _i, _j] = _ny;
				__normalZ[# _i, _j] = _nz;
				++_j;
			}
			++_i;
		}
		return self;
	};

	/// @func build_smooth_normals()
	///
	/// @desc Rebuilds smooth normals.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	///
	/// @note {@link BBMOD_Terrain.build_normals} should be called first!
	static build_smooth_normals = function () {
		var _width = ds_grid_width(__height);
		var _height = ds_grid_height(__height);
		for (var x1 = 0; x1 < _width; ++x1)
		{
			for (var y1 = 0; y1 < _height; ++y1)
			{
				var _nx = ds_grid_get_mean(__normalX, x1 - 1, y1 - 1, x1 + 1, y1 + 1);
				var _ny = ds_grid_get_mean(__normalY, x1 - 1, y1 - 1, x1 + 1, y1 + 1);
				var _nz = ds_grid_get_mean(__normalZ, x1 - 1, y1 - 1, x1 + 1, y1 + 1);
				var _r = sqrt((_nx * _nx) + (_ny * _ny) + (_nz * _nz));
				_nx /= _r;
				_ny /= _r;
				_nz /= _r;
				__normalSmoothX[# x1, y1] = _nx;
				__normalSmoothY[# x1, y1] = _ny;
				__normalSmoothZ[# x1, y1] = _nz;
			}
		}
		return self;
	};

	/// @func build_layer_index()
	///
	/// @desc Builds an index of layers using the current splatmap.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static build_layer_index = function () {
		var _width = 1.0 / texture_get_texel_width(Splatmap);
		var _height = 1.0 / texture_get_texel_height(Splatmap);
		var _buffer = array_create(4);
		var _surface = surface_create(_width, _height);

		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		gpu_set_blendenable(false);

		for (var i = 0; i < 4; ++i)
		{
			shader_set(BBMOD_ShExtractSplatmapLayer);
			texture_set_stage(shader_get_sampler_index(BBMOD_ShExtractSplatmapLayer, "bbmod_Splatmap"), Splatmap);
			shader_set_uniform_i(shader_get_uniform(BBMOD_ShExtractSplatmapLayer, "bbmod_SplatmapIndex"), i);

			surface_set_target(_surface);
			draw_clear_alpha(0, 0);
			// We just need something that has UVs 0..1
			draw_sprite_stretched(BBMOD_SprDefaultBaseOpacity, 0, 0, 0, _width, _height);
			surface_reset_target();

			shader_reset();

			_buffer[@ i] = buffer_create(_width * _height * 4, buffer_fast, 1);
			buffer_get_surface(_buffer[i], _surface, 0);
			// Offset to the second byte, just in case the format was ARGB for example.
			buffer_seek(_buffer[i], buffer_seek_start, 1);
		}

		gpu_pop_state();
		surface_free(_surface);

		ds_grid_resize(__splatmapGrid, _width, _height);
		ds_grid_clear(__splatmapGrid, 0);

		var _j = 0;
		repeat (_height)
		{
			var _i = 0;
			repeat (_width)
			{
				__splatmapGrid[# _i, _j] = (0
					| (buffer_read(_buffer[0], buffer_u8) << 24)
					| (buffer_read(_buffer[1], buffer_u8) << 16)
					| (buffer_read(_buffer[2], buffer_u8) << 8)
					| buffer_read(_buffer[3], buffer_u8));
				buffer_seek(_buffer[0], buffer_seek_relative, 3);
				buffer_seek(_buffer[1], buffer_seek_relative, 3);
				buffer_seek(_buffer[2], buffer_seek_relative, 3);
				buffer_seek(_buffer[3], buffer_seek_relative, 3);
				++_i;
			}
			++_j;
		}

		buffer_delete(_buffer[0]);
		buffer_delete(_buffer[1]);
		buffer_delete(_buffer[2]);
		buffer_delete(_buffer[3]);

		return self;
	};

	/// @func build_mesh()
	///
	/// @desc Rebuilds the terrain's mesh.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static build_mesh = function () {
		if (VertexBuffer != undefined)
		{
			vertex_delete_buffer(VertexBuffer);
		}
		var _height = __height;
		var _rows = ds_grid_width(_height);
		var _cols = ds_grid_height(_height);
		var _vbuffer = vertex_create_buffer();
		vertex_begin(_vbuffer, VertexFormat.Raw);
		var _i = 0;
		repeat (_rows - 1)
		{
			var _j = 0;
			repeat (_cols - 1)
			{
				var _z1 = _height[# _i, _j];
				var _z2 = _height[# _i + 1, _j];
				var _z3 = _height[# _i + 1, _j + 1];
				var _z4 = _height[# _i, _j + 1];

				var _x1 = _i;
				var _y1 = _j;
				var _x2 = _i + 1;
				var _y2 = _j;
				var _x3 = _i + 1;
				var _y3 = _j + 1;
				var _x4 = _i;
				var _y4 = _j + 1;

				var _u1 = _i / _rows;
				var _v1 = _j / _cols;
				var _u2 = (_i + 1) / _rows;
				var _v2 = _j / _cols;
				var _u3 = (_i + 1) / _rows;
				var _v3 = (_j + 1) / _cols;
				var _u4 = _i / _rows;
				var _v4 = (_j + 1) / _cols;

				var _n1X = __normalSmoothX[# _i, _j];
				var _n1Y = __normalSmoothY[# _i, _j];
				var _n1Z = __normalSmoothZ[# _i, _j];

				var _n2X = __normalSmoothX[# _i + 1, _j];
				var _n2Y = __normalSmoothY[# _i + 1, _j];
				var _n2Z = __normalSmoothZ[# _i + 1, _j];

				var _n3X = __normalSmoothX[# _i + 1, _j + 1];
				var _n3Y = __normalSmoothY[# _i + 1, _j + 1];
				var _n3Z = __normalSmoothZ[# _i + 1, _j + 1];

				var _n4X = __normalSmoothX[# _i, _j + 1];
				var _n4Y = __normalSmoothY[# _i, _j + 1];
				var _n4Z = __normalSmoothZ[# _i, _j + 1];

				//var _t1X = - _n1X * _n1Y;
				//var _t1Y = _n1X * _n1X - (-_n1Z) * _n1Z;
				//var _t1Z = (-_n1Z) * _n1Y;

				//var _t2X = - _n2X * _n2Y;
				//var _t2Y = _n2X * _n2X - (-_n2Z) * _n2Z;
				//var _t2Z = (-_n2Z) * _n2Y;

				//var _t3X = - _n3X * _n3Y;
				//var _t3Y = _n3X * _n3X - (-_n3Z) * _n3Z;
				//var _t3Z = (-_n3Z) * _n3Y;

				//var _t4X = - _n4X * _n4Y;
				//var _t4Y = _n4X * _n4X - (-_n4Z) * _n4Z;
				//var _t4Z = (-_n4Z) * _n4Y;

				// 1
				// |\
				// 4-3
				var pos1x = _x1;
				var pos1y = _y1;
				var pos1z = _z1;
				var pos2x = _x3;
				var pos2y = _y3;
				var pos2z = _z3;
				var pos3x = _x4;
				var pos3y = _y4;
				var pos3z = _z4;
				var uv1x = _u1;
				var uv1y = _v1;
				var uv2x = _u3;
				var uv2y = _v3;
				var uv3x = _u4;
				var uv3y = _v4;
				var edge1x = pos2x - pos1x;
				var edge1y = pos2y - pos1y;
				var edge1z = pos2z - pos1z;
				var edge2x = pos3x - pos1x;
				var edge2y = pos3y - pos1y;
				var edge2z = pos3z - pos1z;
				var deltaUV1x = uv2x - uv1x;
				var deltaUV1y = uv2y - uv1y;
				var deltaUV2x = uv3x - uv1x;
				var deltaUV2y = uv3y - uv1y;
				var f = 1.0 / (deltaUV1x * deltaUV2y - deltaUV2x * deltaUV1y);
				var tangent1x = f * (deltaUV2y * edge1x - deltaUV1y * edge2x);
				var tangent1y = f * (deltaUV2y * edge1y - deltaUV1y * edge2y);
				var tangent1z = f * (deltaUV2y * edge1z - deltaUV1y * edge2z);
				var bitangent1x = f * (-deltaUV2x * edge1x + deltaUV1x * edge2x);
				var bitangent1y = f * (-deltaUV2x * edge1y + deltaUV1x * edge2y);
				var bitangent1z = f * (-deltaUV2x * edge1z + deltaUV1x * edge2z);
				var _dot = (new BBMOD_Vec3(_n1X, _n1Y, _n1Z))
					.Cross(new BBMOD_Vec3(tangent1x, tangent1y, tangent1z))
					.Dot(new BBMOD_Vec3(bitangent1x, bitangent1y, bitangent1z));
				var _sign = (_dot < 0.0) ? -1.0 : 1.0;

				vertex_position_3d(_vbuffer, _x1, _y1, _z1);
				vertex_normal(_vbuffer, _n1X, _n1Y, _n1Z);
				vertex_texcoord(_vbuffer, _u1, _v1);
				vertex_float4(_vbuffer, tangent1x, tangent1y, tangent1z, _sign);

				vertex_position_3d(_vbuffer, _x3, _y3, _z3);
				vertex_normal(_vbuffer, _n3X, _n3Y, _n3Z);
				vertex_texcoord(_vbuffer, _u3, _v3);
				vertex_float4(_vbuffer, tangent1x, tangent1y, tangent1z, _sign);

				vertex_position_3d(_vbuffer, _x4, _y4, _z4);
				vertex_normal(_vbuffer, _n4X, _n4Y, _n4Z);
				vertex_texcoord(_vbuffer, _u4, _v4);
				vertex_float4(_vbuffer, tangent1x, tangent1y, tangent1z, _sign);

				// 1-2
				//  \|
				//   3
				var pos1x = _x1;
				var pos1y = _y1;
				var pos1z = _z1;
				var pos2x = _x2;
				var pos2y = _y2;
				var pos2z = _z2;
				var pos3x = _x3;
				var pos3y = _y3;
				var pos3z = _z3;
				var uv1x = _u1;
				var uv1y = _v1;
				var uv2x = _u2;
				var uv2y = _v2;
				var uv3x = _u3;
				var uv3y = _v3;
				var edge1x = pos2x - pos1x;
				var edge1y = pos2y - pos1y;
				var edge1z = pos2z - pos1z;
				var edge2x = pos3x - pos1x;
				var edge2y = pos3y - pos1y;
				var edge2z = pos3z - pos1z;
				var deltaUV1x = uv2x - uv1x;
				var deltaUV1y = uv2y - uv1y;
				var deltaUV2x = uv3x - uv1x;
				var deltaUV2y = uv3y - uv1y;
				var f = 1.0 / (deltaUV1x * deltaUV2y - deltaUV2x * deltaUV1y);
				var tangent1x = f * (deltaUV2y * edge1x - deltaUV1y * edge2x);
				var tangent1y = f * (deltaUV2y * edge1y - deltaUV1y * edge2y);
				var tangent1z = f * (deltaUV2y * edge1z - deltaUV1y * edge2z);
				var bitangent1x = f * (-deltaUV2x * edge1x + deltaUV1x * edge2x);
				var bitangent1y = f * (-deltaUV2x * edge1y + deltaUV1x * edge2y);
				var bitangent1z = f * (-deltaUV2x * edge1z + deltaUV1x * edge2z);
				var _dot = (new BBMOD_Vec3(_n1X, _n1Y, _n1Z))
					.Cross(new BBMOD_Vec3(tangent1x, tangent1y, tangent1z))
					.Dot(new BBMOD_Vec3(bitangent1x, bitangent1y, bitangent1z));
				var _sign = (_dot < 0.0) ? -1.0 : 1.0;

				vertex_position_3d(_vbuffer, _x1, _y1, _z1);
				vertex_normal(_vbuffer, _n1X, _n1Y, _n1Z);
				vertex_texcoord(_vbuffer, _u1, _v1);
				vertex_float4(_vbuffer, tangent1x, tangent1y, tangent1z, _sign);

				vertex_position_3d(_vbuffer, _x2, _y2, _z2);
				vertex_normal(_vbuffer, _n2X, _n2Y, _n2Z);
				vertex_texcoord(_vbuffer, _u2, _v2);
				vertex_float4(_vbuffer, tangent1x, tangent1y, tangent1z, _sign);

				vertex_position_3d(_vbuffer, _x3, _y3, _z3);
				vertex_normal(_vbuffer, _n3X, _n3Y, _n3Z);
				vertex_texcoord(_vbuffer, _u3, _v3);
				vertex_float4(_vbuffer, tangent1x, tangent1y, tangent1z, _sign);

				++_j;
			}
			++_i;
		}
		vertex_end(_vbuffer);
		vertex_freeze(_vbuffer);
		VertexBuffer = _vbuffer;
		return self;
	};

	/// @func submit()
	///
	/// @desc Immediately submits the terrain mesh for rendering.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static submit = function () {
		var _matrix = matrix_build(Position.X, Position.Y, Position.Z, 0, 0, 0, Scale.X, Scale.Y, Scale.Z);
		var _normalMatrix = bbmod_matrix_build_normalmatrix(_matrix);
		matrix_set(matrix_world, _matrix);
		var i = 0;
		repeat (5)
		{
			var _mat = Layer[i];
			if (_mat != undefined && _mat.apply(VertexFormat))
			{
				var _shaderCurrent = shader_current();
				var _uSplatmap = shader_get_sampler_index(_shaderCurrent, "bbmod_Splatmap");
				var _uSplatmapIndex = shader_get_uniform(_shaderCurrent, "bbmod_SplatmapIndex");
				var _uTextureScale = shader_get_uniform(_shaderCurrent, "bbmod_TextureScale");
				var _uNormalMatrix = shader_get_uniform(_shaderCurrent, "bbmod_NormalMatrix");
				texture_set_stage(_uSplatmap, Splatmap);
				shader_set_uniform_i(_uSplatmapIndex, i - 1);
				shader_set_uniform_f(_uTextureScale, TextureRepeat.X, TextureRepeat.Y);
				shader_set_uniform_matrix_array(_uNormalMatrix, _normalMatrix);
				vertex_submit(VertexBuffer, pr_trianglelist, _mat.BaseOpacity);
			}
			++i;
		}
		return self;
	};

	/// @func render()
	///
	/// @desc Enqueues the terrain mesh for rendering.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static render = function () {
		var _matrix = matrix_build(Position.X, Position.Y, Position.Z, 0, 0, 0, Scale.X, Scale.Y, Scale.Z);
		var _normalMatrix = bbmod_matrix_build_normalmatrix(_matrix);
		var i = 0;
		repeat (5)
		{
			var _mat = Layer[i];
			if (_mat != undefined)
			{
				RenderQueue
					.apply_material(_mat, VertexFormat, (i == 0) ? ~0 : (1 << BBMOD_ERenderPass.Forward))
					.begin_conditional_block();

				if (i == 0)
				{
					RenderQueue.set_gpu_blendenable(false);
				}
				else
				{
					RenderQueue.set_gpu_colorwriteenable(true, true, true, false);
				}

				RenderQueue
					.set_gpu_zwriteenable(i == 0)
					.set_gpu_zfunc((i == 0) ? cmpfunc_lessequal : cmpfunc_equal)
					.set_sampler("bbmod_Splatmap", Splatmap)
					.set_uniform_i("bbmod_SplatmapIndex", i - 1)
					.set_uniform_f2("bbmod_TextureScale", TextureRepeat.X, TextureRepeat.Y)
					.set_uniform_matrix_array("bbmod_NormalMatrix", _normalMatrix)
					.set_world_matrix(_matrix)
					.submit_vertex_buffer(VertexBuffer, pr_trianglelist, _mat.BaseOpacity)
					.reset_material()
					.end_conditional_block();
			}
			++i;
		}
		return self;
	};

	static destroy = function () {
		Class_destroy();
		ds_grid_destroy(__splatmapGrid);
		ds_grid_destroy(__height);
		ds_grid_destroy(__normalX);
		ds_grid_destroy(__normalY);
		ds_grid_destroy(__normalZ);
		ds_grid_destroy(__normalSmoothX);
		ds_grid_destroy(__normalSmoothY);
		ds_grid_destroy(__normalSmoothZ);
		if (VertexBuffer != undefined)
		{
			vertex_delete_buffer(VertexBuffer);
		}
		return undefined;
	};

	if (_heightmap != undefined)
	{
		from_heightmap(_heightmap, _subimage);
		smooth_height();
		build_normals();
		build_smooth_normals();
		build_mesh();
	}
}
