class RoleTask < ActiveRecord::Migration
  def self.up
    create_table :roles, :force => true do |t|
      t.column :name, :string, :null=>false
    end

    Role.create(:name => 'Admin');
    Role.create(:name => 'CoachManager');
    Role.create(:name => 'Coach');
    Role.create(:name => 'All');

    create_table :tasks, :force => true do |t|
      t.column :name, :string, :null=>false
      t.column :section,:string
    end

    create_table :roles_tasks do |t|
      t.column :role_id, :integer, :null=>false
      t.column :task_id, :integer, :null=>false
      t.column :read, :boolean
      t.column :write, :boolean
    end

Task.create([{:name => 'Full Name',:section => 'Coach Profile'},
{:name => 'Preferred Name',:section => 'Coach Profile'},
{:name => 'Rosetta Stone Email',:section => 'Coach Profile'},
{:name => 'Personal Email',:section => 'Coach Profile'},
{:name => 'Skype ID',:section => 'Coach Profile'},
{:name => 'Birth Date (only day and month)',:section => 'Coach Profile'},
{:name => 'Hire Date',:section => 'Coach Profile'},
{:name => 'Time Zone',:section => 'Coach Profile'},
{:name => 'Region (Seattle, DC, NYC, Remote, etc.)',:section => 'Coach Profile'},
{:name => 'Coach Manager',:section => 'Coach Profile'},
{:name => 'Primary phone number (Add “Receive text message reminders/requests?” field)',:section => 'Coach Profile'},
{:name => 'Secondary phone number (Add “Receive text message reminders/requests” field)',:section => 'Coach Profile'},
{:name => 'Photo',:section => 'Coach Profile'},
{:name => 'Bio',:section => 'Coach Profile'},
{:name => 'Coach Manager Notes',:section => 'Coach Profile'},
{:name => 'Weekly Templates',:section => 'Coach Profile'},
{:name => 'Schedule of Sessions',:section => 'Studio (Coach specific)'},
{:name => 'Total # of Studio sessions allowed per week  (current)',:section => 'Studio (Coach specific)'},
{:name => 'Total # of availability modifications requested (YTD)',:section => 'Studio (Coach specific)'},
{:name => 'Total # of availability modifications requested within 2 weeks of live events (YTD)',:section => 'Studio (Coach specific)'},
{:name => 'Total # of Studio session cancellations (YTD)',:section => 'Studio (Coach specific)'},
{:name => 'Total # of Sessions where the Coach didn’t show up',:section => 'Studio (Coach specific)'},
{:name => 'Post session learner feedback',:section => 'Studio (Coach specific)'},
{:name => 'Post session Coach feedback (learner evaluations)',:section => 'Studio (Coach specific)'},
{:name => 'Games that the Coach has played (Counts, Game Names, Timestamps)',:section => 'World Activity (for all associated languages tied to account)'},
{:name => 'Total time spent in each Game',:section => 'World Activity (for all associated languages tied to account)'},
{:name => 'Total time spent in World (total time all games)',:section => 'World Activity (for all associated languages tied to account)'},
{:name => 'Total time spent in Language(s) (Drill down capability to view dates/times of activity)',:section => 'Course Activity (for all associated languages tied to account) '},
{:name => 'High Water Mark',:section => 'Course Activity (for all associated languages tied to account) '},
{:name => 'Most Recent Path Completed',:section => 'Course Activity (for all associated languages tied to account) '},
{:name => 'Last Access Timestamp',:section => 'Course Activity (for all associated languages tied to account) '},
{:name => 'Product rights',:section => 'Licenses (for all associated languages tied to account)  '},
{:name => 'License expiration date',:section => 'Licenses (for all associated languages tied to account)  '},
{:name => 'Ability to extend license subscription duration',:section => 'Licenses (for all associated languages tied to account)  '},
{:name => 'Ability to edit/add product rights',:section => 'Licenses (for all associated languages tied to account)  '},
{:name => 'Ability to reset password',:section => 'Licenses (for all associated languages tied to account)  '},
{:name => 'Coach Active? (Yes/No)',:section => 'Configurable Settings'},
{:name => 'Language qualifications',:section => 'Configurable Settings'},
{:name => 'Level qualifications – If the Coach changes this, the CM must be notified and approve this change before implemented. ',:section => 'Configurable Settings'},
{:name => 'Template Time Constraints (Adobe, Support hours, etc)',:section => 'Configurable Settings'},
{:name => 'Wildcard unit capping settings (by language, by unit, as a percentage of sessions)',:section => 'Configurable Settings'},
{:name => 'Technical Feedback form configurations',:section => 'Configurable Settings'},
{:name => 'Learner Evaluations form configurations ',:section => 'Configurable Settings'},
{:name => 'Percentage of time required for automatic attendance ',:section => 'Configurable Settings'},
{:name => 'Minutes before start time to show launch link',:section => 'Configurable Settings'},
{:name => 'Minutes after start time to show launch link',:section => 'Configurable Settings'},
{:name => 'Minutes before start time to show Coach launch link',:section => 'Configurable Settings'},
{:name => 'Minutes after start time to show Coach launch link',:section => 'Configurable Settings'},
{:name => 'Seconds before end to show countdown timer',:section => 'Configurable Settings'},
{:name => 'Cancellation grace period ',:section => 'Configurable Settings'},
{:name => 'Instruction time for hour long sessions ',:section => 'Configurable Settings'},
{:name => 'Minutes after session to kick learners out of the class ',:section => 'Configurable Settings'},
{:name => 'Player video quality (1 to 100)',:section => 'Configurable Settings'},
{:name => 'Audit Logs ',:section => 'Configurable Settings'},
{:name => 'User Roles/Permissions ',:section => 'Configurable Settings'}])
end

  def self.down
    drop_table :roles
    drop_table :roles_tasks
    drop_table :tasks
  end
end
