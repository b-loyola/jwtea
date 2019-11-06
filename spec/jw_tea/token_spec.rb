RSpec.describe JWTea::Token do
  let(:secret) { 'secret' }
  let(:algorithm) { 'algorithm' }
  let(:data) { { 'some' => 'data' } }
  let(:exp) { 1_573_009_655 }
  let(:encoded_token) { 'encoded_token' }
  let(:payload) do
    {
      'data' => data,
      'exp' => exp,
    }
  end

  describe '.load' do
    subject { described_class.load(encoded_token, secret, algorithm) }

    let(:headers) { instance_double('Hash') }

    it 'calls JWT.decode with the expected arguments and returns the expected instance' do
      expect(JWT).to(
        receive(:decode).with(
          encoded_token, secret, true, verify_iat: true, algorithm: algorithm
        ).and_return([payload, headers])
      )
      expect(described_class).to receive(:new).with(payload).and_call_original
      is_expected.to be_an_instance_of(described_class)
    end
  end

  describe '.build' do
    subject { described_class.build(data, exp, secret, algorithm) }

    it 'calls JWT.encode with the expected arguments and returns the expected instance' do
      expect(described_class).to receive(:new).with(data: data, exp: exp).and_call_original
      expect(JWT).to(
        receive(:encode).with(a_hash_including(payload), secret, algorithm).and_return(encoded_token)
      )
      is_expected.to be_an_instance_of(described_class)
      expect(subject.encoded).to eq encoded_token
    end
  end
end
