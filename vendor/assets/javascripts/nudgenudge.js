/*
jquery.nudgenudge.1.0.js

Copyright (C) 2012 Andy Shora, @andyshora, andyshora.com

This plugin is licensed under the MIT license. You can pretty much do whatever you want with it, just keep me in the credits here, and if it really helps you then feel free to give me a tweet and let me know!

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
(function($){
    $.nudgenudge = function(el, options, i){
        // To avoid scope issues, use 'base' instead of 'this'
        // to reference this class from internal events and functions.
        var base = this;

        // Access to jQuery and DOM versions of element
        base.$el = $(el);
        base.el = el;

        // Add a reverse reference to the DOM object
        base.$el.data("nudgenudge", base);

        base.init = function(){

            base.options = $.extend({},$.nudgenudge.defaultOptions, options);

            // Put your initialization code here
        };

        base.addCloseEventHandlers = function(i){
        	$(options.closeEvent.el).bind(options.closeEvent.event, function(){
        		$('#nudgenudge_' + i).hide();
        	});
        };
        base.removeArrow = function(i) {
        	$('#nudgenudge_' + i).remove();
        };
        base.addNudgeAnimation = function(){
        
        	
        	// get offset of element
        	var offset = $(base.el).offset();
        	var el_left = offset.left;
        	var el_top = offset.top;
        	var el_height = $(base.el).outerHeight();
        	var el_width = $(base.el).outerWidth();

        	var n_left = 0;
        	var n_top = 0;
        	
        	n_top = (el_top + (el_height/2)) + options.offsetY - 30;
        	
        	var dir = "";
        	
        	if (options.placement === 'left') {
        		n_left = el_left + options.offsetX - 200;
        		dir = "nudgenudge_left";
        	} else if (options.placement === 'right') {
        		n_left = el_left + options.offsetX + el_width;
        		dir = "nudgenudge_right";
        	}
        
        	$('body').append('<div id="nudgenudge_'+i+'" class="nudgenudge_wrap intensity_'+options.intensity+'" style="top:'+n_top+'px;left:'+n_left+'px;"><img class="nudgenudge '+dir+'" src="'+options.arrow+'" alt="" /></div>');
        	
        	if (options.hideAfter > 0){
	        	var one_nudge_duration = 0;
	        	switch (options.intensity) {
	        		case "low":
	        			one_nudge_duration = 2000;
	        			break;
	        		case "medium":
	        			one_nudge_duration = 1000;
	        			break;
	        		case "high":
	        			one_nudge_duration = 800;
	        			break;
	        	}
	        	if (one_nudge_duration > 0) {
	        		var fade_time = 200;
	        		var timeout = (options.hideAfter * one_nudge_duration) - fade_time;
	        		setTimeout("$('#nudgenudge_"+i+"').fadeOut("+fade_time+");", timeout)
	        	}
        	}
        };

        // Run initializer
        base.init();
        
        
        base.addNudgeAnimation();
        base.addCloseEventHandlers(i);
        
        $(window).resize(function(){
        	base.removeArrow(i);
        	base.addNudgeAnimation();
        });
        
    };

    $.nudgenudge.defaultOptions = {
    	arrow: 'img/arrow_default.png', // path to the arrow image
        intensity: 'medium', // how aggressively shall we point
        placement: 'left',
        hideAfter: 0, // 0 = for the rest of eternity
        offsetX: 5,
        offsetY: 0,
        arrowWidth: 150,
		arrowHeight: 60,
		nudgeLength: 50
    };

    $.fn.nudgenudge = function(options){
    	// count how many instances are already on the page
    	var n = ($('.nudgenudge_wrap')).length;
    
    	var i = n;
        return this.each(function(){
            (new $.nudgenudge(this, options, i));

		   // HAVE YOUR PLUGIN DO STUFF HERE

		   // END DOING STUFF
		   i++;
        });
    };

})(jQuery);