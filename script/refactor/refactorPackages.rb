require 'ftools'
require 'yaml'
require 'pp'

def moveFile (source, dest)
  cmd = @moveCommand.gsub("$source", source)
  cmd = cmd.gsub("$dest", dest)
  puts cmd
  system(cmd)
end

def validatePath (path, do_exit=false)
  if !File.exists? path
    puts "[ERROR] \"#{path}\" is not valid"
    if(do_exit)
      puts "Exiting Script"
      exit
    end
  end
end

def parsePackage(file)
  str = file
  str[@rootPath+"/"] = ""
  return str
end

def parseOutput(file)
  str = file
  str[@outPath+"/"] = ""
  return str
end

def createPackage (dir)
  arr = dir.split("/")
  arr.each {|p| downcaseFirstLetter(p)}
  @newPackage + "." + arr.join(".")
end

def packageToPath (package)
  package.split(".").join("/")
end

def makeDirFromPackage (package)
  dir = @outPath+"/"+packageToPath(package)
  create_if_missing dir
  addToRepo dir
end

def addToRepo dir
  arr = parseOutput(dir).split("/")
  arr.each_index do |i|
      newDir = @outPath + "/" + arr[0..i].join("/")
      system("svn add #{newDir}")
  end
end

def create_if_missing dirs
  puts "Creating #{dirs}"
  File.makedirs dirs unless File.directory?(dirs)
end

def downcaseFirstLetter(str)
  @exceptions.each do |e| 
    if(str == e['source'])
      return e['dest']
    end
  end
  
  if(str.length > 0)
    str[0]=str[0..0].downcase
  end
  
  return str
end

def loopThroughDirectory( dirname )
  Dir["#{dirname}/**/**"].each do | thisfile |
    
    if(File.directory? thisfile)    # If it's a directory
      parsedDir = parsePackage(thisfile)
      newPackage = createPackage(parsedDir)
      print "Directory: ",parsedDir," => ",newPackage,"\n"
      makeDirFromPackage(newPackage)
    else
      parsedDir = parsePackage(File.dirname(thisfile))
      dest = @outPath + "/" + packageToPath(createPackage(parsedDir)) + "/" + File.basename(thisfile)
      print "File: ",parsedDir+"/"+File.basename(thisfile)," => ",dest,"\n"
      moveFile(thisfile,dest)
    end
  end
end

begin
  # Load Configuration
  @conf = open("./config.yml") {|f| YAML.load(f) }
  #pp @conf

  @rootPath = @conf['srcPath']
  @outPath = @conf['outPath']
  @newPackage = @conf['newPackage']
  @moveCommand = @conf['moveCommand']
  @exceptions = @conf['exceptions']
  
  puts "Root Path => #{@rootPath}"

  validatePath(@rootPath,true)
  
  loopThroughDirectory(@rootPath)
  
  system("svn delete #{@rootPath}")
  
#rescue
#  print "Something blew up: ",$!, "\n"
end