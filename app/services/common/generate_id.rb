module Common
  class GenerateId
    def self.ccs_org_id
      "#{(Time.now.to_f * 1000).to_i}".slice(0..8)
    end
  end
end
