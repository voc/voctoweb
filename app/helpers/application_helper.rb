module ApplicationHelper
  def line_break_filename(filename)
    if filename.present?
      filename.gsub(/_/, "_\n")
    else
      ''
    end
  end
end
