# frozen_string_literal: true
prison_estate_ips = ENV.fetch('PRISON_ESTATE_IPS', '0.0.0.0,127.0.0.1,::1')
Rails.configuration.prison_ip_matcher = IpAddressMatcher.new(prison_estate_ips)
