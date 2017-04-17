class Pfsense < Oxidized::Model

  prompt /^(?:[^:#@]+@[^:#@]+)[:#](?:.\[\d+(?:;\d+)*m)? ?$/
  comment '# '

  cmd :all do |cfg|
	  cfg.each_line.to_a[1..-2].join
  end

#show the current config.xml
  pre do
    cfg = cmd 'cat /cf/conf/config.xml'
  end

  cfg :telnet do
    username /^Username:/
    password /^Password:/
  end

  cfg :telnet, :ssh do
    pre_logout 'exit'
  end

end
