class LXCMonitor < Scout::Plugin
  def build_report
    report :memory => mem,
           :cpu => cpu,
           :containers => containers
  end
  
  # Units: MB
  def mem
    File.read('/sys/fs/cgroup/memory/memory.usage_in_bytes').to_f/1024/1024
  end
  
  # In %
  def cpu
    res = nil
    cpu_time = File.read('/sys/fs/cgroup/cpuacct/lxc/cpuacct.usage_percpu').to_f
    if @last_run and last_cpu_time = memory(:last_cpu_time)
      elapsed_time = Time.now - @last_run
      cpu_since_last_run = (cpu_time - last_cpu_time)/1000000000 # in nanoseconds
      if elapsed_time >= 1 and cpu_since_last_run >= 0
        res = (cpu_since_last_run/elapsed_time)*100      
      end
    end
    remember(:last_cpu_time,cpu_time)
    res
  end
  
  def containers
    `lxc-ls | sort -u | wc -l`.to_i
  end
end