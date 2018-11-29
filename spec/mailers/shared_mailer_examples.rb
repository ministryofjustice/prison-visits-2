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

RSpec.shared_examples 'skipping email for the trial' do
  it 'does not send emails for prisons in the dashboard trial' do
    allow(Rails.configuration).
      to receive(:dashboard_trial).
      and_return([visit.prison.estate.name])

    expect(mail.to).to be_nil
  end
end

RSpec.shared_examples 'when the prison is not on prison finder' do
  it 'does not display the link to the Prison Finder service' do
    medway_prison.name = 'Medway Secure Training Centre'
    medway_prison.save

    expect(mail.html_part.body).not_to match(%r{http:\/\/www.justice.gov.uk\/contacts\/prison-finder})
  end
end
