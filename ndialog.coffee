class NDialog
  @version: "0.0.1"

  @instance: null

  @close: ->
    if @instance
      @instance.close()
      @instance = null

  # Alias for `new NDialog`.
  @open: (options={}) ->
    new NDialog(options)

  # Sets default options.
  @configure: (options={}) ->
    $.extend NDialog::options, options
    this

  # Main parent element.
  $el: null

  # The popup container. (belongs to $el)
  $popup: null

  # The white screen that captures clicks.
  $screen: null

  options:
    zIndex: 1000
    margin: [10, 10]
    explicitSize: false
    class: ''
    template: (data) -> data.html # Template function for HTML
    defaultContent: ''
    escapable: true

  constructor: (options={}) ->
    # Don't allow more than one
    NDialog.close()

    # Register it so it may be closed
    NDialog.instance = this

    # Make it
    $.extend @options, options
    @render()

    # Preload
    if options.url
      @load options.url
    else if options.html
      @setHTML options.html

    this

  render: ->
    @$el = $("<div class='ndialog'>")
      .addClass(@options.class)
      .addClass('loading')
      .css(position: 'absolute', top: 0, left: 0, zIndex: @options.zIndex)
      .appendTo($("body"))

    @$screen = $("<div class='ndialog-screen'>")
      .css(position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, zIndex: 1)
      .appendTo(@$el)

    @$popup = $("<div class='ndialog-popup'>")
      .css(position: 'absolute')
      .css(zIndex: 2)
      .html(@options.defaultContent)
      .appendTo(@$el)

    @reposition()
    @bindEvents()
    @trigger 'open', dialog: this

    this

  close: ->
    return unless @$el.parent().length > 0
    @unbindEvents()
    @trigger 'close', dialog: this
    @$el.remove()
    this

  bindEvents: ->
    # Auto-reposition (and adjusting the screen) when resizing
    $(window).on 'resize.ndialog', => @reposition()

    if @options.escapable
      # Double-click on white space to close
      @$screen.on 'dblclick.ndialog', (e) =>
        e.preventDefault(); @close()

      # Press 'escape' to close
      $(document).on 'keydown.ndialog', (e) =>
        @close()  if e.keyCode is 27

    # Close buttons
    @$el.on 'click.ndialog', "[role='close']", (e) =>
      e.preventDefault(); @close()

    this

  unbindEvents: ->
    $(window).off 'resize.ndialog'
    $(document).off 'keydown.ndialog'
    this

  # Updates the HTML. It will be passed through `options.template` (which does
  # nothing by default).
  setHTML: (html) ->
    @$el.removeClass('loading').addClass('loaded')
    @$popup.html(@options.template(html: html))
    @trigger 'content', dialog: this
    @reposition()
    @autofocus()
    this

  # Honors the 'autofocus' attribute.
  autofocus: ->
    @$popup.find('[autofocus]').get(0)?.focus()

  # Loads via a URL path. You may pass AJAX options into `options`.
  # Returns an AJAX promise.
  load: (url, options={}) ->
    newOptions =
      complete: (xhr, status) =>
        if status is 'success'
          @setHTML(xhr.responseText)
        else
          @trigger 'error', dialog: this, status: status, xhr: xhr

    newOptions = $.extend({}, options, newOptions)
    $.ajax url, newOptions

  # Shrink-wraps the popup window around its content.
  resize: ->
    # Remove the width/height overrides of the popup so that it may flow freely.
    @$popup.css width: '', height: ''

    if @options.explicitSize
      @$popup.css
        boxSizing: 'border-box'
        width: @$popup.outerWidth()
        height: @$popup.outerHeight()

    this

  # Moves the popup to the center of the screen.
  reposition: ->
    @resize()

    popup    = (width: @$popup.outerWidth(), height: @$popup.outerHeight())
    viewport = (width: $(window).width(), height: $(window).height())
    offset   = (top: $(window).scrollTop())

    [marginTop, marginLeft] = @options.margin

    @$el.hide().css
      width: $(document).width()
      height: $(document).height()
      display: 'block'

    @$popup.css
      left: parseInt(Math.max(marginLeft, (viewport.width - popup.width) / 2))
      top:  parseInt(offset.top + Math.max(marginTop, (viewport.height - popup.height) / 2))

    this

  # Cheap events:
  # Just delegate the events onto the main element.
  on:  (event, args...) -> @$el.on  "ndialog:#{event}", args...; this
  off: (event, args...) -> @$el.off "ndialog:#{event}", args...; this
  trigger: (event, options={}) -> @$el?.trigger $.Event("ndialog:#{event}", options); this

  # Global events:
  # Catch the events in `document` as they bubble up.
  @on:  (event, args...) -> $(document).on  "ndialog:#{event}", '.ndialog', args...; this
  @off: (event, args...) -> $(document).off "ndialog:#{event}", '.ndialog', args...; this

  @register: (selector, options={}) ->
    $(document).on 'click.ndialog', selector, (e) ->
      if options.condition?
        return true unless options.condition()

      e.preventDefault()
      opts = url: $(this).attr('href')
      dialog = new NDialog($.extend({}, options, opts))

      options.onopen(dialog)  if options.onopen

# jQuery integration
jQuery.fn.ndialog = (options={}) ->
  NDialog.register @selector, options

# Export
window.NDialog = NDialog
