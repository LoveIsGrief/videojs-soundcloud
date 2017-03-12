###
Documentation can be generated using {https://github.com/coffeedoc/codo Codo}
###
Tech = window.videojs.getComponent("Tech")

if not window.DEBUG and window.console
	window.console.debug = ->

###
Add a script to head with the given @scriptUrl
###
addScriptTag = (scriptUrl)->
	console.debug "adding script #{scriptUrl}"
	tag = document.createElement 'script'
	tag.src = scriptUrl
	headTag = document.getElementsByTagName('head')[0]
	headTag.parentNode.appendChild tag

class Soundcloud extends Tech

	@URL_PREFIX = "https://w.soundcloud.com/player/?url="

	###
	Soundcloud Tech - Wrapper for Soundcloud Media API
	API SC.Widget documentation: http://developers.soundcloud.com/docs/api/html5-widget
	API Track documentation: http://developers.soundcloud.com/docs/api/reference#tracks
	@option options {Object}
					The key/value store of player options.
	@param [Component~ReadyCallback] ready
			Callback function to call when the `HTML5` Tech is ready.
	###
	constructor: (options, ready)->
		console.debug "initializing Soundcloud tech"
		super options, ready

		# Init attributes

		@volumeVal = 0
		@durationMilliseconds = 1
		@currentPositionSeconds = 0
		@loadPercentageDecimal = 0
		@paused_ = true
		@poster_ = null

		@soundcloudSource = null
		if "string" == typeof options.source
			console.debug "given string source: #{options.source}"
			@soundcloudSource = options.source
		else if "object" == typeof options.source
			@soundcloudSource = options.source.src

		# Called by @triggerReady once the player is ready for business
		@ready =>
			# TODO check if this is still necessary
			console.debug "ready to play"
			# Trigger to enable controls
			@trigger "loadstart"

		@scWidgetElement.id = @scWidgetId = "soundcloud_api_#{Date.now()}"
		@scWidgetElement.src = "#{Soundcloud.URL_PREFIX}#{@soundcloudSource}"
		@loadSoundcloud()

	createEl: ->
		@scWidgetElement = super 'iframe',
			#			className: 'vjs-tech'
				scrolling: 'no'
				marginWidth: 0
				marginHeight: 0
				frameBorder: 0
				webkitAllowFullScreen: "true"
				mozallowfullscreen: "true"
				allowFullScreen: "true"
		@scWidgetElement.style.visibility = "hidden"
		@scWidgetElement
#@player_.el().classList.add "backgroundContainer"

###
Destruct the tech and it's DOM elements
###
Soundcloud::dispose = ->
	console.debug "dispose"
	if @scWidgetElement
		@scWidgetElement.parentNode.removeChild @scWidgetElement
		console.debug "Removed widget Element"
		delete @scWidgetElement
	console.debug "removed CSS"
	delete @soundcloudPlayer if @soundcloudPlayer

Soundcloud::load = ->
	console.debug "loading"
	@loadSoundcloud()

###
Called from [vjs.Player.src](https://github.com/videojs/video.js/blob/master/docs/api/vjs.Player.md#src-source-)
Triggers "newSource" from vjs.Player once source has been changed

@option option [String] src Source to load
@return [String] current source if @src isn't given
###
Soundcloud::src = (src)->
	return @soundcloudSource if not src
	console.debug "load a new source(#{src})"
	@soundcloudPlayer.load src, callback: =>
		@soundcloudSource = src
		if not @ready_
			@onReady()
		@trigger "loadstart"


Soundcloud::currentSrc = ->
	@src()

###
A getter for the poster
###
Soundcloud::poster = ->
	@poster_

###
Grabs the poster from soundcloud
ASYNC
###
Soundcloud::updatePoster = ->
	try
	# Get artwork for the sound
		@soundcloudPlayer.getCurrentSound (sound) =>
			console.debug "got sound", sound
			return if not (sound and sound.artwork_url)

			# Take the larger version as described at https://developers.soundcloud.com/docs/api/reference#artwork_url
			posterUrl = sound.artwork_url.replace "large.jpg", "t500x500.jpg"
			console.debug "Setting poster to #{posterUrl}"
			@poster_ = posterUrl
			@trigger "posterchange"
	catch e
		console.debug "Could not update poster"

Soundcloud::play = ->
	if @isReady_
		console.debug "play"
		@soundcloudPlayer.play()
	else
		console.debug "to play on ready"
		# We will play it when the API will be ready
		@playOnReady = true

###
Toggle the playstate between playing and paused
###
Soundcloud::toggle = ->
	console.debug "toggle"
	# We used @player_ to trigger events for changing the display
	if @player_.paused()
		@player_.play()
	else
		@player_.pause()

Soundcloud::pause = ->
	console.debug "pause"
	@soundcloudPlayer.pause()
Soundcloud::paused = ->
	console.debug "paused: #{@paused_}"
	@paused_

###
@return track time in seconds
###
Soundcloud::currentTime = ->
	console.debug "currentTime #{@currentPositionSeconds}"
	@currentPositionSeconds

Soundcloud::setCurrentTime = (seconds)->
	console.debug "setCurrentTime #{seconds}"
	@soundcloudPlayer.seekTo seconds * 1000
	@player_.trigger "seeking"

###
@return total length of track in seconds
###
Soundcloud::duration = ->
	#console.debug "duration: #{@durationMilliseconds / 1000}"
	@durationMilliseconds / 1000

# TODO Fix buffer-range calculations
Soundcloud::buffered = ->
	timePassed = @duration() * @loadPercentageDecimal
	console.debug "buffered #{timePassed}" if timePassed > 0
	videojs.createTimeRange 0, timePassed

Soundcloud::volume = ->
	console.debug "volume: #{@volumeVal * 100}%"
	@volumeVal

###
Called from [videojs::Player::volume](https://github.com/videojs/video.js/blob/master/docs/api/vjs.Player.md#volume-percentasdecimal-)
@param percentAsDecimal {Number} A decimal number [0-1]
###
Soundcloud::setVolume = (percentAsDecimal)->
	console.debug "setVolume(#{percentAsDecimal}) from #{@volumeVal}"
	if percentAsDecimal != @volumeVal
		@volumeVal = percentAsDecimal
		@soundcloudPlayer.setVolume @volumeVal
		console.debug "volume has been set"
		@player_.trigger 'volumechange'

Soundcloud::muted = ->
	console.debug "muted: #{@volumeVal == 0}"
	@volumeVal == 0

###
Soundcloud doesn't do muting so we need to handle that.

A possible pitfall is when this is called with true and the volume has been changed elsewhere.
We will use @unmutedVolumeVal

@param {Boolean} muted
###
Soundcloud::setMuted = (muted)->
	console.debug "setMuted(#{muted})"
	if muted
		@unmuteVolume = @volumeVal
		@setVolume 0
	else
		@setVolume @unmuteVolume


###
Take a wild guess ;)
###
Soundcloud.isSupported = ->
	console.debug "isSupported: #{true}"
	return true

###
Fullscreen of audio is just enlarging making the container fullscreen and using it's poster as a placeholder.
###
Soundcloud::supportsFullScreen = ()->
	console.debug "we support fullscreen!"
	return true

###
Fullscreen of audio is just enlarging making the container fullscreen and using it's poster as a placeholder.
###
Soundcloud::enterFullScreen = ()->
	console.debug "enterfullscreen"
	@scWidgetElement.webkitEnterFullScreen()

###
We return the player's container to it's normal (non-fullscreen) state.
###
Soundcloud::exitFullScreen = ->
	console.debug "EXITfullscreen"
	@scWidgetElement.webkitExitFullScreen()

###
Take care of loading the Soundcloud API
###
Soundcloud::loadSoundcloud = ->
	console.debug "loadSoundcloud"

	# Prepare everything for playing
	if Soundcloud.apiReady and not @soundcloudPlayer
		# Wait for the element to be inserted into the player
		setTimeout =>
			console.debug "simply initializing the widget"
			@initWidget()
		, 1
	else
		# Load the Soundcloud API if it is the first Soundcloud audio
		if not Soundcloud.apiLoading
			console.debug "loading soundcloud api"

			# Initiate the soundcloud tech once the API is ready
			checkSoundcloudApiReady = =>
				if typeof window.SC != "undefined"
					console.debug "soundcloud api is ready"
					Soundcloud.apiReady = true
					window.clearInterval Soundcloud.intervalId
					@initWidget()
					console.debug "cleared interval"
			addScriptTag "http://w.soundcloud.com/player/api.js"
			Soundcloud.apiLoading = true
			Soundcloud.intervalId = window.setInterval checkSoundcloudApiReady, 10

###
It should initialize a soundcloud Widget, which will be our player
and which will react to events.
###
Soundcloud::initWidget = ->
	console.debug "Initializing the widget"

	@soundcloudPlayer = SC.Widget @el_
	console.debug "created widget"
	@soundcloudPlayer.bind SC.Widget.Events.READY, =>
		@onReady()
	console.debug "attempted to bind READY"
	@soundcloudPlayer.bind SC.Widget.Events.PLAY_PROGRESS, (eventData)=>
		@onPlayProgress eventData.relativePosition

	@soundcloudPlayer.bind SC.Widget.Events.LOAD_PROGRESS, (eventData) =>
		console.debug "loading"
		@onLoadProgress eventData.loadedProgress

	@soundcloudPlayer.bind SC.Widget.Events.ERROR, =>
		@onError()

	@soundcloudPlayer.bind SC.Widget.Events.PLAY, =>
		@onPlay()

	@soundcloudPlayer.bind SC.Widget.Events.PAUSE, =>
		@onPause()

	@soundcloudPlayer.bind SC.Widget.Events.FINISH, =>
		@onFinished()

	@soundcloudPlayer.bind SC.Widget.Events.SEEK, (event) =>
		@onSeek event.currentPosition

	# onReady won't be called by soundcloud when given an empty source
	if not @soundcloudSource
		@triggerReady()


###
Callback for soundcloud's READY event.
###
Soundcloud::onReady = ->
	console.debug "onReady"

	# Preparing to handle muting
	@soundcloudPlayer.getVolume (volume) =>
		@unmuteVolume = volume
		console.debug "current volume on soundcloud: #{@unmuteVolume}"
		@setVolume @unmuteVolume


	try
	# It's async and won't change so let's do this now
		@soundcloudPlayer.getDuration (duration) =>
			@durationMilliseconds = duration
			@player_.trigger 'durationchange'
			@player_.trigger "canplay"
	catch e
		console.debug "could not get the duration"


	@updatePoster()

	# Trigger buffering
	#@soundcloudPlayer.play()
	#@soundcloudPlayer.pause()

	console.debug "finished onReady"
	@triggerReady()



###
Callback for Soundcloud's PLAY_PROGRESS event
It should keep track of how much has been played.
@param {Decimal= playPercentageDecimal} [0...1] How much has been played  of the sound in decimal from [0...1]
###
Soundcloud::onPlayProgress = (playPercentageDecimal)->
	console.debug "onPlayProgress"
	@currentPositionSeconds = @durationMilliseconds * playPercentageDecimal / 1000
	@player_.trigger "playing"

###
Callback for Soundcloud's LOAD_PROGRESS event.
It should keep track of how much has been buffered/loaded.
@param {Decimal= loadPercentageDecimal} How much has been buffered/loaded of the sound in decimal from [0...1]
###
Soundcloud::onLoadProgress = (@loadPercentageDecimal)->
	console.debug "onLoadProgress: #{@loadPercentageDecimal}"
	@player_.trigger "timeupdate"

###
Callback for Soundcloud's SEEK event after seeking is done.

@param {Number= currentPositionMs} Where soundcloud seeked to
###
Soundcloud::onSeek = (currentPositionMs)->
	console.debug "soundcloud seek callback"
	@currentPositionSeconds = currentPositionMs / 1000
	@player_.trigger "seeked"

###
Callback for Soundcloud's PLAY event.
It should keep track of the player's paused and playing status.
###
Soundcloud::onPlay = ->
	console.debug "onPlay"
	@paused_ = false
	@playing = not @paused_
	@player_.trigger "play"

###
Callback for Soundcloud's PAUSE event.
It should keep track of the player's paused and playing status.
###
Soundcloud::onPause = ->
	console.debug "onPause"
	@paused_ = true
	@playing = not @paused_
	@player_.trigger "pause"

###
Callback for Soundcloud's FINISHED event.
It should keep track of the player's paused and playing status.
###
Soundcloud::onFinished = ->
	@paused_ = false # TODO what does videojs expect here?
	@playing = not @paused_
	@player_.trigger "ended"

###
Callback for Soundcloud's ERROR event.
Sadly soundlcoud doesn't send any information on what happened when using the widget API --> no error message.
###
Soundcloud::onError = ->
	@player_.error("There was a soundcloud error. Check the view.")

Soundcloud.Events = [
	'loadstart',
	'error',
	'canplay',
	'playing',
	'waiting',
	'seeking',
	'seeked',
	'ended',
	'durationchange',
	'timeupdate',
	'progress',
	'play',
	'pause',
	'volumechange'
];

class SoundcloudSourceHandler

	###
	Simple URI host check of the given url to see if it's really a soundcloud url
	@param url {String}
	###
	@isSoundcloudUrl = (url)->
		///^(https?:\/\/)?(www.|api.)?soundcloud.com\/.///i.test(url)

	@canPlayType: (type)->
		if type == "audio/soundcloud"
			"probably"
		else
			''

	###
	We expect "audio/soundcloud" or a src containing soundcloud

	@param {Tech~SourceObject} srcObj
		The source object
	@param {Object} options
		The options passed to the tech
	###
	@canPlaySource: (source, options)->
		ret = if @canPlayType(source.type) or @isSoundcloudUrl(source.src || source)
			"probably"
		else
			''
		console.debug "Can play source?", source, ret
		ret

	@canHandleSource: (source, options)->
		return @canPlaySource source, options

	# Chainable
	@handleSource: (source, tech, options)->
		tech.src source.src
		@


# mix in SourceHandler pattern
Tech.withSourceHandlers(Soundcloud)
# use the pattern
Soundcloud.registerSourceHandler(SoundcloudSourceHandler)

# make the actual registration
Tech.registerTech("Soundcloud", Soundcloud)
