module FEPFileSpecification
  class FileHeaderRecord
    include ActiveModel::Validations

    attr_accessor :originator_id, :file_sequence_id, :company_discretionary_data, :company_entry_description
    attr_reader   :file_creation_date, :file_creation_time
    
    validates_presence_of :file_sequence_id, :originator_id
     
    validates_length_of :originator_id, :is => 10
    validates_length_of :company_discretionary_data, :within => 0..20, :allow_nil => true
    validates_length_of :company_entry_description, :within => 0..10, :allow_nil => true

    validates_numericality_of :originator_id
    # validates_format_of :file_creation_date, :with => /^(19[0-9]{2}|2[0-9]{3})(0[1-9]|1[012])([123]0|[012][1-9]|31)$/
    # validates_format_of :file_creation_time, :with => /^(([0-1]{1}[0-9]{1})|([2]{1}[0-4]{1}))(([0-5]{1}[0-9]{1})|60)$/
    validates_format_of :company_discretionary_data, :company_entry_description, :with => /^[a-zA-Z0-9\s]*$/
    validates_format_of :file_sequence_id, :with => /^[A-Z]{1}$/
    
    # Construct a new FEPFileSpecification::FileHeaderRecord with +originator_id+ and options (see below)
    # 
    # ==== Parameters
    # +originator_id+::               This ID is assigned to the Originator by the Network 1 Financial. 
    #                                 It should contain 10 digits
    # ==== Options
    # +file_sequence_id+::            This field contains a sequence ID when more than one transaction
    #                                 file is generated in one day. This field should contain ‘A’ for 
    #                                 the first file, ‘B’ for the second file, and so on
    # +company_discretionary_data+::  This field will be included in the Batch Header record of the 
    #                                 ACH file that will be generated from this transaction file
    # +company_entry_description+::   This field will be included in the Batch Header record of the 
    #                                 ACH file that will be generated from this transaction file. 
    #                                 The data in this field will be displayed on the Receiver’s bank 
    #                                 account statement when this transaction is posted to 
    #                                 his or her account.
    def initialize(originator_id, options = {})
      @originator_id              = originator_id
      @file_sequence_id           = options.fetch(:file_sequence_id, 'A') || 'A'
      @company_discretionary_data = options[:company_discretionary_data]
      @company_entry_description  = options[:company_entry_description]
      @file_creation_datetime     = Time.now
      @file_creation_date         = @file_creation_datetime.strftime('%Y%m%d')
      @file_creation_time         = @file_creation_datetime.strftime('%I%M')
    end

    def to_s
      raise ValidationError, self.errors.full_messages unless valid?
      
      sprintf("FH000%s%s%s%s%-20s%-10s#{'0'*42}",
              file_creation_date, 
              file_creation_time,
              file_sequence_id,
              originator_id,
              company_discretionary_data,
              company_entry_description).gsub(' ', '0')
    end
  end
end
