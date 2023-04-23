/// @func BBMOD_StaticBatch(_vformat)
///
/// @extends BBMOD_Class
///
/// @desc A static batch is a structure that allows you to compose static models
/// into a single one. Compared to {@link BBMOD_Model.submit}, this drastically
/// reduces draw calls and increases performance, but requires more memory.
/// Current limitation is that the added models must use the same single
/// material.
///
/// @param {Struct.BBMOD_VertexFormat} _vformat The vertex format of the static
/// batch.
/// All models added to the same static batch must have the same vertex format.
/// This vertex format must not contain bone data!
///
/// @example
/// ```gml
/// modTree = new BBMOD_Model("Tree.bbmod");
/// var _vformat = modTree.get_vertex_format();
/// batch = new BBMOD_StaticBatch(_vformat);
/// batch.start();
/// with (OTree)
/// {
///     var _transform = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
///     other.batch.add(other.modTree, _transform);
/// }
/// batch.finish();
/// batch.freeze();
/// ```
///
/// @see BBMOD_Model.get_vertex_format
/// @see BBMOD_DynamicBatch
///
/// @deprecated
function BBMOD_StaticBatch(_vformat)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

	/// @var {Id.__vertexBuffer} A vertex buffer.
	/// @private
	__vertexBuffer = vertex_create_buffer();

	/// @var {Struct.BBMOD_VertexFormat} The format of the vertex buffer.
	/// @private
	__vertexFormat = _vformat;

	/// @var {Constant.__primitiveType} The primitive type of the batch.
	/// @private
	__primitiveType = undefined;

	/// @func start()
	///
	/// @desc Begins adding models into the static batch.
	///
	/// @see BBMOD_StaticBatch.add
	/// @see BBMOD_StaticBatch.finish
	///
	/// @return {Struct.BBMOD_StaticBatch} Returns `self`.
	static start = function () {
		gml_pragma("forceinline");
		vertex_begin(__vertexBuffer, __vertexFormat.Raw);
		return self;
	};

	/// @func add(_model, _transform)
	///
	/// @desc Adds a model to the static batch.
	///
	/// @param {Struct.BBMOD_Model} _model The model.
	/// @param {Array<Real>} _transform A transformation matrix of the model.
	///
	/// @return {Struct.BBMOD_StaticBatch} Returns `self`.
	///
	/// @example
	/// ```gml
	/// modTree = new BBMOD_Model("Tree.bbmod");
	/// var _vformat = modTree.get_vertex_format();
	/// batch = new BBMOD_StaticBatch(_vformat);
	/// batch.start();
	/// with (OTree)
	/// {
	///     var _transform = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
	///     other.batch.add(other.modTree, _transform);
	/// }
	/// batch.finish();
	/// batch.freeze();
	/// ```
	///
	/// @note You must first call {@link BBMOD_StaticBatch.begin} before using
	/// this function!
	///
	/// @see BBMOD_StaticBatch.finish
	static add = function (_model, _transform) {
		gml_pragma("forceinline");
		_model.__to_static_batch(self, _transform);
		return self;
	};

	/// @func finish()
	///
	/// @desc Ends adding models into the static batch.
	///
	/// @return {Struct.BBMOD_StaticBatch} Returns `self`.
	///
	/// @see BBMOD_StaticBatch.start
	static finish = function () {
		gml_pragma("forceinline");
		vertex_end(__vertexBuffer);
		return self;
	};

	/// @func freeze()
	///
	/// @desc Freezes the static batch. This makes it render faster, but disables
	/// adding more models.
	///
	/// @return {Struct.BBMOD_StaticBatch} Returns `self`.
	static freeze = function () {
		gml_pragma("forceinline");
		vertex_freeze(__vertexBuffer);
		return self;
	};

	/// @func submit(_material)
	///
	/// @desc Immediately submits the static batch for rendering.
	///
	/// @param {Struct.BBMOD_BaseMaterial} _material A material.
	///
	/// @return {Struct.BBMOD_StaticBatch} Returns `self`.
	///
	/// @note The static batch is *not* submitted if the material used is not
	/// compatible with the current render pass!
	///
	/// @see BBMOD_StaticBatch.render
	/// @see BBMOD_BaseMaterial
	/// @see BBMOD_ERenderPass
	static submit = function (_material) {
		gml_pragma("forceinline");
		if (!_material.apply(__vertexFormat))
		{
			return self;
		}
		vertex_submit(__vertexBuffer, __primitiveType, _material.BaseOpacity);
		return self;
	};

	/// @func render(_material)
	///
	/// @desc Enqueues the static batch for rendering.
	///
	/// @param {Struct.BBMOD_BaseMaterial} _material A material.
	///
	/// @return {Struct.BBMOD_StaticBatch} Returns `self`.
	///
	/// @see BBMOD_StaticBatch.submit
	/// @see BBMOD_BaseMaterial
	static render = function (_material) {
		gml_pragma("forceinline");
		_material.RenderQueue.draw_mesh(
			__vertexBuffer, __vertexFormat, __primitiveType, -1, _material, matrix_get(matrix_world));
		return self;
	};

	static destroy = function () {
		Class_destroy();
		vertex_delete_buffer(__vertexBuffer);
		return undefined;
	};
}
