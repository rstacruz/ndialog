describe 'Ndialog', ->
  afterEach ->
    @dialog?.close()

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

  describe 'closing', ->
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


