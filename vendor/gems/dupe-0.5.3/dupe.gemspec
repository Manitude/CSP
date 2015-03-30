Gem::Specification.new do |s|
  s.name = "dupe"
  s.version = '0.5.3'
  s.authors = "Matt Parker"
  s.summary = "Dupe - a testing library for ActiveResource"
  s.description = "TDD your services outside in by starting at the client, then working your way back to the server."
  s.email = "moonmaster9000@gmail.com"
  s.homepage = "http://github.com/moonmaster9000/dupe"

  s.files = Dir["lib/**/*"]
  s.test_files = Dir["spec/**/*"]
end