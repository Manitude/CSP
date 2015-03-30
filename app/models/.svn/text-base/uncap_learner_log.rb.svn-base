class UncapLearnerLog < ActiveRecord::Base
  audit_logged :audit_logger_class => CustomAuditLogger

  belongs_to :account, :foreign_key => 'support_user_id'

  validates_presence_of :reason, :case_number

  scope :between, lambda { |start_date, end_date| where('uncap_learner_logs.created_at > ? and uncap_learner_logs.created_at < ?', start_date, end_date) }

  def self.generate_grandfathering_report(file_path, grandfather_logs)

    report = File.new(file_path, 'w')

    CSV::Writer.generate(report, ',') do |row|
      row << ['Date', 'User', 'Case Number', 'Reason', 'Customer GUID']

      grandfather_logs.each do |log|
        row << [
            TimeUtils.format_time(log.created_at, '%m/%d/%y %I:%M %p'),
            log.account.full_name,
            log.case_number,
            log.reason,
            log.license_guid
        ]
      end
    end

    report.close

    true
  end

end
