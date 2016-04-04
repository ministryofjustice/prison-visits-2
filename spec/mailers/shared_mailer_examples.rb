RSpec.shared_examples 'template checks' do
  it 'has no missing translations' do
    html = mail.html_part.body
    expect(html).not_to match(/translation missing/)
  end
end

RSpec.shared_examples 'an email that notifies of unnatended mailbox' do
  it 'sends an email to the sender' do
    expect(mail.to).to include(email_address)
    expect(mail.subject).to eq('This mailbox is not monitored')
  end
end
