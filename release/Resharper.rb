require "Common"

module Resharper

	VersionToken = "$VERSION$"
	ResharperDownloadUrl = "http://www.jetbrains.com/resharper/download/"
	ResharperMsiBinfolder = "/PFiles/JetBrains/ReSharper/v#{VersionToken}/Bin/"

	def Resharper.GetLatestResharperBits(cachePath, libPath)
		Common.EnsurePath(cachePath)
		
		downloadPage = Common.DownloadPage(ResharperDownloadUrl)
		downloadUrl = /href\s*=\s*['"](?<url>[^'\+"]*msi)/.match(downloadPage)["url"]
		version = /\.(?<version>\d*\.\d*\.\d*\.\d*)\./.match(downloadUrl)["version"]
		majorVersion = Common.GetMajorVersion(version)
		libPath = libPath.gsub(VersionToken, majorVersion)
		versionCachePath = "#{cachePath}#{version}/" 
		versionInstallerPath = "#{versionCachePath}ReSharperSetup.#{version}.msi"
		extractPath = "#{versionCachePath}Files"
		
		if !File.exists?(versionInstallerPath) then
			Common.DownloadFile(downloadUrl, versionInstallerPath)
		end
		
		Common.CleanPath(extractPath)
		Common.ExtractMsi(versionInstallerPath, extractPath)

		Common.CleanPath(libPath)
		Dir.glob("#{extractPath}#{ResharperMsiBinfolder.gsub(VersionToken, majorVersion)}*.dll") do |name| 
			FileUtils.cp(name, libPath)
		end
		
		return version
	end

end