SuccessExtranet.TotaleCourseInfo = function () {

  var _langsLevels = null;
  var _langSelect = null;
  var _levelSelect = null;

  var _init = function () {
    _langSelect = $("lang");
    if (_langSelect) {
      _langSelect.observe("change", _respondToChange);
      _respondToChange(); //For the initial selecte value
    }
  };

  var _respondToChange = function (event) {
    var value = _langSelect.value;
    var levelsOpts = _langsLevels[value];
    levelsOpts = typeof(levelsOpts) === "string" ? [levelsOpts] : levelsOpts;
    var options = SuccessExtranet.Util.generateOptionsForSelect(levelsOpts);
    _levelSelect = $("level");
    _levelSelect.update(options); //Updates the content with the new options string
  };


  return {
    /**
     *  inits the form control on the browser
     */
    init: function() {
      _init();
    },

    setLangLevels : function(langsLevels) {
      _langsLevels = langsLevels;
    }
  };
}();

