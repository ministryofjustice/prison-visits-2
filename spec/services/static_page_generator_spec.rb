require 'rails_helper'

RSpec.describe StaticPageGenerator do
  it "renders pages and save them to the filesystem" do
    expected_file_path = Rails.root.join('public', '404.html')
    File.delete(expected_file_path) if File.exist?(expected_file_path)

    described_class.generate!('/pages/404' => '404.html',
                              '/pages/500' => '500.html',
                              '/pages/503' => '503.html')

    expect(File.exist?(expected_file_path)).to be true
  end

  it "raises an error if the page requested fails to render" do
    expect {
      described_class.generate!('/pages/asdf' => 'asdf.html')
    }.to raise_error('No such page: asdf')
  end
end
