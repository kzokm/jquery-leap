// Generated by CoffeeScript 1.8.0

/*
 * jQuery Leap Plugin - 0.1.0, 2014-10-04
 * https://github.com/kzokm/jquery-leap/
 *
 * Copyright (c) 2014 OKAMURA Kazuhide
 *
 * This software is released under the MIT License.
 * http://opensource.org/licenses/mit-license.php
 */

(function() {
  var $, containsPosition, leapToClient;

  $ = jQuery;

  $('<style>').text('.leap-tip-cursor {' + 'width: 10px;' + 'height: 10px;' + 'margin-top: -5px;' + 'margin-left: -5px;' + 'border: 1px solid #000;' + '}').appendTo('head');

  Leap.Controller.plugin('jQuery', function(options) {
    var targets, tipCursor;
    if (options.target_class == null) {
      options.target_class = 'leap-target';
    }
    if (options.hover_class == null) {
      options.hover_class = 'leap-hover';
    }
    if (options.event_type == null) {
      options.event_type = 'leap';
    }
    targets = "." + options.target_class + ":visible";
    tipCursor = void 0;
    if (options.show_cursor) {
      $(function() {
        tipCursor = $('<div class=leap-tip-cursor>').css({
          position: 'absolute',
          display: 'block'
        }).appendTo('body');
        return tipCursor.moveTo = function(position) {
          return this.css({
            left: position[0].toFixed() + 'px',
            top: position[1].toFixed() + 'px'
          });
        };
      });
    }
    $.fn.extend({
      leap: function(selector, config) {
        var $target, event_type, _i, _len, _ref;
        if (config == null) {
          config = {};
        }
        if (typeof selector === 'object') {
          config = arguments[0], selector = arguments[1];
        }
        $target = $(selector != null ? selector : this).addClass(options.target_class);
        _ref = ['enter', 'move', 'leave'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          event_type = _ref[_i];
          if (config[event_type] != null) {
            $target.on(options.event_prefix + event_type, config[event_type]);
          }
        }
        return this;
      }
    });
    return {
      frame: function(frame) {
        var clientPosition, frontmost, _ref;
        frontmost = void 0;
        frame.fingers.forEach(function(finger) {
          if (finger.extended) {
            if ((frontmost == null) || frontmost.stabilizedTipPosition[2] > finger.stabilizedTipPosition[2]) {
              return frontmost = finger;
            }
          }
        });
        if (frontmost) {
          clientPosition = (_ref = options.calibrator) != null ? _ref.convert(frontmost.stabilizedTipPosition) : void 0;
          if (clientPosition == null) {
            clientPosition = leapToClient(frame, frontmost.stabilizedTipPosition);
          }
          if (tipCursor != null) {
            tipCursor.moveTo(clientPosition).show();
          }
          return $(targets).each(function() {
            var $target, event_type, hasFinger;
            $target = $(this);
            hasFinger = $target.data('.leap-finger');
            event_type = containsPosition(this, clientPosition) ? ($target.data('.leap-finger', frontmost).addClass(options.hover_class), hasFinger ? 'move' : 'enter') : hasFinger ? ($target.removeData('.leap-finger').removeClass(options.hover_class), 'leave') : void 0;
            if (event_type) {
              return $target.trigger({
                type: options.event_prefix + event_type,
                clientX: clientPosition[0].toFixed(),
                clientY: clientPosition[1].toFixed(),
                frame: frame,
                finger: frontmost
              });
            }
          });
        } else {
          return tipCursor != null ? tipCursor.hide() : void 0;
        }
      }
    };
  });

  leapToClient = function(frame, position) {
    var norm, screenPosition;
    norm = frame.interactionBox.normalizePoint(position);
    return screenPosition = [window.innerWidth * norm[0], window.innerHeight * (1 - norm[1])];
  };

  containsPosition = function(element, position) {
    var rect, x, y;
    x = position[0], y = position[1];
    rect = element.getBoundingClientRect();
    return x >= rect.left && x <= rect.right && y >= rect.top && y <= rect.bottom;
  };

}).call(this);
