require 'logger'

class Console_logger
  
  @console_logger = nil
  def self.getLogger
    if(@consle_logger == nil)then
      if !File.exist?("/var/logs")then
        Dir.mkdir("/var/logs")
        Dir.mkdir("/var/logs/docker")
      else
        if !File.exist?("/var/logs/docker") then
          Dir.mkdir("/var/logs/docker")
        end
      end
      file = File.open("/var/logs/docker/docker_con.log",File::WRONLY | File::APPEND | File::CREAT)
      @console_logger = Logger.new(file,'weekly')
      @console_logger.level = Logger::DEBUG
      @console_logger.datetime_format = '%Y-%m-%d %H:%M:%S'
      @console_logger.formatter  = proc do |severity, datetime, progname, msg|
        "[#{severity}][#{datetime.strftime("%Y-%m-%d %H:%M:%S %z")}] [#{progname}] Msg:[#{msg}]\n"
      end
      return @console_logger
    end
  end
end
