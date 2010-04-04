require 'ftools'
require 'yaml'
require 'pp'

def validatePath (path, do_exit=false)
  if !File.exists? path
    puts "[ERROR] \"#{path}\" is not valid"
    if(do_exit)
      puts "Exiting Script"
      exit
    end
  end
end

def loopThroughDirectory( dirname )
  Dir["#{dirname}/**/**"].each do |file|
    
    if(File.directory? file)    # If it's a directory
      print "Directory: ",file,"\n"
    else
      @fileTypes.each do |type|
        if(type["type"].include? File.extname(file))
          #print "File: ",File.basename(file),"\n"
          processFile(type, file)
        end
      end
    end
  end
end

def processFile(type,file)
  print "Processing: #{file}... "
  if(File.readlines(file)[0...type["license"].split("\n").length].join.chomp == type["license"].chomp)
    #puts "Line matches license: \n#{File.readlines(file)[0...type["license"].split("\n").length]}"
    puts "Skipping"
    @skipCount += 1
  else
    puts "Adding license"
    #system("open #{file}")
    @addCount += 1
  end
end

begin
  # Load Configuration
  @conf = open("./config.yml") {|f| YAML.load(f) }
  pp @conf

  @rootPath = @conf['srcPath']
  @fileTypes = @conf['fileTypes']
  
  puts "Root Path => #{@rootPath}"

  validatePath(@rootPath,true)
  
  @addCount = @skipCount = 0
  loopThroughDirectory(@rootPath) 
  
  puts "#{@addCount} Added, #{@skipCount} Skipped"
#rescue
#  print "Something blew up: ",$!, "\n"
end