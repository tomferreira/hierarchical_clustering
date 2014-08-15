

class Document

    attr_reader :doc_vector, :name

    def initialize(doc_vector, name)
        @doc_vector = doc_vector
        @name = name
    end

end