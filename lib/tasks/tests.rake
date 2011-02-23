["test:units","test:functionals","test:recent"].each do |name|
	Rake::Task[name].prerequisites.clear
end
