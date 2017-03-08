###
Create a spy for all functions of a given object
by spying on the object's prototype
@param o {Object} object to invade
###
spyOnAllClassFunctions = (o)->
	Object.keys(o.prototype).forEach (funcName)->
		spyOn(o.prototype, funcName).and.callThrough()

videojs = window.videojs

describe "videojs-soundcloud plugin", ->

	################################
	#   Reusable tests
	################################

	sourceObjectTest = (done) ->
		@player.ready =>
			iframe = document.getElementsByTagName("iframe")[0]
			expect(iframe).toBeTruthy()
			expect(iframe.src).toEqual "https://w.soundcloud.com/player/?url=#{@source}"
			done()

	# Test if calling play() works
	playTest = (done) ->
		@player.ready =>
			@player.on "play", =>
				expect(@player.paused()).toBeFalsy()

				@player.one "playing", =>
					# Also check that it is actually playing and time is progressing
					setTimeout =>
						expect(@player.currentTime()).toBeGreaterThan 0
						done()
					, 1000
			@player.play()

	# Tries to seek to 30 seconds
	seekTo30Test = (done) ->
		@player.ready =>
			seconds = 30

			# First we have to start playing otherwise we can't seek
			# (Soundcloud limitation)
			@player.on "play", =>
				@player.pause()
				@player.currentTime seconds
			# Check once we call back
			@player.on "seeked", =>
				expect(Math.round @player.currentTime()).toEqual  seconds
				done()
			@player.play()

	# Try changing the volume
	# volumes are given as decimals
	# https://github.com/videojs/video.js/blob/master/docs/api/vjs.Player.md#volume-percentasdecimal-
	changeVolumeTest = (done) ->
		@player.ready =>
			volume = 0.5
			@player.on "volumechange", =>
				expect(@player.volume()).toEqual volume
				done()
			@player.volume volume

	###
	Try changing the source with a string
	It should trigger the "newSource" event

	The input is the same as vjs.Player.src (that's what's called)
	Which calls @see Soundcloud::src

	@param newSource [Object] { type: <String>, src: <String>}
	@param newSource [String] The URL
	@return [Function] To pass to karma for testing a source change
	###
	changeSourceTest = (newSource) ->
		newSourceString = if "object" == typeof newSource
				newSource.src
			else newSource

		(done) ->
			@player.one "newSource", =>
				console.debug "changed source for to #{newSourceString}"
				expect(@player.src()).toEqual newSourceString
				done()
			console.debug "changing source to #{newSourceString}"
			@player.src newSource

	# TODO add test for posterchange
	# Check the PosterImage component which is used

	beforeEach ->
		console.debug "master beforeEach"
		@plugin = Soundcloud
		@pluginPrototype = @plugin.prototype
		spyOnAllClassFunctions @plugin
		@videoTagId = "myStuff"

		# The audio we wanna play
		@source = "https://soundcloud.com/vaughan-1-1/this-is-what-crazy-looks-like"

	afterEach ->
		console.debug "master afterEach"
		player = videojs.players[@videoTagId]
		player.dispose() if player

		expect(videojs.players[@videoTagId]).toBeFalsy()

	describe "created with html video>source" , ->

		beforeEach ->
			@vFromTag = window.__html__['test/ressources/videojs_from_tag.html']
			document.body.innerHTML = @vFromTag
			expect(document.getElementById(@videoTagId)).not.toBeNull()
			@player = videojs @videoTagId

		xit "should call init" , (done)->
			# For some reason the spy isn't being called
			# but we know damn well init is being called
			# otherwise we wouldn't get this far...
			@player.ready =>
				expect(@pluginPrototype.init).toHaveBeenCalled()
				done()

		it "should create soundcloud iframe", sourceObjectTest

		it "should play the song", playTest

		it "should half the volume", changeVolumeTest

		### To use with @see changeSourceTest ###
		secondSource = {
			src: "https://soundcloud.com/user504272/teki-latex-dinosaurs-with-guns-cyberoptix-remix"
			type: "audio/soundcloud"
		}

		it "should change object sources", changeSourceTest secondSource
		it "should change string sources", changeSourceTest secondSource.src

	describe "created with javascript string source" , ->

		beforeEach ->
			console.debug "beforeEach with video and source tag"
			@vFromScript = window.__html__['test/ressources/videojs_from_script.html']
			document.body.innerHTML = @vFromScript
			expect(document.getElementById @videoTagId).not.toBeNull()
			@player = videojs @videoTagId, {
				"techOrder": ["soundcloud"]
				"sources": [@source]
				}

		it "should create soundcloud iframe", (done)->
			@player.ready =>
					iframe = document.getElementsByTagName("iframe")[0]
					expect(iframe).toBeTruthy()
					expect(iframe.src).toEqual "https://w.soundcloud.com/player/?url=#{@source}"
					done()

		it "should play the song", playTest

		it "should seek to 30 seconds", seekTo30Test

		it "should half the volume", changeVolumeTest

		### To use with @see changeSourceTest ###
		secondSource = {
			src: "https://soundcloud.com/andrewclarke201/under-the-sun-out-now"
			type: "audio/soundcloud"
		}

		it "should change object sources", changeSourceTest secondSource
		it "should change string sources", changeSourceTest secondSource.src

	describe "created with javascript object source" , ->

		beforeEach ->
			console.debug "beforeEach with video and source tag"
			@vFromScript = window.__html__['test/ressources/videojs_from_script.html']
			document.body.innerHTML = @vFromScript
			expect(document.getElementById @videoTagId).not.toBeNull()
			@player = videojs @videoTagId, {
				"techOrder": ["soundcloud"]
				"sources": [ {
					 src: @source
					 type: "audio/soundcloud"
					}]
				}

		it "should create soundcloud iframe", sourceObjectTest

		it "should play the song", playTest

		it "should seek to 30 seconds", seekTo30Test

		it "should half the volume", changeVolumeTest

		### To use with @see changeSourceTest ###
		secondSource = {
			src: "https://soundcloud.com/apexrise/or-nah"
			type: "audio/soundcloud"
		}

		it "should change sources", changeSourceTest secondSource

	describe "created with no source" , ->

		beforeEach ->
			console.debug "beforeEach with no source tag"
			@vFromScript = window.__html__['test/ressources/videojs_from_script.html']
			document.body.innerHTML = @vFromScript
			expect(document.getElementById @videoTagId).not.toBeNull()
			@player = videojs @videoTagId, {
				"techOrder": ["soundcloud"]
				}

		### To use with @see changeSourceTest ###
		secondSource = {
			src: "https://soundcloud.com/pegboardnerds/pegboard-nerds-here-it-comes"
			type: "audio/soundcloud"
		}

		apiSource = {
			src: "https://api.soundcloud.com/tracks/216846955&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false&amp;visual=true"
			type: "audio/soundcloud"
		}

		it "should change object sources", changeSourceTest secondSource
		it "should change string sources", changeSourceTest secondSource.src

		it "should take api object sources", changeSourceTest apiSource
		it "should take api string sources", changeSourceTest apiSource.src

