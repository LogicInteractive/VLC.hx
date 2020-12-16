let project = new Project('Kha-VLC');

project.addSources('src');
project.addLibrary('LibVLC');

project.addCDefine('HXCPP_STACK_TRACE');
project.addCDefine('HXCPP_STACK_LINE');
project.addCDefine('HXCPP_CHECK_POINTER');

resolve(project);
