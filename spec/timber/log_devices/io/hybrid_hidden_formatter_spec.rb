require "spec_helper"

describe Timber::LogDevices::IO::HybridHiddenFormatter do
  describe ".format" do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
    let(:formatter) { described_class.new }
    let(:message) { "a message" }
    let(:log_line) { Timber::LogLine.new(message) }
    subject { formatter.format(log_line) }

    before(:each) do
      server_context = Timber::CurrentContext.get(Timber::Contexts::Server)
      allow(server_context).to receive(:_dt).and_return(time)
    end

    it { should eq("\e7\e[1;30mserver.hostname=comp\e8\e[Kuter-name.domain.com\e8\e[K server._dt=2016-09-\e8\e[K01T12:00:00.000000Z \e8\e[Kserver._version=1 se\e8\e[Krver._index=0 _versi\e8\e[Kon=1 _hierarchy=[ser\e8\e[Kver] [timber.io] \e8\e[K\e[0ma message") }

    context "with a slash" do
      let(:message) { "this is a long message that exceeds the step size".insert(described_class::CLEAR_STEP_SIZE - 1, "\\") }

      before(:each) do
        allow(formatter).to receive(:encoded_context).and_return(message)
      end

      it { should eq("\e7\e[1;30mthis is a long mess\\a\e8\e[Kge that exceeds the \e8\e[Kstep size [timber.io\e8\e[K] \e8\e[K\e[0mthis is a long mess\\age that exceeds the step size") }
    end
  end
end
