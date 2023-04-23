/// @func BBMOD_Model([_file[, _sha1]])
///
/// @extends BBMOD_Resource
///
/// @implements {BBMOD_IRenderable}
///
/// @desc A model.
///
/// @param {String} [_file] The "*.bbmod" model file to load or `undefined`.
/// Defaults to `undefined`.
/// @param {String} [_sha1] Expected SHA1 of the file. If the actual
/// one does not match with this, then the model will not be loaded. Use
/// `undefined` if you do not want to check the SHA1 of the file. Defaults to
/// `undefined`.
///
/// @example
/// ```gml
/// try
/// {
///     modCharacter = new BBMOD_Model("Character.bbmod");
/// }
/// catch (_error)
/// {
///     // The model failed to load!
/// }
/// ```
///
/// @throws {BBMOD_Exception} When the model fails to load.
function BBMOD_Model(_file=undefined, _sha1=undefined)
	: BBMOD_Resource() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	implement(BBMOD_IRenderable);

	static Resource_destroy = destroy;

	/// @var {Real} The major version of the model file.
	VersionMajor = BBMOD_VERSION_MAJOR;

	/// @var {Real} The minor version of the model file.
	VersionMinor = BBMOD_VERSION_MINOR;

	/// @var {Struct.BBMOD_VertexFormat} The vertex format of the model.
	/// @see BBMOD_VertexFormat
	/// @obsolete Since version 3.2 of the BBMOD file format each mesh has
	/// its own vertex format!
	/// @see BBMOD_Mesh.VertexFormat
	/// @readonly
	VertexFormat = undefined;

	/// @var {Array<Struct.BBMOD_Mesh>} Array of meshes.
	/// @readonly
	Meshes = [];

	/// @var {Real} Number of nodes.
	/// @readonly
	NodeCount = 0;

	/// @var {Struct.BBMOD_Node} The root node.
	/// @see BBMOD_Node
	/// @readonly
	RootNode = undefined;

	/// @var {Real} Number of bones.
	/// @readonly
	BoneCount = 0;

	/// @var {Array<Real>} An array of bone offset dual quaternions.
	/// @private
	__offsetArray = [];

	/// @var {Real} Number of materials that the model uses.
	/// @see BBMOD_BaseMaterial
	/// @readonly
	MaterialCount = 0;

	/// @var {Array<String>} An array of material names.
	/// @see BBMOD_Model.Materials
	/// @see BBMOD_Model.get_material
	/// @see BBMOD_Model.set_material
	/// @readonly
	MaterialNames = [];

	/// @var {Array<Struct.BBMOD_BaseMaterial>} An array of materials. Each entry
	/// defaults to {@link BBMOD_MATERIAL_DEFAULT}.
	/// @see BBMOD_Model.MaterialNames
	/// @see BBMOD_Model.get_material
	/// @see BBMOD_Model.set_material
	/// @see BBMOD_BaseMaterial
	Materials = [];

	/// @var {Bool} If `true` then the model is frozen.
	/// @readonly
	/// @see BBMOD_Model.freeze
	Frozen = false;

	/// @func copy(_dest)
	///
	/// @desc Copies model data into another model.
	///
	/// @param {Struct.BBMOD_Model} _dest The model to copy data to.
	///
	/// @return {Struct.BBMOD_Model} Returns `self`.
	static copy = function (_dest) {
		_dest.IsLoaded = IsLoaded;
		_dest.Path = Path;

		_dest.VersionMajor = VersionMajor;
		_dest.VersionMinor = VersionMinor;
		_dest.VertexFormat = VertexFormat;

		for (var i = array_length(_dest.Meshes) - 1; i >= 0; --i)
		{
			_dest.Meshes[i].destroy();
		}

		var _meshCount = array_length(Meshes);
		_dest.Meshes = array_create(_meshCount);

		for (var i = 0; i < _meshCount; ++i)
		{
			var _meshClone = Meshes[i].clone();
			_meshClone.Model = _dest;
			_dest.Meshes[@ i] = _meshClone;
		}

		_dest.NodeCount = NodeCount;

		if (_dest.RootNode)
		{
			_dest.RootNode.destroy();
		}

		if (RootNode)
		{
			_dest.RootNode = RootNode.clone();
			_dest.__pass_self_to_nodes();
		}
		else
		{
			_dest.RootNode = undefined;
		}

		_dest.BoneCount = BoneCount;
		_dest.__offsetArray = bbmod_array_clone(__offsetArray);
		_dest.MaterialCount = MaterialCount;
		_dest.MaterialNames = bbmod_array_clone(MaterialNames);
		_dest.Materials = bbmod_array_clone(Materials);
		_dest.Frozen = Frozen;

		return self;
	};

	/// @func clone()
	///
	/// @desc Creates a clone of the model.
	///
	/// @return {Struct.BBMOD_Model} The created clone.
	static clone = function () {
		var _clone = new BBMOD_Model();
		copy(_clone);
		return _clone;
	};

	/// @func __pass_self_to_nodes([_node])
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_Node} [_node]
	///
	/// @private
	static __pass_self_to_nodes = function (_node=undefined) {
		_node ??= RootNode;
		_node.Model = self;
		for (var i = array_length(_node.Children) - 1; i >= 0; --i)
		{
			__pass_self_to_nodes(_node.Children[i]);
		}
		return self;
	};

	/// @func from_buffer(_buffer)
	///
	/// @desc Loads model data from a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to load the data from.
	///
	/// @return {Struct.BBMOD_Model} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If loading fails.
	static from_buffer = function (_buffer) {
		var _hasMinorVersion = false;

		var _type = buffer_read(_buffer, buffer_string);
		if (_type == "bbmod")
		{
		}
		else if (_type == "BBMOD")
		{
			_hasMinorVersion = true;
		}
		else
		{
			throw new BBMOD_Exception("Buffer does not contain a BBMOD!");
		}

		VersionMajor = buffer_read(_buffer, buffer_u8);
		if (VersionMajor != BBMOD_VERSION_MAJOR)
		{
			throw new BBMOD_Exception(
				"Invalid BBMOD major version " + string(VersionMajor) + "!");
		}

		if (_hasMinorVersion)
		{
			VersionMinor = buffer_read(_buffer, buffer_u8);
			if (VersionMinor > BBMOD_VERSION_MINOR)
			{
				throw new BBMOD_Exception(
					"Invalid BBMOD minor version " + string(VersionMinor) + "!");
			}
		}
		else
		{
			VersionMinor = 0;
		}
	
		// Vertex format
		if (VersionMinor < 2)
		{
			VertexFormat = __bbmod_vertex_format_load(_buffer, VersionMinor);
		}

		// Meshes
		var _meshCount = buffer_read(_buffer, buffer_u32);
		Meshes = array_create(_meshCount, undefined);

		var i = 0;
		repeat (_meshCount)
		{
			Meshes[@ i++] = new BBMOD_Mesh(VertexFormat, self).from_buffer(_buffer);
		}

		// Node count and root node
		NodeCount = buffer_read(_buffer, buffer_u32);
		RootNode = new BBMOD_Node(self).from_buffer(_buffer);

		// Bone offsets
		BoneCount = buffer_read(_buffer, buffer_u32);

		if (BoneCount > 0)
		{
			__offsetArray = array_create(BoneCount * 8, 0);

			repeat (BoneCount)
			{
				var _index = buffer_read(_buffer, buffer_f32) * 8; // Bone index
				__offsetArray[@ _index + 0] = buffer_read(_buffer, buffer_f32);
				__offsetArray[@ _index + 1] = buffer_read(_buffer, buffer_f32);
				__offsetArray[@ _index + 2] = buffer_read(_buffer, buffer_f32);
				__offsetArray[@ _index + 3] = buffer_read(_buffer, buffer_f32);
				__offsetArray[@ _index + 4] = buffer_read(_buffer, buffer_f32);
				__offsetArray[@ _index + 5] = buffer_read(_buffer, buffer_f32);
				__offsetArray[@ _index + 6] = buffer_read(_buffer, buffer_f32);
				__offsetArray[@ _index + 7] = buffer_read(_buffer, buffer_f32);
			}
		}

		// Materials
		MaterialCount = buffer_read(_buffer, buffer_u32);

		if (MaterialCount > 0)
		{
			Materials = array_create(MaterialCount, BBMOD_MATERIAL_DEFAULT);

			var _materialNames = array_create(MaterialCount, undefined);

			i = 0;
			repeat (MaterialCount)
			{
				_materialNames[@ i++] = buffer_read(_buffer, buffer_string);
			}

			MaterialNames = _materialNames;
		}

		IsLoaded = true;

		return self;
	};

	/// @func to_buffer(_buffer)
	///
	/// @desc Writes model data to a buffer.
	///
	/// @param {Id.Buffer} _buffer The buffer to write the data to.
	///
	/// @return {Struct.BBMOD_Model} Returns `self`.
	static to_buffer = function (_buffer) {
		buffer_write(_buffer, buffer_string, "BBMOD");
		buffer_write(_buffer, buffer_u8, VersionMajor);
		buffer_write(_buffer, buffer_u8, VersionMinor);

		// Vertex format
		if (VersionMinor < 2)
		{
			__bbmod_vertex_format_save(VertexFormat, _buffer, VersionMinor);
		}

		// Meshes
		var _meshCount = array_length(Meshes);
		buffer_write(_buffer, buffer_u32, _meshCount)

		var i = 0;
		repeat (_meshCount)
		{
			Meshes[i++].to_buffer(_buffer);
		}

		// Node count and root node
		buffer_write(_buffer, buffer_u32, NodeCount);
		RootNode.to_buffer(_buffer);

		// Bone offsets
		buffer_write(_buffer, buffer_u32, BoneCount);

		if (BoneCount > 0)
		{
			var _index = 0;
			repeat (BoneCount)
			{
				buffer_write(_buffer, buffer_f32, _index / 8); // Bone index
				buffer_write(_buffer, buffer_f32, __offsetArray[_index + 0]);
				buffer_write(_buffer, buffer_f32, __offsetArray[_index + 1]);
				buffer_write(_buffer, buffer_f32, __offsetArray[_index + 2]);
				buffer_write(_buffer, buffer_f32, __offsetArray[_index + 3]);
				buffer_write(_buffer, buffer_f32, __offsetArray[_index + 4]);
				buffer_write(_buffer, buffer_f32, __offsetArray[_index + 5]);
				buffer_write(_buffer, buffer_f32, __offsetArray[_index + 6]);
				buffer_write(_buffer, buffer_f32, __offsetArray[_index + 7]);
				_index += 8;
			}
		}

		// Materials
		buffer_write(_buffer, buffer_u32, MaterialCount);

		i = 0;
		repeat (MaterialCount)
		{
			buffer_write(_buffer, buffer_string, MaterialNames[i++]);
		}

		return self;
	};

	/// @func freeze()
	///
	/// @desc Freezes all vertex buffers used by the model. This should make its
	/// rendering faster, but it disables creating new batches of the model.
	///
	/// @return {Struct.BBMOD_Model} Returns `self`.
	static freeze = function () {
		gml_pragma("forceinline");
		if (!Frozen)
		{
			var i = 0;
			repeat (array_length(Meshes))
			{
				Meshes[i++].freeze();
			}
			Frozen = true;
		}
		return self;
	};

	/// @func find_node(_idOrName[, _node])
	///
	/// @desc Finds a node by its name or id.
	///
	/// @param {Real, String} _idOrName The id (real) or the name (string) of
	/// the node.
	/// @param {Struct.BBMOD_Node} [_node] The node to start searching from.
	/// Defaults to the root node.
	///
	/// @return {Struct.BBMOD_Node} Returns the found node or `undefined`.
	static find_node = function (_idOrName, _node=RootNode) {
		var _isName = is_string(_idOrName);
		if (_isName && _node.Name == _idOrName)
		{
			return _node;
		}
		if (!_isName && _node.Index == _idOrName)
		{
			return _node;
		}
		var _children = _node.Children;
		var i = 0;
		repeat (array_length(_children))
		{
			var _found = find_node(_idOrName, _children[i++]);
			if (_found != undefined)
			{
				return _found;
			}
		}
		return undefined;
	};

	/// @func find_node_id(_nodeName)
	///
	/// @desc Finds id of the model's node by its name.
	///
	/// @param {String} _nodeName The name of the node.
	///
	/// @return {Real} The id of the node or `undefined` when it is not found.
	///
	/// @note It is not recommended to use this method in release builds, because
	/// having many of these lookups can slow down your game! You should instead
	/// use the ids available from the `_log.txt` files, which are created during
	/// model conversion.
	static find_node_id = function (_nodeName) {
		gml_pragma("forceinline");
		var _node = find_node(_nodeName);
		if (_node != undefined)
		{
			return _node.Index;
		}
		return undefined;
	};

	/// @func get_material(_name)
	///
	/// @desc Retrieves a material by its name.
	///
	/// @param {String} _name The name of the material.
	///
	/// @return {Struct.BBMOD_BaseMaterial} The material.
	///
	/// @throws {BBMOD_Exception} If the model does not have a material with
	/// given name.
	///
	/// @see BBMOD_Model.Materials
	/// @see BBMOD_Model.MaterialNames
	/// @see BBMOD_Model.set_material
	/// @see BBMOD_BaseMaterial
	static get_material = function (_name) {
		var i = 0;
		repeat (MaterialCount)
		{
			if (MaterialNames[i] == _name)
			{
				return Materials[i];
			}
			++i;
		}
		throw new BBMOD_Exception("No such material found!");
	};

	/// @func set_material(_name, _material)
	///
	/// @desc Sets a material.
	///
	/// @param {String} _name The name of the material slot.
	/// @param {Struct.BBMOD_BaseMaterial} _material The material.
	///
	/// @return {Struct.BBMOD_Model} Returns `self`.
	///
	/// @throws {BBMOD_Exception} If the model does not have a material with
	/// given name.
	///
	/// @see BBMOD_Model.Materials
	/// @see BBMOD_Model.MaterialNames
	/// @see BBMOD_Model.get_material
	/// @see BBMOD_BaseMaterial
	static set_material = function (_name, _material) {
		var i = 0;
		repeat (MaterialCount)
		{
			if (MaterialNames[i] == _name)
			{
				Materials[@ i] = _material;
				return self;
			}
			++i;
		}
		throw new BBMOD_Exception("No such material found!");
	};

	/// @func get_vertex_format([_bones[, _ids]])
	///
	/// @desc Used to retrieve or create a vertex format compatible with the model.
	///
	/// @param {Bool} [_bones] Use `true` to include bone data in the vertex
	/// format. Defaults to `true`.
	/// @param {Bool} [_ids] Use `true` to include model instance ids in the
	/// vertex format. Defaults to `false`.
	///
	/// @deprecated Each {@link BBMOD_Mesh} now has its own vertex format!
	static get_vertex_format = function (_bones=true, _ids=false) {
		gml_pragma("forceinline");
		var _vertexFormat = VertexFormat ? VertexFormat : Meshes[0].VertexFormat;
		return new BBMOD_VertexFormat(
			_vertexFormat.Vertices,
			_vertexFormat.Normals,
			_vertexFormat.TextureCoords,
			_vertexFormat.Colors,
			_vertexFormat.TangentW,
			_bones ? _vertexFormat.Bones : false,
			_ids);
	};

	/// @func submit([_materials[, _transform[, _batchData]]])
	///
	/// @desc Immediately submits the model for rendering.
	///
	/// @param {Array<Struct.BBMOD_BaseMaterial>} [_materials] An array of
	/// materials, one for each material slot of the model. If not specified,
	/// then {@link BBMOD_Model.Materials} is used. Defaults to `undefined`.
	/// @param {Array<Real>} [_transform] An array of dual quaternions for
	/// transforming animated models or `undefined`.
	/// @param {Array<Real>, Array<Array<Real>>} [_batchData] Data for dynamic
	/// batching or `undefined`.
	///
	/// @return {Struct.BBMOD_Model} Returns `self`.
	///
	/// @example
	/// ```gml
	/// bbmod_material_reset();
	/// // Render a terrain model (does not have animation data)
	/// modTerrain.submit([mat_grass]);
	/// // Render a character model (animated by animationPlayer)
	/// modCharacter.submit([mat_head, mat_body], animationPlayer.get_transform());
	/// bbmod_material_reset();
	/// ```
	///
	/// @note Only parts of the model that use materials compatible with the
	/// current render pass are submitted!
	///
	/// This method does not do anything if the model has not been loaded yet.
	///
	/// @see BBMOD_Resource.IsLoaded
	/// @see BBMOD_BaseMaterial
	/// @see BBMOD_AnimationPlayer.get_transform
	/// @see bbmod_material_reset
	/// @see BBMOD_ERenderPass
	static submit = function (_materials=undefined, _transform=undefined, _batchData=undefined) {
		gml_pragma("forceinline");
		if (RootNode != undefined)
		{
			_materials ??= Materials;
			RootNode.submit(_materials, _transform, _batchData);
		}
		return self;
	};

	/// @func render([_materials[, _transform[, _batchData[, _matrix]]]])
	///
	/// @desc Enqueues the model for rendering.
	///
	/// @param {Array<Struct.BBMOD_BaseMaterial>} [_materials] An array of
	/// materials, one for each material slot of the model. If not specified,
	/// then {@link BBMOD_Model.Materials} is used. Defaults to `undefined`.
	/// @param {Array<Real>} [_transform] An array of dual quaternions for
	/// transforming animated models or `undefined`.
	/// @param {Array<Real>, Array<Array<Real>>} [_batchData] Data for dynamic
	/// batching or `undefined`.
	/// @param {Array<Real>} [_matrix] The world matrix. Defaults to
	/// `matrix_get(matrix_world)`.
	///
	/// @return {Struct.BBMOD_Model} Returns `self`.
	///
	/// @note This method does not do anything if the model has not been loaded
	/// yet.
	///
	/// @see BBMOD_Resource.IsLoaded
	/// @see BBMOD_BaseMaterial
	/// @see BBMOD_AnimationPlayer.get_transform
	/// @see bbmod_material_reset
	static render = function (_materials=undefined, _transform=undefined, _batchData=undefined, _matrix=undefined) {
		gml_pragma("forceinline");
		if (RootNode != undefined)
		{
			_materials ??= Materials;
			if (_matrix == undefined)
			{
				_matrix = matrix_get(matrix_world);
			}
			RootNode.render(_materials, _transform, _batchData, _matrix);
		}
		return self;
	};

	/// @func __to_dynamic_batch(_dynamicBatch)
	///
	/// @param {Struct.BBMOD_DynamicBatch} _dynamicBatch
	///
	/// @return {Struct.BBMOD_Model} Returns `self`.
	///
	/// @private
	static __to_dynamic_batch = function (_dynamicBatch) {
		gml_pragma("forceinline");
		var i = 0;
		repeat (array_length(Meshes))
		{
			Meshes[i++].__to_dynamic_batch(_dynamicBatch);
		}
		return self;
	};

	/// @func __to_static_batch(_staticBatch, _transform)
	///
	/// @param {Struct.BBMOD_StaticBatch} _staticBatch
	/// @param {Array<Real>} _transform
	///
	/// @return {Struct.BBMOD_Model} Returns `self`.
	///
	/// @private
	static __to_static_batch = function (_staticBatch, _transform) {
		gml_pragma("forceinline");
		var i = 0;
		repeat (array_length(Meshes))
		{
			Meshes[i++].__to_static_batch(self, _staticBatch, _transform);
		}
		return self;
	};

	static destroy = function () {
		Resource_destroy();
		var i = 0;
		repeat (array_length(Meshes))
		{
			Meshes[i++].destroy();
		}
		Meshes = [];
		return undefined;
	};

	if (_file != undefined)
	{
		from_file(_file, _sha1);
	}
}
