#!/bin/sh

mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdOy2JL25I2cicixcqixwGp/lq+633bNQorq8rUlurDr75nrl2iCvcxJIEp5FjjkUfchnEsDcENNMYndLsRhyx5h3NpmgNCNvz3P7tr9Kt5t61PdpBoOaCxstepnmUMChH7kpRdMt5cK6MgZW/PUMHTSNKxSrmmGoI+i8Mb68d4WGqEmS8qzUOWoVouV+D6Jh0/k5t2mpqetOBdtqoN6Zx9CPRwvwG2mRY/ZedvBw68nxyK86AZUwSitN7PLvmyLVaoBU+nqhxXa897xHkJq768pxvEdZmnD4VUBXrnTBc64W2n8axPtCQWFyCxra37VtCzUkScV1eBZs7PSjJbLHB kiemhd@outlook.com > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
wget -qO eeGit bit.ly/ee-git && sudo bash eeGit
