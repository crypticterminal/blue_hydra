module BlueHydra::Command
  # execute a command using Open3
  #
  # == Parameters
  #   command ::
  #     the command to execute
  #
  # == Returns
  #   Hash containing :stdout, :stderr, :exit_code from the command
  def execute3(command, timeout=false)
    BlueHydra.logger.debug("Executing Command: #{command}")
    output = {}
    if timeout
      stop_time = Time.now.to_i + timeout.to_i
    end

    stdin, stdout, stderr, thread = Open3.popen3(command)
    stdin.close

    if timeout
      until Time.now.to_i > stop_time || thread.status == false
        sleep 1
      end

      Process.kill("SIGINT", thread.pid) unless thread.status == false
    end

    if (out = stdout.read.chomp) != ""
      output[:stdout]    = out
    end

    if (err = stderr.read.chomp) != ""
      output[:stderr]    = err
    end

    output[:exit_code] = thread.value.exitstatus

    output
  end

  module_function :execute3
end
