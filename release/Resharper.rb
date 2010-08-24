require "Common"
require "tmpdir"

module Resharper

	VersionToken = "$VERSION$"
	ResharperDownloadUrl = "http://www.jetbrains.com/resharper/download/"
	ResharperMsiBinfolder = "/PFiles/JetBrains/ReSharper/v#{VersionToken}/Bin/"
	ResharperPath = "Resharper/"

	def Resharper.GetLatestResharperBits(path, libPath)
		resharperPath = path + ResharperPath
		Common.EnsurePath(resharperPath)
		
		downloadPage = Common.DownloadPage(ResharperDownloadUrl)
		downloadUrl = /href\s*=\s*['"](?<url>[^'\+"]*ResharperSetup\.\d*\.\d*\.\d*\.\d*\.msi)/i.match(downloadPage)["url"]
		version = /\.(?<version>\d*\.\d*\.\d*\.\d*)\./.match(downloadUrl)["version"]
		majorVersion = Common.GetMajorVersion(version)
		versionPath = "#{resharperPath}#{version}/" 
		versionInstallerPath = "#{versionPath}ReSharperSetup.#{version}.msi"
		extractPath = "#{Dir.tmpdir()}/Resharper/#{version}/Files"
		
		if !File.exists?(versionInstallerPath) then
			Common.DownloadFile(downloadUrl, versionInstallerPath)
		end
		
		Common.CleanPath(extractPath)
		path = Common.ExtractMsi(File.expand_path(versionInstallerPath), File.expand_path(extractPath))

		Common.CleanPath(libPath)
		Dir.glob("#{extractPath}#{ResharperMsiBinfolder.gsub(VersionToken, majorVersion)}*.dll") do |name| 
			FileUtils.cp(name, libPath)
		end
		
		Common.DeleteDirectory(extractPath)
		
		return version
	end

end