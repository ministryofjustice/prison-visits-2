RSpec.shared_examples 'template checks' do
  it 'has no missing translations' do
    html = mail.html_part.body
    expect(html).not_to match(/translation missing/)
  end
end

RSpec.shared_examples 'noreply checks' do
  it "sets a noreply subdomain for the 'from' header" do
    expect(mail.from.first).to match(/@robot./)
  end
end
