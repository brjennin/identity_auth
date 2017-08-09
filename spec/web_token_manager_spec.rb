require "spec_helper"
require "jwt"
require "active_support/hash_with_indifferent_access"

RSpec.describe IdentityAuth::WebTokenManager do
  describe ".encode" do
    subject { described_class.encode(payload, expiration) }
    let(:expiration) { Time.now }
    let(:payload) { {sellin: "pablo"} }

    before do
      ENV["JWT_SECRET"] = "rally"
      allow(JWT).to receive(:encode).and_return("token")
    end

    it "encodes the payload with an expiration" do
      subject
      expect(JWT).to have_received(:encode).with(payload.merge({exp: expiration.to_i}), "rally")
    end

    it "returns the encoded token" do
      expect(subject).to eq "token"
    end
  end

  describe ".decode" do
    subject { described_class.decode("token") }

    context "when the token can be decoded" do
      before do
        allow(JWT).to receive(:decode).and_return([{"work" => "sellin"}])
      end

      it "decodes the payload" do
        subject
        expect(JWT).to have_received(:decode).with("token", "rally")
      end

      it "returns the payload" do
        expect(subject).to eq(HashWithIndifferentAccess.new({work: "sellin"}))
      end
    end

    context "when the token is expired" do
      before do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature.new)
      end

      it "raises an exception" do
        expect { subject }.to raise_error(IdentityAuth::ExpiredSignature)
      end
    end
  end
end
