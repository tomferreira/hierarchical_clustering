
class PerformanceMonitor

    @@running = {}
	@@result = {}

    class << self
        attr_accessor :enable

        def restart
            @@running = {}
            @@result = {}
        end

        def start(name)
            return unless self.enable

        	@@running[name] = Time.now
        end

        def stop(name)
            return unless self.enable

            now = Time.now

            start_time = @@running.delete(name)
            raise "Monitor not started: #{name}" if start_time.nil?

            @@result[name] = 0 unless @@result.has_key?(name)
            @@result[name] += (now - start_time)
        end

        def add(name, value)
            @@result[name] = 0 unless @@result.has_key?(name)
            @@result[name] += value
        end

        def results
            self.enable ? @@result : nil
        end
    end

end