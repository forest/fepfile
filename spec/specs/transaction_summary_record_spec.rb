require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "TransactionSummaryRecord" do
  valid_debit_credit_tsr  = "TS0000001970000001757.760001650000001325.640000320000000432.1200000000000000000000000000000000000000"
  valid_debit_tsr         = "TS0000001650000001325.640001650000001325.640000000000000000.0000000000000000000000000000000000000000"

  context ".new" do
  end

  context ".to_s" do
    it "does raise a ValidationError if something is invalid" do
      tsr = FEPFileSpecification::TransactionSummaryRecord.new(:total_debits => "165",
                                                  :total_debits_amount => "$1325.64")
      lambda { tsr.to_s }.should raise_error(FEPFileSpecification::ValidationError)
    end        
  end
  
  context "with credits and debits" do
    context ".to_s" do
      it "does format both credit and debit" do
        tsr = FEPFileSpecification::TransactionSummaryRecord.new(:total_debits => 165,
                                                    :total_debits_amount => 1325.64,
                                                    :total_credits => 32,
                                                    :total_credits_amount => 432.12)
        tsr.to_s[0...5].should == "TS000"
        tsr.to_s.length.should == 100
        tsr.total_transactions.should == 197
        tsr.total_dollar_ammount.should == 1757.76
        tsr.to_s.should == valid_debit_credit_tsr
      end
    end
  end
  
  context "with only debits" do
    context ".to_s" do
      it "does format just debit" do
        tsr = FEPFileSpecification::TransactionSummaryRecord.new(:total_debits => 165,
                                                    :total_debits_amount => 1325.64)
        tsr.to_s[0...5].should == "TS000"
        tsr.to_s.length.should == 100
        tsr.total_transactions.should == 165
        tsr.total_dollar_ammount.should == 1325.64
        tsr.to_s.should == valid_debit_tsr
      end
    end
  end
  
end
