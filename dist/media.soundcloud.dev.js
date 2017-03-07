
/*
Documentation can be generated using {https://github.com/coffeedoc/codo Codo}
 */
var Soundcloud, SoundcloudSourceHandler, Tech, addScriptTag,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

Tech = window.videojs.getComponent("Tech");

if (!window.DEBUG && window.console) {
  window.console.debug = function() {};
}


/*
Add a script to head with the given @scriptUrl
 */

addScriptTag = function(scriptUrl) {
  var headTag, tag;
  console.debug("adding script " + scriptUrl);
  tag = document.createElement('script');
  tag.src = scriptUrl;
  headTag = document.getElementsByTagName('head')[0];
  return headTag.parentNode.appendChild(tag);
};

Soundcloud = (function(superClass) {
  extend(Soundcloud, superClass);


  /*
  	Soundcloud Tech - Wrapper for Soundcloud Media API
  	API SC.Widget documentation: http://developers.soundcloud.com/docs/api/html5-widget
  	API Track documentation: http://developers.soundcloud.com/docs/api/reference#tracks
  	@option options {Object}
  					The key/value store of player options.
  	@param [Component~ReadyCallback] ready
  			Callback function to call when the `HTML5` Tech is ready.
   */

  function Soundcloud(options, ready) {
    console.debug("initializing Soundcloud tech");
    Soundcloud.__super__.constructor.call(this, options, ready);
    this.volumeVal = 0;
    this.durationMilliseconds = 1;
    this.currentPositionSeconds = 0;
    this.loadPercentageDecimal = 0;
    this.paused_ = true;
    this.soundcloudSource = null;
    if ("string" === typeof options.source) {
      console.debug("given string source: " + options.source);
      this.soundcloudSource = options.source;
    } else if ("object" === typeof options.source) {
      this.soundcloudSource = options.source.src;
    }
    if (this.options().autoplay) {
      this.playOnReady = true;
    }
    this.ready((function(_this) {
      return function() {
        console.debug("ready to play");
        return _this.trigger("loadstart");
      };
    })(this));
    this.loadSoundcloud();
  }

  Soundcloud.prototype._getWidgetId = function() {
    if (this.scWidgetId) {
      return this.scWidgetId;
    } else {
      return this.scWidgetId = (this.id()) + "_soundcloud_api_" + (Date.now());
    }
  };

  Soundcloud.prototype.createEl = function() {
    if (!this.scWidgetElement) {
      this.scWidgetElement = Soundcloud.__super__.createEl.call(this, 'iframe', {
        id: this._getWidgetId(),
        scrolling: 'no',
        marginWidth: 0,
        marginHeight: 0,
        frameBorder: 0,
        webkitAllowFullScreen: "true",
        mozallowfullscreen: "true",
        allowFullScreen: "true",
        src: "https://w.soundcloud.com/player/?url=" + this.soundcloudSource
      });
      this.scWidgetElement.style.visibility = "hidden";
    }
    return this.scWidgetElement;
  };

  return Soundcloud;

})(Tech);


/*
Destruct the tech and it's DOM elements
 */

Soundcloud.prototype.dispose = function() {
  console.debug("dispose");
  if (this.scWidgetElement) {
    this.scWidgetElement.parentNode.removeChild(this.scWidgetElement);
    console.debug("Removed widget Element");
    console.debug(this.scWidgetElement);
  }
  console.debug("removed CSS");
  if (this.soundcloudPlayer) {
    return delete this.soundcloudPlayer;
  }
};

Soundcloud.prototype.load = function() {
  console.debug("loading");
  return this.loadSoundcloud();
};


/*
Called from [vjs.Player.src](https://github.com/videojs/video.js/blob/master/docs/api/vjs.Player.md#src-source-)
Triggers "newSource" from vjs.Player once source has been changed

@option option [String] src Source to load
@return [String] current source if @src isn't given
 */

Soundcloud.prototype.src = function(src) {
  if (!src) {
    return this.soundcloudSource;
  }
  console.debug("load a new source(" + src + ")");
  return this.soundcloudPlayer.load(src, {
    callback: (function(_this) {
      return function() {
        _this.soundcloudSource = src;
        _this.onReady();
        console.debug("trigger 'newSource' from " + src);
        return _this.player_.trigger("newSource");
      };
    })(this)
  });
};

Soundcloud.prototype.currentSrc = function() {
  return this.src();
};

Soundcloud.prototype.updatePoster = function() {
  var e, error;
  try {
    return this.soundcloudPlayer.getSounds((function(_this) {
      return function(sounds) {
        var posterUrl, sound;
        console.debug("got sounds");
        if (sounds.length !== 1) {
          return;
        }
        sound = sounds[0];
        if (!sound.artwork_url) {
          return;
        }
        posterUrl = sound.artwork_url.replace("large.jpg", "t500x500.jpg");
        console.debug("Setting poster to " + posterUrl);
        return _this.player_.el().style.backgroundImage = "url('" + posterUrl + "')";
      };
    })(this));
  } catch (error) {
    e = error;
    return console.debug("Could not update poster");
  }
};

Soundcloud.prototype.play = function() {
  if (this.isReady_) {
    console.debug("play");
    return this.soundcloudPlayer.play();
  } else {
    console.debug("to play on ready");
    return this.playOnReady = true;
  }
};


/*
Toggle the playstate between playing and paused
 */

Soundcloud.prototype.toggle = function() {
  console.debug("toggle");
  if (this.player_.paused()) {
    return this.player_.play();
  } else {
    return this.player_.pause();
  }
};

Soundcloud.prototype.pause = function() {
  console.debug("pause");
  return this.soundcloudPlayer.pause();
};

Soundcloud.prototype.paused = function() {
  console.debug("paused: " + this.paused_);
  return this.paused_;
};


/*
@return track time in seconds
 */

Soundcloud.prototype.currentTime = function() {
  console.debug("currentTime " + this.currentPositionSeconds);
  return this.currentPositionSeconds;
};

Soundcloud.prototype.setCurrentTime = function(seconds) {
  console.debug("setCurrentTime " + seconds);
  this.soundcloudPlayer.seekTo(seconds * 1000);
  return this.player_.trigger("seeking");
};


/*
@return total length of track in seconds
 */

Soundcloud.prototype.duration = function() {
  return this.durationMilliseconds / 1000;
};

Soundcloud.prototype.buffered = function() {
  var timePassed;
  timePassed = this.duration() * this.loadPercentageDecimal;
  if (timePassed > 0) {
    console.debug("buffered " + timePassed);
  }
  return videojs.createTimeRange(0, timePassed);
};

Soundcloud.prototype.volume = function() {
  console.debug("volume: " + (this.volumeVal * 100) + "%");
  return this.volumeVal;
};


/*
Called from [videojs::Player::volume](https://github.com/videojs/video.js/blob/master/docs/api/vjs.Player.md#volume-percentasdecimal-)
@param percentAsDecimal {Number} A decimal number [0-1]
 */

Soundcloud.prototype.setVolume = function(percentAsDecimal) {
  console.debug("setVolume(" + percentAsDecimal + ") from " + this.volumeVal);
  if (percentAsDecimal !== this.volumeVal) {
    this.volumeVal = percentAsDecimal;
    this.soundcloudPlayer.setVolume(this.volumeVal);
    console.debug("volume has been set");
    return this.player_.trigger('volumechange');
  }
};

Soundcloud.prototype.muted = function() {
  console.debug("muted: " + (this.volumeVal === 0));
  return this.volumeVal === 0;
};


/*
Soundcloud doesn't do muting so we need to handle that.

A possible pitfall is when this is called with true and the volume has been changed elsewhere.
We will use @unmutedVolumeVal

@param {Boolean} muted
 */

Soundcloud.prototype.setMuted = function(muted) {
  console.debug("setMuted(" + muted + ")");
  if (muted) {
    this.unmuteVolume = this.volumeVal;
    return this.setVolume(0);
  } else {
    return this.setVolume(this.unmuteVolume);
  }
};


/*
Take a wild guess ;)
 */

Soundcloud.isSupported = function() {
  console.debug("isSupported: " + true);
  return true;
};


/*
Fullscreen of audio is just enlarging making the container fullscreen and using it's poster as a placeholder.
 */

Soundcloud.prototype.supportsFullScreen = function() {
  console.debug("we support fullscreen!");
  return true;
};


/*
Fullscreen of audio is just enlarging making the container fullscreen and using it's poster as a placeholder.
 */

Soundcloud.prototype.enterFullScreen = function() {
  console.debug("enterfullscreen");
  return this.scWidgetElement.webkitEnterFullScreen();
};


/*
We return the player's container to it's normal (non-fullscreen) state.
 */

Soundcloud.prototype.exitFullScreen = function() {
  console.debug("EXITfullscreen");
  return this.scWidgetElement.webkitExitFullScreen();
};


/*
Take care of loading the Soundcloud API
 */

Soundcloud.prototype.loadSoundcloud = function() {
  var checkSoundcloudApiReady;
  console.debug("loadSoundcloud");
  if (Soundcloud.apiReady && !this.soundcloudPlayer) {
    console.debug("simply initializing the widget");
    return this.initWidget();
  } else {
    if (!Soundcloud.apiLoading) {
      console.debug("loading soundcloud api");
      checkSoundcloudApiReady = (function(_this) {
        return function() {
          if (typeof window.SC !== "undefined") {
            console.debug("soundcloud api is ready");
            Soundcloud.apiReady = true;
            window.clearInterval(Soundcloud.intervalId);
            _this.initWidget();
            return console.debug("cleared interval");
          }
        };
      })(this);
      addScriptTag("http://w.soundcloud.com/player/api.js");
      Soundcloud.apiLoading = true;
      return Soundcloud.intervalId = window.setInterval(checkSoundcloudApiReady, 10);
    }
  }
};


/*
It should initialize a soundcloud Widget, which will be our player
and which will react to events.
 */

Soundcloud.prototype.initWidget = function() {
  console.debug("Initializing the widget");
  this.soundcloudPlayer = SC.Widget(this.scWidgetId);
  console.debug("created widget");
  this.soundcloudPlayer.bind(SC.Widget.Events.READY, (function(_this) {
    return function() {
      return _this.onReady();
    };
  })(this));
  console.debug("attempted to bind READY");
  this.soundcloudPlayer.bind(SC.Widget.Events.PLAY_PROGRESS, (function(_this) {
    return function(eventData) {
      return _this.onPlayProgress(eventData.relativePosition);
    };
  })(this));
  this.soundcloudPlayer.bind(SC.Widget.Events.LOAD_PROGRESS, (function(_this) {
    return function(eventData) {
      console.debug("loading");
      return _this.onLoadProgress(eventData.loadedProgress);
    };
  })(this));
  this.soundcloudPlayer.bind(SC.Widget.Events.ERROR, (function(_this) {
    return function() {
      return _this.onError();
    };
  })(this));
  this.soundcloudPlayer.bind(SC.Widget.Events.PLAY, (function(_this) {
    return function() {
      return _this.onPlay();
    };
  })(this));
  this.soundcloudPlayer.bind(SC.Widget.Events.PAUSE, (function(_this) {
    return function() {
      return _this.onPause();
    };
  })(this));
  this.soundcloudPlayer.bind(SC.Widget.Events.FINISH, (function(_this) {
    return function() {
      return _this.onFinished();
    };
  })(this));
  this.soundcloudPlayer.bind(SC.Widget.Events.SEEK, (function(_this) {
    return function(event) {
      return _this.onSeek(event.currentPosition);
    };
  })(this));
  if (!this.soundcloudSource) {
    return this.triggerReady();
  }
};


/*
Callback for soundcloud's READY event.
 */

Soundcloud.prototype.onReady = function() {
  var e, error, error1;
  console.debug("onReady");
  this.soundcloudPlayer.getVolume((function(_this) {
    return function(volume) {
      _this.unmuteVolume = volume;
      console.debug("current volume on soundcloud: " + _this.unmuteVolume);
      return _this.setVolume(_this.unmuteVolume);
    };
  })(this));
  try {
    this.soundcloudPlayer.getDuration((function(_this) {
      return function(duration) {
        _this.durationMilliseconds = duration;
        _this.player_.trigger('durationchange');
        return _this.player_.trigger("canplay");
      };
    })(this));
  } catch (error) {
    e = error;
    console.debug("could not get the duration");
  }
  this.updatePoster();
  this.triggerReady();
  try {
    if (this.playOnReady) {
      this.soundcloudPlayer.play();
    }
  } catch (error1) {
    e = error1;
    console.debug("could not play onready");
  }
  return console.debug("finished onReady");
};


/*
Callback for Soundcloud's PLAY_PROGRESS event
It should keep track of how much has been played.
@param {Decimal= playPercentageDecimal} [0...1] How much has been played  of the sound in decimal from [0...1]
 */

Soundcloud.prototype.onPlayProgress = function(playPercentageDecimal) {
  console.debug("onPlayProgress");
  this.currentPositionSeconds = this.durationMilliseconds * playPercentageDecimal / 1000;
  return this.player_.trigger("playing");
};


/*
Callback for Soundcloud's LOAD_PROGRESS event.
It should keep track of how much has been buffered/loaded.
@param {Decimal= loadPercentageDecimal} How much has been buffered/loaded of the sound in decimal from [0...1]
 */

Soundcloud.prototype.onLoadProgress = function(loadPercentageDecimal) {
  this.loadPercentageDecimal = loadPercentageDecimal;
  console.debug("onLoadProgress: " + this.loadPercentageDecimal);
  return this.player_.trigger("timeupdate");
};


/*
Callback for Soundcloud's SEEK event after seeking is done.

@param {Number= currentPositionMs} Where soundcloud seeked to
 */

Soundcloud.prototype.onSeek = function(currentPositionMs) {
  console.debug("soundcloud seek callback");
  this.currentPositionSeconds = currentPositionMs / 1000;
  return this.player_.trigger("seeked");
};


/*
Callback for Soundcloud's PLAY event.
It should keep track of the player's paused and playing status.
 */

Soundcloud.prototype.onPlay = function() {
  console.debug("onPlay");
  this.paused_ = false;
  this.playing = !this.paused_;
  return this.player_.trigger("play");
};


/*
Callback for Soundcloud's PAUSE event.
It should keep track of the player's paused and playing status.
 */

Soundcloud.prototype.onPause = function() {
  console.debug("onPause");
  this.paused_ = true;
  this.playing = !this.paused_;
  return this.player_.trigger("pause");
};


/*
Callback for Soundcloud's FINISHED event.
It should keep track of the player's paused and playing status.
 */

Soundcloud.prototype.onFinished = function() {
  this.paused_ = false;
  this.playing = !this.paused_;
  return this.player_.trigger("ended");
};


/*
Callback for Soundcloud's ERROR event.
Sadly soundlcoud doesn't send any information on what happened when using the widget API --> no error message.
 */

Soundcloud.prototype.onError = function() {
  return this.player_.error("There was a soundcloud error. Check the view.");
};

Soundcloud.Events = ['loadstart', 'error', 'canplay', 'playing', 'waiting', 'seeking', 'seeked', 'ended', 'durationchange', 'timeupdate', 'progress', 'play', 'pause', 'volumechange'];

SoundcloudSourceHandler = (function() {

  /*
  	Simple URI host check of the given url to see if it's really a soundcloud url
  	@param url {String}
   */
  function SoundcloudSourceHandler() {}

  SoundcloudSourceHandler.isSoundcloudUrl = function(url) {
    return /^(https?:\/\/)?(www.)?soundcloud.com\/./i.test(url);
  };

  SoundcloudSourceHandler.canPlayType = function(type) {
    if (type === "audio/soundcloud") {
      return "probably";
    } else {
      return '';
    }
  };


  /*
  	We expect "audio/soundcloud" or a src containing soundcloud
  
  	@param {Tech~SourceObject} srcObj
  		The source object
  	@param {Object} options
  		The options passed to the tech
   */

  SoundcloudSourceHandler.canPlaySource = function(source, options) {
    var ret;
    ret = this.canPlayType(source.type) && this.isSoundcloudUrl(source.src) ? "probably" : '';
    console.debug("Can play source?", source, ret);
    return ret;
  };

  SoundcloudSourceHandler.canHandleSource = function(source, options) {
    return this.canPlaySource(source, options);
  };

  SoundcloudSourceHandler.handleSource = function(source, tech, options) {
    return tech.src(source.src);
  };

  return SoundcloudSourceHandler;

})();

Tech.withSourceHandlers(Soundcloud);

Soundcloud.registerSourceHandler(SoundcloudSourceHandler);

Tech.registerTech("Soundcloud", Soundcloud);
