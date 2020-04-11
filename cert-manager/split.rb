  #!/usr/bin/env ruby
  require 'psych'
  content = File.read(ARGV[0])
  Psych.load_stream(content) do |resource|
    name = "#{resource['metadata']['name']}.#{resource['kind'].downcase}.yaml"
    name = name.gsub(":", ".")
    name = name.gsub("-", ".")
    name = name.gsub("cert.manager", "cert-manager")
    File.open(name, 'w') do |file|
      file.write(resource.to_yaml)
    end
  end 