SuccessExtranet.RworldSocialAppInfo = function () {

  var _langSelect = null;

  var _init = function () {
    _langSelect = $("rworld_info_language");
    if (_langSelect) {
      _langSelect.observe("change", _respondToChange);
    }
  };

  var _respondToChange = function () {
    var value = _langSelect.value;
    var url = "/learners/" + SuccessExtranet.getConfig().user_id + "/rworld_social_app_info?" + "language=" + value;
    new Ajax.Updater("rworld_info_container", url, {method: "get", parameters: {language: value} });
  };

  return {
    /**
     *  inits the form control on the browser
     */
    init: function() {
      _init();
    }
  };
}();