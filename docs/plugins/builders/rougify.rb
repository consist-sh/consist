# frozen_string_literal: true

class Builders::Rougify < SiteBuilder
  def build
    hook :site, :pre_render do
      theme_name = site.config.dig(:rougify, :theme) || "base16"
      theme = Rouge::Theme.find(theme_name)
      if theme
        File.open(site.in_root_dir("frontend", "styles", "syntax-highlighting.css"), "w") do |f|
          css = theme.render(scope: ".highlight")
          f.write(css)
        end
      else
        Bridgetown.logger.warn("Rouge theme not found for #{theme_name}")
      end
    end
  end
end
