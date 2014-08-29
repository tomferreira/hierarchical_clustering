

class TreeBuilder

    DC_INTERSIM_THRESHOLD = 0.0

    def initialize( cluster_manager )
        @cluster_manager = cluster_manager    
    end
    
    # Construct the cluster tree
    def build_tree
        cluster_warehouse = @cluster_manager.cluster_warehouse
        
        all_clusters = cluster_warehouse.all_clusters_reverse_order
        
        puts "*** Building the tree"

        all_clusters.each do |cluster|
            frequencies = cluster.frequencies
            
            result_occurences = DocVector.new(frequencies.length, 0)
            
            cluster.compute_tree_children_occurences(result_occurences)
            
            core_items = cluster.core_items
            
            # Experiment (FMeasure) shows that don't consider great...grandparents produces best result
            potential_parents = Clusters.new
            cluster_warehouse.find_potential_parents(false, core_items, potential_parents)
            
            # set root as its parent, and add it into root's children list
            if core_items.length == 1 || potential_parents.length == 0
                root = cluster_warehouse.tree_root
                root.add_tree_child(cluster)
                cluster.set_tree_parent(root)
            else
                # find as its parent who has the highest score from the potential parents set.                 
                target_cluster = @cluster_manager.get_highest_score_cluster(result_occurences, potential_parents)                
                raise 'error' if target_cluster.nil?
                
                target_cluster.add_tree_child(cluster)
                cluster.set_tree_parent(target_cluster)                
            end
        end
        
        # recompute the frequent 1-itemset based on tree children
        calculate_freq_onte_itemsets_using_tree_children
    end
    
    def remove_empty_clusters(remove_internal)
        puts "*** Removing empty clusters"
        
        cluster_warehouse = @cluster_manager.cluster_warehouse
        
        all_clusters = cluster_warehouse.all_clusters
        all_clusters_reversed = cluster_warehouse.all_clusters_reverse_order
        
        num_empty_pruned = 0
        num_empty_internal = 0
        
        all_clusters_reversed.each do |cluster|
        
            if cluster.num_documents == 0
                children = cluster.tree_children
                
                if children.length == 0
                    # remove this empty leaf node
                    parent = cluster.tree_parent
                    
                    # get siblings
                    siblings = parent.tree_children
                    
                    # remove from parents' children list
                    siblings.delete( cluster )
                    cluster.clear_tree_parent
                    
                    # remove from all clusters
                    all_clusters.delete( cluster )
                    
                    # TODO?                    
                    num_empty_pruned += 1
                elsif remove_internal
                    # this is an empty internal node
                    parent = cluster.tree_parent
                    
                    # move children up
                    children.each do |child|
                        parent.add_tree_child(child)
                        
                        child.set_tree_parent(parent)
                    end
                    
                    children.clear
                    
                    # get siblings
                    siblings = parent.tree_children
                    
                    # remove from parents' children list
                    siblings.delete( cluster )
                    cluster.clear_tree_parent
                    
                    # remove from all clusters
                    all_clusters.delete( cluster )
                    
                    # TODO?                    
                    num_empty_internal += 1
                end
            end
        
        end
        
        puts "#{num_empty_internal} internal empty clusters are pruned!"
        puts "#{num_empty_pruned} empty clusters are pruned!"        
    end
    
    def prune_children
        puts "*** Pruning children clusters based on inter-cluster similarity with parent"
        
        cluster_warehouse = @cluster_manager.cluster_warehouse

        all_clusters_reversed = cluster_warehouse.all_clusters_reverse_order
        
        return if all_clusters_reversed.length == 0
        
        num_pruned = 0
        num_total_pruned = 0
        
        all_clusters_reversed.each do |cluster|
            # skip leaf node
            next if cluster.tree_children.length == 0
            
            # merge children of this cluster
            prune_children2(cluster, 0.2, num_pruned)
            
            num_total_pruned += num_pruned
        end
        
        puts "#{num_total_pruned} children clusters are pruned!"
    end
    
    # Prune the tree based on inter-cluster similarity
    # kcluster = minimum # of clusters
    def inter_sim_prune(kclusters)
        puts "*** Pruning clusters based on inter-cluster similarity"
        
        cluster_warehouse = @cluster_manager.cluster_warehouse
        
        all_clusters_reversed = cluster_warehouse.all_clusters_reverse_order
        
        return if all_clusters_reversed.length == 0
        
        root = cluster_warehouse.tree_root
        
        num_siblings = num_parents = 0
        
        if kclusters == 0
            merge_children(root, false, kclusters, DC_INTERSIM_THRESHOLD, num_siblings, num_parents)
        else
            merge_children(root, false, kclusters, 0.0, num_siblings, num_parents)
        end
        
        raise 'error' if num_parents != 0
        
        puts "#{num_siblings} clusters at level 1 are merged with sibling!"
    end
    
    # Over prune clusters using inter-cluster similarity
    def inter_sim_over_prune(kclusters)
        return if kclusters <= 0
        
        puts "*** Over prune clusters to satisfy specified # of clusters"
        
        cluster_warehouse = @cluster_manager.cluster_warehouse
        
        # get all clusters list
        all_global_clusters = cluster_warehouse.all_clusters
        
        root = cluster_warehouse.tree_root
        
        # get all one item clusters
        all_clusters = root.tree_children
        
        num_clusters = all_clusters.length
        merged_count = 0
        num_min_docs = Float::INFINITY
        
        raise 'error' if num_clusters == 0
        
        victim = nil
        
        while num_clusters > kclusters && !all_clusters.empty?
            num_min_docs = Float::INFINITY
            
            all_clusters.each do |clusterX|
                if clusterX.num_documents_include_tree_children < num_min_docs
                    victim = clusterX
                    num_min_docs = clusterX.num_documents
                end
            end
            
            raise 'error' if victim.nil?
            
            all_clusters.delete(victim)
            
            # pick the most similar cluster from the rest of the list
            best = nil
            best_score = -Float::INFINITY
            
            all_clusters.each do |candidate|
                score = 0.0
                @cluster_manager.calculate_inter_score(victim, candidate, score)
                
                if score > best_score
                    best = candidate
                    best_score = score
                end
            end
            
            raise 'error' if best.nil?
            
            # merge them
            best.merge_cluster_prune_children(victim, all_global_clusters)
            
            merged_count += 1
            num_clusters -= 1
        end
        
        puts "#{merged_count} clusters at level 1 are merged!"
    end
    
private

    def calculate_freq_onte_itemsets_using_tree_children
        puts "*** Recomputing the frequent one itemsets using tree children"
        
        cluster_warehouse = @cluster_manager.cluster_warehouse
        
        all_clusters = cluster_warehouse.all_clusters
        
        all_clusters.each do |cluster|
            frequencies = cluster.frequencies
            
            cluster_frequencies = DocVector.new(frequencies.length, 0)
            cluster.compute_tree_children_frequencies(cluster_frequencies)
            
            num_total_docs = cluster.num_documents_include_tree_children            
            cluster.calculate_freq_one_itemsets(cluster_frequencies, num_total_docs, @cluster_manager.cluster_support)            
        end
    end
    
    def prune_children2(parent_cluster, min_inter_sim_threshold, num_pruned)
        num_pruned = 0
        
        children = parent_cluster.tree_children
        
        sims = Array.new(children.length, 0)
        clusters = Array.new(children.length, 0)
        
        idx = 0
        inter_sim = 0.0
        
        # compute inter-sim with each child
        children.each do |child|
            @cluster_manager.calculate_inter_similarity(parent_cluster, child, inter_sim)
            
            sims[idx] = inter_sim
            clusters[idx] = child
            idx += 1
        end
        
        all_clusters = @cluster_manager.cluster_warehouse.all_clusters

        # merge
        (0...idx).each do |i|
            next if sims[i] <= min_inter_sim_threshold
            
            parent_cluster.merge_cluster(clusters[i], all_clusters)
            num_pruned += 1
        end
    end
    
    # Merge the children of the given parent cluster based on inter-cluster
    # similarity. If kclusters == 0, then use min_intersim_threshold as a stopping criteria.
    def merge_children(parent_cluster, merge_parent, kclusters, min_intersim_threshold, num_merged_sibling, num_merged_parent)
        num_merged_sibling = num_merged_parent = 0
        
        children = parent_cluster.tree_children        
        num_children = children.length
        
        return if num_children <= kclusters
        
        unless merge_parent
            inter_similarities = Array.new( num_children * (num_children - 1) / 2, 0)
            positions1 = Array.new( num_children * (num_children - 1) / 2, 0)
            positions2 = Array.new( num_children * (num_children - 1) / 2, 0)            
        else
            inter_similarities = Array.new( num_children * (num_children - 1) / 2, 0)
            positions1 = Array.new( num_children * (num_children - 1) / 2 + num_children, 0)
            positions2 = Array.new( num_children * (num_children - 1) / 2 + num_children, 0)
        end
        
        count = 0
        
        # TODO: Rever performance!!!
        
        (0...children.length).each do |pos1|
            cluster1 = children[pos1]
            
            # compute inter-cluster similarity with each sibling
            inter_sim = 0.0
            
            (pos1+1...children.length).each do |pos2|
                cluster2 = children[pos2]
                
                @cluster_manager.calculate_inter_similarity(cluster1, cluster2, inter_sim)
                
                inter_similarities[count] = inter_sim
                positions1[count] = cluster1
                positions2[count] = cluster2
                
                count += 1
            end
            
            if merge_parent
                # compute inter-cluster similarity with parent
                @cluster_manager.calculate_inter_similarity(cluster1, parent_cluster, inter_sim)
                
                inter_similarities[count] = inter_sim
                positions1[count] = cluster1
                positions2[count] = parent_cluster
                
                count += 1
            end            
        end
        
        # find the clusters to be merged
        high_index = find_highest_inter_similarity(inter_similarities, count, min_intersim_threshold)
        
        while high_index != -1
            break if num_children <= kclusters
            
            cluster1 = positions1[high_index]
            cluster2 = positions2[high_index]
            
            # swap if necessary
            if cluster2 == parent_cluster || cluster1.num_documents_include_tree_children < cluster2.num_documents_include_tree_children
                cluster1, cluster2 = cluster2, cluster1
            end
            
            # merge cluster2 to cluster1
            cluster1.merge_cluster(cluster2, nil)
            
            num_children -= 1
            
            if cluster1 == parent_cluster
                num_merged_parent += 1
            else
                num_merged_sibling += 1
            end
            
            # cleanup inter-similarity of cluster2
            clean_similarity(cluster2, positions1, positions2, inter_similarities, count)
            
            # update the inter-similarity among clusters
            children.each do |cluster2|
                next if cluster2 == cluster1
                
                index = find_cluster_index(cluster1, positions1, cluster2, positions2, count)
                raise 'error' if index == -1
                
                inter_sim = 0
                @cluster_manager.calculate_inter_similarity(cluster1, cluster2, inter_sim)
                
                inter_similarities[index] = inter_sim
            end
            
            high_index = find_highest_inter_similarity(inter_similarities, count, min_intersim_threshold)
        end        
    end
    
    def find_highest_inter_similarity(inter_similarities, length, min_intersim_threshold)
        high_sim = min_intersim_threshold
        high_index = -1
        
        length.times do |i|
            if inter_similarities[i] > high_sim
                high_sim = inter_similarities[i]
                high_index = i
            end
        end
        
        return high_index
    end
    
    
    def find_cluster_index(cluster1, positions1, cluster2, positions2, length)

        length.times do |i|        
            if ( cluster1 == positions1[i] && cluster2 == positions2[i] ) || ( cluster1 == positions2[i] && cluster2 == positions1[i] )
                return i
            end                    
        end
        
        return -1
    end
    
    def clean_similarity(cluster, positions1, positions2, inter_similarities, length)
        length.times do |i|
            inter_similarities[i] = -Float::INFINITY if positions1[i] == cluster || positions2[i] == cluster
        end
    end
end