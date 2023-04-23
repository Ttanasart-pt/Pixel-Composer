/// @enum An enumeration of all possible render commands.
enum BBMOD_ERenderCommand
{
	/// @member Applies a material if it has a shader that can be used in the
	/// current render pass.
	ApplyMaterial,
	/// @member Marks the beginning of a conditional block. Commands within this
	/// block are executed only if the last command was successfully executed.
	/// @example
	/// ```gml
	/// renderQueue.apply_material(material, vertexFormat)
	///     .begin_conditional_block()
	///     // Commands here will be executed only if the material was applied...
	///     .end_conditional_block();
	/// ```
	/// @see BBMOD_ERenderCommand.EndConditionalBlock
	BeginConditionalBlock,
	/// @member Checks if the current render pass is one of specified passes.
	CheckRenderPass,
	/// @member Draws a mesh if its material can be used in the current render
	/// pass.
	DrawMesh,
	/// @member Draws an animated mesh if its material can be used in the current
	/// render pass.
	DrawMeshAnimated,
	/// @member Draws a dynamically batched mesh if its material can be used in
	/// the current render pass.
	DrawMeshBatched,
	/// @member Marks the end of a conditional block.
	/// @see BBMOD_ERenderCommand.BeginConditionalBlock
	EndConditionalBlock,
	/// @member Pops the GPU state.
	PopGpuState,
	/// @member Pushes the GPU state.
	PushGpuState,
	/// @member Resets material.
	ResetMaterial,
	/// @member Resets shader.
	ResetShader,
	/// @member Enables/disables alpha testing.
	SetGpuAlphaTestEnable,
	/// @member Configures the alpha testing threshold value.
	SetGpuAlphaTestRef,
	/// @member Enables/disables alpha blending.
	SetGpuBlendEnable,
	/// @member Sets a blend mode.
	SetGpuBlendMode,
	/// @member Sets source and destination blend modes.
	SetGpuBlendModeExt,
	/// @member Sets source and destination blend modes with separate blend modes
	/// for the alpha channel.
	SetGpuBlendModeExtSepAlpha,
	/// @member Enables/disables writing into individual color channels.
	SetGpuColorWriteEnable,
	/// @member Sets the culling mode.
	SetGpuCullMode,
	/// @member Configures fog.
	SetGpuFog,
	/// @member Enables/disables texture filtering.
	SetGpuTexFilter,
	/// @member Enables/disables texture filtering for a specific sampler.
	SetGpuTexFilterExt,
	/// @member Sets maximum anisotropy.
	SetGpuTexMaxAniso,
	/// @member Sets maximum anisotropy for a specific sampler.
	SetGpuTexMaxAnisoExt,
	/// @member Sets maximum mipmap level.
	SetGpuTexMaxMip,
	/// @member Sets maximum mipmap level for a specific sampler.
	SetGpuTexMaxMipExt,
	/// @member Sets miminum mipmap level.
	SetGpuTexMinMip,
	/// @member Sets miminum mipmap level for a specific sampler.
	SetGpuTexMinMipExt,
	/// @member Sets mipmapping bias.
	SetGpuTexMipBias,
	/// @member Sets mipmapping bias for a specific sampler.
	SetGpuTexMipBiasExt,
	/// @member Enables/disables mipmapping.
	SetGpuTexMipEnable,
	/// @member Enables/disables mipmapping for a specific sampler.
	SetGpuTexMipEnableExt,
	/// @member Sets mipmap filter function.
	SetGpuTexMipFilter,
	/// @member Sets mipmap filter function for a specific sampler.
	SetGpuTexMipFilterExt,
	/// @member Enables/disables texture repeat.
	SetGpuTexRepeat,
	/// @member Enables/disables texture repeat for a specific sampler.
	SetGpuTexRepeatExt,
	/// @member Sets the depth buffer test function.
	SetGpuZFunc,
	/// @member Enables/disables testing against the depth buffer.
	SetGpuZTestEnable,
	/// @member Enables/disables writing to the depth buffer.
	SetGpuZWriteEnable,
	/// @member Sets the projection matrix.
	SetProjectionMatrix,
	/// @member Sets a shader texture sampler.
	SetSampler,
	/// @member Sets a shader.
	SetShader,
	/// @member Sets a float shader uniform.
	SetUniformFloat,
	/// @member Sets a float2 shader uniform.
	SetUniformFloat2,
	/// @member Sets a float3 shader uniform.
	SetUniformFloat3,
	/// @member Sets a float4 shader uniform.
	SetUniformFloat4,
	/// @member Sets a float array shader uniform.
	SetUniformFloatArray,
	/// @member Sets an int shader uniform.
	SetUniformInt,
	/// @member Sets an int2 shader uniform.
	SetUniformInt2,
	/// @member Sets an int3 shader uniform.
	SetUniformInt3,
	/// @member Sets an int4 shader uniform.
	SetUniformInt4,
	/// @member Sets an int array shader uniform.
	SetUniformIntArray,
	/// @member Sets a matrix shader uniform.
	SetUniformMatrix,
	/// @member Sets a matrix array shader uniform.
	SetUniformMatrixArray,
	/// @member Sets the view matrix.
	SetViewMatrix,
	/// @member Sets the world matrix.
	SetWorldMatrix,
	/// @member Submits a vertex buffer.
	SubmitVertexBuffer,
};
