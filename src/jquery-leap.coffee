
$ = jQuery

Leap.Controller.plugin 'jQuery', (options)->
  options.class ?= 'leap-receiver'
  options.event_type ?= 'leap'

  receivers = ".#{options.class}:visible"

  $.fn.extend
    leap: (selector, callback)->
      if typeof selector == 'function'
        [callback, selector] = arguments
      $target = $(selector ? @)
        .addClass options.class
      if callback?
        $target.on options.event_type, callback
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

      $(receivers).each ->
        if containsPosition @, clientPosition
          $(@).trigger
            type: options.event_type,
            clientX: clientPosition[0].toFixed()
            clientY: clientPosition[1].toFixed()
            frame: frame
            finger: frontmost


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
