require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "TransactionDetailRecord" do
  date      = Time.now.strftime('%Y%m%d')
  valid_tdr = "TD000RECEIVERID00000123456789DDA00000001234509876#{date}D00000012.75TRANSACTIONID000000000000000000"

  context ".new" do
  end

  context ".valid?" do
    it "should be false" do
      tdr = FEPFileSpecification::TransactionDetailRecord.new( :receiver_id => 'RECEIVER ID',
                                                  :routing_number => '123456789X',
                                                  :account_type => 'DxA',
                                                  :account_number => '1234509876AAAAAAAAAAAA',
                                                  :effective_date => date,
                                                  :credit_or_debit_flag => 'P',
                                                  :amount => '$12.75',
                                                  :transaction_id => 'TRANSACTION ID IS VERY COOL')
      tdr.valid?.should be_false
      tdr.errors.length.should == 7
    end
  end
  
  context ".to_s" do
    it "does work" do
      tdr = FEPFileSpecification::TransactionDetailRecord.new( :receiver_id => 'RECEIVERID',
                                                  :routing_number => '123456789',
                                                  :account_type => 'DDA',
                                                  :account_number => '1234509876',
                                                  :effective_date => date,
                                                  :credit_or_debit_flag => 'D',
                                                  :amount => '12.75',
                                                  :transaction_id => 'TRANSACTIONID')
      tdr.to_s[0...5].should == "TD000"
      tdr.to_s.length.should == 100
      tdr.to_s.should == valid_tdr
      tdr.valid?.should be_true
    end
    
    it "does raise a ValidationError if something is invalid" do
      tdr = FEPFileSpecification::TransactionDetailRecord.new
      lambda { tdr.to_s }.should raise_error(FEPFileSpecification::ValidationError)
    end    
  end
end
