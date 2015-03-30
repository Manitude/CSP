module FilterEmail

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def filter_rs_emails(emails)
      emails.delete_if {|email| rs_email?(email) || change_this_email?(email)}
    end

    def rs_email?(email)
      email =~ /rosettastone\.com|trstone\.com/
    end

    def change_this_email?(email)
      email =~ /changethis@example\.com/
    end

    def filter_change_this_email(email)
      (change_this_email?(email) || rs_email?(email)) ? nil : email
    end
  end
end
