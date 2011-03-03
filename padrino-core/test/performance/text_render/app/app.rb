class TextRender < Padrino::Application
  use ::Rack::PerftoolsProfiler, :default_printer => 'text'

  disable :sessions
  disable :flash
  # disable :logging
  set :logging, false
  disable :static
  disable :method_override
  disable :show_exceptions
end
