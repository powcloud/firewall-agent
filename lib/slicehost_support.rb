require 'active_resource'

module SlicehostSupport
  class Slice < ActiveResource::Base
  end

  def slicehost_get_ips(api_key)
    Slice.site = api_key
    slices = Slice.find(:all)

    ips = []

    for slice in slices
      for address in slice.addresses
        ips << address
      end
    end

    ips
  end
end