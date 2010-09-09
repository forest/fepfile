require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'fileutils'

describe "FEPFile" do
  context ".new" do
    it "does create an invalid object with nothing set" do
      FEPFileSpecification::FEPFile.new.valid?.should be_false
    end
  end
  
  context ".valid?" do
    file = FEPFileSpecification::FEPFile.new

    it "should be valid if a FileHeaderRecord and one or more TransactionDetailRecords are set" do
      fhr = FEPFileSpecification::FileHeaderRecord.new( "2283333011",
                                                        :company_discretionary_data => "ThisIsMyCompany")
      file.file_header_record = fhr
      
      tdr = FEPFileSpecification::TransactionDetailRecord.new(:receiver_id => 'RECEIVERID',
                                                              :routing_number => '123456789',
                                                              :account_type => 'DDA',
                                                              :account_number => '1234509876',
                                                              :effective_date => Time.now.strftime('%Y%m%d'),
                                                              :credit_or_debit_flag => 'D',
                                                              :amount => '12.75',
                                                              :transaction_id => 'TRANSACTIONID')
      file.add_transaction_detail_record(tdr)

      file.valid?.should be_true
    end
  end
  context ".file_comment_record" do
    file = FEPFileSpecification::FEPFile.new

    it "should raise InvalidTypeError if parameter is not a FileCommentRecord" do
      lambda { file.file_comment_record = "junk" }.should raise_error(FEPFileSpecification::InvalidTypeError)
    end
    
    it "should return nil if not set" do
      file.file_comment_record.should be_nil
    end
  end
  
  context ".file_header_record" do
    file = FEPFileSpecification::FEPFile.new

    it "should raise InvalidTypeError if parameter is not a FileHeaderRecord" do
      lambda { file.file_header_record = "junk" }.should raise_error(FEPFileSpecification::InvalidTypeError)
    end    

    it "should return nil if not set" do
      file.file_header_record.should be_nil
    end
  end
  
  context ".add_transaction_detail_record" do
    file = FEPFileSpecification::FEPFile.new

    it "should raise InvalidTypeError if parameter is not a TransactionDetailRecord" do
      lambda { file.add_transaction_detail_record("junk") }.should raise_error(FEPFileSpecification::InvalidTypeError)
    end

    it "does increment the number of tansaction detail records" do
      start_count = file.transaction_detail_records.length
      
      tdr = FEPFileSpecification::TransactionDetailRecord.new( :receiver_id => 'RECEIVERID',
                                                  :routing_number => '123456789',
                                                  :account_type => 'DDA',
                                                  :account_number => '1234509876',
                                                  :effective_date => Time.now.strftime('%Y%m%d'),
                                                  :credit_or_debit_flag => 'D',
                                                  :amount => '12.75',
                                                  :transaction_id => 'TRANSACTIONID')
      file.add_transaction_detail_record(tdr)
      
      file.transaction_detail_records.length.should == start_count + 1
    end
  end
  
  context ".transaction_summary_record" do
    context "without transaction detail records" do
      file = FEPFileSpecification::FEPFile.new

      it "should return nil" do
        file.transaction_summary_record.should be_nil
      end
    end

    context "with transaction detail records" do
      file = FEPFileSpecification::FEPFile.new

      tdr1 = FEPFileSpecification::TransactionDetailRecord.new(
        :receiver_id => "RECEIVERID1",
        :routing_number => '123456789',
        :account_type => 'DDA',
        :account_number => '1234509876',
        :effective_date => Time.now.strftime('%Y%m%d'),
        :credit_or_debit_flag => 'D',
        :amount => '12.75',
        :transaction_id => 'TRANSACTIONID')
      file.add_transaction_detail_record(tdr1)

      tdr2 = FEPFileSpecification::TransactionDetailRecord.new(
        :receiver_id => "RECEIVERID2",
        :routing_number => '123456789',
        :account_type => 'SAV',
        :account_number => '1234509876',
        :effective_date => Time.now.strftime('%Y%m%d'),
        :credit_or_debit_flag => 'D',
        :amount => '34.09',
        :transaction_id => 'TRANSACTIONID')
      file.add_transaction_detail_record(tdr2)

      tdr3 = FEPFileSpecification::TransactionDetailRecord.new(
        :receiver_id => "RECEIVERID3",
        :routing_number => '123456789',
        :account_type => 'DDA',
        :account_number => '1234509876',
        :effective_date => Time.now.strftime('%Y%m%d'),
        :credit_or_debit_flag => 'C',
        :amount => '27.21',
        :transaction_id => 'TRANSACTIONID')
      file.add_transaction_detail_record(tdr3)
      
      it "should return a TransactionSummaryRecord" do
        file.transaction_summary_record.should_not be_nil
        file.transaction_summary_record.should be_kind_of(FEPFileSpecification::TransactionSummaryRecord)
      end

      it "should have expected values" do
        file.transaction_summary_record.total_transactions.should == 3
        file.transaction_summary_record.total_debits.should == 2
        file.transaction_summary_record.total_debits_amount.should == 46.84
        file.transaction_summary_record.total_credits.should == 1
        file.transaction_summary_record.total_credits_amount.should == 27.21
        file.transaction_summary_record.total_dollar_ammount.should == 74.05
      end
    end
    
  end
  
  context ".save" do
    save_path = './tmp'
    file_name = 'fepfile_test.txt'
    full_path = "#{save_path}/#{file_name}"        
    FileUtils.mkpath('./tmp')

    context "with invalid FEPFile" do
      file = FEPFileSpecification::FEPFile.new

      it "should raise a ValidationError if it is not valid" do
        FileUtils.rm full_path, :force => true
        lambda {
          file.save(save_path, file_name)
        }.should raise_error(FEPFileSpecification::ValidationError)
        File.exist?(full_path).should be_false
      end
    end
    
    context "with valid FEPFile" do
      file = FEPFileSpecification::FEPFile.new
      
      fch = FEPFileSpecification::FileCommentRecord.new("This Is My Very Cool Comment")
      file.file_comment_record = fch

      fhr = FEPFileSpecification::FileHeaderRecord.new( "2283333011",
                                                        :company_discretionary_data => "This Is My Company")
      file.file_header_record = fhr

      tdr1 = FEPFileSpecification::TransactionDetailRecord.new(
        :receiver_id => "RECEIVERID1",
        :routing_number => '123456789',
        :account_type => 'DDA',
        :account_number => '1234509876',
        :effective_date => Time.now.strftime('%Y%m%d'),
        :credit_or_debit_flag => 'D',
        :amount => '12.75',
        :transaction_id => 'TRANSACTIONID')
      file.add_transaction_detail_record(tdr1)

      tdr2 = FEPFileSpecification::TransactionDetailRecord.new(
        :receiver_id => "RECEIVERID2",
        :routing_number => '123456789',
        :account_type => 'SAV',
        :account_number => '1234509876',
        :effective_date => Time.now.strftime('%Y%m%d'),
        :credit_or_debit_flag => 'D',
        :amount => '34.09',
        :transaction_id => 'TRANSACTIONID')
      file.add_transaction_detail_record(tdr2)

      tdr3 = FEPFileSpecification::TransactionDetailRecord.new(
        :receiver_id => "RECEIVERID3",
        :routing_number => '123456789',
        :account_type => 'DDA',
        :account_number => '1234509876',
        :effective_date => Time.now.strftime('%Y%m%d'),
        :credit_or_debit_flag => 'C',
        :amount => '27.21',
        :transaction_id => 'TRANSACTIONID')
      file.add_transaction_detail_record(tdr3)
      
      it "should create a file called 'fepfile_test.txt' with each line being 100 characters long" do
        FileUtils.rm full_path, :force => true
        file.save(save_path, file_name)
        File.exist?(full_path).should be_true
        
        File.open(full_path).each do |line|
          line.strip.length.should == 100
        end
      end
    end
    
    context "with valid FEPFile from convenience methods" do
      file = FEPFileSpecification::FEPFile.new
      file.set_file_comment("This Is My Very Cool Comment")
      file.set_file_header("2283333011", "MYCOMPANY")
      file.add_transaction("RECEIVERID1",'123456789','DDA','1234509876',Time.now.strftime('%Y%m%d'),'D','12.75','TRANSACTIONID')
      file.add_transaction("RECEIVERID2",'123456789','SAV','1234509876',Time.now.strftime('%Y%m%d'),'D','34.09','TRANSACTIONID')
      file.add_transaction("RECEIVERID3",'123456789','DDA','1234509876',Time.now.strftime('%Y%m%d'),'C','27.21','TRANSACTIONID')
      
      it "should create a file called 'fepfile_test.txt' with each line being 100 characters long" do
        FileUtils.rm full_path, :force => true
        
        file.file_comment_record.should_not be_nil
        file.file_header_record.should_not be_nil
        file.transaction_detail_records.size.should == 3
        file.transaction_summary_record.should_not be_nil
        
        file.save(save_path, file_name)
        File.exist?(full_path).should be_true
        
        File.open(full_path).each do |line|
          line.strip.length.should == 100
        end
      end
    end
    
  end

end
