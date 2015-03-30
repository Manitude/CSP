# custom helper methods to ease coach views,
# that are mostly non functional
module CoachViewHelperMethods

  def display_name
    full_name || user_name
  end
  alias_method :name, :display_name

  # mostly to return the first name
  def short_name
    display_name.split.first
  end

  def active_label
    self.active? ? 'Yes' : 'No'
  end

  def has_qualifications?
    self.qualifications.any?
  end

  def language_qualification_label
    #has_qualifications? ? self.languages.collect(&:display_name).join(' ; ') : '-'
    has_qualifications? ? self.qualifications.collect{|q| (q.language_label + (q.dialect ? " - " + q.dialect.name : "")) if q.language_id != Language["TMM-MCH-L"].id }.compact.join(' ; ') : '-'
  end

  def level_qualification_label
    has_qualifications? ? self.qualifications.collect(&:levels_label).join(' ; ') : '-'
  end

  def units_qualification_label
    has_qualifications? ? self.qualifications.collect(&:units_label).join(' ; ') : '-'
  end

  def birth_date_label
    self.birth_date ? self.birth_date.strftime("%B %d") : '-'
  end

  def hire_date_label
    self.hire_date ? self.hire_date.to_s(:long) : '-'
  end

  def manager_display_name
    self.manager ? self.manager.display_name : '-'
  end

  def notifications_count_label
    notif_count = self.system_notifications.unread.size
    notif_count.zero? ? '' : " (<em id='unread-notif-count'>#{notif_count}</em>)"
  end
end
