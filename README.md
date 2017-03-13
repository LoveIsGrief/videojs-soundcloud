videojs-soundcloud
==================

[![Build Status](https://travis-ci.org/LoveIsGrief/videojs-soundcloud.svg?branch=master)](https://travis-ci.org/LoveIsGrief/videojs-soundcloud)

A [videojs/video-js](https://github.com/videojs/video.js) plugin to support soundcloud track links like:
 
 - https://soundcloud.com/vaughan-1-1/this-is-what-crazy-looks-like
 - 

[Example](https://loveisgrief.github.io/videojs-soundcloud/)
-------

`npm install && grunt compile` will compile 
 - [src/media.soundcloud.coffee](src/media.soundcloud.coffee)
 - [index.jade](index.jade)

One can then open the generated `index.html`.

Developing
----------

* `npm install` to prepare the environment
* `npm test` to run the tests once (Karma with Jasmine)
* `npm run karma` to run tests continuously once a file is changed
* `grunt` after `npm install` to prepare running the example at **example/index.html**
* `grunt watch` to continuously compile coffee and jade, and run livereload for the example
    you can run this alongside `npm run karma` if you wish

How it works
============
We create an iframe (with a soundcloud-embed URL) in the player-element and,
 using the soundcloud [Widget API](http://developers.soundcloud.com/docs/api/html5-widget),
  we initialize a widget that will give us the control methods, getters and setters we need.  
Once the iframe is created it is hidden!

More in detail notes
--------------------
> [**Getters**](http://developers.soundcloud.com/docs/api/html5-widget#methods)

> Since communication between the parent page and the widget's iframe is implemented through 
[window.postMessage](https://developer.mozilla.org/en/DOM/window.postMessage), 
it's not possible to return the value synchronously. 
Because of this, every getter method accepts a callback function as a parameter which,
 when called, will be given the return value of the getter method.

Due to this we have quite a few state variables when using the widget API.

Documentation
-------------
Is generated with [Codo](https://github.com/coffeedoc/codo) and hosted on [coffeedoc.info](http://coffeedoc.info/github/LoveIsGrief/videojs-soundcloud/master/). Props to them :)

