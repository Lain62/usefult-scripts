# Some methods that makes ruby much safer imo

# Creates an enum with symbols for value
#
# USAGE: 
# 001> Directions = define_enum('Unknown', 'West', 'South', 'East', 'North')
# 002> direction = Directions::West => :west
def define_enum(*values)
  enum_module = Module.new
  values.each do |value|
    enum_module.const_set(value, value.downcase.to_sym)
  end
  enum_module
end

# Creates a signature for a variable
#
# USAGE: 
# 001> def hello(name)
# 002>   define_sig(name, String)
# 003>   puts "Hello #{name}"
# 004> end
# 005>
# 006> hello("foo") => "Hello foo"
# 007> hello(2) => ERROR: FILE:6: METHOD: <main> SIGNATURE DOESNT MATCH
def define_sig(var, sig)
  caller_locations(2, 1).first.tap{|loc| raise "ERROR: #{loc.path}:#{loc.lineno}: METHOD: :#{loc.base_label} SIGNATURE DOESNT MATCH" if !(var.instance_of? sig)}
end
