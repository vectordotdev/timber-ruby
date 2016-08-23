require "spec_helper"

describe Timber::LogDevices::HerokuLogplex do
  let(:io) { STDOUT }
  let(:log_device) { described_class.new }

  describe ".write" do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }

    before(:each) do
      server_context = Timber::CurrentContext.get(Timber::Contexts::Server)
      allow(server_context).to receive(:_dt).and_return(time)
    end

    it "writes a proper logfmt line" do
      expect(io).to receive(:write).with("\e7\e[1;30mserver.hostname=comp\e8\e[Kuter-name.domain.com\e8\e[K server._dt=2016-09-\e8\e[K01T12:00:00.000000Z \e8\e[Kserver._version=1 se\e8\e[Krver._index=0 _versi\e8\e[Kon=1 _hierarchy=[ser\e8\e[Kver] [timber.io] \e8\e[K\e[0mthis is a message\n")
      # Notice we do not have dt for the log line since Heroku provides this
      log_device.write("this is a message\n")
    end

    context "with a heroku context" do
      around(:each) do |example|
        heroku = Timber::Contexts::Servers::HerokuSpecific.new("web.1")
        Timber::CurrentContext.add(heroku) { example.run }
      end

      # No need for the heroku context since logplex includes that data by default
      it "does not include the heroku context" do
        expect(io).to receive(:write).with("\e7\e[1;30mserver.hostname=comp\e8\e[Kuter-name.domain.com\e8\e[K server._dt=2016-09-\e8\e[K01T12:00:00.000000Z \e8\e[Kserver._version=1 se\e8\e[Krver._index=0 _versi\e8\e[Kon=1 _hierarchy=[ser\e8\e[Kver,server.heroku] [\e8\e[Ktimber.io] \e8\e[K\e[0mthis is a message\n")
        # Notice we do not have dt for the log line since Heroku provides this
        log_device.write("this is a message\n")
      end
    end

    context "with multiple lines" do |variable|
      it "does not include the heroku context" do
        expect(io).to receive(:write).with("\e7\e[1;30mserver.hostname=comp\e8\e[Kuter-name.domain.com\e8\e[K server._dt=2016-09-\e8\e[K01T12:00:00.000000Z \e8\e[Kserver._version=1 se\e8\e[Krver._index=0 _versi\e8\e[Kon=1 _hierarchy=[ser\e8\e[Kver] [timber.io] \e8\e[K\e[0mline 1\n")
        expect(io).to receive(:write).with("\e7\e[1;30mserver.hostname=comp\e8\e[Kuter-name.domain.com\e8\e[K server._dt=2016-09-\e8\e[K01T12:00:00.000000Z \e8\e[Kserver._version=1 se\e8\e[Krver._index=1 _versi\e8\e[Kon=1 _hierarchy=[ser\e8\e[Kver] [timber.io] \e8\e[K\e[0mline 2\n")
        expect(io).to receive(:write).with("\e7\e[1;30mserver.hostname=comp\e8\e[Kuter-name.domain.com\e8\e[K server._dt=2016-09-\e8\e[K01T12:00:00.000000Z \e8\e[Kserver._version=1 se\e8\e[Krver._index=2 _versi\e8\e[Kon=1 _hierarchy=[ser\e8\e[Kver] [timber.io] \e8\e[K\e[0mline 3\n")
        # Notice we do not have dt for the log line since Heroku provides this
        log_device.write("line 1\nline 2\nline 3\n")
      end
    end
  end
end
