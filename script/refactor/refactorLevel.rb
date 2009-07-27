require 'ftools'

def checkArgs()
  if(ARGV[0])
    validatePath(ARGV[0], true)
    File.copy(ARGV[0], "#{ARGV[0]}.old")
    @input = "#{ARGV[0]}.old"
    @output = ARGV[0]
  else
    puts "Usage: ruby refactorLevel.rb input.pbelevel"
    exit
  end
end

def validatePath (path, do_exit=false)
  if !File.exists? path
    puts "[ERROR] \"#{path}\" is not a valid file"
    if(do_exit)
      #puts "Exiting Script"
      exit
    end
  end
end

def readFile()
  File.open(@input, "r") do |infile|
    while (line = infile.gets)
      writeLine(line)
    end
  end
end

def writeLine(line)
  line = fixPackages(line)
  line = fixTags(line)
  writeFile(line, 'a')
  #puts "#{line}"
end

def writeFile(line, writeMode)
  File.open(@output, writeMode) {|f| f.write(line) }
end

def fixTags(line)
  rx = /\<\/?([A-Z])/
  
  while((line =~ rx) != nil)
    index = line =~ rx
    if(line[index+1..index+1] == "/")
      downcaseLetter(line, index+2)
    else
      downcaseLetter(line, index+1)
    end
  end
  
  return line
end

def fixPackages(line)
  
  rx = /PBLabs\.[^"]+/
  
  while((line =~ rx) != nil)
    line = $` + convertPackage($&).to_s + $'
  end
  
  return line
end

def convertPackage(oldPackage)
  print oldPackage, " -> "
  oldPackage.slice!("PBLabs.")
  arr = oldPackage.split(".")
  arr[0..arr.length-2].each {|p| downcaseLetter(p,0)}
  newPackage = @newPackage + "." + arr.join(".")
  puts newPackage
  return newPackage
end

def downcaseLetter(str, index)
  if(str.length > 0)
    str[index]=str[index..index].downcase
  end
  
  return str
end

begin
  @input = ''
  @output = ''
  @newPackage = 'com.pblabs'

  checkArgs()
  writeFile('','w') # Clear Output file
  readFile()

#rescue
  #print "Something blew up: ",$!, "\n"
end