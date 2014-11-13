
class Controller

    def output_manager(output_manager)
        @output_manager = output_manager
    end
    
    # Abstract method
    def run(input_dir, unrefined_docs)
    end

end
