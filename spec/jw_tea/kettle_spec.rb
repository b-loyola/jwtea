require 'timecop'

RSpec.describe JWTea::Kettle do
  let(:kettle) { described_class.new(secret: secret, store: store, algorithm: algorithm, expires_in: expires_in) }

  let(:secret) { 'secret' }
  let(:store) { instance_double('JWTea::Stores::RedisStore') }
  let(:algorithm) { 'algorithm' }
  let(:expires_in) { 3600 }

  let(:encoded_token) { 'encoded_token' }
  let(:data) { instance_double('Hash') }

  let(:exp) { expires_in.seconds.from_now.to_i }
  let(:jti) { 'jti' }
  let(:token) { instance_double('JWTea::Token', jti: jti, exp: exp, data: data, encoded: encoded_token) }

  let(:current_time) { Time.local(1984, 1, 1, 1) }
  around(:each) do |example|
    Timecop.freeze(current_time) { example.run }
  end

  before do
    allow(JWTea::Token).to receive(:build).with(data, exp, secret, algorithm).and_return(token)
    allow(JWTea::Token).to receive(:load).with(encoded_token, secret, algorithm).and_return(token)
  end

  describe '.brew' do
    subject { kettle.brew(data) }

    it 'stores the token and returns it' do
      expect(store).to receive(:save).with(jti, exp, expires_in)
      is_expected.to be(token)
    end
  end

  describe '.pour' do
    subject { kettle.pour(encoded_token) }

    before do
      allow(store).to receive(:exists?).with(jti, exp).and_return(exists)
    end

    context 'when the token exists in the store' do
      let(:exists) { true }

      it 'loads the token' do
        is_expected.to be(token)
      end
    end

    context 'when the token does not exist in the store' do
      let(:exists) { false }

      it 'raises an InvalidToken error' do
        expect { subject }.to raise_error(JWTea::InvalidToken, 'token revoked')
      end
    end
  end

  describe '.encode' do
    subject { kettle.encode(data) }

    it 'stores the token and returns the encoded string' do
      expect(store).to receive(:save).with(jti, exp, expires_in)
      is_expected.to eq(encoded_token)
    end
  end

  describe '.decode' do
    subject { kettle.decode(encoded_token) }

    before do
      allow(store).to receive(:exists?).with(jti, exp).and_return(exists)
    end

    context 'when the token exists in the store' do
      let(:exists) { true }

      it 'returns the decoded data' do
        is_expected.to eq(data)
      end
    end

    context 'when the token does not exist in the store' do
      let(:exists) { false }

      it 'raises an InvalidToken error' do
        expect { subject }.to raise_error(JWTea::InvalidToken, 'token revoked')
      end
    end
  end

  describe '.revoke' do
    subject { kettle.revoke(encoded_token) }

    it 'deletes the token from the store' do
      expect(store).to receive(:delete).with(jti).and_return(true)
      is_expected.to be true
    end
  end

  describe '.valid?' do
    subject { kettle.valid?(encoded_token) }

    context 'when the token exists in the store' do
      let(:exists) { true }

      it 'checks the store and returns true' do
        expect(store).to receive(:exists?).with(jti, exp).and_return(exists)
        is_expected.to be true
      end
    end

    context 'when the token does not exist in the store' do
      let(:exists) { false }

      it 'checks the store and returns true' do
        expect(store).to receive(:exists?).with(jti, exp).and_return(exists)
        is_expected.to be false
      end
    end
  end
end
