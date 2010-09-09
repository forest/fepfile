require 'money'

module FEPFileSpecification
  class TransactionSummaryRecord
    include ActiveModel::Validations

    attr_accessor :total_transactions, :total_debits, :total_debits_amount,
                  :total_credits, :total_credits_amount, :total_dollar_ammount

    validates_numericality_of :total_transactions, :total_debits, :total_debits_amount,
                              :total_credits, :total_credits_amount, :total_dollar_ammount
    
    # Construct a new FEPFileSpecification::TransactionDetailRecord with parameters (see below)
    # 
    # ==== Parameters
    # +total_debits+::                Total number of debit transactions.
    # +total_debits_amount+::         The sum of all of the debit dollar amounts.
    # +total_credits+::               Total number of credit transactions.
    # +total_credits_amount+::        The sum of all of the credit dollar amounts.
    def initialize(attributes = {})
      @total_debits               = attributes[:total_debits] || 0
      @total_debits_amount        = attributes[:total_debits_amount] || 0.0
      @total_credits              = attributes[:total_credits] || 0
      @total_credits_amount       = attributes[:total_credits_amount] || 0.0
      @total_transactions         = @total_debits.to_i + @total_credits.to_i
      @total_dollar_ammount       = (@total_debits_amount.to_money + @total_credits_amount.to_money).to_f
    end

    def to_s
      raise ValidationError, self.errors.full_messages unless valid?
      
      sprintf("TS000%6s%13.2f%6s%13.2f%6s%13.2f#{'0'*38}",
              total_transactions,
              total_dollar_ammount,
              total_debits,
              total_debits_amount,
              total_credits,
              total_credits_amount).gsub(' ', '0')
    end
  end
end
