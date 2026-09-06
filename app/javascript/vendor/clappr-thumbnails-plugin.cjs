(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("clappr"));
	else if(typeof define === 'function' && define.amd)
		define(["clappr"], factory);
	else if(typeof exports === 'object')
		exports["ClapprThumbnailsPlugin"] = factory(require("clappr"));
	else
		root["ClapprThumbnailsPlugin"] = factory(root["Clappr"]);
})(this, function(__WEBPACK_EXTERNAL_MODULE_8__) {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';Object.defineProperty(exports,"__esModule",{value:true});var _createClass=function(){function defineProperties(target,props){for(var i=0;i<props.length;i++){var descriptor=props[i];descriptor.enumerable=descriptor.enumerable||false;descriptor.configurable=true;if("value"in descriptor)descriptor.writable=true;Object.defineProperty(target,descriptor.key,descriptor);}}return function(Constructor,protoProps,staticProps){if(protoProps)defineProperties(Constructor.prototype,protoProps);if(staticProps)defineProperties(Constructor,staticProps);return Constructor;};}();var _clappr=__webpack_require__(8);var _es6PromisePolyfill=__webpack_require__(2);var _scrubThumbnails=__webpack_require__(7);var _scrubThumbnails2=_interopRequireDefault(_scrubThumbnails);var _style=__webpack_require__(6);var _style2=_interopRequireDefault(_style);function _interopRequireDefault(obj){return obj&&obj.__esModule?obj:{default:obj};}function _classCallCheck(instance,Constructor){if(!(instance instanceof Constructor)){throw new TypeError("Cannot call a class as a function");}}function _possibleConstructorReturn(self,call){if(!self){throw new ReferenceError("this hasn't been initialised - super() hasn't been called");}return call&&(typeof call==="object"||typeof call==="function")?call:self;}function _inherits(subClass,superClass){if(typeof superClass!=="function"&&superClass!==null){throw new TypeError("Super expression must either be null or a function, not "+typeof superClass);}subClass.prototype=Object.create(superClass&&superClass.prototype,{constructor:{value:subClass,enumerable:false,writable:true,configurable:true}});if(superClass)Object.setPrototypeOf?Object.setPrototypeOf(subClass,superClass):subClass.__proto__=superClass;}var ScrubThumbnailsPlugin=function(_UICorePlugin){_inherits(ScrubThumbnailsPlugin,_UICorePlugin);_createClass(ScrubThumbnailsPlugin,[{key:'name',get:function get(){return'scrub-thumbnails';}},{key:'attributes',get:function get(){return{'class':this.name};}},{key:'template',get:function get(){return(0,_clappr.template)(_scrubThumbnails2.default);}/* 
	   * Helper to build the "thumbs" property for a sprite sheet.
	   *
	   * spriteSheetUrl- The url to the sprite sheet image
	   * numThumbs- The number of thumbnails on the sprite sheet
	   * thumbWidth- The width of each thumbnail.
	   * thumbHeight- The height of each thumbnail.
	   * numColumns- The number of columns in the sprite sheet.
	   * timeInterval- The interval (in seconds) between the thumbnails.
	   * startTime- The time (in seconds) that the first thumbnail represents. (defaults to 0)
	   */}],[{key:'buildSpriteConfig',value:function buildSpriteConfig(spriteSheetUrl,numThumbs,thumbWidth,thumbHeight,numColumns,timeInterval,startTime){startTime=startTime||0;var thumbs=[];for(var i=0;i<numThumbs;i++){thumbs.push({url:spriteSheetUrl,time:startTime+i*timeInterval,w:thumbWidth,h:thumbHeight,x:i%numColumns*thumbWidth,y:Math.floor(i/numColumns)*thumbHeight});}return thumbs;}// TODO check if seek enabled
	}]);function ScrubThumbnailsPlugin(core){_classCallCheck(this,ScrubThumbnailsPlugin);var _this=_possibleConstructorReturn(this,(ScrubThumbnailsPlugin.__proto__||Object.getPrototypeOf(ScrubThumbnailsPlugin)).call(this,core));_this._thumbsLoaded=false;_this._show=false;// proportion into seek bar that the user is hovered over 0-1
	_this._hoverPosition=0;_this._oldContainer=null;// each element is {x, y, w, h, imageW, imageH, url, time, duration, src}
	// one entry for each thumbnail
	_this._thumbs=[];// a promise that will be resolved when thumbs have loaded
	_this._onThumbsLoaded=new _es6PromisePolyfill.Promise(function(resolve){_this._onThumbsLoadedResolve=resolve;});_this._buildThumbsFromOptions().then(function(){_this._thumbsLoaded=true;_this._onThumbsLoadedResolve();_this._init();}).catch(function(err){throw err;});return _this;}_createClass(ScrubThumbnailsPlugin,[{key:'bindEvents',value:function bindEvents(){// Clappr 0.3 support
	if(_clappr.Events.CORE_ACTIVE_CONTAINER_CHANGED){this.listenTo(this.core,_clappr.Events.CORE_ACTIVE_CONTAINER_CHANGED,this.rebindEvents);}this.listenTo(this.core.mediaControl,_clappr.Events.MEDIACONTROL_MOUSEMOVE_SEEKBAR,this._onMouseMove);this.listenTo(this.core.mediaControl,_clappr.Events.MEDIACONTROL_MOUSELEAVE_SEEKBAR,this._onMouseLeave);this.listenTo(this.core.mediaControl,_clappr.Events.MEDIACONTROL_RENDERED,this._init);this.listenTo(this.core.mediaControl,_clappr.Events.MEDIACONTROL_CONTAINERCHANGED,this._onMediaControlContainerChanged);}},{key:'rebindEvents',value:function rebindEvents(){this.stopListening();this.bindEvents();}},{key:'_bindContainerEvents',value:function _bindContainerEvents(){if(this._oldContainer){this.stopListening(this._oldContainer,_clappr.Events.CONTAINER_TIMEUPDATE,this._renderPlugin);}this._oldContainer=this.core.mediaControl.container;this.listenTo(this.core.mediaControl.container,_clappr.Events.CONTAINER_TIMEUPDATE,this._renderPlugin);}},{key:'_onMediaControlContainerChanged',value:function _onMediaControlContainerChanged(){this._bindContainerEvents();}// thumbSrc may be an array to add multiple
	},{key:'addThumbnail',value:function addThumbnail(thumbSrc){var _this2=this;var thumbSrcs=thumbSrc.constructor===Array?thumbSrc:[thumbSrc];return this._onThumbsLoaded.then(function(){var promises=thumbSrcs.map(function(a){return _this2._addThumbFromSrc(a).then(function(thumb){if(_this2._getOptions().backdropHeight){// append thumb to backdrop
	var index=_this2._thumbs.indexOf(thumb);var $img=_this2._buildImg(thumb,_this2._getOptions().backdropHeight);// Add thumbnail reference
	_this2._$backdropCarouselImgs.splice(index,0,$img);// Add thumbnail to DOM
	if(_this2._$backdropCarouselImgs.length===1){_this2._$carousel.append($img);}else if(index===0){_this2._$backdropCarouselImgs[1].before($img);}else{_this2._$backdropCarouselImgs[index-1].after($img);}}});});return _es6PromisePolyfill.Promise.all(promises).then(function(){if(promises.length>0){_this2._renderPlugin();}});});}// provide a reference to the thumb object you provided to remove it
	// thumbSrc may be an array to remove multiple
	},{key:'removeThumbnail',value:function removeThumbnail(thumbSrc){var _this3=this;var thumbSrcs=thumbSrc.constructor===Array?thumbSrc:[thumbSrc];return this._onThumbsLoaded.then(function(){var foundAll=true;var foundOne=false;thumbSrcs.forEach(function(a){var found=_this3._thumbs.some(function(thumb,i){if(thumb.src===a){_this3._thumbs.splice(i,1);if(_this3._getOptions().backdropHeight){// remove image from carousel
	_this3._$backdropCarouselImgs[i].remove();_this3._$backdropCarouselImgs.splice(i,1);}return true;}return false;});if(!found){foundAll=false;}else{foundOne=true;}});if(foundOne){_this3._renderPlugin();}return _es6PromisePolyfill.Promise.resolve(foundAll);});}},{key:'_init',value:function _init(){if(!this._thumbsLoaded){// _init() will be called when the thumbs are loaded,
	// and whenever the media control rendered event is fired as just before this the dom elements get wiped in IE (https://github.com/tjenkinson/clappr-thumbnails-plugin/issues/5)
	return;}// Init the backdropCarousel as array to keep reference of thumbnail images
	this._$backdropCarouselImgs=[];// create/recreate the dom elements for the plugin
	this._createElements();this._loadBackdrop();this._renderPlugin();}},{key:'_getOptions',value:function _getOptions(){if(!("scrubThumbnails"in this.core.options)){throw"'scrubThumbnails property missing from options object.";}return this.core.options.scrubThumbnails;}},{key:'_appendElToMediaControl',value:function _appendElToMediaControl(){// insert after the background
	this.core.mediaControl.$el.find(".media-control-background").first().after(this.el);}},{key:'_onMouseMove',value:function _onMouseMove(e){this._calculateHoverPosition(e);this._show=true;this._renderPlugin();}},{key:'_onMouseLeave',value:function _onMouseLeave(){this._show=false;this._renderPlugin();}},{key:'_calculateHoverPosition',value:function _calculateHoverPosition(e){var offset=e.pageX-this.core.mediaControl.$seekBarContainer.offset().left;// proportion into the seek bar that the mouse is hovered over 0-1
	this._hoverPosition=Math.min(1,Math.max(offset/this.core.mediaControl.$seekBarContainer.width(),0));}},{key:'_buildThumbsFromOptions',value:function _buildThumbsFromOptions(){var _this4=this;var thumbs=this._getOptions().thumbs;var promises=thumbs.map(function(thumb){return _this4._addThumbFromSrc(thumb);});return _es6PromisePolyfill.Promise.all(promises);}},{key:'_addThumbFromSrc',value:function _addThumbFromSrc(thumbSrc){var _this5=this;return new _es6PromisePolyfill.Promise(function(resolve,reject){var img=new Image();img.onload=function(){resolve(img);};img.onerror=reject;img.src=thumbSrc.url;}).then(function(img){var startTime=thumbSrc.time;// determine the thumb index
	var index=null;_this5._thumbs.some(function(thumb,i){if(startTime<thumb.time){index=i;return true;}return false;});if(index===null){index=_this5._thumbs.length;}var next=index<_this5._thumbs.length?_this5._thumbs[index]:null;var prev=index>0?_this5._thumbs[index-1]:null;if(prev){// update the duration of the previous thumbnail
	prev.duration=startTime-prev.time;}// the duration this thumb lasts for
	// if it is the last thumb then duration will be null
	var duration=next?next.time-thumbSrc.time:null;var imageW=img.width;var imageH=img.height;var thumb={imageW:imageW,// actual width of image
	imageH:imageH,// actual height of image
	x:thumbSrc.x||0,// x coord in image of sprite
	y:thumbSrc.y||0,// y coord in image of sprite
	w:thumbSrc.w||imageW,// width of sprite
	h:thumbSrc.h||imageH,// height of sprite
	url:thumbSrc.url,time:startTime,// time this thumb represents
	duration:duration,// how long (from time) this thumb represents
	src:thumbSrc};_this5._thumbs.splice(index,0,thumb);return thumb;});}// builds a dom element which represents the thumbnail
	// scaled to the provided height
	},{key:'_buildImg',value:function _buildImg(thumb,height){var scaleFactor=height/thumb.h;var $img=(0,_clappr.$)("<img />").addClass("thumbnail-img").attr("src",thumb.url);// the container will contain the image positioned so that the correct sprite
	// is visible
	var $container=(0,_clappr.$)("<div />").addClass("thumbnail-container");$container.css("width",thumb.w*scaleFactor);$container.css("height",height);$img.css({height:thumb.imageH*scaleFactor,left:-1*thumb.x*scaleFactor,top:-1*thumb.y*scaleFactor});$container.append($img);return $container;}},{key:'_loadBackdrop',value:function _loadBackdrop(){if(!this._getOptions().backdropHeight){// disabled
	return;}// append each of the thumbnails to the backdrop carousel
	var $carousel=this._$carousel;for(var i=0;i<this._thumbs.length;i++){var $img=this._buildImg(this._thumbs[i],this._getOptions().backdropHeight);// Keep reference to thumbnail
	this._$backdropCarouselImgs.push($img);// Add thumbnail to DOM
	$carousel.append($img);}}// calculate how far along the carousel should currently be slid
	// depending on where the user is hovering on the progress bar
	},{key:'_updateCarousel',value:function _updateCarousel(){if(!this._getOptions().backdropHeight){// disabled
	return;}var hoverPosition=this._hoverPosition;var videoDuration=this.core.mediaControl.container.getDuration();var startTimeOffset=this.core.mediaControl.container.getStartTimeOffset();// the time into the video at the current hover position
	var hoverTime=startTimeOffset+videoDuration*hoverPosition;var backdropWidth=this._$backdrop.width();var $carousel=this._$carousel;var carouselWidth=$carousel.width();// slide the carousel so that the image on the carousel that is above where the person
	// is hovering maps to that position in time.
	// Thumbnails may not be distributed at even times along the video
	var thumbs=this._thumbs;// assuming that each thumbnail has the same width
	var thumbWidth=carouselWidth/thumbs.length;// determine which thumbnail applies to the current time
	var thumbIndex=this._getThumbIndexForTime(hoverTime);var thumb=thumbs[thumbIndex];var thumbDuration=thumb.duration;if(thumbDuration===null){// the last thumbnail duration will be null as it can't be determined
	// e.g the duration of the video may increase over time (live stream)
	// so calculate the duration now so this last thumbnail lasts till the end
	thumbDuration=Math.max(videoDuration+startTimeOffset-thumb.time,0);}// determine how far accross that thumbnail we are
	var timeIntoThumb=hoverTime-thumb.time;var positionInThumb=timeIntoThumb/thumbDuration;var xCoordInThumb=thumbWidth*positionInThumb;// now calculate the position along carousel that we want to be above the hover position
	var xCoordInCarousel=thumbIndex*thumbWidth+xCoordInThumb;// and finally the position of the carousel when the hover position is taken in to consideration
	var carouselXCoord=xCoordInCarousel-hoverPosition*backdropWidth;$carousel.css("left",-carouselXCoord);var maxOpacity=this._getOptions().backdropMaxOpacity||0.6;var minOpacity=this._getOptions().backdropMinOpacity||0.08;// now update the transparencies so that they fade in around the active one
	for(var i=0;i<thumbs.length;i++){var thumbXCoord=thumbWidth*i;var distance=thumbXCoord-xCoordInCarousel;if(distance<0){// adjust so that distance is always a measure away from
	// each side of the active thumbnail
	// at every point on the active thumbnail the distance should
	// be 0
	distance=Math.min(0,distance+thumbWidth);}// fade over the width of 2 thumbnails
	var opacity=Math.max(maxOpacity-Math.abs(distance)/(2*thumbWidth),minOpacity);this._$backdropCarouselImgs[i].css("opacity",opacity);}}},{key:'_updateSpotlightThumb',value:function _updateSpotlightThumb(){if(!this._getOptions().spotlightHeight){// disabled
	return;}var hoverPosition=this._hoverPosition;var videoDuration=this.core.mediaControl.container.getDuration();// the time into the video at the current hover position
	var startTimeOffset=this.core.mediaControl.container.getStartTimeOffset();var hoverTime=startTimeOffset+videoDuration*hoverPosition;// determine which thumbnail applies to the current time
	var thumbIndex=this._getThumbIndexForTime(hoverTime);var thumb=this._thumbs[thumbIndex];// update thumbnail
	var $spotlight=this._$spotlight;$spotlight.empty();$spotlight.append(this._buildImg(thumb,this._getOptions().spotlightHeight));var elWidth=this.$el.width();var thumbWidth=$spotlight.width();var spotlightXPos=elWidth*hoverPosition-thumbWidth/2;// adjust so the entire thumbnail is always visible
	spotlightXPos=Math.max(Math.min(spotlightXPos,elWidth-thumbWidth),0);$spotlight.css("left",spotlightXPos);}// returns the thumbnail which represents a time in the video
	// or null if there is no thumbnail that can represent the time
	},{key:'_getThumbIndexForTime',value:function _getThumbIndexForTime(time){var thumbs=this._thumbs;for(var i=thumbs.length-1;i>=0;i--){var thumb=thumbs[i];if(thumb.time<=time){return i;}}// stretch the first thumbnail back to the start
	return 0;}},{key:'_renderPlugin',value:function _renderPlugin(){if(!this._thumbsLoaded){return;}if(this._show&&this._thumbs.length>0){this.$el.removeClass("hidden");this._updateCarousel();this._updateSpotlightThumb();}else{this.$el.addClass("hidden");}}},{key:'_createElements',value:function _createElements(){this.$el.html(this.template({'backdropHeight':this._getOptions().backdropHeight,'spotlightHeight':this._getOptions().spotlightHeight}));this.$el.append(_clappr.Styler.getStyleFor(_style2.default));// cache dom references
	this._$spotlight=this.$el.find(".spotlight");this._$backdrop=this.$el.find(".backdrop");this._$carousel=this._$backdrop.find(".carousel");this.$el.addClass("hidden");this._appendElToMediaControl();}}]);return ScrubThumbnailsPlugin;}(_clappr.UICorePlugin);exports.default=ScrubThumbnailsPlugin;module.exports=exports['default'];

/***/ }),
/* 1 */
/***/ (function(module, exports) {

	"use strict";/*
		MIT License http://www.opensource.org/licenses/mit-license.php
		Author Tobias Koppers @sokra
	*/// css base code, injected by the css-loader
	module.exports=function(){var list=[];// return the list of modules as css string
	list.toString=function toString(){var result=[];for(var i=0;i<this.length;i++){var item=this[i];if(item[2]){result.push("@media "+item[2]+"{"+item[1]+"}");}else{result.push(item[1]);}}return result.join("");};// import a list of modules into the list
	list.i=function(modules,mediaQuery){if(typeof modules==="string")modules=[[null,modules,""]];var alreadyImportedModules={};for(var i=0;i<this.length;i++){var id=this[i][0];if(typeof id==="number")alreadyImportedModules[id]=true;}for(i=0;i<modules.length;i++){var item=modules[i];// skip already imported module
	// this implementation is not 100% perfect for weird media query combinations
	//  when a module is imported multiple times with different media queries.
	//  I hope this will never occur (Hey this way we have smaller bundles)
	if(typeof item[0]!=="number"||!alreadyImportedModules[item[0]]){if(mediaQuery&&!item[2]){item[2]=mediaQuery;}else if(mediaQuery){item[2]="("+item[2]+") and ("+mediaQuery+")";}list.push(item);}}};return list;};

/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

	var __WEBPACK_AMD_DEFINE_RESULT__;/* WEBPACK VAR INJECTION */(function(global, setImmediate) {'use strict';var _typeof=typeof Symbol==="function"&&typeof Symbol.iterator==="symbol"?function(obj){return typeof obj;}:function(obj){return obj&&typeof Symbol==="function"&&obj.constructor===Symbol&&obj!==Symbol.prototype?"symbol":typeof obj;};(function(global){//
	// Check for native Promise and it has correct interface
	//
	var NativePromise=global['Promise'];var nativePromiseSupported=NativePromise&&// Some of these methods are missing from
	// Firefox/Chrome experimental implementations
	'resolve'in NativePromise&&'reject'in NativePromise&&'all'in NativePromise&&'race'in NativePromise&&// Older version of the spec had a resolver object
	// as the arg rather than a function
	function(){var resolve;new NativePromise(function(r){resolve=r;});return typeof resolve==='function';}();//
	// export if necessary
	//
	if(typeof exports!=='undefined'&&exports){// node.js
	exports.Promise=nativePromiseSupported?NativePromise:Promise;exports.Polyfill=Promise;}else{// AMD
	if(true){!(__WEBPACK_AMD_DEFINE_RESULT__ = function(){return nativePromiseSupported?NativePromise:Promise;}.call(exports, __webpack_require__, exports, module), __WEBPACK_AMD_DEFINE_RESULT__ !== undefined && (module.exports = __WEBPACK_AMD_DEFINE_RESULT__));}else{// in browser add to global
	if(!nativePromiseSupported)global['Promise']=Promise;}}//
	// Polyfill
	//
	var PENDING='pending';var SEALED='sealed';var FULFILLED='fulfilled';var REJECTED='rejected';var NOOP=function NOOP(){};function isArray(value){return Object.prototype.toString.call(value)==='[object Array]';}// async calls
	var asyncSetTimer=typeof setImmediate!=='undefined'?setImmediate:setTimeout;var asyncQueue=[];var asyncTimer;function asyncFlush(){// run promise callbacks
	for(var i=0;i<asyncQueue.length;i++){asyncQueue[i][0](asyncQueue[i][1]);}// reset async asyncQueue
	asyncQueue=[];asyncTimer=false;}function asyncCall(callback,arg){asyncQueue.push([callback,arg]);if(!asyncTimer){asyncTimer=true;asyncSetTimer(asyncFlush,0);}}function invokeResolver(resolver,promise){function resolvePromise(value){resolve(promise,value);}function rejectPromise(reason){reject(promise,reason);}try{resolver(resolvePromise,rejectPromise);}catch(e){rejectPromise(e);}}function invokeCallback(subscriber){var owner=subscriber.owner;var settled=owner.state_;var value=owner.data_;var callback=subscriber[settled];var promise=subscriber.then;if(typeof callback==='function'){settled=FULFILLED;try{value=callback(value);}catch(e){reject(promise,e);}}if(!handleThenable(promise,value)){if(settled===FULFILLED)resolve(promise,value);if(settled===REJECTED)reject(promise,value);}}function handleThenable(promise,value){var resolved;try{if(promise===value)throw new TypeError('A promises callback cannot return that same promise.');if(value&&(typeof value==='function'||(typeof value==='undefined'?'undefined':_typeof(value))==='object')){var then=value.then;// then should be retrived only once
	if(typeof then==='function'){then.call(value,function(val){if(!resolved){resolved=true;if(value!==val)resolve(promise,val);else fulfill(promise,val);}},function(reason){if(!resolved){resolved=true;reject(promise,reason);}});return true;}}}catch(e){if(!resolved)reject(promise,e);return true;}return false;}function resolve(promise,value){if(promise===value||!handleThenable(promise,value))fulfill(promise,value);}function fulfill(promise,value){if(promise.state_===PENDING){promise.state_=SEALED;promise.data_=value;asyncCall(publishFulfillment,promise);}}function reject(promise,reason){if(promise.state_===PENDING){promise.state_=SEALED;promise.data_=reason;asyncCall(publishRejection,promise);}}function publish(promise){var callbacks=promise.then_;promise.then_=undefined;for(var i=0;i<callbacks.length;i++){invokeCallback(callbacks[i]);}}function publishFulfillment(promise){promise.state_=FULFILLED;publish(promise);}function publishRejection(promise){promise.state_=REJECTED;publish(promise);}/**
	* @class
	*/function Promise(resolver){if(typeof resolver!=='function')throw new TypeError('Promise constructor takes a function argument');if(this instanceof Promise===false)throw new TypeError('Failed to construct \'Promise\': Please use the \'new\' operator, this object constructor cannot be called as a function.');this.then_=[];invokeResolver(resolver,this);}Promise.prototype={constructor:Promise,state_:PENDING,then_:null,data_:undefined,then:function then(onFulfillment,onRejection){var subscriber={owner:this,then:new this.constructor(NOOP),fulfilled:onFulfillment,rejected:onRejection};if(this.state_===FULFILLED||this.state_===REJECTED){// already resolved, call callback async
	asyncCall(invokeCallback,subscriber);}else{// subscribe
	this.then_.push(subscriber);}return subscriber.then;},'catch':function _catch(onRejection){return this.then(null,onRejection);}};Promise.all=function(promises){var Class=this;if(!isArray(promises))throw new TypeError('You must pass an array to Promise.all().');return new Class(function(resolve,reject){var results=[];var remaining=0;function resolver(index){remaining++;return function(value){results[index]=value;if(! --remaining)resolve(results);};}for(var i=0,promise;i<promises.length;i++){promise=promises[i];if(promise&&typeof promise.then==='function')promise.then(resolver(i),reject);else results[i]=promise;}if(!remaining)resolve(results);});};Promise.race=function(promises){var Class=this;if(!isArray(promises))throw new TypeError('You must pass an array to Promise.race().');return new Class(function(resolve,reject){for(var i=0,promise;i<promises.length;i++){promise=promises[i];if(promise&&typeof promise.then==='function')promise.then(resolve,reject);else resolve(promise);}});};Promise.resolve=function(value){var Class=this;if(value&&(typeof value==='undefined'?'undefined':_typeof(value))==='object'&&value.constructor===Class)return value;return new Class(function(resolve){resolve(value);});};Promise.reject=function(reason){var Class=this;return new Class(function(resolve,reject){reject(reason);});};})(typeof window!='undefined'?window:typeof global!='undefined'?global:typeof self!='undefined'?self:undefined);
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }()), __webpack_require__(5).setImmediate))

/***/ }),
/* 3 */
/***/ (function(module, exports) {

	'use strict';// shim for using process in browser
	var process=module.exports={};// cached from whatever global is present so that test runners that stub it
	// don't break things.  But we need to wrap it in a try catch in case it is
	// wrapped in strict mode code which doesn't define any globals.  It's inside a
	// function because try/catches deoptimize in certain engines.
	var cachedSetTimeout;var cachedClearTimeout;function defaultSetTimout(){throw new Error('setTimeout has not been defined');}function defaultClearTimeout(){throw new Error('clearTimeout has not been defined');}(function(){try{if(typeof setTimeout==='function'){cachedSetTimeout=setTimeout;}else{cachedSetTimeout=defaultSetTimout;}}catch(e){cachedSetTimeout=defaultSetTimout;}try{if(typeof clearTimeout==='function'){cachedClearTimeout=clearTimeout;}else{cachedClearTimeout=defaultClearTimeout;}}catch(e){cachedClearTimeout=defaultClearTimeout;}})();function runTimeout(fun){if(cachedSetTimeout===setTimeout){//normal enviroments in sane situations
	return setTimeout(fun,0);}// if setTimeout wasn't available but was latter defined
	if((cachedSetTimeout===defaultSetTimout||!cachedSetTimeout)&&setTimeout){cachedSetTimeout=setTimeout;return setTimeout(fun,0);}try{// when when somebody has screwed with setTimeout but no I.E. maddness
	return cachedSetTimeout(fun,0);}catch(e){try{// When we are in I.E. but the script has been evaled so I.E. doesn't trust the global object when called normally
	return cachedSetTimeout.call(null,fun,0);}catch(e){// same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error
	return cachedSetTimeout.call(this,fun,0);}}}function runClearTimeout(marker){if(cachedClearTimeout===clearTimeout){//normal enviroments in sane situations
	return clearTimeout(marker);}// if clearTimeout wasn't available but was latter defined
	if((cachedClearTimeout===defaultClearTimeout||!cachedClearTimeout)&&clearTimeout){cachedClearTimeout=clearTimeout;return clearTimeout(marker);}try{// when when somebody has screwed with setTimeout but no I.E. maddness
	return cachedClearTimeout(marker);}catch(e){try{// When we are in I.E. but the script has been evaled so I.E. doesn't  trust the global object when called normally
	return cachedClearTimeout.call(null,marker);}catch(e){// same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error.
	// Some versions of I.E. have different rules for clearTimeout vs setTimeout
	return cachedClearTimeout.call(this,marker);}}}var queue=[];var draining=false;var currentQueue;var queueIndex=-1;function cleanUpNextTick(){if(!draining||!currentQueue){return;}draining=false;if(currentQueue.length){queue=currentQueue.concat(queue);}else{queueIndex=-1;}if(queue.length){drainQueue();}}function drainQueue(){if(draining){return;}var timeout=runTimeout(cleanUpNextTick);draining=true;var len=queue.length;while(len){currentQueue=queue;queue=[];while(++queueIndex<len){if(currentQueue){currentQueue[queueIndex].run();}}queueIndex=-1;len=queue.length;}currentQueue=null;draining=false;runClearTimeout(timeout);}process.nextTick=function(fun){var args=new Array(arguments.length-1);if(arguments.length>1){for(var i=1;i<arguments.length;i++){args[i-1]=arguments[i];}}queue.push(new Item(fun,args));if(queue.length===1&&!draining){runTimeout(drainQueue);}};// v8 likes predictible objects
	function Item(fun,array){this.fun=fun;this.array=array;}Item.prototype.run=function(){this.fun.apply(null,this.array);};process.title='browser';process.browser=true;process.env={};process.argv=[];process.version='';// empty string to avoid regexp issues
	process.versions={};function noop(){}process.on=noop;process.addListener=noop;process.once=noop;process.off=noop;process.removeListener=noop;process.removeAllListeners=noop;process.emit=noop;process.prependListener=noop;process.prependOnceListener=noop;process.listeners=function(name){return[];};process.binding=function(name){throw new Error('process.binding is not supported');};process.cwd=function(){return'/';};process.chdir=function(dir){throw new Error('process.chdir is not supported');};process.umask=function(){return 0;};

/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global, process) {"use strict";(function(global,undefined){"use strict";if(global.setImmediate){return;}var nextHandle=1;// Spec says greater than zero
	var tasksByHandle={};var currentlyRunningATask=false;var doc=global.document;var registerImmediate;function setImmediate(callback){// Callback can either be a function or a string
	if(typeof callback!=="function"){callback=new Function(""+callback);}// Copy function arguments
	var args=new Array(arguments.length-1);for(var i=0;i<args.length;i++){args[i]=arguments[i+1];}// Store and register the task
	var task={callback:callback,args:args};tasksByHandle[nextHandle]=task;registerImmediate(nextHandle);return nextHandle++;}function clearImmediate(handle){delete tasksByHandle[handle];}function run(task){var callback=task.callback;var args=task.args;switch(args.length){case 0:callback();break;case 1:callback(args[0]);break;case 2:callback(args[0],args[1]);break;case 3:callback(args[0],args[1],args[2]);break;default:callback.apply(undefined,args);break;}}function runIfPresent(handle){// From the spec: "Wait until any invocations of this algorithm started before this one have completed."
	// So if we're currently running a task, we'll need to delay this invocation.
	if(currentlyRunningATask){// Delay by doing a setTimeout. setImmediate was tried instead, but in Firefox 7 it generated a
	// "too much recursion" error.
	setTimeout(runIfPresent,0,handle);}else{var task=tasksByHandle[handle];if(task){currentlyRunningATask=true;try{run(task);}finally{clearImmediate(handle);currentlyRunningATask=false;}}}}function installNextTickImplementation(){registerImmediate=function registerImmediate(handle){process.nextTick(function(){runIfPresent(handle);});};}function canUsePostMessage(){// The test against `importScripts` prevents this implementation from being installed inside a web worker,
	// where `global.postMessage` means something completely different and can't be used for this purpose.
	if(global.postMessage&&!global.importScripts){var postMessageIsAsynchronous=true;var oldOnMessage=global.onmessage;global.onmessage=function(){postMessageIsAsynchronous=false;};global.postMessage("","*");global.onmessage=oldOnMessage;return postMessageIsAsynchronous;}}function installPostMessageImplementation(){// Installs an event handler on `global` for the `message` event: see
	// * https://developer.mozilla.org/en/DOM/window.postMessage
	// * http://www.whatwg.org/specs/web-apps/current-work/multipage/comms.html#crossDocumentMessages
	var messagePrefix="setImmediate$"+Math.random()+"$";var onGlobalMessage=function onGlobalMessage(event){if(event.source===global&&typeof event.data==="string"&&event.data.indexOf(messagePrefix)===0){runIfPresent(+event.data.slice(messagePrefix.length));}};if(global.addEventListener){global.addEventListener("message",onGlobalMessage,false);}else{global.attachEvent("onmessage",onGlobalMessage);}registerImmediate=function registerImmediate(handle){global.postMessage(messagePrefix+handle,"*");};}function installMessageChannelImplementation(){var channel=new MessageChannel();channel.port1.onmessage=function(event){var handle=event.data;runIfPresent(handle);};registerImmediate=function registerImmediate(handle){channel.port2.postMessage(handle);};}function installReadyStateChangeImplementation(){var html=doc.documentElement;registerImmediate=function registerImmediate(handle){// Create a <script> element; its readystatechange event will be fired asynchronously once it is inserted
	// into the document. Do so, thus queuing up the task. Remember to clean up once it's been called.
	var script=doc.createElement("script");script.onreadystatechange=function(){runIfPresent(handle);script.onreadystatechange=null;html.removeChild(script);script=null;};html.appendChild(script);};}function installSetTimeoutImplementation(){registerImmediate=function registerImmediate(handle){setTimeout(runIfPresent,0,handle);};}// If supported, we should attach to the prototype of global, since that is where setTimeout et al. live.
	var attachTo=Object.getPrototypeOf&&Object.getPrototypeOf(global);attachTo=attachTo&&attachTo.setTimeout?attachTo:global;// Don't get fooled by e.g. browserify environments.
	if({}.toString.call(global.process)==="[object process]"){// For Node.js before 0.9
	installNextTickImplementation();}else if(canUsePostMessage()){// For non-IE10 modern browsers
	installPostMessageImplementation();}else if(global.MessageChannel){// For web workers, where supported
	installMessageChannelImplementation();}else if(doc&&"onreadystatechange"in doc.createElement("script")){// For IE 6–8
	installReadyStateChangeImplementation();}else{// For older browsers
	installSetTimeoutImplementation();}attachTo.setImmediate=setImmediate;attachTo.clearImmediate=clearImmediate;})(typeof self==="undefined"?typeof global==="undefined"?undefined:global:self);
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }()), __webpack_require__(3)))

/***/ }),
/* 5 */
/***/ (function(module, exports, __webpack_require__) {

	/* WEBPACK VAR INJECTION */(function(global) {"use strict";var scope=typeof global!=="undefined"&&global||typeof self!=="undefined"&&self||window;var apply=Function.prototype.apply;// DOM APIs, for completeness
	exports.setTimeout=function(){return new Timeout(apply.call(setTimeout,scope,arguments),clearTimeout);};exports.setInterval=function(){return new Timeout(apply.call(setInterval,scope,arguments),clearInterval);};exports.clearTimeout=exports.clearInterval=function(timeout){if(timeout){timeout.close();}};function Timeout(id,clearFn){this._id=id;this._clearFn=clearFn;}Timeout.prototype.unref=Timeout.prototype.ref=function(){};Timeout.prototype.close=function(){this._clearFn.call(scope,this._id);};// Does not start the time, just sets up the members needed.
	exports.enroll=function(item,msecs){clearTimeout(item._idleTimeoutId);item._idleTimeout=msecs;};exports.unenroll=function(item){clearTimeout(item._idleTimeoutId);item._idleTimeout=-1;};exports._unrefActive=exports.active=function(item){clearTimeout(item._idleTimeoutId);var msecs=item._idleTimeout;if(msecs>=0){item._idleTimeoutId=setTimeout(function onTimeout(){if(item._onTimeout)item._onTimeout();},msecs);}};// setimmediate attaches itself to the global object
	__webpack_require__(4);// On some exotic environments, it's not clear which object `setimmediate` was
	// able to install onto.  Search each possibility in the same order as the
	// `setimmediate` library.
	exports.setImmediate=typeof self!=="undefined"&&self.setImmediate||typeof global!=="undefined"&&global.setImmediate||undefined&&undefined.setImmediate;exports.clearImmediate=typeof self!=="undefined"&&self.clearImmediate||typeof global!=="undefined"&&global.clearImmediate||undefined&&undefined.clearImmediate;
	/* WEBPACK VAR INJECTION */}.call(exports, (function() { return this; }())))

/***/ }),
/* 6 */
/***/ (function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(1)();
	// imports


	// module
	exports.push([module.id, ".scrub-thumbnails {\n  position: absolute;\n  bottom: 55px;\n  width: 100%;\n  -webkit-transition: opacity 0.3s ease;\n  -moz-transition: opacity 0.3s ease;\n  -o-transition: opacity 0.3s ease;\n  transition: opacity 0.3s ease; }\n  .scrub-thumbnails.hidden {\n    opacity: 0; }\n  .scrub-thumbnails .thumbnail-container {\n    display: inline-block;\n    position: relative;\n    overflow: hidden;\n    background-color: #000000; }\n    .scrub-thumbnails .thumbnail-container .thumbnail-img {\n      position: absolute;\n      width: auto; }\n  .scrub-thumbnails .spotlight {\n    background-color: #000000;\n    overflow: hidden;\n    position: absolute;\n    bottom: 0;\n    left: 0;\n    border-color: #ffffff;\n    border-style: solid;\n    border-width: 2px; }\n    .scrub-thumbnails .spotlight img {\n      width: auto; }\n  .scrub-thumbnails .backdrop {\n    position: absolute;\n    left: 0;\n    bottom: 0;\n    right: 0;\n    background-color: #000000;\n    overflow: hidden; }\n    .scrub-thumbnails .backdrop .carousel {\n      position: absolute;\n      top: 0;\n      left: 0;\n      height: 100%;\n      white-space: nowrap; }\n      .scrub-thumbnails .backdrop .carousel img {\n        width: auto; }\n", ""]);

	// exports


/***/ }),
/* 7 */
/***/ (function(module, exports) {

	module.exports = "<% if (backdropHeight) { %>\n<div class=\"backdrop\" style=\"height: <%= backdropHeight%>px;\">\n\t<div class=\"carousel\"></div>\n</div>\n<% }; %>\n<% if (spotlightHeight) { %>\n<div class=\"spotlight\" style=\"height: <%= spotlightHeight%>px;\"></div>\n<% }; %>\n";

/***/ }),
/* 8 */
/***/ (function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_8__;

/***/ })
/******/ ])
});
;