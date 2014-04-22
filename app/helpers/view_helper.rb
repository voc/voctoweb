module ViewHelper


  def conference_folder(label: 'Path', path: '/')
    if File.readable? path
      "#{label} (#{path})"
    else
      "#{label} (missing: #{path})"
    end
  end

  def job_object(job)
    begin
      YAML.load(job.handler).object.class.to_s
    rescue
      ""
    end
  end

  def job_method(job)
    begin
      YAML.load(job.handler).method_name.to_s
    rescue
      ""
    end
  end

end
