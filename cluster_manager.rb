
require_relative 'cluster_warehouse'

class ClusterManager

    attr_reader :cluster_warehouse, :cluster_support

    def initialize
        @cluster_warehouse = ClusterWarehouse.new
    end

    def make_clusters(documents, global_freqitemsets, cluster_support)
        return false if documents.nil? || global_freqitemsets.nil? || global_freqitemsets.empty?
        
        @documents = documents
        @cluster_support = cluster_support
        
        puts "*** Adding clusters to warehouse"
        return false unless @cluster_warehouse.add_clusters(global_freqitemsets)
        
        puts "#{global_freqitemsets.length} clusters are constructed"
        
        puts "*** Constructing initial clusters"

        # Assign documents to cluster (initial clustering)
        construct_initial_clusters
        
        puts "*** Computing frequent one itemsets for initial clusters"

        # Compute the frequent 1-itemsets for each cluster
        # Maintain the cluster support for each frequent item in the cluster
        compute_freq_one_itemsets(false, cluster_support)
        
        # Clear all the documents in all the clusters in the Warehouse
        return false unless remove_all_documents
        
        puts "*** Constructing clusters based on scores"
        return false unless construct_score_clusters
        
        # Recompute the frequent 1-itemests for each cluster
        puts "*** Computing frequent one itemsets for clusters"
        compute_freq_one_itemsets(true, cluster_support)
        
        return true
    end
    
    # Given a list of potential clusters, get the highest score cluster that
    # suits the given DocVector.  Note: DocVector can be either a vector for
    # a document or a vector (frequencies) for the whole cluster.
    #
    # Why does this function need a pointer to the clusterWH? Because we need
    # that in the score calcuation function.  See the comments in score function.
    def get_highest_score_cluster(doc_vector, potential_clusters)
        raise 'error' if doc_vector.nil? || potential_clusters.nil?
        
        target_cluster = nil
        
        max_score = -Float::INFINITY
        
        # Scan through each cluster
        potential_clusters.each do |cluster|
        
            # compute the score
            score = calculate_cluster_score_v1(doc_vector, cluster)
            
            if score > max_score
                target_cluster = cluster
                max_score = score
            end
            
        end
        
        return target_cluster    
    end
    
    # Calculate the similarity between two clusters.
    # Idea is from F-Measure.
    def calculate_inter_similarity(cluster1, cluster2, inter_sim)
        sum = 0
        inter_sim = 0.0
        
        occurences1 = DocVector.new(cluster1.occurences.length, 0)
        occurences2 = DocVector.new(cluster1.occurences.length, 0)
        
        cluster1.compute_tree_children_occurences(occurences1)
        score1 = calculate_cluster_score_v1(occurences1, cluster2)
        
        sum = occurences1.inject{|res, x| res + x }
        
        # calculate similarity by normalizing the score
        score1 = sum == 0.0 ? 0.0 : score1.to_f / sum
        
        cluster2.compute_tree_children_occurences(occurences2)
        score2 = calculate_cluster_score_v1(occurences2, cluster1)
        
        sum = occurences2.inject{|res, x| res + x }
        
        # calculate similarity by normalizing the score
        score2 = sum == 0.0 ? 0.0 : score2.to_f / sum
        
        # negative inter-similarity?
        both_negative = ( score1 < 0 )
        
        negative = false
        
        if score1 < 0
            score1 *= -1.0
            negative = true
        end
        
        if score2 < 0
            score2 *= -1.0
            negative = true
        end
        
        # geometric mean
        inter_sim = ( score1 * score2 ) ** 0.5
        
        inter_sim *= -1.0 if negative
        inter_sim *= 2.0 if both_negative        
    end
    
    # Calculate the socre of cluster1 against cluster2's frequent 1-itemsets.
    # It is possible that the returned score is < 0.
    def calculate_inter_score(cluster1, cluster2, inter_score)
        inter_score = 0.0
        
        # initialize the occurences1        
        occurences1 = DocVector.new( cluster1.occurences.length, 0 )
        
        # compute occurences of cluster1 including its children
        cluster1.compute_tree_children_occurences(occurences1)
        
        # calculate the score against cluster2
        inter_score = calculate_cluster_score_v1(occurences1, cluster2)
    end
    
private
    
    # Construct the initial clusters based on the presented frequent items in the document
    def construct_initial_clusters
        start_global = Time.now
        timers = Array.new(4,0)        
        
        @documents.each do |document|        
            start = Time.now        
            # get the appeared items in the document
            present_freq_items = document.doc_vector.get_present_items(true)            
            timers[1] += (Time.now - start)
            
            start = Time.now
            covered_clusters = Clusters.new
            # get all clusters that can cover this doc
            @cluster_warehouse.find_covered_clusters(present_freq_items, covered_clusters)
            timers[2] += (Time.now - start)
            
            start = Time.now
            # assign doc to all the covered clusters
            assign_doc_to_clusters(document, covered_clusters)
            timers[3] += (Time.now - start)
        end
        
        timers[0] = Time.now - start_global
        
        puts "Duration: #{timers.inspect}"
    end
    
    # Assign the document to the given clusters.
    def assign_doc_to_clusters(document, clusters)    
        clusters.each do |cluster|
            cluster.add_document(document)
        end
    end
    
    # Compute the frequent 1-itemsets for each cluster.
    # If include_potencial_children == TRUE, then include all its potential children;
    # otherwise, compute the frequent 1-itemset for each cluster individually.
    def compute_freq_one_itemsets(include_potencial_children, cluster_support)
    
        all_clusters = @cluster_warehouse.all_clusters
        
        all_clusters.each_with_index do |cluster, j|
            frequencies = cluster.frequencies
            
            domain_frequencies = DocVector.new
            domain_frequencies.concat(frequencies)
            
            # number of documents in this cluster and its children
            num_docs = cluster.num_documents

            compute_potential_children_frequencies(cluster.core_items, domain_frequencies, num_docs) if include_potencial_children

            # compute the frequent 1-itemsets for this cluster based on this domain frequencies
            cluster.calculate_freq_one_itemsets(domain_frequencies, num_docs, cluster_support)
        end
    end
    
    # Compute the potential children frequencies
    # input: resultFrequencies should contain the parent node frequencies
    # input: numDocs should contains number of documents in the parent node
    # output: resultFrequencies will contain the result of adding up all frequencies 
    # from all potential children AND the parent.
    # output: numDocs will contain the total number documents in parent and children
    def compute_potential_children_frequencies(core_items, domain_frequencies, num_docs)
    
        children_clusters = Clusters.new
    
        # get all the children clusters
        @cluster_warehouse.find_potencial_children(core_items, children_clusters)
        
        # add up all frequencies in these children
        add_up_cluster_frequencies(children_clusters, domain_frequencies, num_docs)
    end
    
    # Remove all the documents in the Cluster Warehouse
    def remove_all_documents
    
        all_clusters = @cluster_warehouse.all_clusters
        
        all_clusters.each do |cluster|
            cluster.remove_all_documents
        end
        
        @cluster_warehouse.clear_dangling_documnents                
    end
    
    # Construct clusters based on score function
    def construct_score_clusters

        @documents.each do |document|
        
            doc_vector = document.doc_vector
        
            # get the appeared items in the document
            present_items = doc_vector.get_present_items(true)
            
            if present_items.empty?
                # this doc contains no frequent items, add it to dangling array
                @cluster_warehouse.add_dangling_document(document)

                next
            end
            
            covered_clusters = Clusters.new
            
            # get all clusters that can cover this doc
            @cluster_warehouse.find_covered_clusters(present_items, covered_clusters)
            
            raise 'error' if covered_clusters.empty?
            
            # get the highest score cluster
            high_score_cluster = get_highest_score_cluster(doc_vector, covered_clusters)
            
            raise 'error' if high_score_cluster.nil?
            
            # assign doc to all the target cluster
            high_score_cluster.add_document(document)
        
        end

    end
    
    # Calculate the score of a doc against a cluster.
    # Version 1: Score = ClusterFreqItems - ClusterNonFreqItems
    # 
    # Why does this function need a pointer to the clusterWH? Because we need
    # to retrieve the GlobalSupport for the non-frequent item from WH.
    # 
    # The reason that we store the GlobalSupport in the WH is just for efficiency
    # and completeness.  ClusterMgr does not need to deal with the DocMgr.
    def calculate_cluster_score_v1(doc_vector, cluster)
        
        score = 0.0
        
        # get the cluster's core and frequent items
        core_freq_itemset = ClusterFreqItemset.new
        cluster.core_items.each { |item| core_freq_itemset.add_freqitem(item) }
        cluster.freqitems.each { |item| core_freq_itemset.add_freqitem(item) }
        
        # scan through each frequent item in the document vector
        doc_vector.each_with_index do |frequency, item_id|
            next if frequency == 0
            
            freqitem = core_freq_itemset.get_freqitem(item_id)
            
            unless freqitem.nil?
                # add score --> n(x) * ClusterSupport(x)
                cluster_sup = freqitem.cluster_support
                
                raise 'error' if cluster_sup < 0 || cluster_sup > 1
                
                score += frequency * cluster_sup
            else
                # deduct score --> n(x') * GlobalSupport(x')
                infreq_sup = @cluster_warehouse.get_frequent_item_global_support(item_id)
                
                raise 'error' if infreq_sup < 0 || infreq_sup > 1
                
                score -= frequency * infreq_sup
            end            
        end
        
        return score
    end
    
    def add_up_cluster_frequencies(clusters, result_vector, num_docs)
        clusters.each do |cluster|        
            result_vector.add_up(cluster.frequencies)
        end
    end

end