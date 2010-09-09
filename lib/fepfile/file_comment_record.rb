module FEPFileSpecification
  class FileCommentRecord
    include ActiveModel::Validations
    
    validates_length_of :comment, :within => 0..95, :allow_nil => true
    validates_format_of :comment, :with => /^[a-zA-Z0-9\s]*$/
    
    attr_accessor :comment
    
    # Construct a new FEPFileSpecification::FileCommentRecord with an optional +comment+
    # The +comment+ must be alphanumeric and at most 95 characters long 
    def initialize(comment=nil)
      @comment = comment
    end

    def to_s
      raise ValidationError, self.errors.full_messages unless valid?
      
      sprintf("XX000%s", comment.ljust(95, '0'))
    end
  end
end
