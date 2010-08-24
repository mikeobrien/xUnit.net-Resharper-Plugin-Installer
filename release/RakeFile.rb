require "Common"
require "Albacore"
require "Resharper"
require "XunitContrib"
require "XunitNet"

InstallerSolutionPath = "../src/XUnitNetResharperPlugin.sln"
ResharperFolder = "d:/Software/Resharper/"
TempFolder = "../temp/"
LibFolder =  "../lib/xunitnetcontrib"
ResharperVersion = "0.0"
ResharperMajorVersion = "0.0"

task :default => :buildInstaller

task :init do
	XUnitContrib.DownloadSource(TempFolder)
	ResharperVersion = Resharper.GetLatestResharperBits(ResharperFolder, XUnitContrib.GetResharperLibPath(TempFolder))
	ResharperMajorVersion = Common.GetMajorVersion(ResharperVersion)
	XUnitContrib.DereferenceUnnecessaryPluginProjects(TempFolder)
	XUnitContrib.MakeAssemblyNamesVersionNeutral(TempFolder)
end

msbuild :buildXunitContrib => :init do |msb|
  msb.path_to_command = File.join(ENV["windir"], "Microsoft.NET", "Framework", "v4.0.30319", "MSBuild.exe")
  msb.properties :configuration => :Release
  msb.targets :Clean, :Build
  msb.solution = TempFolder + XUnitContrib::SolutionPath
end

xunitnet :testXunitContrib => :buildXunitContrib do |xunit|
	xunit.xunitPath = "../lib/xunitnet"
	xunit.assembly = XUnitContrib.GetResharperTestsPath(TempFolder)
	xunit.htmlResults = TempFolder + "TestResults.html"
end

task :copyPluginFiles => :testXunitContrib do
	Common.CleanPath(LibFolder)
	Common.CopyFiles(XUnitContrib.GetPluginPath(TempFolder), LibFolder)
	Common.CopyFiles(TempFolder + XUnitContrib::AnnotationsPath, LibFolder)
	Common.CopyFiles(TempFolder + "*.ver", LibFolder)
	Common.DeleteDirectory(TempFolder)
end

msbuild :buildInstaller => :copyPluginFiles do |msb|
  msb.path_to_command = File.join(ENV["windir"], "Microsoft.NET", "Framework", "v4.0.30319", "MSBuild.exe")
  msb.properties :configuration => :Release, :ResharperVersion => ResharperVersion, :ResharperMajorVersion => ResharperMajorVersion
  msb.targets :Clean, :Build
  msb.solution = "../src/XUnitNetResharperPlugin.sln"
end