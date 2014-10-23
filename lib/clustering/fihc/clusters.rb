
require 'clustering/fihc/cluster_freqitemset'

module Clustering::Fihc
    class Clusters < Array

        # Add the new cluster to this collection.  Given the current data structure
        # is a list, it should look like:
        # {{100}, {100, 101}, {100, 102}, {100, 334, 500}, {100, 120, 130, 202}}
        def add_cluster(new_cluster)

            if empty?
                push( new_cluster )
                return
            end

            new_core_items = new_cluster.core_items        
            num_new_core_items = new_cluster.num_core_items

            # for performance
            pos = self.length - 1

            reverse_each do |cluster|

                num_core_items = cluster.num_core_items

                if num_core_items > num_new_core_items
                    # not found yet, keep going.
                    pos -= 1
                    next            
                elsif num_core_items < num_new_core_items
                    # insert new cluster after the current cluster
                    self.insert(pos+1, new_cluster)
                    return true
                else
                    core_items = cluster.core_items                
                    res = core_items.compare_to( new_core_items )

                    case res
                    when FreqItemset::COMPARE_SMALLER
                        # not found yet, keep going.
                        pos -= 1
                        next

                    when FreqItemset::COMPARE_LARGER
                        # insert new cluster After the current cluster
                        self.insert(pos+1, new_cluster)
                        return true

                    when FreqItemset::COMPARE_EQUAL
                        return false
                    end
                end

                pos -= 1
            end

            # add head
            self.insert(0, new_cluster)
        end

        # Add a list of new clusters to this collection.  The resultant clusters are sorted in ascending order
        def add_clusters(clusters)
            return if clusters.nil?

            clusters.each do |cluster|
                add_cluster(cluster)
            end    
        end

        # Find the clusters that has core item which is a subset of freq_itemset
        # No specific order in the resultant clusters.
        def find_subset_clusters(freq_itemset, clusters)

            num_freqitems = freq_itemset.length

            self.each do |cluster|

                return true if cluster.num_core_items > num_freqitems

                # the frequent itemset is a superset of the core itemset of the current cluster  
                core_items = cluster.core_items

                clusters << cluster if freq_itemset.contains_all(core_items)
            end

            return true
        end

        # Find the clusters that has core item which is a superset of freq_itemset
        # No specific order in the resultant clusters.
        def find_superset_clusters(freq_itemset, clusters)

            num_freqitems = freq_itemset.length

            self.each do |cluster|
                next if cluster.num_core_items < num_freqitems

                # the core itemset of the current cluster is a superset of the frequent itemset
                core_items = cluster.core_items

                clusters << cluster if core_items.contains_all(freq_itemset)
            end
        end

        # Retain the itemset that has k items in it
        def retain_k_itemsets(k)
            self.delete_if do |cluster|
                cluster.num_core_items != k
            end    
        end

        # 
        def remove_larger_than_k_itemsets(k)    
            self.delete_if do |cluster|
                cluster.num_core_items > k
            end
        end

    end
end