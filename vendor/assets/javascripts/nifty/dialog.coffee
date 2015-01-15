window.Nifty ||= {}
window.Nifty.Dialog =

  # The numerical ID to start showing dialogs from
  startingID: 1

  # A callback reference which is run on content set if set.
  onSetContent: null

  # Stores all behaviors
  behaviors: {}

  # Open a new dialog which will accept a number of possible options.
  #
  #   id         => the ID to assign to this dialog (prefixed with 'niftyDialog-' )
  #
  #   url        => open a dialog containing the HTML at the given URL. When
  #                 displaying using a URL, the dialog will open immediately
  #                 and containing a spinner until the data is loaded.
  #
  #   html       => a string of HTML which contains the HTML which should be
  #                 displayed in the dialog.
  #
  #   afterLoad  => a callback to execute after the dialog has been loaded.
  #
  #   width      => the width of the dialog (in px, defaults to CSS-provided)
  #
  #   offset     => specifies a vertical offset (in px)
  #
  #   stack      => adds an offset if this is not the first open dialog
  #
  #   class      => the CSS class to assign to this dialog
  #
  #   behavior   => the name of a behavior set to be invoked on dialog open/close.
  #                 Behaviors can be setup using the Nifty.Dialog.addBehavior method.
  #                 Valid behaviors: beforeLoad, onLoad, onSetContent, onClose
  #
  open: (options={})->
    # set a dialog ID for this dialog
    dialogsOpen = $('div.niftyDialog').length
    dialogID = if dialogsOpen == 0 then this.startingID else (dialogsOpen * 10) + this.startingID

    options.id = dialogID unless options.id?

    # Add the overlay
    overlayClass = ''
    overlayClass = 'invisible' if dialogID > 1
    theOverlay = $("<div class='niftyOverlay #{overlayClass}'></div>").appendTo($('body')).css('z-index', 2000 + dialogID - 1)

    # create a template and assign the ID
    dialogTemplate = $("<div class='niftyDialog #{options.class || ''}' id='niftyDialog-#{options.id}'></div>")
    dialogTemplate.data('dialogID', dialogID)

    # insert the dialog into the page
    insertedDialog = dialogTemplate.appendTo(theOverlay)
    insertedDialog.css('z-index', 2000 + dialogID)

    # set the content on the dialog
    insertedDialog.data('options', options)

    # fade the overlay
    $('body').addClass('niftyDialog-open')
    theOverlay.fadeIn('fast')

    # if we have a width, set the width for the dialog
    if options.width?
      insertedDialog.css('width', "#{options.width}px")

    if options.offset?
      insertedDialog.css('top', "#{options.offset}px")
      insertedDialog.css('left', "#{options.offset}px")

    if options.stack?
      currentLeft = insertedDialog.css('left')
      currentTop = insertedDialog.css('left')
      currentLeft = 0 if currentLeft == 'auto'
      currentTop = 0  if currentTop == 'auto'
      x = parseInt(currentLeft, 10) + (dialogsOpen * 20)
      y = parseInt(currentTop, 10) + (dialogsOpen * 30)
      insertedDialog.css
        'left': "#{x}px"
        'top': "#{y}px"


    # Set the closing action for the inserted dialog to close dialog
    # and fade out the appropriate overlay
    insertedDialog.data 'closeAction', =>
      options.onClose.call(null, insertedDialog, options) if options.onClose?
      if options.behavior? && behavior = this.behaviors[options.behavior]
        behavior.onClose.call(null, insertedDialog, options) if behavior.onClose?
      insertedDialog.fadeOut 'fast', -> insertedDialog.remove()
      theOverlay.fadeOut 'fast', ->
        theOverlay.remove()
        if $('.niftyOverlay').length == 0
          $('body').removeClass('niftyDialog-open')


    # Set that clicking on the dialog's overlay will close the dialog
    theOverlay.on 'click', (e)->
      if $(e.target).is('.niftyOverlay')
        insertedDialog.data('closeAction').call()

    # load in the content
    if options.url?
      # if loading from a URL, do this
      insertedDialog.addClass 'ajax'
      insertedDialog.addClass 'loading'
      if options.behavior? && behavior = this.behaviors[options.behavior]
        behavior.beforeLoad.call(null, insertedDialog, options) if behavior.beforeLoad?

      $.ajax
        url: options.url
        success: (data)=> this.displayDialog(insertedDialog, data)

    else if options.html?
      this.displayDialog(insertedDialog, options.html)

    else
      # anything else won't work
      console.log "Dialog could not be displayed. Invalid options passed."
      console.log options
      return false

  # Add a behaviour callback which will be executed
  addBehavior: (options)->
    if options.name?
      this.behaviors[options.name] = options
      true
    else
      console.log "Must pass a 'name' option to the addBehavior method."
      false

  # Complete the opening of a dialog with the given HTML
  displayDialog: (dialog, content)->
    dialog.html(content)
    dialog.fadeIn('fast')
    dialog.removeClass 'loading'
    options = dialog.data('options')
    if options.behavior? && behavior = this.behaviors[options.behavior]
      behavior.onLoad.call(null, dialog, options) if behavior.onLoad?
      behavior.onSetContent.call(null, dialog, options) if behavior.onSetContent?
    options.afterLoad.call(null, dialog) if options.afterLoad?
    this.onSetContent(null, dialog) if this.onSetContent?

  # This method will replace the contents of the nearest dialog (or the one with the
  # given ID if one is given).
  setContent: (content, id = null)->
    dialog = if id == null then $('div.niftyDialog:last') else $("div.niftyDialog#niftyDialog-#{id}")
    if dialog.length
      dialog.html(content)
      options = dialog.data('options')
      if options.behavior? && behavior = this.behaviors[options.behavior]
        behavior.onSetContent.call(null, dialog, options) if behavior.onSetContent?
      this.onSetContent(null, dialog) if this.onSetContent?

  # This method will refectch the contents of the nearest dialog (or the one with the
  # given ID if one is given).
  reloadContent: (id = null)->
    dialog = if id == null then $('div.niftyDialog:last') else $("div.niftyDialog#niftyDialog-#{id}")
    options = dialog.data('options')
    if options.url?
      if options.behavior? && behavior = this.behaviors[options.behavior]
        behavior.beforeLoad.call(null, dialog, options) if behavior.beforeLoad?
      $.ajax
        url: options.url
        success: (data)=> this.setContent(data, id)

  # Create a new overlay
  createOverlay: (options)->
    overlay = $("<div class='niftyOverlay invisible'></div>")
    overlay.insertBefore(options.behind)
    overlay.css("z-index", options.behind.css('z-index') - 1)
    overlay.on 'click', ->
      options.close.call(overlay)
      overlay.fadeOut 'fast', ->
        overlay.remove()
    overlay.fadeIn('fast')

  # Closes the top dialgo in the dialog stack
  closeTopDialog: ->
    if $('div.niftyDialog').length
      $('div.niftyDialog:last').data('closeAction').call()


