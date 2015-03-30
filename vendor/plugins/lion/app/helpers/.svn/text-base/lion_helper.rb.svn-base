module LionHelper

  def render_styles
    %Q[
      <style type='text/css'>
        #{stylesheet_string}
      </style>
    ]
  end

  def short_filename(file)
    file.sub("#{Rails.root.join('db','translations')}/", "")
  end

  def id_for_file(file)
    "file_#{short_filename(file).sub("/","_").sub('.csv','')}"
  end

  def lion_icon_base_64
    "data:image/png;base64,#{Base64.encode64(File.read(File.join(plugin_root_dir, 'images', 'lion.png')))}"
  end

  private

  def stylesheet_string
    File.read(stylesheet_path)
  end

  def stylesheet_path
    File.join(plugin_root_dir , 'stylesheets', 'lion.css')
  end

  def plugin_root_dir
    File.dirname(__FILE__) + "/../../"
  end

end
