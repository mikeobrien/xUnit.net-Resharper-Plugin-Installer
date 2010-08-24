require "Common"
require "Resharper"

module XUnitContrib

	SourcePath = "xUnitNetContrib/"
	SolutionPath = SourcePath + "xunitcontrib.sln"
	XUnitContribSourceUrl = "https://hg01.codeplex.com/xunitcontrib"
	ResharperPath = SourcePath + "3rdParty/ReSharper_v#{Resharper::VersionToken}"
	TestsPath = SourcePath + "resharper/tests.xunitcontrib.runner.resharper.runner.#{Resharper::VersionToken}/tests.xunitcontrib.runner.resharper.runner.#{Resharper::VersionToken}.dll"

	def XUnitContrib.DereferenceUnnecessaryPluginProjects(path, version)
		majorVersion = Common.GetMajorVersion(version)
		solution = Common.ReadAllFileText(path + SolutionPath)
		
		solution.scan(/Project.*?EndProject/m).each do |project|
			projectName = /\"[\w\.]*xunitcontrib.runner.resharper[\w\.]*?\.(?<version>[\d\.]*)\"/.match(project)
			if (projectName != nil) then
				if projectName["version"] != majorVersion then
					solution = solution.gsub(project, "")
				end
			end
		end
		
		nestedProjects = /GlobalSection\(NestedProjects\).*?EndGlobalSection/m.match(solution)
		solution = solution.gsub(nestedProjects[0], "")
		
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