module REXML
  class Element
    def get_tag_value(child_tag)
      self.elements[child_tag] ? self.elements[child_tag].text : ''
    end
  end
end
