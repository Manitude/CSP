var BoxBox = {
  initialize: function() {
    this._add_required_elements();
  },

  show: function(content_element, onshow_handler, additional_css_class) {
    [this.shadow, this.content].each(Element.show);
    this.current_content = $(content_element).parentNode.replaceChild(this._placeholder_element(), $(content_element));
    this.content.appendChild(this.current_content);
    this._fix_ie_select_brokenisms();
    this._wax_scrollbars();
    if (additional_css_class) {
      this.content.addClassName(additional_css_class);
      this.additional_css_class = additional_css_class;
    }
    Element.show(this.current_content);
    if (typeof(onshow_handler) == 'function') { onshow_handler(); }
    this._add_key_handlers();
  },

  // Only one instance can be active at a time so we don't need to take any args.
  dismiss: function() {
    if (this.additional_css_class) {
      this.content.removeClassName(this.additional_css_class);
      this.additional_css_class = null;
    }
    [this.shadow, this.content, this.current_content].each(Element.hide);
    $('boxbox_placeholder').parentNode.replaceChild(this.content.removeChild(this.current_content), $('boxbox_placeholder'));
    Element.hide(this.shim_iframe);
    this._unwax_scrollbars();
    this._remove_key_handlers();
  },

/* Private */

  _visible: function() {
    return this.content.visible();
  },

  _add_required_elements: function() {
    var body_element = document.getElementsByTagName('body')[0];
    new Insertion.Bottom(body_element, '<div class="boxbox_hidden_element" id="boxbox_shadow" style="display: none;"></div>');
    new Insertion.Bottom(body_element, '<div class="boxbox_hidden_element" id="boxbox_content" style="display: none;"></div>');
    this.shadow = $('boxbox_shadow');
    this.content = $('boxbox_content');
    this.shim_iframe = this._add_shim_iframe();
  },

  _placeholder_element: function() {
    var ph = document.createElement('div');
    ph.style.display = 'none';
    ph.id = 'boxbox_placeholder';
    return ph;
  },

  _fix_ie_select_brokenisms: function() {
    $w('top left width height').each(function(property_name){
      this.shim_iframe.style[property_name] = this.shadow.getStyle(property_name);
    }.bind(this));
    this.shim_iframe.style.display = 'block';
  },

  // stops select boxes showing through to the div in IE 6
  _add_shim_iframe: function() {
    new Insertion.Before(this.content, '<iframe style="display: none; position: absolute; width: 0px; height: 0px;" src="javascript:\'<html></html>\'" frameBorder="0" scrolling="no" id="boxbox_ie_select_fix"></iframe>');
    $('boxbox_ie_select_fix').style.filter = 'progid:DXImageTransform.Microsoft.Alpha(style=0,opacity=0)';
    $('boxbox_ie_select_fix').style.zIndex = ((parseInt(this.content.getStyle('z-index'), 10) - 1) + '');
    return $('boxbox_ie_select_fix');
  },

  _wax_scrollbars: function() {
    this.previous_overflow = $$('html')[0].style['overflow'];
    $$('html')[0].style['overflow'] = 'hidden';
  },

  _unwax_scrollbars: function() {
    $$('html')[0].style['overflow'] = this.previous_overflow;
  },

  _add_key_handlers: function() {
    document.observe('keyup', this._on_keyup.bind(this));
  },

  _remove_key_handlers: function() {
    document.stopObserving('keyup', this._on_keyup.bind(this));
  },

  _on_keyup: function(event) {
    if (event.keyCode == Event.KEY_ESC && this._visible()) {
      this.dismiss();
    }
  }
};

Event.observe(window, 'load', function() {
  BoxBox.initialize();
});