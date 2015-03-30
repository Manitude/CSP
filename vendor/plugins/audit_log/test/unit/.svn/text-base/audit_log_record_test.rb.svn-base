require File.join(File.dirname(__FILE__), '..', 'test_helper')

require 'song'

class AuditLogRecordTest < ActiveSupport::TestCase
  fixtures :artists, :albums, :audit_log_records

  test 'audit_log_record is readonly after find' do
    assert artist = artists(:the_smashing_pumpkins)
    alr = artist.reload.audit_log_records.first
    assert_true alr.readonly?
  end

  test 'audit_log_record is writeable after new' do
    alr = AuditLogRecord.new(valid_audit_log_record_properties)
    assert_false alr.readonly? || false
  end

  test 'audit_log_record is readonly after create!' do
    alr = AuditLogRecord.create!(valid_audit_log_record_properties)
    assert_true alr.readonly?
  end

  test 'audit_log_record is readonly after create_log_entry!' do
    alr = AuditLogRecord.create_log_entry!(valid_audit_log_record_properties)
    assert_true alr.readonly?
  end

private

  def valid_audit_log_record_properties
    assert artist = artists(:the_smashing_pumpkins)
    {
      :loggable_type => artist.class.to_s,
      :loggable_id => artist.id,
      :attribute_name => 'name',
      :action => 'update',
      :previous_value => 'The Smashing Pumpkins',
      :new_value => 'TSP',
      :timestamp => Time.now
    }
  end
end