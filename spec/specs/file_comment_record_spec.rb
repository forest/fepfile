require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "FileCommentRecord" do
  one_hundred     = "07a13316123cf7ec72a6f2e344127592ebb4c3000cbbad729c8101bd043f21420f39ad6db3381111fdcbeda1dd1234567890"
  ninety_five     = "07a13316123cf7ec72a6f2e344127592ebb4c3000cbbad729c8101bd043f21420f39ad6db3381111fdcbeda1dd12345"
  twenty          = "12345678901234567890"
  fcr_ninety_five = "XX00007a13316123cf7ec72a6f2e344127592ebb4c3000cbbad729c8101bd043f21420f39ad6db3381111fdcbeda1dd12345"
  fcr_twenty      = "XX00012345678901234567890000000000000000000000000000000000000000000000000000000000000000000000000000"

  context ".new" do
    it "does accept an empty comment parameter" do
      fcr = FEPFileSpecification::FileCommentRecord.new
      fcr.comment.should be_nil
    end

    it "does accept comment parameter over 95 characters" do
      fcr = FEPFileSpecification::FileCommentRecord.new(one_hundred)
      fcr.comment.should == one_hundred
    end
    
    it "does accept comment parameter equal to 95 characters" do
      fcr = FEPFileSpecification::FileCommentRecord.new(ninety_five)
      fcr.comment.should == ninety_five
    end

    it "does accept comment parameter less than 95 characters" do
      fcr = FEPFileSpecification::FileCommentRecord.new(twenty)
      fcr.comment.should == twenty
    end
  end
  
  context ".valid?" do
    it "should be true with an empty comment" do
      fcr = FEPFileSpecification::FileCommentRecord.new
      fcr.valid?.should be_true
    end

    it "should be true with a comment of 95 characters" do
      fcr = FEPFileSpecification::FileCommentRecord.new(ninety_five)
      fcr.valid?.should be_true
    end

    it "should be true with a comment of less than 95 characters" do
      fcr = FEPFileSpecification::FileCommentRecord.new(twenty)
      fcr.valid?.should be_true
    end
    
    it "should be false with a comment over 95 characters" do
      fcr = FEPFileSpecification::FileCommentRecord.new(one_hundred)
      fcr.valid?.should be_false
    end
  end
  
  context ".to_s" do
    it "does return a string with length of 100" do
      fcr = FEPFileSpecification::FileCommentRecord.new(twenty)
      fcr.to_s.length.should == 100
    end
    
    it "does include the Record ID and Reserved space" do
      fcr = FEPFileSpecification::FileCommentRecord.new(twenty)
      fcr.to_s[0...5] == "XX000"
    end

    it "does pad the remaining space with zeros if needed" do
      fcr = FEPFileSpecification::FileCommentRecord.new(twenty)
      fcr.to_s.should == fcr_twenty
    end
    
    it "does not pad the remaining space with zeros if not needed" do
      fcr = FEPFileSpecification::FileCommentRecord.new(ninety_five)
      fcr.to_s.length.should == 100
      fcr.to_s.should == fcr_ninety_five
    end
    
    it "does raise a ValidationError if the comment is over 95 characters" do
      fcr = FEPFileSpecification::FileCommentRecord.new(one_hundred)
      lambda { fcr.to_s }.should raise_error(FEPFileSpecification::ValidationError)
    end
  end
end
