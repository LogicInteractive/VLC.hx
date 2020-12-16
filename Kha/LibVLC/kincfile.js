let project = new Project('LibVLC');

project.addFile('sources/**');
project.addIncludeDir('sources');
project.addLib('sources/lib/libvlc.x64');

resolve(project);
