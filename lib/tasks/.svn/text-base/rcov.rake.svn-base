require 'rcov/rcovtask'

Rcov::RcovTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb', 'test/unit/*.rb', 'test/unit/agenst/*.rb', 'test/unit/community/*.rb', 'test/unit/eschool/*.rb', 'test/unit/helpers/*.rb', 'test/unit/lib/*.rb', 'test/unit/locos/*.rb', 'test/unit/parser/*.rb', 'test/unit/presenters/*.rb', 'test/unit/utils/*.rb', 'test/unit/validator/*.rb', 'test/functional/*.rb', 'test/functional/extranet/*.rb', 'test/functional/report/*.rb', 'test/functional/support_user_portal/*.rb', 'test/integration/*.rb', ]
  t.verbose = true
end