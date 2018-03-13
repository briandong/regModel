#!/ic/tools/ruby/2.4.1/bin/ruby -w

# This script builds the UVM register model, based on pre-defined address map in markdown (mk) style

# Definition of a sample user class
class User

    # Name of user
    attr_accessor :name

    # What does the user say
    def speak
        return 'HelloWorld!'
    end

end #class User

# Definition of field class
class Field

    attr_accessor :name
    attr_accessor :size
    attr_accessor :position
    attr_accessor :access
    attr_accessor :volatile
    attr_accessor :reset_value
    attr_accessor :reset
    attr_accessor :rand
    attr_accessor :individual

    # Init
    def initialize(name, size, position, access, volatile, reset_value, reset, rand, individual, info)
        @name = name
		@size = size
		@position = position
		@access = access
		@volatile = volatile
		@reset_value = reset_value
		@reset = reset
		@rand = rand
		@individual = individual
		@info = info
    end

end #class Field

# Definition of register class
class Register

    # accessor
    attr_accessor :name
    attr_accessor :offset
    attr_accessor :rights
    attr_accessor :f_list

    # Init
    def initialize(name, offset, size, rights, f_list)
        @name = 'REG_' + name
		@offset = offset
		@size = size
		@rights = rights
		@f_list = f_list
    end

	# Display
	def display
		s = <<-HEREDOC_REG0

class #{@name}_t extends uvm_reg;

    `uvm_object_utils(#{@name}_t)

        HEREDOC_REG0

		@f_list.each do |f|
			s += " "*4
			s += "rand " if f.rand
			s += "uvm_reg_field #{f.name};\n"
		end

        s += <<-HEREDOC_REG1

    function new(string name = "#{@name}");
       super.new(name, #{@size.to_i*8}, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        HEREDOC_REG1

		@f_list.each do |f|
			s += " "*8
			s += "this.#{f.name} = uvm_reg_field::type_id::create(\"#{f.name}\");\n"
		end

		@f_list.each do |f|
			s += " "*8
			s += "this.#{f.name}.configure(this, #{f.size}, #{f.position}, \"#{f.access}\", #{f.volatile}, #{f.reset_value}, #{f.reset}, #{f.rand}, #{f.individual});\n"
		end

		s += " "*4 + "endfunction\n\n"

		s += "endclass\n\n"
	end

end #class Register

# Definition of memory class
class Memory

    # accessor
    attr_accessor :name
    attr_accessor :offset
    attr_accessor :rights

    # Init
    def initialize(name, offset, size, bits, rights, info)
        @name = 'MEM_' + name
		@offset = offset
		@size = size
		@bits = bits
		@rights = rights
		@info = info
    end

	# Display
	def display
		s = <<-HEREDOC_MEM0

class #{@name}_t extends uvm_mem;

    `uvm_object_utils(#{@name}_t)

    function new(string name = "dut_RAM");
        super.new(name, #{@size}, #{@bits}, \"#{@rights}\", UVM_NO_COVERAGE);
    endfunction
   
endclass

        HEREDOC_MEM0
	end

end #class Memory

# Definition of block class
class Block

    # accessor
    attr_accessor :name
    attr_accessor :reg_list
    attr_accessor :mem_list

    # Init
    def initialize(name, addr, width, reg_list, mem_list)
        @name = 'BLK_' + name
		@addr = addr
		@width = width
		@reg_list = reg_list
		@mem_list = mem_list
    end

	# Display
	def display

		s = ""

		@reg_list.each do |r|
            s += r.display
		end

		@mem_list.each do |m|
            s += m.display
		end

		s += <<-HEREDOC_BLK0

class #{@name} extends uvm_reg_block;

    `uvm_object_utils(#{@name})

        HEREDOC_BLK0

		@reg_list.each do |r|
			s += " "*4
			s += "rand "
			s += "#{r.name}_t #{r.name};\n"
		end

		@mem_list.each do |m|
			s += " "*4
			s += "rand "
			s += "#{m.name}_t #{m.name};\n"
		end

		s += <<-HEREDOC_BLK1

   function new(string name = "#{@name}");
      super.new(name, UVM_NO_COVERAGE);
   endfunction

   virtual function void build();

        HEREDOC_BLK1

		@reg_list.each do |r|
			s += " "*8
			s += "#{r.name} = #{r.name}_t::type_id::create(\"#{r.name}\");\n"
		end

		@mem_list.each do |m|
			s += " "*8
			s += "#{m.name} = #{m.name}_t::type_id::create(\"#{m.name}\");\n"
		end

		s += "\n" + " "*8
		s += "//configure\n"

		@reg_list.each do |r|
			s += " "*8
			s += "#{r.name}.configure(this, null, \"#{r.name}\");\n"
			s += " "*8
			s += "#{r.name}.build();\n"
		end

		@mem_list.each do |m|
			s += " "*8
			s += "#{m.name}.configure(this, \"#{m.name}\");\n"
		end

		s += "\n" + " "*8
		s += "//default map\n"
		s += " "*8
        s += "default_map = create_map(\"default_map\", #{@addr}, #{@width}, UVM_LITTLE_ENDIAN, 1);\n"

		@reg_list.each do |r|
			s += " "*8
			s += "default_map.add_reg(#{r.name}, #{r.offset}, \"#{r.rights}\");\n"
		end

		@mem_list.each do |m|
			s += " "*8
			s += "default_map.add_mem(#{m.name}, #{m.offset}, \"#{m.rights}\");\n"
		end
		s += " "*4 + "endfunction\n\n"

		s += "endclass\n\n"
	end

end #class Block


# Only run the following code when this file is the main file being run if __FILE__ == $0

	if ARGV[0] == nil or ARGV[0] =~ /-h/
		puts "Usage: #{$0} AddrMap_File Output_File"
		exit
	else

		# check options
	    addr_map_file = ARGV[0]
        fail "Error: invalid address map file specified" unless File::exist? addr_map_file
		out_file = ARGV[1] 
        fail "Error: please specify the output file" unless out_file
		fail "Error: output file already exists - #{out_file}" if File::exist? out_file

		debug_flag = false
		debug_flag = true if ARGV[2] == '-d'

		# create output dir
        #unless File::directory? out_dir
		#	Dir.mkdir out_dir 
		#    puts "making output dir: #{out_dir}"
        #else
		#    puts "output dir already exists: #{out_dir}"
        #end

		# the flags
		reg_flag = false
		mem_flag = false

		# the lists
		field_l = []
		reg_l = []
		mem_l = []

		# the variables
		i_name = nil
		i_offset = nil
		i_size = nil
		i_bits = nil
		i_rights = nil
		i_info = nil
		i_addr = nil
		i_width = nil

		# parse addr map file
        addr_map = File::open(addr_map_file)
        addr_map.each do |line|
            
            if line =~ /^#+\s*Register List/ #start of register list
                reg_flag = true
		        mem_flag = false
				puts "=== start of register list ==="
            elsif line =~ /^#+\s*Memory List/ #start of memory list
                reg_flag = false
		        mem_flag = true
				puts "=== start of memory list ==="
			elsif line =~ /^#+\s*(\w*)/ #start of item
				i_name = $1
				puts "#{i_name}:"
			elsif line =~ /^BaseAddr:\s*(\S*)/
				i_addr = $1
				puts "\tbaseAddr - #{i_addr}"
			elsif line =~ /^Width(.*):\s*(\S*)/
				i_width = $2
				puts "\twidth - #{i_width}"
			elsif line =~ /^Offset:\s*(\S*)/
				i_offset = $1
				puts "\toffset - #{i_offset}"
			elsif line =~ /^Size(.*):\s*(\w*)/
				i_size = $2
				puts "\tsize - #{i_size}"
			elsif line =~ /^\|(.*)\|$/ #table
				tab_l = $1.split '|'
				tab_l.map! {|x| x.strip}
				#p tab_l
				if tab_l[0] == 'Name' and tab_l[1] == 'Size' #header
					next
				elsif tab_l[0] == '-' and tab_l[1] == '-' #separator
					next
				else
				    if reg_flag
						fail "Error: (line #{$.}) Invalid table format" unless tab_l.size == 10
						my_field = Field.new(tab_l[0], tab_l[1], tab_l[2], tab_l[3], tab_l[4], tab_l[5], tab_l[6], tab_l[7], tab_l[8], tab_l[9])
				    	field_l << my_field
				        puts "\t#{tab_l}"
				    elsif mem_flag
						fail "Error: (line #{$.}) Invalid table format" unless tab_l.size == 4
						i_size = tab_l[1]
						i_bits = tab_l[2]
						i_info = tab_l[3]
				    else
				    	fail "Error: (line #{$.}) Invalid type. Should be register or memory"
				    end					
				end
			elsif line =~ /^Rights:\s*(\w*)/ #end of item
				i_rights = $1
				puts "\trights - #{i_rights}"

				# initialize items
				if reg_flag
					my_reg = Register.new(i_name, i_offset, i_size, i_rights, field_l)
					reg_l << my_reg
					field_l = [] #clear field list
					puts my_reg.display if debug_flag
				elsif mem_flag
					my_mem = Memory.new(i_name, i_offset, i_size, i_bits, i_rights, i_info)
					mem_l << my_mem
					puts my_mem.display if debug_flag
				else
					fail "Error: (line #{$.}) Invalid type. Should be register or memory"
				end
            end
        end

		# initialize block
		my_blk = Block.new("regmodel", i_addr, i_width, reg_l, mem_l)
		puts my_blk.display if debug_flag
		
		# generate the register model package
		File::open(out_file, 'w') do |f|
			f.puts my_blk.display
		end
	end

end #if
