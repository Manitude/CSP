SuccessExtranet.Util = function () {

  return {

    /**
     * Returns an array of option element for the parsed opts array
     */
    generateOptionsForSelect : function(opts) {
      var options = [];
      var optsLength = opts.length;
      for (var i = 0; i < optsLength; i++ ) {
        options[i] = '<option value="' + opts[i] +'">' + opts[i] + '</options>';//new Element('option').update(opts[i]);
      }
      return options.join('\n');
    }

  };

}();

