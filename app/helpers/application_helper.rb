require "active_support/number_helper"

module ApplicationHelper
  def line_break_filename(filename)
    if filename.present?
      filename.gsub(/_/, "_\n")
    else
      ''
    end
  end
  def human_readable_views_count(count)
    if count < 1000 
      "#{count}"
    else
      "#{(count / 1000.0).round(1)}k"
    end
  end
  def delimited_views_count(count)
    ActiveSupport::NumberHelper.number_to_delimited(count)
  end
end
