# Provides a simple variable substitution capability, similar, in concept,
# to Python's +StringTemplate+ class. See the Grizzled::String::Template
# module, the Grizzled::String::UnixShellStringTemplate class and the
# Grizzled::String::WindowsCmdStringTemplate class for complete details.
#
# ---
#
# This software is released under a BSD license, adapted from
# http://opensource.org/licenses/bsd-license.php
#
# Copyright (c) 2011, Brian M. Clapper
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright
#   notice, this list of conditions and the following disclaimer in the
#   documentation and/or other materials provided with the distribution.
#
# * Neither the names "clapper.org", "Grizzled Ruby Library", nor the
#   names of its contributors may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ---------------------------------------------------------------------------

# Grizzled Ruby: A library of miscellaneous, general-purpose Ruby modules.
#
# Author:: Brian M. Clapper (mailto:bmc@clapper.org)
# Copyright:: Copyright (c) 2011 Brian M. Clapper
# License:: BSD License
module Grizzled

  module String

    # Grizzled::String::Template - A simple string templating solution
    # modeled after Python's +StringTemplate+ library. While Ruby has less
    # need of this kind of library, because of its built-in string
    # interpolation, this module can be useful for interoperating with
    # Python or with the Grizzled Scala library's string templating
    # library.
    module Template

      # Exception raised for non-existent variables in non-safe templates.
      class VariableNotFoundException < StandardError; end

      # What a parsed variable looks like.
      class Variable

        attr_reader :istart, :iend, :name, :default

        def initialize(istart, iend, name, default=nil)
          @istart = istart
          @iend = iend
          @name = name
          @default = default
        end

        alias :inspect :to_s
        def to_s
          "#{name}"
        end
      end

      # Base (abstract) class for a string template. Common logic is here.
      # Subclasses implement specific methods.
      class TemplateBase

        attr_reader :resolver, :safe

        # Initializer.
        #
        # Parameters:
        #
        # [+resolver+] A hash-like object that can take a variable name (via
        #              the +[]+ function) and resolve its value, returning
        #              the value (which is converted to string) or +nil+.
        # [+options+]  hash of options. See below.
        #
        # Options:
        #
        # [+:safe+]    +true+ for a safe template that substitutes a blank
        #              string for a non-existent variable, instead of
        #              throwing an exception. Defaults to +true+.
        def initialize(resolver, options={})
          @resolver = resolver
          @safe = options.fetch(:safe, true)
        end

        # Replace all variable references in the given string. Variable
        # references are recognized per the regular expression passed to
        # the constructor. If a referenced variable is not found in the
        # resolver, this method either:
        #
        # - throws a +VariableNotFoundException+ (if +safe+ is +false+).
        # - substitutes an empty string (if +safe+ is +true+)
        #
        # Recursive references are supported (but beware of infinite recursion).
        #
        # Parameters:
        #
        # [+s+] the string in which to replace variable references
        #
        # Returns the substituted result.
        def substitute(s)

          def substitute_variable(var, s)
            end_string = var.iend == s.length ? "" : s[var.iend..-1]
            value = get_variable(var.name, var.default)
            transformed = 
              (var.istart == 0 ? "" : s[0..(var.istart-1)]) + value + end_string
            substitute(transformed)
          end

          # Locate the next variable reference.
          var = find_variable_ref(s)
          if var.nil?
            s
          else
            substitute_variable(var, s)
          end
        end

        # Parse the location of the first variable in the string. Subclasses
        # should override this method.
        #
        # Parameters:
        #
        # [+s+] the string
        #
        # Returns a +Variable+ object, or +nil+.
        def find_variable_ref(s)
          nil
        end

        # Get a variable's value, returning the empty string or throwing an
        # exception, depending on the setting of +safe+.
        #
        # Parameters:
        #
        # [+name+]    Variable name
        # [+default+] Default value, or +nil+
        def get_variable(name, default)
          
          def handle_no_value(default, name)
            if not default.nil?
              default
            elsif @safe
              ""
            else
              raise VariableNotFoundException.new(name)
            end
          end

          resolver[name] || handle_no_value(default, name)
        end
      end # TemplateBase

      # A string template that uses the Unix shell-like syntax +${varname}+
      # (or +$varname+) for variable references. A variable's name typically
      # consists of alphanumerics and underscores, but is controlled by the a
      # supplied regular expression. To include a literal "$" in a string,
      # escape it with a backslash.
      #
      # For this class, the general form of a variable reference is:
      #
      #     ${varname?default}
      #
      # The +?default+ suffix is optional and specifies a default value
      # to be used if the variable has no value.
      #
      # A shorthand form of a variable reference is:
      #
      #     $varname
      #
      # The _default_ capability is not available in the shorthand form.
      class UnixShellStringTemplate < TemplateBase

        ESCAPED_DOLLAR_PLACEHOLDER = "\001"
        ESCAPED_DOLLAR = %r{(\\*)(\\\$)}

        # Initialize a new +UnixShellStringTemplate+. Supports various hash
        # options.
        #
        # Parameters:
        #
        # [+resolver+] A hash-like object that can take a variable name (via
        #              the +[]+ function) and resolve its value, returning
        #              the value (which is converted to string) or +nil+.
        # [+options+]  hash of options. See below.
        #
        # Options:
        #
        # [+:safe+]         +true+ for a safe template that substitutes a blank
        #                   string for a non-existent variable, instead of
        #                   throwing an exception. Defaults to +true+.
        # [+:var_pattern+]  Regular expression pattern (as a string, not a
        #                   Regexp object) to match a variable name. Defaults
        #                   to "[A-Za-z0-9_]+"
        def initialize(resolver, options={})
          super(resolver, options)
          var_re = options.fetch(:var_pattern, "[A-Za-z0-9_]+")
          @long_var_regexp = %r{\$\{(#{var_re})(\?[^\}]*)?\}}
          @short_var_regexp = %r{\$(#{var_re})}
        end

        # Replace all variable references in the given string. Variable
        # references are recognized per the regular expression passed to
        # the constructor. If a referenced variable is not found in the
        # resolver, this method either:
        #
        # - throws a +VariableNotFoundException+ (if +safe+ is +false+).
        # - substitutes an empty string (if +safe+ is +true+)
        #
        # Recursive references are supported (but beware of infinite recursion).
        #
        # Parameters:
        #
        # [+s+] the string in which to replace variable references
        #
        # Returns the substituted result.
        def substitute(s)
          # Kludge to handle escaped "$". Temporarily replace it with
          # something highly unlikely to be in the string. Then, put a single
          # "$" in its place, after the substitution. Must be sure to handle
          # even versus odd number of backslash characters.

          def pre_sub(s)

            def handle_match(m, s)
              if (m[1].length % 2) == 0
                # Odd number of backslashes before "$", including
                # the one with the dollar token (group 2). Valid escape.

                b = m.begin(0)
                start = (b == 0 ? "" : s[0..(b-1)])
                start + ESCAPED_DOLLAR_PLACEHOLDER + pre_sub(s[m.end(0)..-1])
              else
                # Even number of backslashes before "$", including the one
                # with the dollar token (group 2). Not an escape.
                s
              end
            end

            # Check for an escaped "$"
            m = ESCAPED_DOLLAR.match(s)
            if (m)
              handle_match(m, s)
            else
              s
            end
          end

          s2 = super(pre_sub(s))
          s2.gsub(ESCAPED_DOLLAR_PLACEHOLDER, '$')
        end

        # Parse the location of the first variable in the string. Subclasses
        # should override this method.
        #
        # Parameters:
        #
        # [+s+] the string
        #
        # Returns a +Variable+ object, or +nil+.
        def find_variable_ref(s)

          def handle_long_match(m)
            name = m[1]
            if m[2].nil?
              default = nil
            else
              # Pull off the "?"
              default = m[2][1..-1]
            end

            Variable.new(m.begin(0), m.end(0), name, default)
          end

          def handle_no_long_match(s)
            m = @short_var_regexp.match(s)
            if m.nil?
              nil
            else
              Variable.new(m.begin(0), m.end(0), m[1], nil)
            end
          end

          m = @long_var_regexp.match(s)
          if m.nil?
            handle_no_long_match(s)
          else
            handle_long_match(m)
          end
        end

      end # UnixShellStringTemplate

      # A string template that uses the Windows +cmd.exe+ syntax +%varname%+
      # for variable references. A variable's name may consist of alphanumerics
      # and underscores. To include a literal "%" in a string, escape it with
      # a backslash ("\%").
      class WindowsCmdStringTemplate < TemplateBase

        ESCAPED_PERCENT = %r{(\\*)(%)}
        ESCAPED_PERCENT_PLACEHOLDER = '\001'

        # Initialize a new +WindowsCmdStringTemplate+. Supports various hash
        # options.
        #
        # Parameters:
        #
        # [+resolver+] A hash-like object that can take a variable name (via
        #              the +[]+ function) and resolve its value, returning
        #              the value (which is converted to string) or +nil+.
        # [+options+]  hash of options. See below.
        #
        # Options:
        #
        # [+:safe+]         +true+ for a safe template that substitutes a blank
        #                   string for a non-existent variable, instead of
        #                   throwing an exception. Defaults to +true+.
        # [+:var_pattern+]  Regular expression pattern (as a string, not a
        #                   Regexp object) to match a variable name. Defaults
        #                   to "[A-Za-z0-9_]+"
        def initialize(resolver, options={})
          super(resolver, options)
          var_pat = options.fetch(:var_pattern, "[A-Za-z0-9_]+")
          @var_re = %r{%(#{var_pat})%}
        end

        # Replace all variable references in the given string. Variable
        # references are recognized per the regular expression passed to
        # the constructor. If a referenced variable is not found in the
        # resolver, this method either:
        #
        # - throws a +VariableNotFoundException+ (if +safe+ is +false+).
        # - substitutes an empty string (if +safe+ is +true+)
        #
        # Recursive references are supported (but beware of infinite recursion).
        #
        # Parameters:
        #
        # [+s+] the string in which to replace variable references
        #
        # Returns the substituted result.
        def substitute(s)
          # Kludge to handle escaped "%". Temporarily replace it with
          # something highly unlikely to be in the string. Then, put a single
          # "%" in its place, after the substitution. Must be sure to handle
          # even versus odd number of backslash characters.

          def pre_sub(s)

            def handle_match(m, s)
              if (m[1].length % 2) == 1
                # Odd number of backslashes before "%". Valid escape.

                b = m.begin(0)
                start = (b == 0 ? "" : s[0..(b-1)])
                start + ESCAPED_PERCENT_PLACEHOLDER + pre_sub(s[m.end(0)..-1])
              else
                # Even number of backslashes before "%". Not an escape.
                s
              end
            end

            # Check for an escaped "%"
            m = ESCAPED_PERCENT.match(s)
            if (m)
              handle_match(m, s)
            else
              s
            end
          end

          s2 = super(pre_sub(s))
          s2.gsub(ESCAPED_PERCENT_PLACEHOLDER, '%')
        end

        # Parse the location of the first variable in the string. Subclasses
        # should override this method.
        #
        # Parameters:
        #
        # [+s+] the string
        #
        # Returns a +Variable+ object, or +nil+.
        def find_variable_ref(s)
          m = @var_re.match(s)
          if m.nil?
            nil
          else
            Variable.new(m.begin(0), m.end(0), m[1], nil)
          end
        end
      end # WindowsCmdStringTemplate

    end # module
  end # module
end
