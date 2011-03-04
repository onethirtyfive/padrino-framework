class TextRender < Padrino::Application
  use ::Rack::PerftoolsProfiler, :default_printer => 'text'

  disable :sessions
  disable :flash
  disable :logging
  disable :padrino_logging
  disable :static
  disable :method_override
  disable :show_exceptions
  disable :reload
end
