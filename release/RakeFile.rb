require "Resharper"
require "XunitContrib"

WorkingFolder = "D:/Temp/ResharperXunit.net/"
ResharperDownloadCache = WorkingFolder + "ResharperCache/"
BinFolder =  WorkingFolder + "bin"

task :default => :build

task :build do
	XUnitContrib.DownloadSource(WorkingFolder)
	version = Resharper.GetLatestResharperBits(ResharperDownloadCache, WorkingFolder + XUnitContrib::ResharperPath)
	XUnitContrib.DereferenceUnnecessaryPluginProjects(WorkingFolder, version)
	XUnitContrib.BuildSolution(WorkingFolder)
	# run the tests
	# copy the bin files
	# build the installer
end