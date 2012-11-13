describe Notifications do

  describe '#signed_petition' do
    let(:petition) do
      build :petition, id: 99,
        title: 'a<br>html&nbsp;&quot;title&quot;', 
        petition_images: [image],
        petition_summaries: [summary],
        description: description
    end

    let(:description) do
      'a<br>html&nbsp;&quot;body&quot;<p>foo</p><p>LINK</p><p>bar</p>'
    end

    let(:image) { build :petition_image, url: 'url' }
    let(:summary) { build :petition_summary, short_summary: 'foo' }
    let(:signature) { create :signature, petition: petition }
    let(:unsubscribe_link) { 'http://test/unsubscribe' }
    let(:referer) { signature.member.to_hash }
    let(:mail) { Notifications.signed_petition(signature) }

    subject { mail }
    its(:subject) { should match(/#{signature.petition.title}/) }
    its(:to) { should eq([signature.email]) }

    context 'html' do
      let(:entities) { 'a&lt;br&gt;html&amp;nbsp;&amp;quot;title&amp;quot;' }
      let(:link) { "http://test/petitions/#{signature.petition.id}?r=#{referer}" }
      let(:paragraph) do
        "<p><b><a href=\"#{link}\">Please, click here to sign now!</a></b></p>"
      end

      subject { mail.body.encoded }
      it { should include unsubscribe_link }
      it { should include paragraph }
      it { should include entities }
      it { should include link }
      it { should_not include 'LINK' }
    end

    context 'plain text' do
      subject { mail.body.parts.find{ |p| p.content_type =~ /text\/plain/ }.body }
      it { should include "a\nhtml \"title\"" }
      it { should include "a\nhtml \"body\"" }
      it { should include "foo\n\nbar" }
      it { should_not include 'LINK' }
    end
  end

  describe '#unsubscribed' do
    subject { Notifications.unsubscribed(build(:unsubscribe)).body.encoded }
    it { should include 'http://test/subscribe' }
  end
end
