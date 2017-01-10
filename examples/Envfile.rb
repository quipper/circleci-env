Dir[File.expand_path('../projects', __FILE__) + '/**/*.rb'].each do |file|
  require file
end
