require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe PrisonMailer, '.autorespond' do
  let(:email_address) { 'example@example.com' }
  let(:mail) { described_class.autorespond(email_address) }

  it_behaves_like 'an email that notifies of unnatended mailbox'
end
