task :parser do
  sh "rbx -Ilib/vendor/kpeg/lib ./lib/vendor/kpeg/bin/kpeg -f -s -n Atomo::Parser lib/atomo/atomo.kpeg"
end

task :clean do
  sh "find . -name '*.rbc' -delete; find . -name '*.atomoc' -delete"
end