module ScreenshotHelper

  def self.included(parent_class)
    # taken_screenshots stores which screenshots have already been taken on this test run so we don't do extra work
    parent_class.send(:cattr_accessor, :taken_screenshots)
    parent_class.send(:cattr_accessor, :all_non_screenshotable_keys_as_strings)
    parent_class.send(:cattr_accessor, :translations_hash)
    parent_class.send(:cattr_accessor, :taken_translation_screenshots)
    parent_class.send(:cattr_accessor, :input_keys)
    parent_class.send(:cattr_accessor, :non_shot_keys)
    parent_class.send(:cattr_accessor, :keys_with_periods_to_shoot)
  end

  def take_screenshot(relative_file_path)
    return unless taking_screenshots?
    klass.taken_screenshots ||= []
    if klass.taken_screenshots.include?(relative_file_path)
      logger.debug("skipping screenshot #{relative_file_path}; already have it on this run")
      return
    else
      klass.taken_screenshots << relative_file_path
    end
    full_file_path = File.join(Lion.screenshots_base_file_path, "#{relative_file_path}.png")
    $stderr.puts(ENV['suppress_actual_shot'] == 'true' ? "would have taken screenshot #{full_file_path}" : "taking screenshot #{full_file_path}")

    orig_height = get_current_window_height
    full_height = get_screenshot_window_height
    change_window_height_to(full_height)
    orig_width = get_current_window_width
    change_window_width_to(1024)
    capture_entire_page_screenshot(full_file_path) if ENV['suppress_actual_shot'] != 'true'
  ensure
    change_window_height_to(orig_height) if orig_height
    change_window_width_to(orig_width) if orig_width
  end
  
  def take_translation_screenshots(dom_id = nil, key_to_shoot = nil, iframe_name = nil)
    return if !taking_translation_screenshots?
    return if ENV['skip_screenshots'] == 'true'
    key_to_shoot = ENV['only_shoot_this_key'] if !ENV['only_shoot_this_key'].blank?
    dom_id = key_to_shoot if !ENV['only_shoot_this_key'].blank?
    single_key_with_periods_to_shoot = key_to_shoot.un_substitute_characters if key_to_shoot
    ENV['take_screenshots'] = 'true'
    
    # TODO: maybe it isn't necessary to cache this.. probably not a huge performance issue
    klass.taken_translation_screenshots ||= Lion::Screenshots.screenshots_taken(I18n.locale)
    klass.translations_hash ||= I18n.backend.send(:translations)
    # for filtering out strings (initializing these before the locales loop)
    klass.all_non_screenshotable_keys_as_strings ||= Lion::Screenshots.all_non_screenshotable_keys_as_strings
    klass.input_keys ||= ENV['source'] == 'all' ? Lion::CSV.all_used_csv_keys : Lion::CSV.input_csv_keys
    iso = ENV['translation_screenshot_locale'] || Lion.default_locale
    relative_file_dir = File.join('translations', iso)
    I18n.locale = iso

    keys_to_shoot(single_key_with_periods_to_shoot, dom_id).each do |key_with_periods|
      # if single_key_with_periods_to_shoot is specified, it is probably because the span_id version of it doesn't correspond with the dom_id given
      # but if single_key_with_periods_to_shoot isn't specified, then one key converted to span_id should match the dom_id
      # However, sometimes single_key_with_periods_to_shoot IS compatible with the dom_id (because we wanted the screenshot to be taken super fast)
      # But this doesn't ruin that scenario because keys_to_shoot were set to a single value array of that text
      next if single_key_with_periods_to_shoot.blank? && !dom_id.blank? && (dom_id != Lion.convert_to_span_id(key_with_periods))
      next if !Lion::Translate.translation_exists_for(iso, key_with_periods, klass.translations_hash) # don't shoot it if it hasn't been translated yet
      span_id = dom_id || Lion.convert_to_span_id(key_with_periods)
      
      
      select_element_with_javascript(iframe_name, span_id, key_with_periods)
      
      begin
        number_of_elements = window_eval(%Q|window.els.length|).to_i
      rescue
        $stderr.puts "UH OH!!! window got blown away3 for #{key_with_periods}"
        next # FIXME: for some reason window is blown away occasionally, even though it gets into this block!!
      end
      
      $stderr.puts "UH OH!!! we expected #{key_with_periods} to be here, but it was not" if number_of_elements == 0 && dom_id && ENV['only_shoot_this_key'].blank?
      (0..(number_of_elements - 1)).each do |element_num|
        window_eval(%Q|elementWithPhrase = window.els[#{element_num}]|)
        if window_eval(%Q|elementWithPhrase|) != 'null' && is_visible?(dom_id, single_key_with_periods_to_shoot)
          with_background_highlighting do
            filename = Lion.using_natural_keys ? Lion.convert_to_filename(key_with_periods) : key_with_periods
            take_screenshot(File.join(relative_file_dir, filename))
            klass.taken_translation_screenshots << key_with_periods
            if ENV['suppress_actual_shot'] != 'true'
              Lion::CSV.update_output(key_with_periods, {"#{iso}_screenshot" => 'yes',
                                                        'test_name' => "#{self.class.to_s}: #{@method_name}",
                                                        'screenshotable' => 'yes'})
            end
          end
          break if !dom_id.nil?
        end
      end
    end
  end
  
  def select_element_with_javascript(iframe_name, span_id, key)
    window_eval(%Q|window.els = new Array()|)
    if window_eval('window.$$') != 'null'
      if !iframe_name.blank? && firefox?
        # FIXME: the $$ function does not get an element that you can access the style property from, so it does not work later on, however it would be nice to get multiple elements with the same id, and then only screenshot the visible one, and that is what $$ is supposed to be giving us here
        # if window_eval("window.frames['#{iframe_name}'].$$") != 'null'
        #   window_eval(%Q|window.els.push(window.frames['#{iframe_name}'].$$('##{span_id}'))|)
        # else
          window_eval(%Q|window.els.push(window.frames['#{iframe_name}'].document.getElementById('#{span_id}'))|) # TODO: get multiple elements by id without prototype
        # end
      else
        begin
          window_eval(%Q|window.els = window.$$('##{span_id}')|)
        rescue
          $stderr.puts "UH OH!!! window got blown away for '#{key}' with iframe_name: '#{iframe_name}' and span_id: '#{span_id}'"
          next # FIXME: for some reason window is blown away occasionally, even though it gets into this block!!
        end
      end
    else
      if !iframe_name.blank? && firefox?
        window_eval(%Q|window.els.push(window.frames['#{iframe_name}'].document.getElementById('#{span_id}'))|) # TODO: get multiple elements by id without prototype
      else
        begin
          window_eval(%Q|window.els.push(window.document.getElementById('#{span_id}'))|) # TODO: get multiple elements by id without prototype
        rescue
          $stderr.puts "UH OH!!! window got blown away2 for #{key}"
          next # FIXME: for some reason window is blown away occasionally, even though it gets into this block!!
        end
      end
    end
  end

  def keys_to_shoot(single_key_with_periods_to_shoot, dom_id)
    klass.keys_with_periods_to_shoot ||= []
    keys_with_periods = klass.keys_with_periods_to_shoot
    if keys_with_periods_to_shoot.empty?
      keys_with_periods = klass.input_keys # we'll strip more out later
      klass.keys_with_periods_to_shoot = keys_with_periods
    end
    
    # if we're trying to shoot only one key
    if !dom_id.blank? && !single_key_with_periods_to_shoot.blank?
      # don't iterate through all the keys_with_periods_to_shoot if we only are looking for one
      keys_with_periods = (klass.keys_with_periods_to_shoot).include?(single_key_with_periods_to_shoot) || (ENV['only_shoot_this_key'] == single_key_with_periods_to_shoot) ? [single_key_with_periods_to_shoot] : []
    end
  
    if ENV['only_shoot_this_key'] != single_key_with_periods_to_shoot
      # strip out the keys we know we don't need to shoot
      keys_with_periods -= klass.taken_translation_screenshots + klass.all_non_screenshotable_keys_as_strings
    end
    keys_with_periods
  end
  
  def with_background_highlighting(&block)
    orig_background = window_eval(%Q|elementWithPhrase.style.background|)
    window_eval(%Q|elementWithPhrase.style.background = '#d88'|)
    yield
    window_eval(%Q|elementWithPhrase.style.background = '#{orig_background}'|)
  end
  
  def is_visible?(dom_id, single_key_with_periods_to_shoot)
    if !dom_id.blank? && !single_key_with_periods_to_shoot.blank?
      return true # we are assuming that it is visible if you are calling it out explicitly... plus, visible_text_content doesn't work with button text
    else
      if window_eval('window.visible_text_content') != 'null'
        if window_eval(%Q|window.visible_text_content(window.elementWithPhrase)|) != ''
          return true
        end
      else
        return true # gonna assume this for now.  could be made better
      end
    end
    return false
  end

  def taking_screenshots?
    ENV['take_screenshots'] == 'true' && firefox? # capturing entire page only works in firefox
  end

  def taking_translation_screenshots?
    ENV['take_translation_screenshots'] == 'true' && firefox?
  end

  def taking_any_screenshots?
    taking_screenshots? || taking_translation_screenshots?
  end
  
  def click(locator)
    take_translation_screenshots if ENV['on_every_click'] == 'true'
    @selenium_driver.click(locator)
  end
  
  # overriding polonium's click_and_wait, so we can call our local click
  def click_and_wait(locator, wait_for = default_timeout)
    click locator
    assert_page_loaded(wait_for)
  end
  
  def wait_for_message_and_take_shot(string_or_key, iframe_name = nil)
    unharvested_wait_for_message_and_take_shot(string_or_key, iframe_name)
  end
  
  def unharvested_wait_for_message_and_take_shot(string_or_key, iframe_name = nil)
    return unless taking_translation_screenshots?
    span_id = Lion.using_natural_keys ? Lion.convert_to_span_id(string_or_key) : string_or_key # if not using natural keys, the key will already be the span_id
    wait_for(:message => "Expected '#{string_or_key}': to be visible, but it was not") do
      if iframe_name.blank?
        window_eval("document.getElementById('#{span_id}')") != 'null'
      elsif firefox?
        window_eval("window.frames['#{iframe_name}'].document.getElementById('#{span_id}')") != 'null'
      end
    end
    take_translation_screenshots(span_id, string_or_key, iframe_name)
  end
  
private

  # how tall do we need to be to capture the entire page?
  def get_screenshot_window_height
    if is_element_present('main')
      get_element_height('main').to_i + 175 # add a fudge factor for header & footer
    else
      1500 # fallback to a pretty tall screen
    end
  end
  
  def with_suppressed_shot_on_click(&block)
    on_every_click_original = ENV['on_every_click']
  end

end