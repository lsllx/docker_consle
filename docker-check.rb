require 'open3'

class Docker_status

  def initialize()
    @os_type =  RUBY_PLATFORM.split("-")[1]
    @os_bit = RUBY_PLATFORM.split("-")[0]
    @docker_status =  get_docker_status
    #    puts @os_type
    #    puts @os_bit
    #   puts @docker_status
    # stop_docker
    #start_docker
    # @docker_status = get_docker_status
    #puts @docker_status
  end
  
  def get_docker_status()
    Open3.popen3("service","docker","status")  do |i,o,e,t|
      return  (o.read.chomp.include? "running") ? "running" : "stopped"
    end
  end

  def start_docker()
    Open3.popen3("service","docker","start")  do |i,o,e,t|
      if e.read==nil || e.read.empty? then
        puts "#{o.read.chomp}"
        @docker_status = "running"
      else
        puts "Starting error:#{e.read.chomp}"
      end
    end
  end

  private:get_docker_status  
  def ensure_start
    puts "Now the docker service is #{@docker_status}."    
    if @docker_status != "running"
      self.start_docker()
    end
  end
  def stop_docker()
    is_running = false;
    Open3.popen3("service","docker","status") do |i,o,e,t|
      is_running = o.read.chomp.include? "running"
    end
      if is_running then
        running_container_num = 0
        Open3.popen3("docker","ps") do |i,o,e,t|
          running_container_num  = o.readlines.length
        end
        if(running_container_num>1) then
          puts  "Docker has running containers,please stop its before you stop docker. "
          return
        else
          puts "running_container_num:#{running_container_num-1}"
        end     
      end
    Open3.popen3("service","docker","stop")  do |i,o,e,t|
      puts o.read.chomp
      @docker_status =  "stopped"
    end        
  end
end
