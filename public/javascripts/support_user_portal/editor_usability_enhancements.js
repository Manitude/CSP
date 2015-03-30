var EditorAccessKeys = {
  invalid_focus_types: $A(['hidden', 'submit', 'checkbox', 'radio']),
  valid_focus_tags:  $A(['input', 'textarea', 'select']),

  add_access_key_highlighting: function(nav_block_id) {
    var nav_block = $(nav_block_id);
if ($(nav_block_id)){
    var links = $A(nav_block.getElementsByTagName('a'));
    links.each(function(link) {
      re = new RegExp('(' + link.accessKey + ')', 'i');
      link.innerHTML = link.innerHTML.replace(re, "<em>$1</em>");
    });
   }
  },

  focus_first_non_hidden_form_field_on_page: function() {
    var first_form = document.forms[0];
    if (!first_form || (first_form.elements.length === 0)) { return; }
    var elems = $A(first_form.elements);
    var focusable = elems.detect(function(elem) {
      return(this.valid_focus_tags.include(elem.tagName.toLowerCase()) &&
        !this.invalid_focus_types.include(elem.type.toLowerCase()) &&
        elem.visible());
    }.bind(this));
    if (focusable) { focusable.focus(); }
  },

  force_form_element_to_submit_on_return: function(elem) {
    $(elem).addEventListener('keypress', this._submit_parent_form_on_return, true);
  },

  _submit_parent_form_on_return: function(evt) {
    return (evt.keyCode == '13') ? this.form.submit() : true;
  }
};

Event.observe(window, 'load', function() { EditorAccessKeys.add_access_key_highlighting('nav_main'); });
Event.observe(window, 'load', function() { EditorAccessKeys.focus_first_non_hidden_form_field_on_page(); });
