SUBSYSTEM_DEF(icon_smooth)
	name = "Icon Smoothing"
	init_order = INIT_ORDER_ICON_SMOOTHING
	wait = 1
	priority = FIRE_PRIORITY_SMOOTHING
	flags = SS_TICKER

	var/list/smooth_queue = list()
	var/list/deferred = list()

/datum/controller/subsystem/icon_smooth/fire()
	var/list/cached = smooth_queue
	while(cached.len)
		var/atom/smoothing_atom = cached[cached.len]
		cached.len--
		if(QDELETED(smoothing_atom) || !(smoothing_atom.smoothing_flags & SMOOTH_QUEUED))
			continue
		if(smoothing_atom.flags_1 & INITIALIZED_1)
			smoothing_atom.smooth_icon()
		else
			deferred += smoothing_atom
		if (MC_TICK_CHECK)
			return

	if(!cached.len)
		if(deferred.len)
			smooth_queue = deferred
			deferred = cached
		else
			can_fire = FALSE

/datum/controller/subsystem/icon_smooth/Initialize()
	var/list/queue = smooth_queue
	smooth_queue = list()

	while(length(queue))
		var/atom/smoothing_atom = queue[length(queue)]
		queue.len--
		if(QDELETED(smoothing_atom) || !(smoothing_atom.smoothing_flags & SMOOTH_QUEUED) || !smoothing_atom.z)
			continue
		smoothing_atom.smooth_icon()
		CHECK_TICK

	return ..()

/datum/controller/subsystem/icon_smooth/proc/add_to_queue(atom/thing)
	if(thing.smoothing_flags & SMOOTH_QUEUED)
		return
	thing.smoothing_flags |= SMOOTH_QUEUED
	smooth_queue += thing
	if(!can_fire)
		can_fire = TRUE

/datum/controller/subsystem/icon_smooth/proc/remove_from_queues(atom/thing)
	thing.smoothing_flags &= ~SMOOTH_QUEUED
	smooth_queue -= thing
	deferred -= thing
