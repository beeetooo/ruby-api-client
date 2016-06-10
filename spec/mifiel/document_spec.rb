describe Mifiel::Document do
  let!(:certificate) { File.read('spec/fixtures/FIEL_AAA010101AAA.cer') }
  let!(:private_key) { File.read('spec/fixtures/FIEL_AAA010101AAA.key') }
  let!(:private_key_pass) { '12345678a' }

  describe '#create' do
    context 'with a document' do
      let(:document) do
        Mifiel::Document.create(
          file: 'spec/fixtures/example.pdf',
          signatories: [
            { name: 'Signer 1', email: 'signer1@email.com', tax_id: 'AAA010101AAA' },
            { name: 'Signer 2', email: 'signer2@email.com', tax_id: 'AAA010102AAA' }
          ]
        )
      end

      it { expect(document).to be_a(Hash) }
    end
  end

  describe '#request_signature' do
    let!(:document) { Mifiel::Document.all.first }

    it '' do
      expect do
        document.request_signature('some@email.com')
      end.not_to raise_error
    end
  end

  describe '#sign' do
    let!(:signature) { 'signature' }
    let!(:document) { Mifiel::Document.all.first }
    let!(:certificate_id) { SecureRandom.uuid }

    context 'without build_signature first called' do
      it do
        expect do
          document.sign(certificate_id: certificate_id)
        end.to raise_error(Mifiel::NoSignatureError)
      end
    end

    context 'with build_signature called before' do
      it do
        document.build_signature(private_key, private_key_pass)
        expect do
          document.sign(certificate_id: certificate_id)
        end.not_to raise_error
      end
    end

    context 'with signature' do
      it do
        document.signature = signature
        expect do
          document.sign(certificate_id: certificate_id)
        end.not_to raise_error
      end
    end

    context 'with certificate' do
      it do
        document.build_signature(private_key, private_key_pass)
        expect do
          document.sign(certificate: certificate)
        end.not_to raise_error
      end
    end

    context 'with certificate in hex' do
      it do
        document.build_signature(private_key, private_key_pass)
        expect do
          document.sign(certificate: certificate.unpack('H*')[0])
        end.not_to raise_error
      end
    end
  end

  describe '#build_signature' do
    let!(:document) { Mifiel::Document.all.first }

    context 'with a wrong private_key' do
      it do
        expect do
          document.build_signature('asd', private_key_pass)
        end.to raise_error(Mifiel::PrivateKeyError)
      end
    end

    context 'with a private_key that is not a private_key' do
      xit do
        cer = OpenSSL::X509::Certificate.new(certificate)
        expect do
          document.build_signature(cer.public_key.to_der, private_key_pass)
        end.to raise_error(Mifiel::NotPrivateKeyError)
      end
    end

    context 'with a wrong password' do
      it do
        expect do
          document.build_signature('asd', private_key_pass)
        end.to raise_error(Mifiel::PrivateKeyError)
      end
    end
  end

end
