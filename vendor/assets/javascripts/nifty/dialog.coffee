window.Nifty ||= {}
window.Nifty.Dialog =
  
  # The zindex to start showing dialogs from
  startingID: 1
  
  # A callback reference which is run on content set if set.
  onSetContent: null
  
  closeTopDialog: ->
    if $('div.niftyDialog').length
      $('div.niftyDialog:last').data('closeAction').call()
  
  # Closes the any overlay which is in place
  closeOverlay: -> this.closeTopDialog()
      
  # Open a new dialog which will accept a number of possible options.
  #
  #   url        => open a dialog containing the HTML at the given URL. When
  #                 displaying using a URL, the dialog will open immediately
  #                 and containing a spinner until the data is loaded.
  #
  open: (options={})->

    # set a dialog ID for this dialog
    dialogsOpen = $('div.dialog').length
    dialogID = if dialogsOpen == 0 then this.startingID else (dialogsOpen * 10) + this.startingID
    
    # create a template and assign the ID
    dialogTemplate = $("<div class='niftyDialog #{options.class}' id='niftyDialog-#{options.id}'></div>")
    dialogTemplate.data('dialogID', dialogID)
    # insert the dialog into the page
    insertedDialog = dialogTemplate.appendTo($('body'))
    insertedDialog.css('z-index', 2000 + dialogID)
    
    overlayClass = ''
    overlayClass = 'invisible' if dialogID > 1
    theOverlay = $("<div class='niftyOverlay #{overlayClass}'></div>").insertBefore(insertedDialog).css('z-index', 2000 + dialogID - 1)
    theOverlay.fadeIn('fast')
    
      # if we have a width, set the width for the dialog
    if options.width?
      insertedDialog.css('width', "#{options.width}px")
      insertedDialog.css('margin-left', "-#{options.width / 2}px")
    
    # load in the content
    if options.url?
      # if loading from a URL, do this
      insertedDialog.addClass 'ajax'
      insertedDialog.addClass 'loading'
      $.ajax
        url: options.url
        success: (data)=>
          insertedDialog.html(data)
          insertedDialog.removeClass 'loading'
          options.afterLoad.call(insertedDialog) if options.afterLoad?
          insertedDialog.data 'closeAction', ->
            closeMethod = insertedDialog.data('onClose')
            closeMethod.call(insertedDialog) if closeMethod
            insertedDialog.fadeOut 'fast', -> insertedDialog.remove()
            theOverlay.fadeOut 'fast', -> theOverlay.remove()
          theOverlay.on 'click', -> insertedDialog.data('closeAction').call()
          insertedDialog.fadeIn('fast')
          this.onSetContent(null, insertedDialog) if this.onSetContent?

    else
      # anything else won't work
      console.log "Dialog could not be displayed. Invalid options passed."
      console.log options
      return false
    
    
  # This method will replace the contents of the nearest dialog (or the one with the
  # given ID if one is given).
  setContent: (content, id = null)->
    dialog = if id == null then $('div.dialog:last') else $("div.dialog.dialog-#{id}")
    dialog.html(content)
    this.onSetContent(null, dialog) if this.onSetContent?
  
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
    