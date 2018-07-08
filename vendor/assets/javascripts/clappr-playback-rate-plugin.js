(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory(require("Clappr"));
	else if(typeof define === 'function' && define.amd)
		define(["Clappr"], factory);
	else if(typeof exports === 'object')
		exports["PlaybackRatePlugin"] = factory(require("Clappr"));
	else
		root["PlaybackRatePlugin"] = factory(root["Clappr"]);
})(this, function(__WEBPACK_EXTERNAL_MODULE_1__) {
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
/******/ 	__webpack_require__.p = "<%=baseUrl%>/";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';Object.defineProperty(exports,'__esModule',{value:true});var _createClass=(function(){function defineProperties(target,props){for(var i=0;i < props.length;i++) {var descriptor=props[i];descriptor.enumerable = descriptor.enumerable || false;descriptor.configurable = true;if('value' in descriptor)descriptor.writable = true;Object.defineProperty(target,descriptor.key,descriptor);}}return function(Constructor,protoProps,staticProps){if(protoProps)defineProperties(Constructor.prototype,protoProps);if(staticProps)defineProperties(Constructor,staticProps);return Constructor;};})();var _get=function get(_x,_x2,_x3){var _again=true;_function: while(_again) {var object=_x,property=_x2,receiver=_x3;_again = false;if(object === null)object = Function.prototype;var desc=Object.getOwnPropertyDescriptor(object,property);if(desc === undefined){var parent=Object.getPrototypeOf(object);if(parent === null){return undefined;}else {_x = parent;_x2 = property;_x3 = receiver;_again = true;desc = parent = undefined;continue _function;}}else if('value' in desc){return desc.value;}else {var getter=desc.get;if(getter === undefined){return undefined;}return getter.call(receiver);}}};function _interopRequireDefault(obj){return obj && obj.__esModule?obj:{'default':obj};}function _classCallCheck(instance,Constructor){if(!(instance instanceof Constructor)){throw new TypeError('Cannot call a class as a function');}}function _inherits(subClass,superClass){if(typeof superClass !== 'function' && superClass !== null){throw new TypeError('Super expression must either be null or a function, not ' + typeof superClass);}subClass.prototype = Object.create(superClass && superClass.prototype,{constructor:{value:subClass,enumerable:false,writable:true,configurable:true}});if(superClass)Object.setPrototypeOf?Object.setPrototypeOf(subClass,superClass):subClass.__proto__ = superClass;}var _clappr=__webpack_require__(1);var _publicPlaybackRateSelectorHtml=__webpack_require__(2);var _publicPlaybackRateSelectorHtml2=_interopRequireDefault(_publicPlaybackRateSelectorHtml);var _publicStyleScss=__webpack_require__(3);var _publicStyleScss2=_interopRequireDefault(_publicStyleScss);var DEFAULT_PLAYBACK_RATES=[{value:'0.5',label:'0.5x'},{value:'0.75',label:'0.75x'},{value:'1.0',label:'Normal'},{value:'1.5',label:'1.5x'},{value:'2.0',label:'2x'}];var DEFAULT_PLAYBACK_RATE='1.0';var PlaybackRatePlugin=(function(_UICorePlugin){_inherits(PlaybackRatePlugin,_UICorePlugin);function PlaybackRatePlugin(){_classCallCheck(this,PlaybackRatePlugin);_get(Object.getPrototypeOf(PlaybackRatePlugin.prototype),'constructor',this).apply(this,arguments);}_createClass(PlaybackRatePlugin,[{key:'bindEvents',value:function bindEvents(){this.listenTo(this.core.mediaControl,_clappr.Events.MEDIACONTROL_CONTAINERCHANGED,this.reload);this.listenTo(this.core.mediaControl,_clappr.Events.MEDIACONTROL_RENDERED,this.render);this.listenTo(this.core.mediaControl,_clappr.Events.MEDIACONTROL_HIDE,this.hideContextMenu);this.listenTo(this.core.mediaControl,PlaybackRatePlugin.MEDIACONTROL_PLAYBACKRATE,this.updatePlaybackRate);}},{key:'unBindEvents',value:function unBindEvents(){this.stopListening(this.core.mediaControl,_clappr.Events.MEDIACONTROL_CONTAINERCHANGED);this.stopListening(this.core.mediaControl,_clappr.Events.MEDIACONTROL_RENDERED);this.stopListening(this.core.mediaControl,_clappr.Events.MEDIACONTROL_HIDE);}},{key:'reload',value:function reload(){this.unBindEvents();this.bindEvents();}},{key:'shouldRender',value:function shouldRender(){if(!this.core.getCurrentContainer()){return false;}var currentPlayback=this.core.getCurrentPlayback();if(currentPlayback.tagName != 'video' && currentPlayback.tagName != 'audio'){ //console.warn('PlaybackRatePlugin#shouldRender: Cannot affect rate for playback', currentPlayback);
	return false;}return true;}},{key:'render',value:function render(){ //console.log('PlaybackRatePlugin#render()');
	var cfg=this.core.options.playbackRateConfig || {};if(!this.playbackRates){this.playbackRates = cfg.options || DEFAULT_PLAYBACK_RATES;}if(!this.selectedRate){this.selectedRate = cfg.defaultValue || DEFAULT_PLAYBACK_RATE;}if(this.shouldRender()){var t=(0,_clappr.template)(_publicPlaybackRateSelectorHtml2['default']);var html=t({playbackRates:this.playbackRates,title:this.getTitle()});this.$el.html(html);var style=_clappr.Styler.getStyleFor(_publicStyleScss2['default'],{baseUrl:this.core.options.baseUrl});this.$el.append(style);this.core.mediaControl.$('.media-control-right-panel').append(this.el);this.updateText();}return this;}},{key:'onRateSelect',value:function onRateSelect(event){ //console.log('onRateSelect', event.target);
	var rate=event.target.dataset.playbackRateSelect;this.setSelectedRate(rate);this.toggleContextMenu();event.stopPropagation();return false;}},{key:'onShowMenu',value:function onShowMenu(event){this.toggleContextMenu();}},{key:'toggleContextMenu',value:function toggleContextMenu(){this.$('.playback_rate ul').toggle();}},{key:'hideContextMenu',value:function hideContextMenu(){this.$('.playback_rate ul').hide();}},{key:'updatePlaybackRate',value:function updatePlaybackRate(rate){this.setSelectedRate(rate);}},{key:'setSelectedRate',value:function setSelectedRate(rate){ // Set <video playbackRate="..."
	this.core.$el.find('video').get(0).playbackRate = rate;this.selectedRate = rate;this.updateText();}},{key:'setActiveListItem',value:function setActiveListItem(rateValue){this.$('a').removeClass('active');this.$('a[data-playback-rate-select="' + rateValue + '"]').addClass('active');}},{key:'buttonElement',value:function buttonElement(){return this.$('.playback_rate button');}},{key:'getTitle',value:function getTitle(){var _this=this;var title=this.selectedRate;this.playbackRates.forEach(function(r){if(r.value == _this.selectedRate){title = r.label;}});return title;}},{key:'updateText',value:function updateText(){this.buttonElement().text(this.getTitle());this.setActiveListItem(this.selectedRate);}},{key:'name',get:function get(){return 'playback_rate';}},{key:'template',get:function get(){return (0,_clappr.template)(_publicPlaybackRateSelectorHtml2['default']);}},{key:'attributes',get:function get(){return {'class':this.name,'data-playback-rate-select':''};}},{key:'events',get:function get(){return {'click [data-playback-rate-select]':'onRateSelect','click [data-playback-rate-button]':'onShowMenu'};}}]);return PlaybackRatePlugin;})(_clappr.UICorePlugin);exports['default'] = PlaybackRatePlugin;PlaybackRatePlugin.type = 'core';PlaybackRatePlugin.MEDIACONTROL_PLAYBACKRATE = 'playbackRate';module.exports = exports['default'];

/***/ },
/* 1 */
/***/ function(module, exports) {

	module.exports = __WEBPACK_EXTERNAL_MODULE_1__;

/***/ },
/* 2 */
/***/ function(module, exports) {

	module.exports = "<button data-playback-rate-button>\n  <%= title %>\n</button>\n<ul>\n  <% for (var i = 0; i < playbackRates.length; i++) { %>\n    <li><a href=\"#\" data-playback-rate-select=\"<%= playbackRates[i].value %>\"><%= playbackRates[i].label %></a></li>\n  <% }; %>\n</ul>\n";

/***/ },
/* 3 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(4)();
	// imports


	// module
	exports.push([module.id, ".playback_rate[data-playback-rate-select] {\n  float: right;\n  margin-top: 5px;\n  position: relative; }\n  .playback_rate[data-playback-rate-select] button {\n    background-color: transparent;\n    color: #fff;\n    font-family: Roboto,\"Open Sans\",Arial,sans-serif;\n    -webkit-font-smoothing: antialiased;\n    border: none;\n    font-size: 10px;\n    cursor: pointer; }\n    .playback_rate[data-playback-rate-select] button:hover {\n      color: #c9c9c9; }\n    .playback_rate[data-playback-rate-select] button.changing {\n      -webkit-animation: pulse 0.5s infinite alternate; }\n  .playback_rate[data-playback-rate-select] > ul {\n    display: none;\n    list-style-type: none;\n    position: absolute;\n    bottom: 25px;\n    border: 1px solid black;\n    border-radius: 4px;\n    background-color: rgba(0, 0, 0, 0.7); }\n  .playback_rate[data-playback-rate-select] li {\n    position: relative;\n    font-size: 10px; }\n    .playback_rate[data-playback-rate-select] li[data-title] {\n      padding: 5px; }\n    .playback_rate[data-playback-rate-select] li a {\n      color: #aaa;\n      padding: 2px 10px 2px 15px;\n      display: block;\n      text-decoration: none; }\n      .playback_rate[data-playback-rate-select] li a.active {\n        background-color: black;\n        font-weight: bold;\n        color: #fff; }\n        .playback_rate[data-playback-rate-select] li a.active:before {\n          content: '\\2713';\n          position: absolute;\n          top: 2px;\n          left: 4px; }\n      .playback_rate[data-playback-rate-select] li a:hover {\n        color: #fff;\n        text-decoration: none; }\n\n@-webkit-keyframes pulse {\n  0% {\n    color: #fff; }\n  50% {\n    color: #ff0101; }\n  100% {\n    color: #B80000; } }\n", ""]);

	// exports


/***/ },
/* 4 */
/***/ function(module, exports) {

	/*
		MIT License http://www.opensource.org/licenses/mit-license.php
		Author Tobias Koppers @sokra
	*/ // css base code, injected by the css-loader
	"use strict";module.exports = function(){var list=[]; // return the list of modules as css string
	list.toString = function toString(){var result=[];for(var i=0;i < this.length;i++) {var item=this[i];if(item[2]){result.push("@media " + item[2] + "{" + item[1] + "}");}else {result.push(item[1]);}}return result.join("");}; // import a list of modules into the list
	list.i = function(modules,mediaQuery){if(typeof modules === "string")modules = [[null,modules,""]];var alreadyImportedModules={};for(var i=0;i < this.length;i++) {var id=this[i][0];if(typeof id === "number")alreadyImportedModules[id] = true;}for(i = 0;i < modules.length;i++) {var item=modules[i]; // skip already imported module
	// this implementation is not 100% perfect for weird media query combinations
	//  when a module is imported multiple times with different media queries.
	//  I hope this will never occur (Hey this way we have smaller bundles)
	if(typeof item[0] !== "number" || !alreadyImportedModules[item[0]]){if(mediaQuery && !item[2]){item[2] = mediaQuery;}else if(mediaQuery){item[2] = "(" + item[2] + ") and (" + mediaQuery + ")";}list.push(item);}}};return list;};

/***/ }
/******/ ])
});
;