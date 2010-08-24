require "Common"
require "Resharper"

module XUnitContrib

	VersionToken = "$VERSION$"
	SourcePath = "xUnitNetContrib/"
	SolutionPath = SourcePath + "xunitcontrib.sln"
	XUnitContribSourceUrl = "https://hg01.codeplex.com/xunitcontrib"
	ResharperPath = SourcePath + "3rdParty/ReSharper_v#{VersionToken}"
	TestsPath = SourcePath + "resharper/tests.xunitcontrib.runner.resharper.runner.#{VersionToken}/bin/release/tests.xunitcontrib.runner.resharper.runner.#{VersionToken}.dll"
	ProjectRegex = /Project.*?EndProject/m
	VersionRegex = /\"[\w\.]*xunitcontrib.runner.resharper[\w\.]*?\.(?<version>[\d\.]*)\"/
	PluginPath = SourcePath + "resharper/xunitcontrib.runner.resharper.provider.#{VersionToken}/bin/Release/*.dll"
	AnnotationsPath = SourcePath + "resharper/ExternalAnnotations/*.xml"
	RunnerProjectPath = SourcePath + "resharper/xunitcontrib.runner.resharper.runner.#{VersionToken}/xunitcontrib.runner.resharper.runner.#{VersionToken}.csproj"
	ProviderProjectPath = SourcePath + "resharper/xunitcontrib.runner.resharper.provider.#{VersionToken}/xunitcontrib.runner.resharper.provider.#{VersionToken}.csproj"

	def XUnitContrib.GetPluginPath(path)
		return path + PluginPath.gsub(VersionToken, GetLatestSupportedVersion(path))
	end

	def XUnitContrib.GetResharperLibPath(path)
		return path + ResharperPath.gsub(VersionToken, GetLatestSupportedVersion(path))
	end

	def XUnitContrib.GetResharperTestsPath(path)
		return path + TestsPath.gsub(VersionToken, GetLatestSupportedVersion(path))
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

	def XUnitContrib.MakeAssemblyNamesVersionNeutral(path)
		latestVersion = XUnitContrib.GetLatestSupportedVersion(path)
		MakeProjectAssemblyNamesVersionNeutral(path + RunnerProjectPath.gsub(VersionToken, latestVersion), "xunitcontrib.runner.resharper.runner", latestVersion)
		MakeProjectAssemblyNamesVersionNeutral(path + ProviderProjectPath.gsub(VersionToken, latestVersion), "xunitcontrib.runner.resharper.provider", latestVersion)
	end

	def XUnitContrib.MakeProjectAssemblyNamesVersionNeutral(path, name, version)
		project = Common.ReadAllFileText(path)
		project = project.gsub("<AssemblyName>#{name}.#{version}</AssemblyName>", "<AssemblyName>#{name}</AssemblyName>")
		Common.WriteAllFileText(path, project)
	end

	def XUnitContrib.DownloadSource(path)
		Common.CleanPath(path + SourcePath)
		Common.DownloadHgSource(XUnitContribSourceUrl, path + SourcePath)
	end

end