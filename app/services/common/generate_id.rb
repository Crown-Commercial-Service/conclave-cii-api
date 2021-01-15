module Common
  class GenerateId
    def self.ccs_org_id
      "#{Time.now.to_i}"
    end
  end
end
