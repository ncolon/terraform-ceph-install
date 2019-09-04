[RHCSv3:children]
mons
osds
mgrs

[RHCSv3:vars]
ansible_ssh_user=${ssh_user}
ansible_become=true
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[mons]
${node_list}

[osds]
${node_list}

[mgrs]
${node_list}
