require "Common"

class XunitNet
    attr_accessor :xunitPath, :assembly, :xmlResults, :htmlResults, :nunitResults
    
    def run()
        command = "#{@xunitPath}/xunit.console.exe " \
                   "\"#{@assembly}\" "
				   
		if @xmlResults != nil then
			command += "/xml \"#{@xmlResults}\" "
		end
				   
		if @htmlResults != nil then
			command += "/html \"#{@htmlResults}\" "
		end
				   
		if @nunitResults != nil then
			command += "/nunit \"#{@nunitResults}\" "
		end
		puts(command)
        sh command
    end
end

def xunitnet(*args, &block)
    body = lambda { |*args|
        xunit = XunitNet.new
        block.call(xunit)
        xunit.run
    }
    Rake::Task.define_task(*args, &body)
end