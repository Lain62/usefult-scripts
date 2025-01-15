def check_folder_file out
    dirname = File.dirname(out)
    if !Dir.exist? dirname
        Dir.mkdir dirname
    end

    if File.exist? out
        File.delete(out)
    end
end

def open_file file
    data = File.read file
    data
end

def output(out = nil)
    if out == nil
        return default_out = "./build/out"
    else
        return out
    end
end

def write_to_build data, out
    File.write(out, data, mode: "a")
    File.write(out, "\n", mode: "a")
end

def panic message
    puts message
    exit(1)
end

def main args
    if args.size > 0
        lexer = []
        args.each do |arg|
            if arg[0] == '-'
                lexer.push({type: :option, arg: "#{arg[1]}"})
            else
                lexer.push({type: :arg, arg: "#{arg}"})
            end
        end    

        ast = []
        lexer.each_with_index do |lex, idx|
            if lex[:type] == :arg
                next
            end
            if lex[:type] == :option
                args = []
                for i in idx+1..lexer.size-1
                    break if lexer[i][:type] == :option

                    args.push(lexer[i][:arg])
                end
                
                case lex[:arg]
                when "o"
                    panic "ERROR: -o arg more than 1" if args.size > 1                
                    ast.push({type: :out, args: args[0]})
                when "f"
                    ast.push({type: :files, args: args})
                when "d"
                    ast.push({type: :dir, args: args})
                when "h"
                    ast.push({type: :help})
                end
            end
        end

        ast.each do |arg|
            case arg[:type]
            when :files
                out = output nil
                if ast.any? {|w| w[:type] == :out}
                    a = ast.select {|w| w[:type] == :out}
                    out = a[0][:args]
                end
                check_folder_file out
                arg[:args].each do |file|
                    panic "ERROR: file \"#{file}\" DOESNT EXIST" if !File.exist? file
                    puts "Writing #{file} to #{out}"
                    data = open_file file
                    write_to_build data, out
                end
            when :dir
                out = output nil
                if ast.any? {|w| w[:type] == :out}
                    a = ast.select {|w| w[:type] == :out}
                    out = a[0][:args]
                end
                check_folder_file out
                arg[:args].each do |dir|
                    panic "ERROR: directory \"#{dir}\" DOESNT EXIST" if !Dir.exist? dir
                    globed = Dir.glob "#{dir}/**"
                    globed.each do |glob|
                        panic "ERROR: file \"#{glob}\" DOESNT EXIST" if !File.exist? glob
                        next if Dir.exist? glob
                        puts "Writing #{glob} to #{out}"
                        data = open_file glob
                        write_to_build data, out
                    end
                end
            when :help
                puts "COMMANDS\tDESC"
                puts "-o\tchanges the default output folder (default is \"./build/out\")"
                puts "-d\tuse folders as source files"
                puts "-f\tuse files as source"
                puts "h\topens this"
            end
        end
    else
        puts "COMMANDS\tDESC"
        puts "-o\tchanges the default output folder (default is \"./build/out\")"
        puts "-d\tuse folders as source files"
        puts "-f\tuse files as source"
        puts "h\topens this"        
    end
    
end

main ARGV
