class AddLearnerDataToTaskList < ActiveRecord::Migration
  def self.up
    Task.create([{:name => 'Name',:section => 'Learner Profile'},
{:name => 'Preferred Name',:section => 'Learner Profile'},
{:name => 'Age (birth date)',:section => 'Learner Profile'},
{:name => 'Gender',:section => 'Learner Profile'},
{:name => 'Location',:section => 'Learner Profile'},
{:name => 'Language(s) learning',:section => 'Learner Profile'},
{:name => 'Simbio Language selected',:section => 'Learner Profile'},
{:name => 'High water mark',:section => 'Learner Profile'},
{:name => 'Studio sessions attended',:section => 'Learner Profile'},
{:name => 'Studio sessions skipped',:section => 'Learner Profile'},
{:name => 'Studio sessions scheduled',:section => 'Learner Profile'},
{:name => 'Learner Evaluations',:section => 'Learner Profile'},
{:name => 'CST Discovery Information',:section => 'Learner Profile'}])
end

  def self.down
  end
end
