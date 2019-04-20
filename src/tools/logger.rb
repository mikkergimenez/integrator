class Logger
  def self.warning message
    puts message
  end

  def self.check ok, message
    if ok
      ok_message = "[   ok   ]".green
    else
      ok_message = "[  warn  ]".red
    end
    printf "> %-80s %s\n", message, ok_message
  end

  def self.section message
    puts "==> #{message}"
  end

  def self.job_end message
    puts message
    puts "------------------------------------------------------"
    puts ""
  end

  def self.job_start message
    puts ""
    puts "======================================================"
    puts message
    puts "------------------------------------------------------"
  end

end
