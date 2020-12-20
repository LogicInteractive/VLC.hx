let project = new Project('Kha-VLC');

// Resolve //////////////////////////////////////////

project.addDefine('analyzer-optimize');

// project.addShaders('c:/dev/fox/kha/shaders/**');
// project.addSources('c:/dev/fox/kha');
// project.addSources('c:/dev/fox/common');
// project.addSources('c:/dev/fox/thirdparty/common');
// project.addSources('c:/dev/fox/thirdparty/kha');
// project.addShaders('c:/dev/fox/thirdparty/kha/shaders/**');

project.addShaders('src/shaders/**');
project.addSources('src');
project.addLibrary('LibVLC');

project.addCDefine('HXCPP_STACK_TRACE');
project.addCDefine('HXCPP_STACK_LINE');
project.addCDefine('HXCPP_CHECK_POINTER');

// project.addParameter('-dce full');
project.addParameter('-main Main');

resolve(project);
