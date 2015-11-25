RSpec.shared_examples 'template checks' do
  it 'has no missing translations' do
    html = mail.html_part.body
    expect(html).not_to match(/translation missing/)
  end
end
