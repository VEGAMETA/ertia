@tool
extends CompositorEffect
class_name CompositorEffectDatamosh

var context : StringName = "PreviousFrame"
var texture : StringName = "texture"
var x_groups : int = 0
var y_groups : int = 0
var datamosh_amount : float = .8
var refresh_frame : bool = false
var uniform : RDUniform
var input_set : RID
var velocity_set : RID
var previous_set : RID
var dst_set : RID
var compute_list : int
var start :bool = true

func _init() -> void:
	needs_motion_vectors = true
	effect_callback_type = CompositorEffect.EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	RenderingServer.call_on_render_thread(_initialize_compute)

func _notification(what : int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if datamosh_shader.is_valid():
			rd.free_rid(datamosh_shader)
		if loop_frame_shader.is_valid():
			rd.free_rid(loop_frame_shader)

var rd : RenderingDevice
var datamosh_shader : RID
var datamosh_pipeline : RID
var loop_frame_shader : RID
var loop_frame_pipeline : RID

func _initialize_compute() -> void:
	await  Globals.get_tree().create_timer(1).timeout
	rd = RenderingServer.get_rendering_device()
	if not rd: return

	var shader_file : RDShaderFile = load("uid://do7rmo0edjdf7")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	datamosh_shader = rd.shader_create_from_spirv(shader_spirv)
	datamosh_pipeline = rd.compute_pipeline_create(datamosh_shader)
	
	shader_file = load("uid://bdl6777e8qlj0")
	shader_spirv = shader_file.get_spirv()
	loop_frame_shader = rd.shader_create_from_spirv(shader_spirv)
	loop_frame_pipeline = rd.compute_pipeline_create(loop_frame_shader)


func get_image_uniform(image : RID, binding : int = 0) -> RDUniform:
	var uniform_image := RDUniform.new()
	uniform_image.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform_image.binding = binding
	uniform_image.add_id(image)
	return uniform_image


func _render_callback(p_effect_callback_type : EffectCallbackType, p_render_data : RenderData) -> void:
	if Engine.is_editor_hint(): return
	
	if not(rd and p_effect_callback_type == CompositorEffect.EFFECT_CALLBACK_TYPE_POST_TRANSPARENT): return
	var render_scene_buffers : RenderSceneBuffersRD = p_render_data.get_render_scene_buffers()
	
	if not render_scene_buffers: return
	var size := render_scene_buffers.get_internal_size()
	if size.x == 0 and size.y == 0: return
	x_groups = size.x
	y_groups =  size.y

	if render_scene_buffers.has_texture(context, texture):
		var tf : RDTextureFormat = render_scene_buffers.get_texture_format(context, texture)
		if tf.width != size.x or tf.height != size.y:
			render_scene_buffers.clear_context(context)
	else:
		render_scene_buffers.create_texture(
			context, 
			texture, 
			RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT, 
			RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT,
			RenderingDevice.TEXTURE_SAMPLES_1, 
			size, 1, 1, true, false)
		refresh_frame = true
		print("recreate")
	var view_count := render_scene_buffers.get_view_count()
	for view in range(view_count):
		var input_image := render_scene_buffers.get_color_layer(view)
		var velocity_buffer := render_scene_buffers.get_velocity_texture()
		var previous_texture_image := render_scene_buffers.get_texture(context, texture)
		
		var push_constant := PackedByteArray()
		push_constant.resize(16)
		push_constant.encode_s32(0, size.x)
		push_constant.encode_s32(4, size.y)
		push_constant.encode_s32(8, Time.get_ticks_msec())
		push_constant.encode_s32(12, int(datamosh_amount*100.0))
		
		if not refresh_frame:
			uniform = get_image_uniform(input_image)
			input_set = UniformSetCacheRD.get_cache(datamosh_shader, 0, [ uniform ])
			uniform = get_image_uniform(velocity_buffer)
			velocity_set = UniformSetCacheRD.get_cache(datamosh_shader, 1, [ uniform ])
			uniform = get_image_uniform(previous_texture_image)
			previous_set = UniformSetCacheRD.get_cache(datamosh_shader, 2, [ uniform ])
			
			compute_list = rd.compute_list_begin()
			rd.compute_list_bind_compute_pipeline(compute_list, datamosh_pipeline)
			rd.compute_list_bind_uniform_set(compute_list, input_set, 0)
			rd.compute_list_bind_uniform_set(compute_list, velocity_set, 1)
			rd.compute_list_bind_uniform_set(compute_list, previous_set, 2)
			rd.compute_list_set_push_constant(compute_list, push_constant, 16)
			rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
			rd.compute_list_end()
			p_render_data.get_camera_attributes().get_id()
		
		uniform = get_image_uniform(input_image)
		input_set = UniformSetCacheRD.get_cache(datamosh_shader, 0, [ uniform ])
		uniform = get_image_uniform(previous_texture_image)
		previous_set = UniformSetCacheRD.get_cache(datamosh_shader, 1, [ uniform ])
		compute_list = rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, loop_frame_pipeline)
		rd.compute_list_bind_uniform_set(compute_list, input_set, 0)
		rd.compute_list_bind_uniform_set(compute_list, previous_set, 1)
		rd.compute_list_dispatch(compute_list, x_groups, y_groups, 1)
		rd.compute_list_end()
		refresh_frame = false
