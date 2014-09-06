
require 'builder'
require_relative 'document_manager'
require_relative 'cluster_manager'

class OutputManager

    def initialize( document_manager, cluster_manager )
        @document_manager = document_manager
        @cluster_manager = cluster_manager
    end

    def produce_output( out_file_path )
        return if @cluster_manager.nil?
        
        # get the root of the cluster tree
        root_cluster = @cluster_manager.cluster_warehouse.tree_root
        
        write_tree_to_xml( out_file_path, root_cluster )
    end
    
private

    def write_tree_to_xml( out_file_path, root_cluster )
    
        # create an XML file
        xml = Builder::XmlMarkup.new( :indent => 2 )
        xml.instruct! :xml, :encoding => "ASCII"
        
        xml.root( :num_docs => root_cluster.num_documents_include_tree_children, 
                  :num_clusters => root_cluster.num_clusters_include_tree_children,
                  :num_children => root_cluster.tree_children.length ) {
        
            # write the tree
            write_sub_tree(root_cluster, xml)
        
        }
        
        puts out_file_path
        
        # Save the file
        File.open(out_file_path, "wb") { |file| file.write(xml.target!) }
    end
    
    def write_sub_tree( parent_cluster, xml )

        # write the frequent (non-core) items in this cluster
        write_cluster_freqitems( parent_cluster, xml )
        
        # write all documents in this cluster
        write_documents( parent_cluster, xml )
        
        children = parent_cluster.tree_children
        
        # do the same step for each child
        children.each do |child|

            # make a new cluster element
            xml.cluster( :num_docs => child.num_documents_include_tree_children, 
                         :num_children => child.tree_children.length, 
                         :global_support => child.core_items.global_support,
                         :label => child.label( @document_manager ) ) {
                
                write_sub_tree( child, xml )
            }

        end

    end
    
    def write_cluster_freqitems( cluster, xml )
    
        xml.cluster_freq_items(:num_items => cluster.freqitems.length ) {
            cluster.freqitems.each do |freqitem|
                # get the word from its ID
                word = @document_manager.get_freq_term_from_id(freqitem.freq_item_id)

                xml.description( word, :cluster_support => freqitem.cluster_support )
            end
        }

    end
    
    def write_documents( cluster, xml )
    
        xml.documents(:num_docs => cluster.documents.length) {
            cluster.documents.each do |doc|
                xml.document(doc.name)
            end
        }

    end
    
    def get_cluster_attributes( cluster )
    
    end

end