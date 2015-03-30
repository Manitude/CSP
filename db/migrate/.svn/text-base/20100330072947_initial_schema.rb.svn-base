class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :sessions, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string :session_id, :null => false
      t.text   :data
      t.timestamps
    end
    add_index :sessions, :session_id
    add_index :sessions, :updated_at

    create_table :coaches, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string   :time_zone
      t.string   :user_name
      t.string   :full_name
      t.string   :preferred_name
      t.string   :rs_email
      t.string   :personal_email
      t.string   :skype_id
      t.string   :primary_phone
      t.string   :secondary_phone
      t.string   :region
      t.date     :birth_date
      t.date     :hire_date
      t.text     :bio
      t.text     :manager_notes
      t.integer  :sessions_allowed_per_week, :default => 8,     :null => false,  :limit => 2
      t.boolean  :active,                    :default => true,  :null => false
      t.integer  :manager_id
      t.timestamps
    end
    add_index :coaches, :manager_id
    add_index :coaches, :user_name

    create_table :profile_photos, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.binary  :image_file_data, :size => 10_000_000, :null => false
      t.integer :coach_id,        :null => false
    end
    execute "ALTER TABLE `profile_photos` MODIFY `image_file_data` MEDIUMBLOB"
    add_index :profile_photos, [:coach_id], :unique => true

    create_table :coach_availability_templates, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.belongs_to  :coach,     :null => false
      t.string      :label
      t.datetime    :effective_start_date
      t.integer     :approval_status, :limit => 1,        :default => 0
      t.text        :comments
      # 0 - Waiting for approval, 1 - Approved, 2 - Approved with changes, 3 - Rejected with changes, 4 - Resubmitted for approval
      t.timestamps
    end

    create_table :coach_availabilities, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.belongs_to  :coach_availability_template, :null => false
      t.integer     :day_index,       :limit => 1,        :null => false
      t.integer     :status,          :limit => 1,        :default => 2     # 0 - Available, 1 - Scheduled, 2 - Unavailable
      t.time        :start_time,      :null => false
      t.time        :end_time,        :null => false
      t.integer     :suggested_by,    :limit => 1    # 0 - Coach, 1 - Coach Manager
      t.timestamps
    end

    create_table :coach_availability_exceptions, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.belongs_to  :coach,      :null => false
      t.integer     :status,     :limit => 1,       :default => 2     # 0 - Available, 1 - Scheduled, 2 - Unavailable
      t.date        :date,       :null => false
      t.time        :start_time, :null => false
      t.time        :end_time,   :null => false
      t.string      :reason
      t.timestamps
    end

    create_table :languages, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string  :identifier, :null => false
      t.timestamps
    end
    add_index :languages, :identifier

    ProductLanguages.standard_language_codes.each do |code|
      insert(%Q[insert into languages (identifier, created_at) values ('#{code}', NOW())])
    end

    create_table :levels, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.integer :number, :null => false
      t.timestamps
    end
    add_index :levels, :number, :unique => true
    1.upto(5) do |level|
      insert("insert into levels (number) values (#{level})")
    end

    create_table :qualifications, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.belongs_to :coach
      t.belongs_to :language
      t.belongs_to :max_level
      t.timestamps
    end
    add_index :qualifications, :coach_id
    add_index :qualifications, :language_id

    create_table :trigger_events, :force => true, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.string :name
      t.text :description
    end
    add_index :trigger_events, :name
    insert_str = "insert into trigger_events (name, description) values"
    insert("#{insert_str} ('PROCESS_NEW_TEMPLATE', 'System processes a new template for review by a Coach Manager.')")
    insert("#{insert_str} ('APPROVE_TEMPLATE', 'Coach Manager approves a new template.')")
    insert("#{insert_str} ('REJECT_TEMPLATE_WITH_CHANGES', 'Coach Manager requests changes to a new template')")
    insert("#{insert_str} ('POLICY_VIOLATION', 'Coach violates studio policy by changing a schedule less than 2 weeks in advance.')")

    create_table :notifications, :force => true, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.belongs_to :trigger_event
      t.text :message
      t.string :target_type
    end
    add_index :notifications, :trigger_event_id
    insert_str = "insert into notifications (trigger_event_id, message, target_type) values"
    insert("#{insert_str} (1, 'A new template for has been submitted for review.', 'CoachAvailabilityTemplate')")
    insert("#{insert_str} (2, 'Your template beginning has been approved.', 'CoachAvailabilityTemplate')")
    insert("#{insert_str} (3, 'Changes have been requested for your template beginning ', 'CoachAvailabilityTemplate')")
    insert("#{insert_str} (4, 'has violated Studio policy by changing the template less than 2 weeks in advance.', 'CoachAvailabilityTemplate')")

    create_table :notification_recipients, :force => true, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.belongs_to :notification
      t.string :name
      t.string :rel_recipient_obj
    end
    add_index :notification_recipients, :notification_id
    insert_str = "insert into notification_recipients (notification_id, name, rel_recipient_obj) values"
    insert("#{insert_str} (1, 'Coach Manager', 'coach.manager')")
    insert("#{insert_str} (2, 'Coach', 'coach')")
    insert("#{insert_str} (3, 'Coach', 'coach')")
    insert("#{insert_str} (4, 'Coach Manager', 'coach.manager')")

    create_table :notification_message_dynamics, :force => true, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.belongs_to :notification
      t.integer :msg_index
      t.string :name
      t.string :rel_obj_type
      t.string :rel_obj_attr
    end
    add_index :notification_message_dynamics, :notification_id
    insert_str = "insert into notification_message_dynamics (notification_id, msg_index, name, rel_obj_type, rel_obj_attr) values"
    insert("#{insert_str} (1, 15, 'Template Name', NULL, 'label')")
    insert("#{insert_str} (1, 19, 'Coach Name', 'coach', 'name')")
    insert("#{insert_str} (2, 14, 'Template Name', NULL, 'label')")
    insert("#{insert_str} (2, 24, 'date', NULL, 'effective_start_date')")
    insert("#{insert_str} (3, 46, 'Template Name', NULL, 'label')")
    insert("#{insert_str} (3, 56, 'date', NULL, 'effective_start_date')")
    insert("#{insert_str} (4, 0, 'Coach Name', 'coach', 'name')")
    insert("#{insert_str} (4, 52, 'Template Name', NULL, 'label')")

    create_table :system_notifications, :force => true, :options => "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
      t.belongs_to :notification
      t.belongs_to :recipient, :polymorphic => true
      t.integer :target_id
      t.integer :status, :limit => 1, :default => 0 # 0 => New, 1 => Read and more
      t.timestamps
    end
    add_index :system_notifications, [ :recipient_id, :recipient_type ]
  end

  def self.down
    drop_table :sessions
    drop_table :coaches
    drop_table :profile_photos
    drop_table :coach_availability_templates
    drop_table :coach_availabilities
    drop_table :coach_availability_exceptions
    drop_table :languages
    drop_table :levels
    drop_table :qualifications
    drop_table :trigger_events
    drop_table :notifications
    drop_table :notification_recipients
    drop_table :notification_message_dynamics
    drop_table :system_notifications
  end
end
