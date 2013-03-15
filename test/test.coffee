describe 'Ndialog', ->
  beforeEach ->
    # Save the options before NDialog.configure.
    @options = NDialog::options

  afterEach ->
    @dialog?.close()
    NDialog::options = @options
    $(document).off '.ndialog'

  describe 'basic', ->
    beforeEach ->
      @dialog = NDialog.open(html: '<div class="msg">hello</div>')

    it 'should work', ->
      console.log @dialog.$el

    it 'should close', (done) ->
      @dialog.on 'close', -> done()
      @dialog.close()
      @dialog = null

    it 'should handle double-close', (done) ->
      count = 0
      @dialog.on 'close', -> count += 1
      @dialog.close()
      @dialog.close()
      @dialog.close()
      @dialog = null

      setTimeout (->
        count.should.equal 1
        done()
      ), 25

    it 'should have .ndialog-popup', ->
      @dialog.$popup[0].should.equal @dialog.$el.find('.ndialog-popup')[0]

    it 'should have .ndialog-screen', ->
      @dialog.$screen[0].should.equal @dialog.$el.find('.ndialog-screen')[0]

    it 'should have message in popup', ->
      @dialog.$popup.find('.msg').length.should.equal 1

  it 'should focus auto-focus boxes', (done) ->
    $html = $('<div class="msg">hello<input type="text" class="textbox" autofocus></div>')
    $html.find('.textbox').on 'focus', -> done()

    @dialog = NDialog.open(html: $html)

  describe 'escapable: true', ->
    beforeEach ->
      @count = 0
      @dialog = NDialog.open html: '''
        <div class="msg">hello</div>
        <button role='close' class='close-button'>Close</button>
      '''
      @dialog.on 'close', => @count += 1

    afterEach (done) ->
      setTimeout (=>
        @count.should.equal 1
        done()
      ), 25

    it 'should work via close button', ->
      @dialog.$popup.find('.close-button').click()

    it 'should work via double click', ->
      @dialog.$screen.dblclick()

    it 'should work via Escape key', ->
      $(document).trigger $.Event('keydown', keyCode: 27)

  describe 'escapable: false', ->
    beforeEach ->
      NDialog.configure escapable: false
      @count = 0
      @dialog = NDialog.open html: '''
        <div class="msg">hello</div>
        <button role='close' class='close-button'>Close</button>
      '''
      @dialog.on 'close', => @count += 1

    it 'should work via close button', ->
      @dialog.$popup.find('.close-button').click()
      @count.should.equal 1

    describe 'escaping', ->
      afterEach (done) ->
        setTimeout (=>
          @count.should.equal 0
          done()
        ), 25

      it 'should work via double click', ->
        @dialog.$screen.dblclick()

      it 'should work via Escape key', ->
        $(document).trigger $.Event('keydown', keyCode: 27)

  describe 'templates', ->
    beforeEach ->
      @fn = (data) ->
        """
          <div class='popup-box'>
            #{data.html}
          </div>
        """

    it 'should work with html', ->
      @dialog = NDialog.open template: @fn, html: "<div class='msg'>hello</div>"

      @dialog.$popup.find('.popup-box').length.should.equal 1
      @dialog.$popup.find('.msg').length.should.equal 1

    it 'should work via .configure', ->
      NDialog.configure template: @fn

      @dialog = NDialog.open html: "<div class='msg'>hello</div>"

      @dialog.$popup.find('.popup-box').length.should.equal 1
      @dialog.$popup.find('.msg').length.should.equal 1

  describe 'options', ->
    it 'defaultContent', ->
      @dialog = NDialog.open defaultContent: '<div class="msg">xxx</div>'

      @dialog.$popup.find('.msg').text().should.equal 'xxx'

    it 'zIndex', ->
      @dialog = NDialog.open zIndex: 3050
      @dialog.$el.css('z-index').should.equal '3050'

    it 'class', ->
      @dialog = NDialog.open class: 'ticklesphinx'
      @dialog.$el.is('.ticklesphinx').should.equal true

  describe 'shrinkwrapping', ->
    for size in [100, 200]
      it "should work (#{size}px)", ->
        @dialog = NDialog.open html: """
          <div style='width: #{size}px; height: #{size + 10}px;'></div>
        """

        @dialog.$popup.outerWidth().should.equal size
        @dialog.$popup.outerHeight().should.equal (size + 10)

  describe 'errors', ->
    it 'should trigger the error event', (done) ->
      @dialog = NDialog.open url: 'xxx'

      @dialog.on 'error', (e) ->
        e.status.should.equal 'error'
        (typeof e.xhr.readyState).should.equal 'number'
        done()

    it 'should work on the document level', (done) ->
      NDialog.on 'error', (e) ->
        e.status.should.equal 'error'
        (typeof e.xhr.readyState).should.equal 'number'
        done()

      @dialog = NDialog.open url: 'xxx'

   describe 'register', ->
     it 'should work', (done) ->
       NDialog.on 'open', -> done()
       $('.ndialog-link').ndialog()
       $link = $("<a href='lol' class='ndialog-link'>")
       $(document.body).append $link
       $link.trigger 'click'
