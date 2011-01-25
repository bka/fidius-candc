# The documentaion may be generated with YARD (http://yardoc.info),
# which generates some nice pages. To parse also the register_command
# method, a YARD handler must be plugged in. Since YARD used different
# parsers for Ruby 1.8 and 1.9 and the MsfWorker still uses 1.8 for
# @@reason but should migrate to 1.9, both parsers are supported...

if RUBY_VERSION >= '1.9'
  class RegisterCommandHandler < YARD::Handlers::Ruby::AttributeHandler
    handles method_call(:register_command)
    namespace_only

    def process
      name = "cmd_" + statement.parameters.first.jump(:tstring_content, :ident).source
      object = YARD::CodeObjects::MethodObject.new(namespace, name)
      object.parameters << :options
      register(object)
      parse_block(statement.last.last, :owner => object)
      object.dynamic = true
    end
  end
else
  # Gnah. The YARD legacy parser is not really well described. This
  # approach should be categorized as untested hack...
  class RegisterCommandHandler < YARD::Handlers::Ruby::Legacy::AttributeHandler
    handles /\AFIDIUS::MsfWorker\.register_command\b/ # *sigh*...
    namespace_only

    def process
      name = "cmd_" + statement.tokens[6].text.gsub(/^:/, '')
      object = YARD::CodeObjects::MethodObject.new(namespace, name)
      object.parameters << :options
      register(object)
      parse_block(:owner => object)
      object.dynamic = true
    end
  end
end
