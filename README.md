# Ndialog

Simple modal dialog implementation.

Why?
----

Sure there are tons of modal dialog implementations out there, but:

 * NDialog is dead simple.

It has these limitations, which I'd like to consider as features:

 * NDialog assumes no IE7/IE6 support, meaning the markup is much simpler.
 * NDialog has no support for image galleries.
 * Only one dialog can be open for now (multi-dialogs to be implemented later).,

Opening
-------

You can open a dialog by using `NDialog.open` or the constructor.

``` javascript
NDialog.open({url: '/users/index.html'});
NDialog.open({html: '<div>hello there</div>'});

// Or you can also use the constructor (works the same way):
new NDialog({url: 'x'});
new NDialog({html: 'x'});
```

Or you can do it manually:

``` javascript
var dialog = new NDialog();

dialog.load('/users/index.html');
dialog.setHTML('<div>hello there</div>');
```

Closing the dialog
------------------

Simply call '#close()':

``` javascript
dialog = new NDialog({url: '/users/index.html'});

dialog.close();
```

Or you can close all dialogs:

``` javascript
NDialog.close()
```

In the HTML, you can have `role='close'` on any element and it'd act as a
close button:

``` html
<button role='close'>
```

Instance tracking
-----------------

There can always be just one instance of NDialog at any time. They are stored
in `NDialog.instance`.

``` javascript
NDialog.instance
// null, or NDialog instance
```

Events
------

You can bind events using `#on()` and `#off()`:

``` javascript
n = new NDialog();

n.on('content', function (e, dialog) {
  _gaq.push(...);
});
```

Available events are:

    content   - when content is loaded
    close     - triggered before the popup is removed
    open      - triggered after opening
    error     - when there's an ajax error

Options
-------

There are lots of options. You can pass them to the constructor:

``` javascript
var dialog = new NDialog({ zIndex: 30 });
```

or through the jQuery integration macro:

``` javascript
var dialog = $("[role='dialog']").ndialog({ zIndex: 30 });
```

or through NDialog.configure, which sets defaults for all dialog boxes:

``` javascript
NDialog.configure({ zIndex: 30 });
```

Available options
-----------------

 - zIndex: (Number) the z index. Default: 1000
 - margin: Vertical and horizontal margins. Default: [10, 10]
 - explicitSize: false
 - class: (String) additional class name. Default: ''
 - defaultContent: ''
 - escapable: (Boolean) allows you to double-click or escape to exit. Default: true
 - template: (Function) Template function for HTML

Customizing templates
---------------------

You can pass a template function that works like this:

``` javascript
var tpl = function(data) {
  return "" +
  "<button class='close' role='close'>&times;</button>" +
  "<div class='content'>" + data.html + "</div>";
};

var dialog = new NDialog({ template: tpl });
```

Or make it apply to all:

``` javascript
NDialog.configure({ template: tpl });
```

This makes the templates apply on `setHTML()` and `load()`.

jQuery integration
------------------

This will make all links of a given selector open as NDialog popups.

``` javascript
var dialog = $("[role='dialog']").ndialog();
```

You can pass options that will go to the constructor of NDialog, for example:

``` javascript
var dialog = $("[role='dialog']").ndialog({ zIndex: 30 });
```

For responsive UIs, you can pass a `condition` function. If this function
returns false, a dialog will not be opened, and a link will be followed
normally instead.

    var dialog = $("[role='dialog']").ndialog({
      condition: function() { return $(window).width() > 600; }
    });

Event binding
-------------

``` javascript
var dialog = new NDialog(...);

dialog.on('close', function() { ... });
```

You can bind events to all dialogs via `NDialog.on` -- this will take effect
on all dialogs.

``` javascript
dialog.on('close', function (e, dialog) {
});
```

Basic CSS
---------

Unlike other lightbox libraries, CSS needed by NDialog is dirt simple. Here's
a sample to get you started: this is actually enough to get you started already.

``` css
.ndialog-screen {
  background: #222; opacity: 0.5; }

.ndialog-popup {
  border: solid 2px #333;
  background: white; }

.loading .ndialog-popup:before {
  content: 'Loading...' }
```

Markup
------

The generated markup looks like this:

``` html
<body>
  <div class='ndialog'>
    <div class='ndialog-screen'></div>
    <div class='ndialog-popup'>...</div>
  </div>
</body>
```

Some notes:

  - `.ndialog` has the class `loading` or `loaded` depending on its state.
  - `.ndialog-screen` is below `.ndialog-popup` in terms of zIndex.

Error handling
--------------

Just catch the `error` event.

``` javascript
NDialog.on('error', function(e) {
  dialog.setHTML("Something went wrong. There was a '"+e.status+"' error.");

  e.status; /* Ajax status */
  e.xhr;    /* XmlHTTPRequest object */
  e.dialog; /* Dialog object */
});
```
