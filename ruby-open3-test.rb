require 'open3'
require 'docker-check.rb'
class Docker_cmd
  attr_accessor:command
  attr_accessor:private_registry
  attr_accessor:registry_port
  attr_accessor:resources
  attr_accessor:parameters
	def initialize ()
          @docker = "docker"
          @command = "version"
          @private_registry = nil
          @parameters = ""
          @registry_port = 5000
          @resources = Array.new
          @service = Docker_status.new
          @service.ensure_start
	end

	def fill_resources(output)
  		line_number = 1
  		output.readlines.each do |line|
			#puts "lines #{line_number} : #{line}"
	   		array = line.split("  ")
	   		type_size = array.length
	   		single_res = Array.new
	   		type_size.times do |i|
	     		if array[i].length >1 then
			 		single_res.push(array[i].chomp)
		 		end
 	   		end
	   		self.resources.push(single_res)
			line_number+=1
  		end	
	end

        def output_resources()
          cmd.resources.each do |array|
            array.each do |str|
              print(str,"\t\t")	
            end
            puts 
          end        
        end

        def execute()
          puts "Execute:#{@command} Parameter:#{@parameters}"
          command = "docker "+@command +" "+@parameters
          puts command
          Open3.popen3(command) do |i,o,e,t|
            error = e.read.chomp
            if(@command=="images"||@command=="ps") then 
             if(error.empty?) then
               self.fill_resources(o)
               puts self.resources
             else
               puts "Output:#{o.read.chomp}"
               puts "Error:#{error}"
             end           
            else
              if(error.empty?) then
                puts "Output:#{o.read.chomp}"
              else
                puts "Output:#{o.read.chomp}"
                puts "Error:#{error}"
                puts "Terminal:#{t}"
              end           
             
            end
          end
        end
end


cmd = Docker_cmd.new
puts "\n Start test!"
cmd.command = "run"
cmd.parameters = "-itd 10.1.11.194:5000/mysql  /bin/bash"
cmd.execute
puts      cmd.resources
