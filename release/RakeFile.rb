require "Resharper"
require "XunitContrib"

WorkingFolder = "../Temp/"
BinFolder =  WorkingFolder + "bin"

task :default => :build

task :build do
	XUnitContrib.DownloadSource(WorkingFolder)
	version = Resharper.GetLatestResharperBits(WorkingFolder, WorkingFolder + XUnitContrib.GetResharperLibPath(WorkingFolder))
	XUnitContrib.DereferenceUnnecessaryPluginProjects(WorkingFolder)
	XUnitContrib.BuildSolution(WorkingFolder)
	# run the tests
	# copy the bin files
	# build the installer
end