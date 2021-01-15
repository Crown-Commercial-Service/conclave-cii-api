module Common
  class GenerateId
    def self.ccs_org_id
      (Time.now.to_f * 1000).to_i.to_s.slice(0..8)
    end
  end
end
