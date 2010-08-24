require "Common"
require "Albacore"
require "Resharper"
require "XunitContrib"
require "XunitNet"

ResharperFolder = "d:/Software/Resharper/"
TempFolder = "../temp/"
LibFolder =  "../lib/xunitnetcontrib"

task :default => :copyPluginFiles

task :init do
	XUnitContrib.DownloadSource(TempFolder)
	version = Resharper.GetLatestResharperBits(ResharperFolder, XUnitContrib.GetResharperLibPath(TempFolder))
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
	Common.DeleteDirectory(TempFolder)
end

	# copy the bin files
	# build the installer