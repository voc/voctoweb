module ApplicationHelper

  def line_break_filename(filename)
    filename.gsub(/_/, "_\n")
  end

end
