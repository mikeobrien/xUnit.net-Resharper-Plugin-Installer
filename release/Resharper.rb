require "Common"
require "tmpdir"

module Resharper

	VersionToken = "$VERSION$"
	ResharperDownloadUrl = "http://www.jetbrains.com/resharper/download/"
	ResharperMsiBinfolder = "/PFiles/JetBrains/ReSharper/v#{VersionToken}/Bin/"

	def Resharper.GetLatestResharperBits(path, libPath)
		
		downloadPage = Common.DownloadPage(ResharperDownloadUrl)
		downloadUrl = /href\s*=\s*['"](?<url>[^'\+"]*ResharperSetup\.\d*\.\d*\.\d*\.\d*\.msi)/i.match(downloadPage)["url"]
		version = /\.(?<version>\d*\.\d*\.\d*\.\d*)\./.match(downloadUrl)["version"]
		majorVersion = Common.GetMajorVersion(version)
		installerPath = "#{path}ReSharperSetup.#{version}.msi"
		extractPath = "#{Dir.tmpdir()}/Resharper/#{version}/Files"
		
		if !File.exists?(installerPath) then
			Common.DownloadFile(downloadUrl, installerPath)
		end
		
		Common.CleanPath(extractPath)
		path = Common.ExtractMsi(File.expand_path(installerPath), File.expand_path(extractPath))

		Common.CleanPath(libPath)
		Common.CopyFiles("#{extractPath}#{ResharperMsiBinfolder.gsub(VersionToken, majorVersion)}*.dll", libPath)

		Common.DeleteDirectory(extractPath)
		
		return version
	end
	
end