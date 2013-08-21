module RedmineEupathdb
  # Patches EuPathDB instances of Issue
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        before_save :average_priority
      end
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def average_priority
      # Calculate the average of PI priorities.
      #
      # Custom field names are "JK", "CS", and "DR".
      # We want to calculate the average across fields _with_ a value,
      # meaning the population size should be the number of non-zero fields

      # bail if our custom fields aren't available
      return unless ['JK', 'CS', 'DR', 'PIs'].all? {|pi| self.available_custom_fields.any? {|cf| cf.name == pi}}

      ::Rails.logger.info 'getting PI priority fields'

      # get PIs custom_field object <IssueCustomField>
      cf_pis = self.available_custom_fields.find {|cf| cf.name == 'PIs'}
      ::Rails.logger.info cf_pis.default_value
      # custom fields to average
      cf_field_names = ['JK', 'CS', 'DR']
      pi_vals = []
      cf_field_names.each do |cf_field_name|
        cf_field = self.available_custom_fields.find {|cf| cf.name == cf_field_name }
        cf_value = self.custom_field_values.find {|cf| cf.custom_field_id == cf_field.id}.value.to_f
        cf = self.custom_field_values.find {|cf| cf.custom_field_id == cf_field.id}
        ::Rails.logger.info "found #{cf_field.name} with value #{cf_value}, #{cf.class}" if cf_value > 0
        pi_vals << cf_value.to_f if cf_value > 0
      end
      # set average to PIs
      if pi_vals.empty?
        self.custom_field_values.find {|cf| cf.custom_field == cf_pis}.value = cf_pis.default_value
      else
        # find PIs custom field value and set value...
        self.custom_field_values.find {|cf| cf.custom_field == cf_pis}.value =
            (pi_vals.inject {|sum, v| sum + v} / pi_vals.size).round(1).to_s
      end
    end
  end
end
