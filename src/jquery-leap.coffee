
$ = jQuery

$('<style>')
  .text '.leap-tip-cursor {' +
    'width: 10px;' +
    'height: 10px;' +
    'margin-top: -5px;' +
    'margin-left: -5px;' +
    'border: 1px solid #000;' +
  '}'
  .appendTo 'head'

Leap.Controller.plugin 'jQuery', (options)->
  options.target_class ?= 'leap-target'
  options.hover_class ?= 'leap-hover'
  options.event_type ?= 'leap'

  targets = ".#{options.target_class}:visible"

  tipCursor = undefined
  if options.show_cursor
    $ ->
      tipCursor = $('<div class=leap-tip-cursor>')
        .css
          position: 'absolute'
          display: 'block'
        .appendTo 'body'
      tipCursor.moveTo = (position)->
        @css
          left: position[0].toFixed() + 'px'
          top: position[1].toFixed() + 'px'

  $.fn.extend
    leap: (selector, config = {})->
      if typeof selector == 'object'
        [config, selector] = arguments
      $target = $(selector ? @)
        .addClass options.target_class

      for event_type in ['enter', 'move', 'leave']
        if config[event_type]?
          $target.on options.event_prefix + event_type, config[event_type]
      @

  frame: (frame)->
    frontmost = undefined
    frame.fingers.forEach (finger)->
      if finger.extended
        if !frontmost? || frontmost.stabilizedTipPosition[2] > finger.stabilizedTipPosition[2]
          frontmost = finger

    if frontmost
      clientPosition = options.calibrator?.convert frontmost.stabilizedTipPosition
      clientPosition ?= leapToClient frame, frontmost.stabilizedTipPosition
      tipCursor?.moveTo clientPosition
        .show()

      $(targets).each ->
        $target = $(@)
        hasFinger = $target.data '.leap-finger'

        event_type = if containsPosition @, clientPosition
          $target
            .data '.leap-finger', frontmost
            .addClass options.hover_class
          if hasFinger then 'move' else 'enter'
        else if hasFinger
          $target
            .removeData '.leap-finger'
            .removeClass options.hover_class
          'leave'

        if event_type
          $target.trigger
            type: options.event_prefix + event_type
            clientX: clientPosition[0].toFixed()
            clientY: clientPosition[1].toFixed()
            frame: frame
            finger: frontmost
    else
      tipCursor?.hide()


leapToClient = (frame, position)->
  norm = frame.interactionBox.normalizePoint position
  screenPosition = [ window.innerWidth * norm[0], window.innerHeight * (1 - norm[1]) ]

containsPosition = (element, position)->
  [x, y] = position
  rect = element.getBoundingClientRect()
  x >= rect.left &&
    x <= rect.right &&
    y >= rect.top &&
    y <= rect.bottom
