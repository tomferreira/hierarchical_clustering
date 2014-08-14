
require_relative 'binary_tree'

class VocalularyTree < BinaryTree

    def insert(word, value)
    
        #puts "Insering word '#{word}' ..."
    
        if @root.nil?
            @root = BinaryTreeNode.new(word, value)
            return
        end
        
        # used as the superRoot of the real root
        super_root = BinaryTreeNode.new
        super_root.left_child = @root
        
        # in the whole process of insertion, this pointer always points to the node that probably needs rearrangement after insertion        
        pn = current_node = @root
        
        # parent of possible node
        pp = super_root
        
        # if the word to insert already in the tree
        if word == current_node.word
        
            if value != current_node.value
                current_node.freq += 1
                current_node.value = value
            end
            
            return nil
        end
        
        current_child = (word < current_node.word) ? current_node.left_child : current_node.right_child
        
        # find a suitable position to insert word a
        while current_child != nil do
        
            if current_child.balance != 0
                pn = current_child
                pp = current_node
            end
            
            current_node = current_child
            
            if word == current_node.word
                
                if value != current_node.value
                    current_node.freq += 1
                    current_node.value = value
                end
                
                return nil            
            end
            
            current_child = (word < current_node.word) ? current_node.left_child : current_node.right_child
        end
        
        new_node = BinaryTreeNode.new(word, value)
        
        if word < current_node.word
            current_node.left_child = new_node
        else
            current_node.right_child = new_node
        end
        
        start_node = (word < pn.word) ? pn.left_child : pn.right_child
        
        update_balance(word, pp, pn, start_node, new_node, super_root)
    end

end