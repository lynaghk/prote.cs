// This is a lightweight experimental framework for building JS apps in the Model-View-Presenter style.
// It's not really done yet, but it works well enough to power some of the Prote.cs examples.
// Keep an eye on my website for an eventual release: www.dirigibleFlightcraft.com
//   -Kevin
(function() {
  var Dispatcher, View;
  Dispatcher = function() {
    var dispatchers;
    this._directory = {};
    dispatchers = window._dispatchers || (window._dispatchers = []);
    dispatchers.push(this);
    return this;
  };
  Dispatcher.prototype.register = function(listener, event_str, callback) {
    var directory, self;
    if (typeof event_str === 'object') {
      self = this;
      return _(event_str).each(function(callback, event_str) {
        return self.register(listener, event_str, callback);
      });
    } else {
      if (this.listener_is_valid(listener)) {
        directory = this._directory[event_str] || (this._directory[event_str] = []);
        return directory.push({
          listener: listener,
          callback: callback
        });
      } else {
        p("Tried to register object without @uid; put \"_.uniqueId 'ClassName_'\" in the constructor before trying to register with a dispatcher");
        throw 'InvalidListener';
      }
    }
  };
  Dispatcher.prototype.listener_is_valid = function(obj) {
    var _ref;
    return (typeof (_ref = obj.uid) !== "undefined" && _ref !== null);
  };
  Dispatcher.prototype.trigger = function(event_str, args) {
    var directory, e;
    directory = this._directory[event_str] || [];
    e = {
      timeStamp: new Date().getTime(),
      type: event_str
    };
    return directory.length > 0 ? _(directory).each(function(d) {
      return d.callback.call(d.listener, e, args);
    }) : p("no listeners for '" + (event_str) + "'!");
  };
  View = function() {
    if (this.$container.length !== 1) {
      throw 'View not passed a wrapped jQuery container';
    }
    this.$tt = $('<span>', {
      "class": 'tooltip'
    }).appendTo(this.$container);
    return this;
  };
  View.prototype.trigger = function(msg, data) {
    return this.dispatcher.trigger(msg, data);
  };
  View.prototype.pv_defaults = {
    width: 600,
    height: 500,
    label_margin: 15,
    label_size: 12,
    bar_spacing: 1
  };
  View.prototype.show_tooltip = function(o) {
    var _ref;
    o = _({
      margin: 5,
      x: 0,
      y: 0
    }).extend(o);
    this.$tt.css({
      left: o.x + o.margin,
      top: o.y + o.margin
    });
    if (typeof (_ref = o.html) !== "undefined" && _ref !== null) {
      this.$tt.html(o.html);
    } else if (typeof (_ref = o.$) !== "undefined" && _ref !== null) {
      this.$tt.children().remove();
      this.$tt.append(o.$);
    }
    return this.$tt.show();
  };
  View.prototype.hide_tooltip = function() {
    return this.$tt.hide();
  };
  window.Dispatcher = Dispatcher;
  window.View = View;
}).call(this);
