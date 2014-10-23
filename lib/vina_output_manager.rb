
require 'json'
require_relative 'output_manager'

class VinaOutputManager < OutputManager

private

    def write_tree( root_cluster )
    
        structure = { 
            "topic_data" => write_sub_tree(root_cluster, 0)
        }
                
        # Save the file
        File.open(@out_file_path + ".json", "wb") { |file| file.write(structure.to_json) }
    end
    
    def write_sub_tree( cluster, level )
        
        # do the same step for each child
        cluster.tree_children.map! do |child|
        
            words = [child.label( @document_manager ).join(" ")] #[level..-1]

            child.freqitems.each do |freqitem|
                # get the word from its ID
                words << @document_manager.get_freq_term_from_id(freqitem.freq_item_id)
            end
        
            hash = { 
                "words" => words,
                "name" => "name",
                "documents" => child.documents.map(&:name),
                "links" => child.documents.map(&:link)
            }
            
            sub_tree = write_sub_tree( child, level+1 )
            hash["children"] = sub_tree unless sub_tree.empty?
            
            hash
        end

    end

end
