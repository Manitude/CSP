class LionMailer < ActionMailer::Base

  def general_email(recipients, from, subject, paragraphs)
    @recipients, @from, @subject, @body[:paragraphs] = [recipients, from, subject, paragraphs]
  end

end