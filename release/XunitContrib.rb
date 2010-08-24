require "Common"
require "Resharper"

module XUnitContrib

	VersionToken = "$VERSION$"
	SourcePath = "xUnitNetContrib/"
	SolutionPath = SourcePath + "xunitcontrib.sln"
	XUnitContribSourceUrl = "https://hg01.codeplex.com/xunitcontrib"
	ResharperPath = SourcePath + "3rdParty/ReSharper_v#{VersionToken}"
	TestsPath = SourcePath + "resharper/tests.xunitcontrib.runner.resharper.runner.#{Resharper::VersionToken}/tests.xunitcontrib.runner.resharper.runner.#{Resharper::VersionToken}.dll"
	ProjectRegex = /Project.*?EndProject/m
	VersionRegex = /\"[\w\.]*xunitcontrib.runner.resharper[\w\.]*?\.(?<version>[\d\.]*)\"/

	def XUnitContrib.GetResharperLibPath(path)
		return ResharperPath.gsub(VersionToken, GetLatestSupportedVersion(path))
	end

	def XUnitContrib.GetLatestSupportedVersion(path)
		solution = Common.ReadAllFileText(path + SolutionPath)
		
		latestVersion = ""
		
		solution.scan(ProjectRegex).each do |project|
			projectName = VersionRegex.match(project)
			if (projectName != nil) then
				if projectName["version"] > latestVersion then
					latestVersion = projectName["version"]
				end
			end
		end
		
		return latestVersion
	end

	def XUnitContrib.DereferenceUnnecessaryPluginProjects(path)
		
		latestVersion = XUnitContrib.GetLatestSupportedVersion(path)

		solution = Common.ReadAllFileText(path + SolutionPath)
		
		solution.scan(ProjectRegex).each do |project|
			projectName = VersionRegex.match(project)
			if (projectName != nil) then
				if projectName["version"] != latestVersion then
					solution = solution.gsub(project, "")
				end
			end
		end
		
		nestedProjects = /GlobalSection\(NestedProjects\).*?EndGlobalSection/m.match(solution)
		if (nestedProjects != nil) then
			solution = solution.gsub(nestedProjects[0], "")
		end
		
		Common.WriteAllFileText(path + SolutionPath, solution)
	end

	def XUnitContrib.DownloadSource(path)
		Common.CleanPath(path + SourcePath)
		Common.DownloadHgSource(XUnitContribSourceUrl, path + SourcePath)
	end

	def XUnitContrib.BuildSolution(path)
		Common.MsBuild(path + SolutionPath, "Release")
	end

	def XUnitContrib.RunTests(path)
		Common.MsBuild(path + SolutionPath, "Release")
	end

end