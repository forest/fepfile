require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "FileHeaderRecord" do
  date                              = Time.now.strftime('%Y%m%d')
  time                              = Time.now.strftime('%I%M')
  file_sequence_id                  = 'A'
  originator_id                     = '9780907020'
  company_discretionary_data_long   = "12345678901234567890+"
  company_discretionary_data_short  = "1234567890"
  company_entry_description_long    = "1234567890+"
  company_entry_description_short   = "12345"

  simple_valid_fhr = "FH000#{date}#{time}A9780907020000000000000000000000000000000000000000000000000000000000000000000000000"
  custom_valid_fhr = "FH000#{date}#{time}A9780907020DISCDATA000000000000MYCOMPANY0000000000000000000000000000000000000000000"

  context ".new" do
    it "does create a file_creation_date attr set to day file is created" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id)
      fhr.file_creation_date.should == date
    end

    it "does create a file_creation_time attr set to time file is created" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id)
      fhr.file_creation_time.should == time
    end
  end

  context ".valid?" do
    it "should be false with nil originator_id" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(nil)
      fhr.valid?.should be_false
    end

    it "should be true with just an originator_id and default file_sequence_id" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id)
      fhr.valid?.should be_true
    end

    it "should be false with non-numeric originator_id" do
      fhr = FEPFileSpecification::FileHeaderRecord.new("originator_id")
      fhr.valid?.should be_false
    end

    it "should be false with originator_id less than 10 digits" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(12345)
      fhr.valid?.should be_false
    end

    it "should be true with (A-Z) file_sequence_id" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id)
      ('A'..'Z').each do |id|
        fhr.file_sequence_id = id
        fhr.valid?.should be_true
      end
    end

    it "should be false with non-(A-Z) file_sequence_id" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id)
      [1, "A34D", 81, "AA", "0"].each do |id|
        fhr.file_sequence_id = id
        fhr.valid?.should be_false
      end
    end

    it "should be false with non-alphanumeric company_discretionary_data" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id, :company_discretionary_data => "This is Not C00l!")
      fhr.valid?.should be_false
    end
    
    it "should be false with company_discretionary_data over 20 characters" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id, :company_discretionary_data => company_discretionary_data_long)
      fhr.valid?.should be_false
    end

    it "should be true with company_discretionary_data equal to 20 characters" do
      company_discretionary_data_10 = company_discretionary_data_long[0...20]
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id, :company_discretionary_data => company_discretionary_data_10)
      fhr.valid?.should be_true
    end

    it "should be true with company_discretionary_data less than 20 characters" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id, :company_discretionary_data => company_discretionary_data_short)
      fhr.valid?.should be_true
    end

    it "should be false with non-alphanumeric company_entry_description" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id, :company_entry_description => "So C00l!")
      fhr.valid?.should be_false
    end

    it "should be false with company_entry_description over 10 characters" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id, :company_entry_description => company_entry_description_long)
      fhr.valid?.should be_false
    end

    it "should be true with company_entry_description equal to 10 characters" do
      company_entry_description_10 = company_entry_description_long[0...10]
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id, :company_entry_description => company_entry_description_10)
      fhr.valid?.should be_true
    end

    it "should be true with company_entry_description less than 10 characters" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id, :company_entry_description => company_entry_description_short)
      fhr.valid?.should be_true
    end
  end
  
  context ".to_s" do
    it "does return a string with length of 100" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id)
      fhr.to_s.length.should == 100
    end
    
    it "does include the Record ID and Reserved space" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id)
      fhr.to_s.length.should == 100
      fhr.to_s[0...5] == "FH000"
    end

    it "does pad the remaining space with zeros if needed" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id)
      fhr.to_s.length.should == 100
      fhr.to_s.should == simple_valid_fhr
    end
    
    it "does include the optional fields" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(originator_id,
                                          :file_sequence_id => file_sequence_id,
                                          :company_discretionary_data => "DISCDATA", 
                                          :company_entry_description => "MYCOMPANY")
      fhr.to_s.length.should == 100
      fhr.to_s.should == custom_valid_fhr
    end
    
    it "does raise a ValidationError if something is invalid" do
      fhr = FEPFileSpecification::FileHeaderRecord.new(nil)
      lambda { fhr.to_s }.should raise_error(FEPFileSpecification::ValidationError)
    end    
  end
  
end
