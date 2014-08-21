
require_relative 'cluster_freqitemset'

class Clusters < Array

    # Add the new cluster to this collection.  Given the current data structure
    # is a list, it should look like:
    # {{100}, {100, 101}, {100, 102}, {100, 334, 500}, {100, 120, 130, 202}}
    def add_cluster(new_cluster)
        self.push( new_cluster ) if self.empty?
        
        new_core_items = new_cluster.core_items        
        num_new_core_items = new_cluster.num_core_items
        
        reverse_each do |cluster|
        
            num_core_items = cluster.num_core_items
            
            if num_core_items > num_new_core_items
                # not found yet, keep going.
                next            
            elsif num_core_items < num_new_core_items
                # insert new cluster after the current cluster
                self.insert(self.index(cluster), new_cluster)
                return true
            else
                core_items = cluster.core_items                
                res = core_items.compare_to( new_core_items )
                
                case res
                when FreqItemset::COMPARE_SMALLER
                    # not found yet, keep going.
                    next

                when FreqItemset::COMPARE_LARGER
                    # insert new cluster After the current cluster
                    self.insert(self.index(cluster), new_cluster)
                    return true
                    
                when FreqItemset::COMPARE_EQUAL
                    return false
                end
            end

        end
        
        self.insert(0, new_cluster)
    end

end