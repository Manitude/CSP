include ActiveSupport::JSON::backend
ActiveSupport::OkJson.module_eval do
  Spc = ' '[0]
   def tok(s)
      case s[0]
      when ?{  then ['{', s[0,1], s[0,1]]
      when ?}  then ['}', s[0,1], s[0,1]]
      when ?:  then [':', s[0,1], s[0,1]]
      when ?,  then [',', s[0,1], s[0,1]]
      when ?[  then ['[', s[0,1], s[0,1]]
      when ?]  then [']', s[0,1], s[0,1]]
      when ?n  then nulltok(s)
      when ?t  then truetok(s)
      when ?f  then falsetok(s)
      when ?"  then strtok(s)
      when ?'  then strtok_ext(s)
      when Spc then [:space, s[0,1], s[0,1]]
      when ?\t then [:space, s[0,1], s[0,1]]
      when ?\n then [:space, s[0,1], s[0,1]]
      when ?\r then [:space, s[0,1], s[0,1]]
      else          numtok(s)
      end
    end

    def strtok_ext(s)
      m = /'([^'\\]|\\['\/\\bfnrt]|\\u[0-9a-fA-F]{4})*'/.match(s)
      if ! m
        raise Error, "invalid string literal at #{abbrev(s)}"
      end
      [:str, m[0], unquote(m[0])]
    end
    
 end