require 'rails_helper'

RSpec.describe ParsedEmail do
  context "given valid data" do
    let :data do
      {
        from: "Some Dude <some.dude@digital.justice.gov.uk>",
        to: 'test@example.com',
        text: "some text",
        charsets: { to: "UTF-8", html: "utf-8", subject: "UTF-8", from: "UTF-8", text: "utf-8" }.to_json,
        subject: "important email"
      }
    end

    it "parses the email" do
      expect(described_class.parse(data)).to be_valid
    end

    it "reports the source as coming in from a visitor" do
      expect(described_class.parse(data).source).to eq(:visitor)
    end
  end

  context "given data from hotmail.com" do
    let :data do
      {
        from: "=?ISO-8859-1?Q?Keld_J=F8rn_Simonsen?= <keld@dkuug.dk>",
        to: 'test@example.com',
        text: "æ".encode('windows-1252'),
        charsets: { to: "utf-8", subject: "windows-1252", from: "utf-8", text: "windows-1252" }.to_json,
        subject: "Wøt up?".encode('windows-1252')
      }
    end

    it "parses the email" do
      email = described_class.parse(data)
      expect(email).to be_valid

      expect(email.from.display_name).to eq("Keld Jørn Simonsen")
      expect(email.subject).to eq("Wøt up?")
      expect(email.text).to eq("æ")
    end
  end

  context "when an e-mail from the prison comes in" do
    let(:data) do
      {
        from: from,
        to: 'test@example.com',
        text: "some text",
        charsets: { to: "UTF-8", html: "utf-8", subject: "UTF-8", from: "UTF-8", text: "utf-8" }.to_json,
        subject: "important email"
      }
    end

    context 'from a hmps subdomain' do
      let(:from) { "HMP Prison <prison@hmps.gsi.gov.uk>" }

      it "reports the source as 'prison'" do
        expect(described_class.parse(data).source).to eq(:prison)
      end
    end

    context 'from a noms subdomain' do
      let(:from) { 'HMP Prison <prison@noms.gsi.gov.uk>' }

      it "reports the source as 'prison'" do
        expect(described_class.parse(data).source).to eq(:prison)
      end
    end
  end
end
