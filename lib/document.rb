
class Document

    attr_reader :doc_vector, :name, :link

    def initialize(doc_vector, name, link)
        @doc_vector = doc_vector
        @name = name
        @link = link
    end

end