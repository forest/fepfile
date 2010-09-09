module FEPFileSpecification
  class TransactionDetailRecord
    include ActiveModel::Validations

    attr_accessor :receiver_id, :routing_number, :account_type, :account_number, :effective_date,
                  :credit_or_debit_flag, :amount, :transaction_id

    validates_presence_of :receiver_id, :routing_number, :account_type, :account_number, :effective_date,
                          :credit_or_debit_flag, :amount

    validates_length_of :receiver_id, :within => 1..15
    validates_format_of :receiver_id, :with => /^[a-zA-Z0-9]*$/, :message => 'must be Alphanumeric'
    
    validates_length_of :routing_number, :is => 9
    validates_length_of :account_number, :within => 5..17
    validates_numericality_of :routing_number, :account_number
    
    # validates_length_of :account_type, :is => 3
    validates_format_of :account_type, :with => /^(DDA|SAV)$/, :message => 'must be DDA or SAV'

    # validates_length_of :effective_date, :is => 8
    validates_format_of :effective_date, :with => /^(19[0-9]{2}|2[0-9]{3})(0[1-9]|1[012])([123]0|[012][1-9]|31)$/, :message => "does not match YYYYMMDD"

    validates_format_of :credit_or_debit_flag, :with => /^[CD]$/, :message => 'must be C or D'
    
    validates_format_of :amount, :with => /^\d{1,8}\.\d\d$/, :message => 'does not match $$$$$$$$.cc'
    
    validates_length_of :transaction_id, :within => 0..15, :allow_blank => true
    validates_format_of :transaction_id, :with => /^[a-zA-Z0-9]*$/, :message => 'must be Alphanumeric'

    # Construct a new FEPFileSpecification::TransactionDetailRecord with parameters (see below)
    # 
    # ==== Parameters
    # +receiver_id+::                 This key matches the transaction back to the customer.
    #                                 (Alphanumeric)
    # +routing_number+::              The Routing & Transit number of the financial institution where 
    #                                 the Receiver has his or her account. (Numeric)
    # +account_type+::                This field should contain the type of account, ‘DDA’ if the 
    #                                 account is a demand deposit account (i.e., checking, money market) 
    #                                 or ‘SAV’ if the account is a savings account.
    # +account_number+::              This field should contain the number of the Receiver’s account. 
    #                                 It is very important that this account number be left-justified 
    #                                 and padded with spaces id it is less than 17 characters.
    # +effective_date+::              The date the transaction should become effective, in other words, 
    #                                 the date the transaction should be credited to or debited 
    #                                 from the Receiver’s account. (YYYYMMDD)
    # +credit_or_debit_flag+::        This field should contain a ‘C’ it the amount is a credit or ‘D’ 
    #                                 if the amount is a debit to the Receiver’s account.
    # +amount+::                      The amount to be credited to or debited from the Receiver’s account.
    # +transaction_id+::              This field can be used to identify a single transaction to the 
    #                                 Originator. For instance, if an insurance company is creating two 
    #                                 debits, one for health insurance and one for auto insurance, it 
    #                                 may specify the different account numbers for the different insurance
    #                                 policies in this field. This is also an override to the 
    #                                 Receiver ID field. (Alphanumeric)
    def initialize(attributes = {})
      @receiver_id                = attributes[:receiver_id]
      @routing_number             = attributes[:routing_number]
      @account_type               = attributes[:account_type]
      @account_number             = attributes[:account_number]
      @effective_date             = attributes[:effective_date]
      @credit_or_debit_flag       = attributes[:credit_or_debit_flag]
      @amount                     = attributes[:amount]
      @transaction_id             = attributes[:transaction_id]
    end

    def to_s
      raise ValidationError, errors.full_messages unless valid?
      
      sprintf("TD000%-15s%s%s%17s%s%s%11s%-15s#{'0'*16}",
              receiver_id,
              routing_number,
              account_type,
              account_number,
              effective_date,
              credit_or_debit_flag,
              amount,
              transaction_id).gsub(' ', '0')
    end
  end
end
