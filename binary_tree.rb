
class BinaryTreeNode

    attr_reader :word
    attr_accessor :left_child, :right_child, :balance, :freq, :value

    def initialize(word = '', value = nil)
        @word = word
        @value = value
        
        @balance = 0
        @freq = 1
        
        @right_child = nil
        @left_child = nil
    end

end

class BinaryTree

    attr_reader :root

    def initialize
        @root = nil    
    end
    
    # virtual
    def insert(word, value) 
    end
    
    def print(subtree_root)
    
        if subtree_root != nil
            print(subtree_root.left_child)
            
            puts "(#{subtree_root.word}, #{subtree_root.value})"
            
            print(subtree_root.right_child)            
        end
    end
    
private

    # pp: parent of possible node
    # pn: possible node
    # start: start node
    # end: end node

    def update_balance(word, pp, pn, start_node, end_node, super_root)
    
        current_node = start_node
        
        while current_node != end_node do
        
            if word < current_node.word            
                current_node.balance = -1
                current_node = current_node.left_child            
            else
                current_node.balance = 1
                current_node = current_node.right_child            
            end

        end
        
        aux = (word < pn.word) ? -1 : 1
        
        if pn.balance == 0
            pn.balance = aux
            @root = super_root.left_child
            return
        end
        
        if pn.balance == -aux
            pn.balance = 0
            @root = super_root.left_child
            return            
        end

        if aux == -1
            rearrange_left_subtree(start_node, pp, pn)
        else
            rearrange_right_subtree(start_node, pp, pn)
        end
        
        @root = super_root.left_child
    end
    
    def rearrange_left_subtree(start, pp, pn)
    
        if start.balance == -1
            if pp.left_child == pn
                pp.left_child = start
            else
                pp.right_child = start
            end
            
            aux = start.right_child
            start.right_child = pn
            pn.left_child = aux
            
            pn.balance = 0
            start.balance = 0            
        else        
            aux = start.right_child
            aux_r = aux.right_child
            aux_l = aux.left_child
            
            if pp.left_child == pn
                pp.left_child = aux
            else
                pp.right_child = aux
            end
            
            aux.left_child = start
            aux.right_child = pn
            start.right_child = aux_l
            pn.left_child = aux_r
            
            start.balance = 0
            pn.balance = 0
            
            pn.balance = 1 if aux.balance < 0
            
            start.balance = -1 if aux.balance > 0
            
            aux.balance = 0        
        end
    end
    
    def rearrange_right_subtree(start, pp, pn)
    
        if start.balance == 1        
            if pp.left_child == pn
                pp.left_child = start
            else
                pp.right_child = start
            end
            
            aux = start.left_child
            start.left_child = pn
            pn.right_child = aux
            
            pn.balance = 0
            start.balance = 0        
        else
            aux = start.left_child
            aux_r = aux.right_child
            aux_l = aux.left_child
            
            if pp.left_child == pn
                pp.left_child = aux
            else
                pp.right_child = aux
            end
            
            aux.right_child = start
            aux.left_child = pn
            start.left_child = aux_r
            pn.right_child = aux_l
            
            start.balance = 0
            pn.balance = 0
            
            pn.balance = -1 if aux.balance > 0
            
            start.balance = 1 if aux.balance < 0
            
            aux.balance = 0
        end

    end

end