require 'open3'
require 'docker_console_log'
=begin
The operation of docker

Can use it to 'pull' 'tag'  'run' 'stop' 'remove_container' 'remove_images' 'commit' 'images' 'save'
 'search' 'kill' 'build'
=end
class Operation
  Pre_cmd = "docker "
  @logger  = Console_logger.getLogger
  class << self
    def pull(private_registry,images_name)
      command = Pre_cmd + "pull "
      if(private_registry != nil && !private_registry.empty?)
        command.concat(private_registry)
      end
      if(images_name !=nil && !images_name.empty?)
        command.concat(images_name)
      else
        return "error#command:pull#reason:1:invaild images name"
      end
      Open3.popen3(command) do |i,o,e,t|#input output error thread
        out = o.read.chomp
        error = e.read.chomp
        if(error.empty?)
          out.each_line do |line|
            @logger.debug("docker_operation_pull"){line.chomp}
          end
          return out
        else
          @logger.debug("docker_operation_pull"){error}
          return  "error#command:pull#reason:0:#{error}"
        end
      end
    end

    def run(option,container_name,cmd)#must run with -d,default is "-itd" cmd default is /bin/bash
      command = Pre_cmd + "run "
      if(option ==nil || option.empty?)
        option = "-itd"
      end
      if(!option.include? "d")
        return "error#command:run#reason:1:must run container with option -d!"
      end
      command.concat(option)
      command.concat(32) #add space
      if(container_name == nil || container_name.empty?)
        return "error#command:run#reason:1:invalid container name"
      end
      command.concat(container_name)
      command.concat(32)
      if(cmd == nil || cmd.empty?)
        cmd = "/bin/bash"
      end
      command.concat(cmd)
      Open3.popen3(command) do |i,o,e,t|
        output = o.read.chomp
        error = e.read.chomp
        if(error.empty?)
          return output
        else
          return "error#command:run#reason:0:#{error}"
        end
      end
    end

    #==stop
    #used to stop container
    #if you want stop all container .you can use Operation.stop with no parameter 
    #else you can use Operation.stop("a","b","c") to stop the container named a,b,c(also id is a,b,c) 
    #if you want to specify the longest waiting time , you must use Operation.stop("-t",max_time,"a","b","c") to set the waiting time before docker kill it.
    #you can use a array to replace the containers name like "array = ["a","b","c"];Operation.stop(array)" 
    def stop (*names)
      type = nil
      option = nil
      ids =  ""
      command = Pre_cmd + "stop "
      if(names == nil || names.length==0) then type = "all" 
      else
        if(names[0]=="-t") then
          if(names[1].is_a?(Integer)) then
            option = "-t "+names[1].to_s+" "
          else
            option = "-t"+names[1]+" "
          end
          for i in 2..names.length-1
            ids.concat(names[i]).concat(32)
          end
        else
          for i in 0..names.length-1
            ids.concat(names[i]).concat(32)
          end
        end
      end
      if(type == "all")
        command.concat("$(docker ps -aq)")
      else
        command.concat(ids)
      end
      Open3.popen3(command) do |i,o,e,t|
        output = o.read.chomp
        error = e.read.chomp
        if(error.empty?)
          return output
        else
          return "error#command:stop#reason:0:#{error}"
        end
      end
    end

    # if you want to remove a container ,you must ensure that the containers you want to removed is stopped or use option "-f" to force remove it
    #if parameter 'names' is null , it will remove all containers(exclude running container),you can also add option '-f' remove all of them.
    def remove_c(options,*names)
      command = Pre_cmd + " "+ " rm "
      containers = ""
      if names !=nil && names.length!=0 then
        names.each do |container|
          containers.concat(container)
          containers.concat(32)
        end
      else 
        containers = " $(docker ps -aq) "
      end
      command.concat(options)
      command.concat(32)
      command.concat(containers)
      #puts command        
      Open3.popen3(command) do |i,o,e,t|
        output = o.read.chomp
        error = e.read.chomp
        if(error.empty?)
          return output
        else
          return "error#command:remove#reason:0:#{error}#output:#{output}"
        end
      end
    end

    def reomve_i(options,*names)
      command = Pre_cmd + " rmi "
      images = ""
      if names!=nil && names.length >0 then
        names.each do |name|
          images.concat(name)
          images.concat(32)
        end
      else
        return "error#command:reomve_i#type:1:invalid names"
      end
      command.concat(images)
      Open3.popen3(command) do |i,o,e,t|
        output = o.read.chomp
        error = e.read/chomp
        if(error.empty?)
          return output
        else
          return "error#command:reomve_i#reason:0:#{error}#output:#{output}"
        end
      end
    end

    def tag
    end

    def commit
    end

    def images
    end

    def save
    end

    def search
    end

    def kill
    end

    def build(options,path)
      command = Pre_cmd + "build "
      if(options==nil || options.empty?)
        return "error#command:build#reason:1:invalid options"
      end

      if(path == nil || path.empty?)
        return "error#command:build#reason:1:invalid path"
      end
      
      command.concat(options)
      command.concat(32)
      command.concat(path)
      Open3.popen3(command) do |i,o,e,t|
        output = o.read.chomp
        error = e.read.chomp
        if(error.empty?)
          
          return output
        else
          return "error#command:build#reason:0:#{error}"
        end       
      end
    end
  end
end

puts Operation.pull("10.1.11.194:5000/","ubuntu")
#Operation.run(option,container_name,cmd)
#Operation.stop((option(-t),max_waiting_time),(names))
#puts Operation.run("-itd","ubuntu","/bin/bash")
#puts Operation.stop("-t",1,"a6b20f3c2bfb")
#puts Operation.remove_c("-f");
#puts Operation.build("-t centos/test:wei","/opt/dockfile")
