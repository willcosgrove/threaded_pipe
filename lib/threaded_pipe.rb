require "threaded_pipe/version"

class ThreadedPipe
  def initialize(*procs)
    pipes = build_pipes(procs.size - 1)

    @threads = procs.map.with_index do |procedure, index|
      Thread.new(*pipes[index]) do |*pipes|
        procedure.call(*pipes)
      ensure
        pipes.each(&:close)
      end
    end
  end

  def join
    @threads.each(&:join)
  end

  def values
    @threads.map(&:value)
  end

  private

  def build_pipes(count)
    pipes = [[]]

    count.times do |index|
      rd, wr = IO.pipe
      pipes[index] << wr
      pipes[index + 1] = [rd]
    end

    pipes
  end
end
