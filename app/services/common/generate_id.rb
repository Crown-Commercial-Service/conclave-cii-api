module Common
  class GenerateId
    def self.ccs_org_id
      "#{rand(100000)}#{(Time.now.to_f.round(3) * 1000).to_i}"
    end
  end
end
