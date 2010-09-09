require 'active_model'
require 'money'
require 'fepfile/file_comment_record'
require 'fepfile/file_header_record'
require 'fepfile/transaction_addenda_record'
require 'fepfile/transaction_detail_record'
require 'fepfile/transaction_summary_record'

module FEPFileSpecification
  
  class InvalidTypeError < StandardError 
  end

  class ValidationError < StandardError 
  end
  
  class FEPFile
    attr_accessor :file_comment_record, :file_header_record
    attr_reader :transaction_detail_records, :transaction_summary_record
    
    def initialize
      @file_comment_record = nil
      @file_header_record = nil
      @transaction_detail_records = []
      @transaction_summary_record = nil
    end
    
    def valid?
      ( file_comment_record ? file_comment_record.valid? : true &&
        file_header_record && file_header_record.valid? &&
        !transaction_detail_records.empty? &&
        transaction_detail_records.find { |record| !record.valid? }.nil? )
    end
    
    # set the file comment 
    def set_file_comment(comment)
      self.file_comment_record = FileCommentRecord.new(comment)
    end
    
    # set the file header
    def set_file_header(originator_id, company_entry_description, file_sequence_id=nil)
      self.file_header_record = FileHeaderRecord.new( originator_id,
                                                      :company_entry_description => company_entry_description,
                                                      :file_sequence_id => file_sequence_id)
    end
    
    # add a transaction
    def add_transaction(receiver_id, routing_number, account_type, account_number,
                        effective_date, credit_or_debit_flag, amount, transaction_id='')
      add_transaction_detail_record(TransactionDetailRecord.new(
            :receiver_id => receiver_id,
            :routing_number => routing_number,
            :account_type => account_type,
            :account_number => account_number,
            :effective_date => effective_date,
            :credit_or_debit_flag => credit_or_debit_flag,
            :amount => amount,
            :transaction_id => transaction_id))
    end
    
    # Set the FEPFileSpecification::FileCommentRecord for this file
    def file_comment_record=(record)
      raise InvalidTypeError, "Expected record of type FileCommentRecord" unless record.is_a?(FileCommentRecord)
      @file_comment_record = record
    end
    
    # Set the FEPFileSpecification::FileHeaderRecord for this file
    def file_header_record=(record)
      raise InvalidTypeError, "Expected record of type FileHeaderRecord" unless record.is_a?(FileHeaderRecord)
      @file_header_record = record
    end
    
    # Adds a new FEPFileSpecification::TransactionDetailRecord to this file
    def add_transaction_detail_record(record)
      raise InvalidTypeError, "Expected record of type TransactionDetailRecord" unless record.is_a?(TransactionDetailRecord)      
      @transaction_detail_records << record
    end
    
    # Builds and returns a FEPFileSpecification::TransactionSummaryRecord 
    # based on the list of FEPFileSpecification::TransactionDetailRecord
    def transaction_summary_record
      return nil if transaction_detail_records.empty?
      # return @transaction_summary_record unless detail_records_dirty?
      
      grouped = transaction_detail_records.group_by do |record|
        case record.credit_or_debit_flag
        when 'D'
          :debit
        when 'C'
          :credit
        else
          :unknown
        end
      end
      
      @transaction_summary_record = TransactionSummaryRecord.new(
        :total_debits => grouped[:debit] ? grouped[:debit].size : 0,
        :total_debits_amount => grouped[:debit] ? grouped[:debit].inject(Money.empty) { |sum, record| sum += record.amount.to_money} : Money.empty,
        :total_credits => grouped[:credit] ? grouped[:credit].size : 0,
        :total_credits_amount => grouped[:credit] ? grouped[:credit].inject(Money.empty) { |sum, record| sum += record.amount.to_money} : Money.empty)
    end
    
    # Saves the file to the specified +file_path+ and +file_name+
    # If +file_name+ is not given then a timestamped name will be used
    def save(file_path, file_name = nil)
      raise ValidationError, "FEPFile does not have all required data set: #{validation_errors.inspect}" unless valid?
      
      name = file_name || "fepfile_%s.txt" % Time.now.strftime('%Y%m%d%H%M%S')
      full_name = "#{file_path}/#{name}"
      
      open(full_name, "w+") do |file|
        file.write(file_comment_record.to_s+"\r\n") unless file_comment_record.nil?
        file.write(file_header_record.to_s+"\r\n")
        transaction_detail_records.each do |tdr|
          file.write(tdr.to_s+"\r\n")
        end
        file.write(transaction_summary_record.to_s+"\r\n")
      end
      
      [full_name, true]
    end
    
    private 

    def validation_errors
      errors = {}
      # print errors messages from records
      if file_comment_record && !file_comment_record.valid?
        errors["FileCommentRecord"] = file_comment_record.errors.full_messages
      end
      
      if file_header_record && !file_header_record.valid?
        errors["FileHeaderRecord"] = file_header_record.errors.full_messages
      end

      errors["TransactionDetailRecords"] = transaction_detail_records.collect do |tdr|
        unless tdr.valid?
          { "TransactionDetailRecord" => tdr.errors.full_messages, "routing_number" => tdr.routing_number, "account_number" => tdr.account_number }
        end
      end

      if transaction_summary_record && !transaction_summary_record.valid?
        errors["TransactionSummaryRecord"] = transaction_summary_record.errors.full_messages
      end
      errors
    end
    
  end
  
end
