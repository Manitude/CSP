class ReportMailer < ActionMailer::Base
  
  default :from => "noreply@rosettastone.com"
  
  def internal_report(start_date, end_date, report)
    attachments['rights_extension_report.csv'] = report.read
    mail(
      :to           => ["rblack@rosettastone.com"],
      :subject      => "Rights Extension Report for the period: #{start_date.to_date} TO #{end_date.to_date}",
      :content_type => "multipart/alternative",
      :body         => "PFA the report containing the details of the extension added through Tier1."
      )
  end

  def sync_report(time, file_location)
    attachments['Coach conflict report.txt'] = File.read(file_location)
    mail(
      :to           => ["rmonte@rosettastone.com","mwillis@rosettastone.com"],
      :subject      => "CCS - eSchool report genrated #{time}",
      :content_type => "text/plain",
      :body         => "PFA the nightly coach syncronization report between eSchool and CCS.\nFor windows users: Please use Wordpad to open the file."
      )
  end

end
