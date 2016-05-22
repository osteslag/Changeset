Pod::Spec.new do |spec|
	spec.name = 'Changeset'
	spec.version = '1.0.4'
	spec.license = { :type => 'MIT', :file => 'LICENSE' }
	spec.homepage = 'https://github.com/osteslag/Changeset'
	spec.author = { 'Joachim Bondo' => 'joachim@bondo.net' }
	spec.social_media_url = 'https://twitter.com/osteslag'
	spec.summary = 'Minimal edits from one collection to another'
	spec.description = 'A Swift value type to compute and hold the edits required to go from one CollectionType of Equatable elements to another.'
	spec.source = { :git => 'https://github.com/osteslag/Changeset.git', :tag => "v#{spec.version}" }
	spec.source_files = 'Sources/*.swift'
	spec.requires_arc = true
	spec.ios.deployment_target = '8.0'
	spec.osx.deployment_target = '10.9'
	spec.watchos.deployment_target = '2.0'
end
