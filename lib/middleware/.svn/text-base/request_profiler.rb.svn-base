require 'ruby-prof'
require 'time'

class RequestProfiler

  def initialize(app, options={})
    @app = app
    @min = options['min_percent'].to_i || 1
    @where = options['write_to'] || 'tmp/prof'
    which = options['printer'] || 'graph_html'
    @printer = ::RubyProf.const_get("#{which.camelcase}Printer")
  end

  def call(env)
    status, headers, body = nil
    res = ::RubyProf.profile do
      status, headers, body = @app.call(env)
    end
    report(env, res)
    [status, headers, body]
  end

  private

  def file(env)
    Dir.mkdir('tmp/prof') unless File.exists? 'tmp/prof'
    f = ::File.open "#{@where}/#{env['REQUEST_METHOD']}_#{env['REQUEST_URI'].gsub('/', '.')}_#{Time.now.to_i}_#{$$}.html", 'w'
    yield f
  ensure
    f.close if f
  end

  def report(env, res)
    file(env) do |f|
      p = @printer.new(res)
      p.print(f, :min_percent=>@min)
    end
  end

end
