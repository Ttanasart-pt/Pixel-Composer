/// @macro {Struct.BBMOD_VertexFormat} The default vertex format for static
/// models.
/// @see BBMOD_VertexFormat
#macro BBMOD_VFORMAT_DEFAULT __bbmod_vformat_default()

/// @macro {Struct.BBMOD_VertexFormat} The default vertex format for animated
/// models.
/// @see BBMOD_VertexFormat
#macro BBMOD_VFORMAT_DEFAULT_ANIMATED __bbmod_vformat_default_animated()

/// @macro {Struct.BBMOD_VertexFormat} The default vertex format for dynamically
/// batched models.
/// @see BBMOD_VertexFormat
/// @see BBMOD_DynamicBatch
#macro BBMOD_VFORMAT_DEFAULT_BATCHED __bbmod_vformat_default_batched()

/// @func BBMOD_VertexFormat([_confOrVertices[, _normals[, _uvs[, _colors[, _tangentw[, _bones[, _ids]]]]]]])
///
/// @extends BBMOD_Class
///
/// @desc A wrapper of a raw GameMaker vertex format.
///
/// @param {Struct, Bool} [_confOrVertices] Either a struct with keys called
/// after properties of `BBMOD_VertexFormat` and values `true` or `false`,
/// depending on whether the vertex format should have the property, or `true`,
/// since every vertex format must have vertex positions.
/// @param {Bool} [_normals] If `true` then the vertex format must have normal
/// vectors. Defaults to `false`. Used only if the first argument is not a
/// struct.
/// @param {Bool} [_uvs] If `true` then the vertex format must have texture
/// coordinates. Defaults to `false`. Used only if the first argument is not a
/// struct.
/// @param {Bool} [_colors] If `true` then the vertex format must have vertex
/// colors. Defaults to `false`. Used only if the first argument is not a
/// struct.
/// @param {Bool} [_tangentw] If `true` then the vertex format must have tangent
/// vectors and bitangent signs. Defaults to `false`. Used only if the first
/// argument is not a struct.
/// @param {Bool} [_bones] If `true` then the vertex format must have vertex
/// weights and bone indices. Defaults to `false`. Used only if the first
/// argument is not a struct.
/// @param {Bool} [_ids] If `true` then the vertex format must have ids for
/// dynamic batching. Defaults to `false`. Used only if the first argument
/// is not a struct.
function BBMOD_VertexFormat(
	_confOrVertices=true,
	_normals=false,
	_uvs=false,
	_colors=false,
	_tangentw=false,
	_bones=false,
	_ids=false
) : BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	var _isConf = is_struct(_confOrVertices);

	/// @var {Bool} If `true` then the vertex format has vertices. Should always
	/// be `true`!
	/// @readonly
	Vertices = _isConf
		? (_confOrVertices[$ "Vertices"] ?? true)
		: _confOrVertices;

	/// @var {Bool} If `true` then the vertex format has normal vectors.
	/// @readonly
	Normals = _isConf
		? (_confOrVertices[$ "Normals"] ?? false)
		: _normals;

	/// @var {Bool} If `true` then the vertex format has texture coordinates.
	/// @readonly
	TextureCoords = _isConf
		? (_confOrVertices[$ "TextureCoords"] ?? false)
		: _uvs;

	/// @var {Bool} If `true` then the vertex format has a second texture
	/// coordinates layer.
	/// @readonly
	TextureCoords2 = _isConf
		? (_confOrVertices[$ "TextureCoords2"] ?? false)
		: false;

	/// @var {Bool} If `true` then the vertex format has vertex colors.
	/// @readonly
	Colors = _isConf
		? (_confOrVertices[$ "Colors"] ?? false)
		: _colors;

	/// @var {Bool} If `true` then the vertex format has tangent vectors and
	/// bitangent sign.
	/// @readonly
	TangentW = _isConf
		? (_confOrVertices[$ "TangentW"] ?? false)
		: _tangentw;

	/// @var {Bool} If `true` then the vertex format has vertex weights and bone
	/// indices.
	Bones = _isConf
		? (_confOrVertices[$ "Bones"] ?? false)
		: _bones;

	/// @var {Bool} If `true` then the vertex format has ids for dynamic
	/// batching.
	/// @readonly
	Ids = _isConf
		? (_confOrVertices[$ "Ids"] ?? false)
		: _ids;

	/// @var {Id.VertexFormat} The raw vertex format.
	/// @readonly
	Raw = undefined;

	/// @var {Ds.Map} A map of existing raw vertex formats (`Real`s to
	/// `Id.VertexFormat`s).
	/// @private
	static __formats = ds_map_create();

	/// @func get_hash()
	///
	/// @desc Makes a hash based on the vertex format properties. Vertex buffers
	/// with same propereties will have the same hash.
	///
	/// @return {Real} The hash.
	static get_hash = function () {
		return (0
			| (Vertices << 0)
			| (Normals << 1)
			| (TextureCoords << 2)
			| (TextureCoords2 << 3)
			| (Colors << 4)
			| (TangentW << 5)
			| (Bones << 6)
			| (Ids << 7)
			);
	};

	/// @func get_byte_size()
	///
	/// @desc Retrieves the size of a single vertex using the vertex format in
	/// bytes.
	///
	/// @return {Real} The byte size of a single vertex using the vertex format.
	static get_byte_size = function () {
		gml_pragma("forceinline");
		return (0
			+ (buffer_sizeof(buffer_f32) * 3 * Vertices)
			+ (buffer_sizeof(buffer_f32) * 3 * Normals)
			+ (buffer_sizeof(buffer_f32) * 2 * TextureCoords)
			+ (buffer_sizeof(buffer_f32) * 2 * TextureCoords2)
			+ (buffer_sizeof(buffer_u32) * 1 * Colors)
			+ (buffer_sizeof(buffer_f32) * 4 * TangentW)
			+ (buffer_sizeof(buffer_f32) * 8 * Bones)
			+ (buffer_sizeof(buffer_f32) * 1 * Ids)
		);
	};

	var _hash = get_hash();

	if (ds_map_exists(__formats, _hash))
	{
		Raw = __formats[? _hash];
	}
	else
	{
		vertex_format_begin();

		if (Vertices)
		{
			vertex_format_add_position_3d();
		}

		if (Normals)
		{
			vertex_format_add_normal();
		}

		if (TextureCoords)
		{
			vertex_format_add_texcoord();
		}

		if (TextureCoords2)
		{
			vertex_format_add_texcoord();
		}

		if (Colors)
		{
			vertex_format_add_colour();
		}

		if (TangentW)
		{
			vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
		}

		if (Bones)
		{
			vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
			vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
		}

		if (Ids)
		{
			vertex_format_add_custom(vertex_type_float1, vertex_usage_texcoord);
		}

		Raw = vertex_format_end();
		__formats[? _hash] = Raw;
	}
}

/// @func __bbmod_vertex_format_save(_vertexFormat, _buffer[, _versionMinor])
///
/// @desc Saves a vertex format to a buffer.
///
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format to save.
/// @param {Id.Buffer} _buffer The buffer to save the vertex format to.
/// @param {Real} [_versionMinor] The minor version of the BBMOD file format.
/// Defaults to {@link BBMOD_VERSION_MINOR}.
///
/// @private
function __bbmod_vertex_format_save(_vertexFormat, _buffer, _versionMinor=BBMOD_VERSION_MINOR)
{
	with (_vertexFormat)
	{
		buffer_write(_buffer, buffer_bool, Vertices);
		buffer_write(_buffer, buffer_bool, Normals);
		buffer_write(_buffer, buffer_bool, TextureCoords);
		if (_versionMinor >= 3)
		{
			buffer_write(_buffer, buffer_bool, TextureCoords2);
		}
		buffer_write(_buffer, buffer_bool, Colors);
		buffer_write(_buffer, buffer_bool, TangentW);
		buffer_write(_buffer, buffer_bool, Bones);
		buffer_write(_buffer, buffer_bool, Ids);
	}
}

/// @func __bbmod_vertex_format_load(_buffer[, _versionMinor])
///
/// @desc Loads a vertex format from a buffer.
///
/// @param {Id.Buffer} _buffer The buffer to load the vertex format from.
/// @param {Real} _versionMinor The minor version of the BBMOD file format.
/// Defaults to {@link BBMOD_VERSION_MINOR}.
///
/// @return {Struct.BBMOD_VertexFormat} The loaded vetex format.
///
/// @private
function __bbmod_vertex_format_load(_buffer, _versionMinor=BBMOD_VERSION_MINOR)
{
	var _vertices = buffer_read(_buffer, buffer_bool);
	var _normals = buffer_read(_buffer, buffer_bool);
	var _textureCoords = buffer_read(_buffer, buffer_bool);
	var _textureCoords2 = (_versionMinor >= 3)
		? buffer_read(_buffer, buffer_bool)
		: false;
	var _colors = buffer_read(_buffer, buffer_bool);
	var _tangentW = buffer_read(_buffer, buffer_bool);
	var _bones = buffer_read(_buffer, buffer_bool);
	var _ids = buffer_read(_buffer, buffer_bool);

	return new BBMOD_VertexFormat({
		"Vertices": _vertices,
		"Normals": _normals,
		"TextureCoords": _textureCoords,
		"TextureCoords2": _textureCoords2,
		"Colors": _colors,
		"TangentW": _tangentW,
		"Bones": _bones,
		"Ids": _ids,
	});
}

function __bbmod_vformat_default()
{
	static _vformat = new BBMOD_VertexFormat(
		true, true, true, false, true, false, false);
	return _vformat;
}

function __bbmod_vformat_default_animated()
{
	static _vformat = new BBMOD_VertexFormat(
		true, true, true, false, true, true, false);
	return _vformat;
}

function __bbmod_vformat_default_batched()
{
	static _vformat = new BBMOD_VertexFormat(
		true, true, true, false, true, false, true);
	return _vformat;
}
