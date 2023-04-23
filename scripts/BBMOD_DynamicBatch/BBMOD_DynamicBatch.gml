/// @macro {Real} Maximum number of vec4 uniforms for dynamic batch data
/// available in the default shaders. Equals to 192.
#macro BBMOD_MAX_BATCH_VEC4S 192

/// @func BBMOD_DynamicBatch([_model[, _size[, _slotsPerInstance]]])
///
/// @extends BBMOD_Class
///
/// @desc A dynamic batch is a structure that allows you to render multiple
/// instances of a single model at once, each with its own position, scale and
/// rotation. Compared to {@link BBMOD_Model.submit}, this drastically reduces
/// draw calls and increases performance, but requires more memory. Number of
/// model instances per batch is also affected by maximum number of uniforms
/// that a vertex shader can accept.
///
/// @param {Struct.BBMOD_Model} [_model] The model to create a dynamic batch of.
/// @param {Real} [_size] Number of model instances in the batch. Default value
/// is 32.
/// @param {Real} [_slotsPerInstance] Number of slots that each instance takes
/// in the data array. Default value is 12.
///
/// @example
/// Following code renders all instances of a car object in batches of 64.
/// ```gml
/// /// @desc Create event
/// modCar = new BBMOD_Model("Car.bbmod");
/// matCar = new BBMOD_DefaultMaterial(BBMOD_ShDefaultBatched,
///     sprite_get_texture(SprCar, 0));
/// carBatch = new BBMOD_DynamicBatch(modCar, 64);
///
/// /// @desc Draw event
/// carBatch.render_object(OCar, matCar);
/// ```
///
/// @see BBMOD_StaticBatch
function BBMOD_DynamicBatch(_model=undefined, _size=32, _slotsPerInstance=12)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

	/// @var {Struct.BBMOD_Model} A model that is being batched.
	/// @readonly
	Model = _model;

	/// @var {Struct.BBMOD_Model} The batched model.
	/// @readonly
	Batch = undefined;

	/// @var {Real} Number of model instances in the batch.
	/// @readonly
	Size = _size;

	/// @var {Real} Number of instances currently added to the dynamic batch.
	/// @readonly
	/// @see BBMOD_DynamicBatch.add_instance
	InstanceCount = 0;

	/// @var {Real} Number of slots that each instance takes in the data array.
	/// @readonly
	SlotsPerInstance = _slotsPerInstance;

	/// @var {Real} Total length of batch data array for a single draw call.
	/// @readonly
	BatchLength = Size * SlotsPerInstance;

	/// @var {Function} A function that writes instance data into the batch data
	/// array. It must take the instance, array and starting index as arguments!
	/// Defaults to {@link BBMOD_DynamicBatch.default_fn}.
	DataWriter = default_fn;

	/// @var {Array<Array<Real>>}
	/// @private
	__data = [];

	/// @var {Array<Array<Id.Instance>}}
	/// @private
	__ids = [];

	/// @var {Id.DsMap} Mapping from instances to indices at which they are
	/// stored in the data array.
	/// @private
	__instanceToIndex = ds_map_create();

	/// @var {Id.DsMap} Mapping from data array indices to instances that they
	/// hold.
	/// @private
	__indexToInstance = ds_map_create();

	// @func from_model(_model)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_Model} _model
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	static from_model = function (_model) {
		Model = _model;
		build_batch();
		return self;
	};

	/// @func __resize_data()
	///
	/// @desc Resizes `__data` and `__ids` arrays to required size.
	///
	/// @private
	static __resize_data = function () {
		var _requiredArrayCount = ceil(InstanceCount / Size);
		var _currentArrayCount = array_length(__data);

		if (_currentArrayCount > _requiredArrayCount)
		{
			array_resize(__data, _requiredArrayCount);
			array_resize(__ids, _requiredArrayCount);
		}
		else if (_currentArrayCount < _requiredArrayCount)
		{
			repeat (_requiredArrayCount - _currentArrayCount)
			{
				array_push(__data, array_create(BatchLength, 0.0));
				array_push(__ids, array_create(Size, 0.0));
			}
		}
	};

	/// @func add_instance(_instance)
	///
	/// @desc Adds an instance to the dynamic batch.
	///
	/// @param {Id.Instance, Struct} _instance The instance to be added.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	static add_instance = function (_instance) {
		var _indexIds = InstanceCount;
		var _indexData = _indexIds * SlotsPerInstance;
		__instanceToIndex[? _instance] = _indexData;
		__indexToInstance[? _indexData] = _instance;
		++InstanceCount;
		__resize_data();
		method(_instance, DataWriter)(__data[_indexData div BatchLength], _indexData mod BatchLength);
		__ids[_indexIds div Size][@ _indexIds mod Size] = real(_instance[$ "id"] ?? 0.0);
		return self;
	};

	/// @func update_instance(_instance)
	///
	/// @desc Updates batch data for given instance.
	///
	/// @param {Id.Instance, Struct} _instance The instance to update.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	///
	/// @see BBMOD_DynamicBatch.DataWriter
	static update_instance = function (_instance) {
		gml_pragma("forceinline");
		var _index = __instanceToIndex[? _instance];
		method(_instance, DataWriter)(__data[_index div BatchLength], _index mod BatchLength);
		return self;
	};

	/// @func remove_instance(_instance)
	///
	/// @desc Removes an instance from the dynamic batch.
	///
	/// @param {Id.Instance, Struct} _instance The instance to remove.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	static remove_instance = function (_instance) {
		var _indexDataDeleted = __instanceToIndex[? _instance];
		if (_indexDataDeleted != undefined)
		{
			var _indexIdDeleted = _indexDataDeleted / SlotsPerInstance;

			--InstanceCount;
			if (InstanceCount > 0)
			{
				////////////////////////////////////////////////////////////////
				// Data

				// Get last used index
				var _indexLast = InstanceCount * SlotsPerInstance;
				// Get instance that is stored on that index
				var _instanceLast = __indexToInstance[? _indexLast];
				// Find the exact array that stores the data
				var _dataLast = __data[_indexLast div BatchLength];
				// Get starting index within that array
				var i = _indexLast mod BatchLength;

				// Copy data of the last instance over the data of the removed instance
				array_copy(
					__data[_indexDataDeleted div BatchLength], _indexDataDeleted mod BatchLength,
					_dataLast, i, SlotsPerInstance);

				// Clear slots
				repeat (SlotsPerInstance)
				{
					_dataLast[i++] = 0.0;
				}

				////////////////////////////////////////////////////////////////
				// Ids

				// Get last used index
				var _indexLast = InstanceCount;
				// Find the exact array that stores the id
				var _idsLast = __ids[_indexLast div Size];
				// Get starting index within that array
				var i = _indexLast mod Size;

				// Copy id of the last instance over the id of the removed instance
				__ids[_indexIdDeleted div Size][@ _indexIdDeleted mod Size] = _idsLast[i];

				// Clear slots
				_idsLast[i] = 0.0;

				////////////////////////////////////////////////////////////////

				// Last instance is now stored instead of the deleted one
				__instanceToIndex[? _instanceLast] = _indexDataDeleted;
				__indexToInstance[? _indexDataDeleted] = _instanceLast;
				ds_map_delete(__indexToInstance, _indexLast);
			}
			__resize_data();
		}
		return self;
	};

	/// @func submit([_materials[, _batchData]])
	///
	/// @desc Immediately submits the dynamic batch for rendering.
	///
	/// @param {Array<Struct.BBMOD_Material>} [_materials] An array of materials.
	/// @param {Array<Real>, Array<Array<Real>>} [_batchData] Data for dynamic
	/// batching.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	///
	/// @see BBMOD_DynamicBatch.submit_object
	/// @see BBMOD_DynamicBatch.render
	/// @see BBMOD_DynamicBatch.render_object
	/// @see BBMOD_Material
	/// @see BBMOD_ERenderPass
	static submit = function (_materials=undefined, _batchData=undefined) {
		gml_pragma("forceinline");
		_batchData ??= __data;
		if (array_length(_batchData) > 0)
		{
			if (_materials != undefined
				&& !is_array(_materials))
			{
				_materials = [_materials];
			}
			matrix_set(matrix_world, matrix_build_identity());
			Batch.submit(_materials, undefined, _batchData);
		}
		return self;
	};

	/// @func render([_materials[, _batchData[, _ids]]])
	///
	/// @desc Enqueues the dynamic batch for rendering.
	///
	/// @param {Array<Struct.BBMOD_Material>} [_materials] An array of materials.
	/// @param {Array<Real>, Array<Array<Real>>} [_batchData] Data for dynamic
	/// batching. Defaults to data of instances added with
	/// {@link BBMOD_DynamicBatch.add_instance}.
	/// @param {Array<Id.Instance>, Array<Array<Id.Instance>>} [_ids] IDs of
	/// instances in the `_batchData` array(s). Defaults to IDs of instances
	/// added with {@link BBMOD_DynamicBatch.add_instance}. Applicable only when
	/// `_batchData` is `undefined`!
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	///
	/// @see BBMOD_DynamicBatch.submit
	/// @see BBMOD_DynamicBatch.submit_object
	/// @see BBMOD_DynamicBatch.render_object
	/// @see BBMOD_Material
	static render = function (_materials=undefined, _batchData=undefined, _ids=undefined) {
		gml_pragma("forceinline");

		if (_batchData == undefined)
		{
			_batchData = __data;
			global.__bbmodInstanceIDBatch = __ids;
		}
		else
		{
			global.__bbmodInstanceIDBatch = _ids;
		}

		if (array_length(_batchData) > 0)
		{
			if (_materials != undefined
				&& !is_array(_materials))
			{
				_materials = [_materials];
			}
			matrix_set(matrix_world, matrix_build_identity());
			Batch.render(_materials, undefined, _batchData);
		}

		return self;
	};

	/// @func default_fn(_data, _index)
	///
	/// @desc The default data writer function. Uses instance's variables
	/// `x`, `y`, `z` for position, `image_xscale` for uniform scale and
	/// `image_angle` for rotation around the `z` axis.
	///
	/// @param {Array<Real>} _data An array to which the function will write
	/// instance data. The data layout is compatible with shader `BBMOD_ShDefaultBatched`
	/// and hence with material {@link BBMOD_MATERIAL_DEFAULT_BATCHED}.
	/// @param {Real} _index An index at which the first variable will be written.
	///
	/// @see BBMOD_DynamicBatch.submit_object
	/// @see BBMOD_DynamicBatch.render_object
	static default_fn = function (_data, _index) {
		// Position
		_data[@ _index] = x;
		_data[@ _index + 1] = y;
		_data[@ _index + 2] = z;
		// Uniform scale
		_data[@ _index + 3] = image_xscale;
		// Rotation
		new BBMOD_Quaternion()
			.FromAxisAngle(BBMOD_VEC3_UP, image_angle)
			.ToArray(_data, _index + 4);
		// ID
		_data[@ _index + 8] = ((id & $000000FF) >> 0) / 255;
		_data[@ _index + 9] = ((id & $0000FF00) >> 8) / 255;
		_data[@ _index + 10] = ((id & $00FF0000) >> 16) / 255;
		_data[@ _index + 11] = ((id & $FF000000) >> 24) / 255;
	};

	static __draw_object = function (_method, _object, _materials, _fn=undefined) {
		if (!instance_exists(_object))
		{
			return;
		}

		_fn ??= DataWriter;

		var _slotsPerInstance = SlotsPerInstance;
		var _size = Size;
		var _dataSize = _size * _slotsPerInstance;
		var _data = array_create(_dataSize, 0.0);
		var _ids = array_create(_size, 0.0);
		var _indexData = 0;
		var _indexId = 0;
		var _batchData = [_data];
		var _batchIds = [_ids];

		with (_object)
		{
			method(self, _fn)(_data, _indexData);
			_indexData += _slotsPerInstance;

			_ids[@ _indexId++] = real(self[$ "id"] ?? 0.0);

			if (_indexData >= _dataSize)
			{
				_data = array_create(_dataSize, 0.0);
				_indexData = 0;
				array_push(_batchData, _data);

				_ids = array_create(_size, 0.0);
				_indexId = 0;
				array_push(_batchIds, _ids);
			}
		}
	
		_method(_material, _batchData, _batchIds);
	};

	/// @func submit_object(_object[, _materials[, _fn]])
	///
	/// @desc Immediately submits all instances of an object for rendering in
	/// batches of {@link BBMOD_DynamicBatch.size}.
	///
	/// @param {Real} _object An object to submit.
	/// @param {Array<Struct.BBMOD_Materials>} [_material] An array of materials
	/// to use.
	/// @param {Function} [_fn] A function that writes instance data to an array
	/// which is then passed to the material's shader. Defaults to
	/// {@link BBMOD_DynamicBatch.default_fn} if `undefined`.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	///
	/// @example
	/// ```gml
	/// carBatch.submit_object(OCar, [matCar], function (_data, _index) {
	///     // Position
	///     _data[@ _index] = x;
	///     _data[@ _index + 1] = y;
	///     _data[@ _index + 2] = z;
	///     // Uniform scale
	///     _data[@ _index + 3] = image_xscale;
	///     // Rotation
	///     new BBMOD_Quaternion()
	///         .FromAxisAngle(BBMOD_VEC3_UP, image_angle)
	///         .ToArray(_data, _index + 4);
	///     // ID
	///     _data[@ _index + 8] = ((id & $000000FF) >> 0) / 255;
	///     _data[@ _index + 9] = ((id & $0000FF00) >> 8) / 255;
	///     _data[@ _index + 10] = ((id & $00FF0000) >> 16) / 255;
	///     _data[@ _index + 11] = ((id & $FF000000) >> 24) / 255;
	/// });
	/// ```
	/// The function defined in this example is actually the implementation of
	/// {@link BBMOD_DynamicBatch.DataWriter}. You can use this to create you own
	/// variation of it.
	///
	/// @see BBMOD_DynamicBatch.submit
	/// @see BBMOD_DynamicBatch.render
	/// @see BBMOD_DynamicBatch.render_object
	/// @see BBMOD_DynamicBatch.DataWriter
	static submit_object = function (_object, _materials=undefined, _fn=undefined) {
		gml_pragma("forceinline");
		__draw_object(method(self, submit), _object, _materials, _fn);
		return self;
	};

	/// @func render_object(_object[, _materials[, _fn]])
	///
	/// @desc Enqueues all instances of an object for rendering in batches of
	/// {@link BBMOD_DynamicBatch.size}.
	///
	/// @param {Asset.GMObject} _object An object to render.
	/// @param {Array<Struct.BBMOD_Material>} [_materials] An array of materials
	/// to use.
	/// @param {Function} [_fn] A function that writes instance data to an
	/// array which is then passed to the material's shader. Defaults to
	/// {@link BBMOD_DynamicBatch.DataWriter} if `undefined`.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	///
	/// @example
	/// ```gml
	/// carBatch.render_object(OCar, [matCar], function (_data, _index) {
	///     // Position
	///     _data[@ _index] = x;
	///     _data[@ _index + 1] = y;
	///     _data[@ _index + 2] = z;
	///     // Uniform scale
	///     _data[@ _index + 3] = image_xscale;
	///     // Rotation
	///     new BBMOD_Quaternion()
	///         .FromAxisAngle(BBMOD_VEC3_UP, image_angle)
	///         .ToArray(_data, _index + 4);
	///     // ID
	///     _data[@ _index + 8] = ((id & $000000FF) >> 0) / 255;
	///     _data[@ _index + 9] = ((id & $0000FF00) >> 8) / 255;
	///     _data[@ _index + 10] = ((id & $00FF0000) >> 16) / 255;
	///     _data[@ _index + 11] = ((id & $FF000000) >> 24) / 255;
	/// });
	/// ```
	/// The function defined in this example is actually the implementation of
	/// {@link BBMOD_DynamicBatch.default_fn}. You can use this to create your
	/// own variation of it.
	///
	/// @see BBMOD_DynamicBatch.submit
	/// @see BBMOD_DynamicBatch.submit_object
	/// @see BBMOD_DynamicBatch.render
	/// @see BBMOD_DynamicBatch.DataWriter
	static render_object = function (_object, _materials=undefined, _fn=undefined) {
		gml_pragma("forceinline");
		__draw_object(method(self, render), _object, _materials, _fn);
		return self;
	};

	/// @func freeze()
	///
	/// @desc Freezes the dynamic batch. This makes it render faster.
	///
	/// @return {Struct.BBMOD_DynamicBatch} Returns `self`.
	static freeze = function () {
		gml_pragma("forceinline");
		Batch.freeze();
		return self;
	};

	static build_batch = function () {
		if (Batch != undefined)
		{
			return;
		}

		Batch = Model.clone();
		var _vertexFormatOld = Batch.VertexFormat;
		var _vertexFormatNew;

		if (_vertexFormatOld != undefined)
		{
			_vertexFormatNew = new BBMOD_VertexFormat({
				Vertices: _vertexFormatOld.Vertices,
				Normals: _vertexFormatOld.Normals,
				TextureCoords: _vertexFormatOld.TextureCoords,
				TextureCoords2: _vertexFormatOld.TextureCoords2,
				Colors: _vertexFormatOld.Colors,
				TangentW: _vertexFormatOld.TangentW,
				Bones: _vertexFormatOld.Bones,
				Ids: true,
			});
			Batch.VertexFormat = _vertexFormatNew;
		}

		for (var i = array_length(Batch.Meshes) - 1; i >= 0; --i)
		{
			var _mesh = Batch.Meshes[i];
			var _meshVertexFormatOld = _mesh.VertexFormat ?? _vertexFormatOld;
			var _byteSizeOld = _meshVertexFormatOld.get_byte_size();

			var _meshVertexFormatNew;
			if (_mesh.VertexFormat)
			{
				_meshVertexFormatNew = new BBMOD_VertexFormat({
					Vertices: _meshVertexFormatOld.Vertices,
					Normals: _meshVertexFormatOld.Normals,
					TextureCoords: _meshVertexFormatOld.TextureCoords,
					TextureCoords2: _meshVertexFormatOld.TextureCoords2,
					Colors: _meshVertexFormatOld.Colors,
					TangentW: _meshVertexFormatOld.TangentW,
					Bones: _meshVertexFormatOld.Bones,
					Ids: true,
				});
			}
			else
			{
				_meshVertexFormatNew = _vertexFormatNew;
			}

			var _byteSizeNew = _meshVertexFormatNew.get_byte_size();
			var _vertexBufferOld = _mesh.VertexBuffer;
			var _bufferOld = buffer_create_from_vertex_buffer(_vertexBufferOld, buffer_fixed, 1);
			var _vertexCount = buffer_get_size(_bufferOld) / _byteSizeOld;
			var _bufferNew = buffer_create(Size * _vertexCount * _byteSizeNew, buffer_fixed, 1);
			var _offsetNew = 0;
			var _sizeOfF32 = buffer_sizeof(buffer_f32);

			var _id = 0;
			repeat (Size)
			{
				var _offsetOld = 0;
				repeat (_vertexCount)
				{
					buffer_copy(_bufferOld, _offsetOld, _byteSizeOld, _bufferNew, _offsetNew);
					_offsetOld += _byteSizeOld;
					_offsetNew += _byteSizeOld;
					buffer_poke(_bufferNew, _offsetNew, buffer_f32, _id);
					_offsetNew += _sizeOfF32;
				}
				++_id;
			}

			_mesh.VertexBuffer = vertex_create_buffer_from_buffer(_bufferNew, _meshVertexFormatNew.Raw);
			_mesh.VertexFormat = _meshVertexFormatNew;
			buffer_delete(_bufferNew);

			vertex_delete_buffer(_vertexBufferOld);
			buffer_delete(_bufferOld);
		}
	};

	static destroy = function () {
		Class_destroy();
		if (Batch != undefined)
		{
			Batch = Batch.destroy();
		}
		__data = undefined;
		ds_map_destroy(__instanceToIndex);
		ds_map_destroy(__indexToInstance);
		return undefined;
	};

	if (Model != undefined)
	{
		build_batch();
	}
}
