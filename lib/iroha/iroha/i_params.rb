module Iroha

  class IParams < Hash
    def _to_exp(indent)
      if self.size == 0 then
        return indent + "(PARAMS)"
      else
        return ([indent + "(PARAMS"] + self.to_a.map{|pair| indent + "  (#{pair[0]} #{pair[1]})"} + [indent + ")"]).join("")
      end
    end
    def self.convert_from(params)
      new_params = self.new
      params.each_pair do |key, value|
        if value.class == String then
          new_params[key] = value.clone
        else
          new_params[key] = value
        end
      end
      return new_params
    end
  end
end

