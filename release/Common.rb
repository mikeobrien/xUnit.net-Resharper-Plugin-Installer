require "net/http"
require "fileutils"

module Common

	def Common.GetMajorVersion(version)
		versionParts = version.split(".")
		return "#{versionParts[0]}.#{versionParts[1]}"
	end

	def Common.DeleteDirectory(path)
		if Dir.exists?(path) then 
			 FileUtils.rm_rf path
		end
	end

	def Common.EnsurePath(path)
		if !Dir.exists?(path) then 
			FileUtils.mkdir_p(path)
		end
	end

	def Common.CleanPath(path)
		DeleteDirectory(path)
		EnsurePath(path)
	end

	def Common.ReadAllFileText(path)
	  data = ""
	  file = File.open(path, "r") 
	  file.each_line do |line|
		data += line
	  end
	  return data
	end

	def Common.WriteAllFileText(path, text) 
		File.open(path, 'w') do |file|  
		  file.puts text
		end 
	end

	def Common.DownloadPage(url)
		return Net::HTTP.get(URI.parse(url))
	end

	def Common.DownloadFile(url, path)
		uri = URI.parse(url)
		EnsurePath(File.dirname(path))
		Net::HTTP.start(uri.host) do |http|
			head = http.head(uri.path)
			if head.is_a?(Net::HTTPRedirection) then
				DownloadFile(head["location"], path)
			else
				file = open(path, "wb")
				begin
					http.request_get(uri.path) do |resp|
						resp.read_body do |segment|
							file.write(segment)
						end
					end
				ensure
					file.close()
				end
			end
		end
	end

	def Common.ExtractMsi(sourceMsi, targetPath)
		result = system("msiexec", "/a", sourceMsi.gsub("/", "\\"), "/qn", "TARGETDIR=#{targetPath.gsub("/", "\\")}")
	end

	def Common.DownloadHgSource(url, path)
		result = system("hg", "clone", "-r", "tip", url, path)
	end
	
	MsBuildPath = "C:/Windows/Microsoft.NET/Framework/v4.0.30319/MSBuild.exe"

	def Common.MsBuild(path, config)
		result = system(MsBuildPath, path, "/property:Configuration=#{config}")
	end

end